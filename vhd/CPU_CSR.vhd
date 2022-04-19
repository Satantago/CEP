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
signal outofmcause, outofmip,to_csr,inmie, outofmie,inmstatus,inmtvec,outofmtvec,inmepc,outofmepc, bla : w32;
signal outofmstatus : w32;
    begin
    	r_mcause : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst = '1' then
    			outofmcause <= w32_zero;
    	        elsif irq = '1' then
    			outofmcause <= mcause;
    		end if;
    	end if;
    	end process;
    	r_mip : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmip <= w32_zero;
    		else
    			outofmip(11) <= meip;
    			outofmip(7) <= mtip;
    		end if;
    	end if;
    	end process;
    	
    	r_mie : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmie <= w32_zero;
    		elsif cmd.CSR_we = CSR_mie then
    			outofmie <= inmie;
    		end if;
    	end if;
    	end process;
    	r_mstatus : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmstatus <= w32_zero;
    		else
                 	outofmstatus <= inmstatus;
                if cmd.mstatus_mie_set = '1' then
                    	outofmstatus(3) <= '1';
                if cmd.mstatus_mie_reset = '1' then
                   	oufofmstatus(3) <= '0';
                end if;
                
                end if;
                end if;
 	end if;
    	end process;
    	r_mtvec : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmtvec <= w32_zero;
    		elsif cmd.CSR_we = CSR_mtvec then
    			outofmtvec <= inmtvec;
    		end if;
    	end if;
    	end process;
    	r_mepc : process(clk)
    	begin
    	if rising_edge(clk) then
    		if rst='1' then
    			outofmepc <= w32_zero;
    		elsif cmd.CSR_we = CSR_mepc then
    			outofmepc <= inmepc;
    		end if;
    	end if;
    	end process;
	process(all)
 	begin 
 	inmie <= outofmie;
 	inmtvec <= outofmtvec;
 	inmepc <= outofmepc;
 	inmstatus <= outofmstatus;
    	if cmd.csr_we = csr_mepc then 
        	inmepc <= bla; 
        	inmepc(0)<='0';
        	inmepc(1)<='0';
    	elsif cmd.csr_we = csr_mtvec then 
        	inmepc <= csr_write(TO_CSR, outofmtvec, cmd.CSR_WRITE_mode);
        	inmepc(0)<='0';
        	inmepc(1)<='0';
    	elsif cmd.csr_we = csr_mstatus then
        	inmstatus <= csr_write(TO_CSR, outofmstatus, cmd.CSR_WRITE_mode);
    	elsif cmd.csr_we = CSR_mie then
        	inmie <= csr_write(TO_CSR, outofmie, cmd.CSR_WRITE_mode);
    	end if ;
	end process ;   
-- equations
it <= irq and outofmstatus(3);	
mepc <= outofmepc;
mie <= outofmie;
mtvec <= outofmtvec;
mip <= outofmip;
--multiplexeurs
CSR <= outofmcause   when  cmd.csr_sel = CSR_FROM_MCAUSE else
       outofmip      when  cmd.csr_sel = CSR_FROM_MIP else
       outofmie      when  cmd.csr_sel = CSR_FROM_MIE else
       outofmstatus  when  cmd.csr_sel = CSR_FROM_MSTATUS else
       outofmtvec    when  cmd.csr_sel = CSR_FROM_MTVEC else
       outofmepc     when  cmd.csr_sel = CSR_FROM_MEPC;

bla <= csr_write(to_csr, outofmepc, cmd.CSR_WRITE_mode) when cmd.MEPC_sel=mepc_from_csr else PC ;
to_csr <= RS1 when cmd.TO_CSR_sel = TO_csr_from_rs1 else imm;	
end architecture;
