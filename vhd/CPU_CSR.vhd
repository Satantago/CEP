library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CSR is
    generic (
        INTERRUPT_VECTOR : waddr   := w32_zero;
        mutant           : integer := 0
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Interface de et vers la PO
        cmd         : in  PO_cs_cmd;
        it          : out std_logic;
        pc          : in  w32;
        rs1         : in  w32;
        imm         : in  W32;
        csr         : out w32;
        mtvec       : out w32;
        mepc        : out w32;

        -- Interface de et vers les IP d'interruption
        irq         : in  std_logic;
        meip        : in  std_logic;
        mtip        : in  std_logic;
        mie         : out w32;
        mip         : out w32;
        mcause      : in  w32
    );
end entity;

architecture RTL of CPU_CSR is
    -- Fonction retournant la valeur à écrire dans un csr en fonction
    -- du « mode » d'écriture, qui dépend de l'instruction
    function CSR_write (CSR        : w32;
                         CSR_reg    : w32;
                         WRITE_mode : CSR_WRITE_mode_type)
        return w32 is
        variable res : w32;
    begin
        case WRITE_mode is
            when WRITE_mode_simple =>
                res := CSR;
            when WRITE_mode_set =>
                res := CSR_reg or CSR;
            when WRITE_mode_clear =>
                res := CSR_reg and (not CSR);
            when others => null;
        end case;
        return res;
    end CSR_write;
signal outofmcause, outofmip,to_csr, outofmie,outofmstatus,outofmtvec,inmepc,outofmepc : w32;
signal reg_iq : std_logic;
    begin
    	r_mcause : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst = '1' then
    			outofmcause <= (others => '0');
    	        elsif irq = '1' then
    			outofmcause <= CSR_write(mcause, (others => '0') , WRITE_mode_simple);
    		end if;
    	end if;
    	end process;
    	r_mip : process(clk)
    	begin
    	if rising_edge(clk) then
    		outofmip <= (11 => meip, 7 => mtip , others => '0') ;
    	end if;
    	end process;
    	
    	r_mie : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmie <= (others => '0');
    		elsif cmd.CSR_we = CSR_mie then
    			outofmie <= to_csr;
    		end if;
    	end if;
    	end process;
    	r_mstatus : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmstatus <= (others => '0');
    		elsif cmd.MSTATUS_mie_reset='1' then
    			outofmstatus <= CSR_write(to_csr, (3=>'1', others =>'0'),WRITE_mode_clear);
    		elsif cmd.MSTATUS_mie_set = '1' then
    			outofmstatus <= CSR_write(to_csr, (3=>'1', others => '0'),WRITE_mode_set);
    		elsif cmd.CSR_we = CSR_mstatus then
    			outofmstatus <= CSR_write(to_csr, (others => '0'), WRITE_mode_simple);
    		end if;
    	end if;
    	end process;
    	r_mtvec : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmtvec <= (others => '0');
    		elsif cmd.CSR_we = CSR_mtvec then
    			outofmtvec <= to_csr;
    		end if;
    	end if;
    	end process;
    	r_mepc : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmepc <= (others => '0');
    		elsif cmd.CSR_we = CSR_mepc then
    			outofmepc <= inmepc;
    		end if;
    	end if;
    	end process;
    	registre_irq : process(clk)
    	begin
    		if rising_edge(clk) then
    			if rst='1' then
    				reg_iq <= '0';
    			else
    				reg_iq <= irq ;
    			end if;
    		end if;
    	end process;
-- equations
it <= reg_iq and outofmstatus(3);	

with cmd.CSR_sel select
CSR <= outofmcause when CSR_from_mcause,
	outofmip when CSR_from_mip ,
	outofmie when CSR_from_mie ,
	outofmstatus when CSR_from_mstatus,
	outofmtvec when CSR_from_mtvec,
	outofmepc when CSR_from_mepc,
	(others =>'0') when others;
	
inmepc <= to_csr when cmd.MEPC_sel = mepc_from_csr else pc;

to_csr <= RS1 when cmd.TO_CSR_sel = TO_csr_from_rs1 else imm;	
end architecture;
