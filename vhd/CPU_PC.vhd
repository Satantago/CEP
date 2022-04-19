library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_sll,
        S_auipc,
        S_BEQ,
        S_SLT,
        S_LW,
        S_LW1,
        S_LW2,
	S_LB,
	S_LB1,
	S_LB2,
	S_LBU,
	S_LBU1,
	S_LBU2,
	S_LH,
	S_LH1,
	S_LH2,
	S_LHU,
	S_LHU1,
	S_LHU2,
        S_SW,
        S_SW1,
        S_JAL,
	S_SB,
	S_SB1,
	S_SH,
	S_SH1,
	S_JALR,
	S_SUB,
	S_OR,
	S_ORI,
	S_AND,
	S_ANDI,
	S_XOR,
	S_XORI,
	S_SLLI,
	S_SRA,
	S_SRAI,
	S_SRL,
	S_SRLI,
	S_SLTI,
	S_SLTIU,
	S_SLTU,
	S_BGE,
	S_BGEU,
	S_BLT,
	S_BLTU,
	S_BNE,
	S_CSRRC,
	S_CSRRCI,
	S_CSRRS,
	S_CSRRSI,
	S_CSRRW,
	S_CSRRWI,
	S_IT1,
	S_IT2,
	S_CND,
	S_MRET
    );

    signal state_d, state_q : State_type;


begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

-- Valeurs par défaut de cmd à définir selon les préférences de chacun
cmd.ALU_op <= ALU_PLUS;
cmd.LOGICAL_op <= UNDEFINED;
cmd.ALU_Y_sel <= ALU_Y_immI;

cmd.SHIFTER_op <= SHIFT_rl;
cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;

cmd.RF_we <= 'U';
cmd.RF_SIZE_sel <= UNDEFINED;
cmd.RF_SIGN_enable <= 'U';
cmd.DATA_sel <= DATA_from_pc;

cmd.PC_we <= 'U';
cmd.PC_sel <= UNDEFINED;

cmd.PC_X_sel <= PC_X_pc;
cmd.PC_Y_sel <= PC_Y_immU;

cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;

cmd.AD_we <= 'U';
cmd.AD_Y_sel <= UNDEFINED;

cmd.IR_we <= 'U';

cmd.ADDR_sel <= ADDR_from_pc;
cmd.mem_we <= 'U';
cmd.mem_ce <= 'U';

cmd.cs.CSR_we <= UNDEFINED;

cmd.cs.TO_CSR_sel <= UNDEFINED;
cmd.cs.CSR_sel <= UNDEFINED;
cmd.cs.MEPC_sel <= UNDEFINED;

cmd.cs.MSTATUS_mie_set <= 'U';
cmd.cs.MSTATUS_mie_reset <= 'U';

cmd.cs.CSR_WRITE_mode <= UNDEFINED;

        state_d <= state_q;


        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;
            when S_IT1 =>
                  cmd.PC_we <= '1' ;
            	  cmd.PC_sel <= PC_mtvec ;
            	  cmd.CS.MSTATUS_mie_reset <= '1' ;
                 cmd.CS.MEPC_sel <= MEPC_from_pc ;
                 cmd.CS.CSR_we <= CSR_mepc ;
                 state_d <= S_Pre_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>

                -- On peut aussi utiliser un case, ...
	   	-- et ne pas le faire juste pour les branchements et auipc
		if status.IR(6 downto 0) = "1100011" and status.IR(14 downto 12) = "000" then
			state_d <= S_beq;
		elsif status.IR(6 downto 0) = "1110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';
            		state_d <= S_IT2;
            	elsif status.IR(6 downto 0) = "1100011" then 
			state_d <= S_CND;
		elsif status.IR(6 downto 0) = "1100011" and status.IR(14 downto 12) = "111" then
			state_d <= S_beq;
		elsif status.IR(6 downto 0) = "1100011" and status.IR(14 downto 12) = "101" then
			state_d <= S_beq;
		elsif status.IR(6 downto 0) = "1100011" and status.IR(14 downto 12) = "100" then
			state_d <= S_beq;
		elsif status.IR(6 downto 0) = "1100011" and status.IR(14 downto 12) = "110" then
			state_d <= S_beq;
		elsif status.IR(6 downto 0) = "1100011" and status.IR(14 downto 12) = "001" then
			state_d <= S_beq;
		elsif status.IR(6 downto 0)="0100011" and status.IR(14 downto 12) = "010" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	    	state_d <= S_SW;
		elsif status.IR(6 downto 0)="0100011" and status.IR(14 downto 12) = "000" then
            cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            cmd.PC_sel <= PC_from_pc;
            cmd.PC_we <= '1';
            state_d <= S_SB;
         elsif status.IR(6 downto 0)="0100011" and status.IR(14 downto 12) = "001" then
            cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            cmd.PC_sel <= PC_from_pc;
            cmd.PC_we <= '1';
            state_d <= S_SH;
		elsif status.IR(6 downto 0)="0000011" and status.IR(14 downto 12) = "010" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		   	 cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	    		state_d <= S_LW;
		elsif status.IR(6 downto 0)="0000011" and status.IR(14 downto 12) = "000" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    	cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	    		state_d <= S_LB;
		elsif status.IR(6 downto 0)="0000011" and status.IR(14 downto 12) = "100" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    	cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	    		state_d <= S_LBU;
		elsif status.IR(6 downto 0)="0000011" and status.IR(14 downto 12) = "001" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    	cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	    		state_d <= S_LH;
		elsif status.IR(6 downto 0)="0000011" and status.IR(14 downto 12) = "101" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    	cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	    		state_d <= S_LHU;
		
		elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "010" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_SLT;
		elsif status.IR(14 downto 12) = "010" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';   
            		state_d <= S_SLTI;
		elsif status.IR(14 downto 12) = "011" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';   
            		state_d <= S_SLTIU;
		elsif status.IR(14 downto 12) = "011" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';   
            		state_d <= S_SLTU;
		
		elsif status.IR(6 downto 0) = "0110011" and status.IR(14 downto 12) = "001" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_sll;

		elsif status.IR(31 downto 25) = "0100000" and status.IR(14 downto 12) = "000" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_SUB;
		elsif status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "110" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_OR;
		elsif status.IR(14 downto 12) = "110" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_ORI;
		elsif status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "111" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_AND;
		elsif status.IR(14 downto 12) = "111" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_ANDI;
		elsif status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "100" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_XOR;	
		elsif status.IR(14 downto 12) = "100" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_XORI;
		elsif status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "001" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
           		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';
            		state_d <= S_SLLI;
		elsif status.IR(31 downto 25) = "0100000" and status.IR(14 downto 12) = "101" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';
            		state_d <= S_SRA;
		elsif status.IR(31 downto 25) = "0100000" and status.IR(14 downto 12) = "101" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';
            		state_d <= S_SRAI;
		elsif status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "101" and status.IR(6 downto 0) = "0110011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';
            		state_d <= S_SRL;
		elsif status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "101" and status.IR(6 downto 0) = "0010011" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
            		cmd.PC_sel <= PC_from_pc;
            		cmd.PC_we <= '1';
            		state_d <= S_SRLI;
		elsif status.IR(6 downto 0) = "0110011" and status.IR(31 downto 25) = "0000000" and status.IR(14 downto 12) = "000" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			state_d <= S_ADD;
		elsif status.IR(6 downto 0) = "1100111" and status.IR(14 downto 12) = "000" then
			state_d <= S_JALR ;
		elsif status.IR(6 downto 0) = "0110111" then
		    	cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    	cmd.PC_sel <= PC_from_pc;
		    	cmd.PC_we <= '1';
		    	state_d <= S_LUI;
		elsif status.IR(6 downto 0) = "1101111" then
			state_d <= S_JAL ;
		elsif status.IR(6 downto 0) = "0010011" then
		    	cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		    	cmd.PC_sel <= PC_from_pc;
		    	cmd.PC_we <= '1';
		    	state_d <= S_ADDI;
		elsif status.IR(6 downto 0) = "0010111" then
			state_d <= S_auipc;
		
		else
		    state_d <= S_Error; -- Pour d ́etecter les rat ́es du d ́ecodage
		end if;
---------- Instructions avec immediat de type U ----------

	   when S_LUI =>
		-- rd <- ImmU + 0
		cmd.PC_X_sel <= PC_X_cst_x00;
		cmd.PC_Y_sel <= PC_Y_immU;
		cmd.RF_we <= '1';
		cmd.DATA_sel <= DATA_from_pc;
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

---------- Instructions arithmétiques et logiques ----------
	   when S_ADDI =>
	   	--rd <- 
	   	cmd.ALU_Y_sel <= ALU_Y_immI;
	   	cmd.ALU_op <= ALU_plus;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_alu;
	   	-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
	   	-- next state
	   	state_d <= S_fetch;
	   when S_ADD =>
	   	--rd <- rs1 + rs2
	   	cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
	   	cmd.ALU_op <= ALU_plus;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_alu;
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	state_d <= S_fetch;
	   when S_sll =>
	    	--rd <- rs1 << rs2
	   	cmd.SHIFTER_op <= SHIFT_ll;
	   	cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_shifter;
	   	--lecture mem[PC]
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	--next state
	   	state_d <= S_fetch;
	   when S_SLLI =>
	    	--rd <- rs1 << shamt
	   	cmd.SHIFTER_op <= SHIFT_ll;
	   	cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_shifter;
	   	--lecture mem[PC]
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	--next state
	   	state_d <= S_fetch;
	   when S_SRA =>
	   	cmd.SHIFTER_op <= SHIFT_ra;
	   	cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_shifter;
	   	--lecture mem[PC]
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	--next state
	   	state_d <= S_fetch;
	   when S_SRAI =>
	   	cmd.SHIFTER_op <= SHIFT_ra;
	   	cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_shifter;
	   	--lecture mem[PC]
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	--next state
	   	state_d <= S_fetch;
	   when S_SRL =>
	   	cmd.SHIFTER_op <= SHIFT_rl;
	   	cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_shifter;
	   	--lecture mem[PC]
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	--next state
	   	state_d <= S_fetch;
	   when S_SRLI =>
	   	cmd.SHIFTER_op <= SHIFT_rl;
	   	cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
	   	cmd.RF_we <= '1';
	   	cmd.DATA_sel <= DATA_from_shifter;
	   	--lecture mem[PC]
	   	cmd.ADDR_sel <= ADDR_from_pc;
	   	cmd.mem_ce <= '1';
	   	cmd.mem_we <= '0';
	   	--next state
	   	state_d <= S_fetch;
	   when S_auipc =>
	   	--rd <- (IR_{31.....12} || 0) + pc
		cmd.PC_Y_sel <= PC_Y_immU;
		cmd.PC_X_sel <= PC_X_pc;
		cmd.RF_we <= '1';
		cmd.DATA_sel <= DATA_from_pc;
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		--incrémentation PC
		cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
		cmd.PC_sel <= PC_from_pc;
		cmd.PC_we <= '1';
		-- next state
		state_d <= S_Pre_Fetch;

---------- Instructions de saut ----------
		
	when S_BEQ =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
	   	if status.JCOND = true then
	   		cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	   	else
	   		cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
	   	end if;
	   	state_d <= S_Pre_fetch;
	when S_SLT =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.DATA_sel <= DATA_from_slt;
		cmd.RF_we <= '1';
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	when S_SLTI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.DATA_sel <= DATA_from_slt;
		cmd.RF_we <= '1';
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	when S_SLTIU =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.DATA_sel <= DATA_from_slt;
		cmd.RF_we <= '1';
		-- cmd.RF_SIGN_enable <= '0';
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	when S_SLTU =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.DATA_sel <= DATA_from_slt;
		cmd.RF_we <= '1';
		-- cmd.RF_SIGN_enable <= '0';
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	when S_JAL =>
		cmd.DATA_sel <= DATA_from_pc ;
		cmd.PC_Y_sel <= PC_Y_cst_x04;
		cmd.PC_X_sel <= PC_X_pc;
		cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
	   	cmd.RF_we <= '1';
	   	cmd.PC_sel <= PC_from_pc;
	   	cmd.PC_we <= '1';
	   	state_d <= S_Pre_Fetch;
	when S_JALR =>
		cmd.DATA_sel <= DATA_from_pc ;
		cmd.PC_Y_sel <= PC_Y_cst_x04;
		cmd.PC_X_sel <= PC_X_pc;
	   	cmd.RF_we <= '1';
		cmd.ALU_Y_sel <= ALU_Y_immI ;
        	cmd.AD_Y_sel  <= AD_Y_immI;
	   	cmd.PC_sel <= PC_from_alu;
	   	cmd.PC_we <= '1';
	   	state_d <= S_Pre_Fetch;

---------- Instructions de chargement à partir de la mémoire ----------
	when S_LW =>
		--réalise l'addition--
		cmd.AD_Y_sel <= AD_Y_immI;
		cmd.AD_we <= '1';
		state_d <= S_LW1;
	when S_LW1 =>
		-- acces mémoire--
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_LW2;
	when S_LW2 =>
		-- écriture dans le registre --
		cmd.DATA_sel <= DATA_from_mem;
		cmd.RF_we <= '1';
		cmd.RF_size_sel <= RF_SIZE_word;
		state_d <= S_Pre_Fetch;

	when S_LB =>
		cmd.AD_Y_sel <= AD_Y_immI;
		cmd.AD_we <= '1';
		state_d <= S_LB1;
	when S_LB1 =>
		-- acces mémoire--
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_LB2;
	when S_LB2 =>
		-- écriture dans le registre --
		cmd.DATA_sel <= DATA_from_mem;
		cmd.RF_we <= '1';
		cmd.RF_SIGN_enable <= '1';
		cmd.RF_size_sel <= RF_SIZE_byte;
		state_d <= S_Pre_Fetch;
	
	when S_LBU =>
		cmd.AD_Y_sel <= AD_Y_immI;
		cmd.AD_we <= '1';
		state_d <= S_LBU1;
	when S_LBU1 =>
		-- acces mémoire--
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_LBU2;
	when S_LBU2 =>
		-- écriture dans le registre --
		cmd.DATA_sel <= DATA_from_mem;
		cmd.RF_we <= '1';
		cmd.RF_SIGN_enable <= '0';
		cmd.RF_size_sel <= RF_SIZE_byte;
		state_d <= S_Pre_Fetch;

	when S_LH =>
		cmd.AD_Y_sel <= AD_Y_immI;
		cmd.AD_we <= '1';
		state_d <= S_LH1;
	when S_LH1 =>
		-- acces mémoire--
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_LH2;
	when S_LH2 =>
		-- écriture dans le registre --
		cmd.DATA_sel <= DATA_from_mem;
		cmd.RF_we <= '1';
		cmd.RF_SIGN_enable <= '1';
		cmd.RF_size_sel <= RF_SIZE_half;
		state_d <= S_Pre_Fetch;

	when S_LHU =>
		cmd.AD_Y_sel <= AD_Y_immI;
		cmd.AD_we <= '1';
		state_d <= S_LHU1;
	when S_LHU1 =>
		-- acces mémoire--
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_LHU2;
	when S_LHU2 =>
		-- écriture dans le registre --
		cmd.DATA_sel <= DATA_from_mem;
		cmd.RF_we <= '1';
		cmd.RF_SIGN_enable <= '0';
		cmd.RF_size_sel <= RF_SIZE_half;
		state_d <= S_Pre_Fetch;


---------- Instructions de sauvegarde en mémoire ----------
	when S_SW =>
		-- réalise l'addition --
		cmd.AD_Y_sel <= AD_Y_immS;
		cmd.AD_we <= '1';
		state_d <= S_SW1;
	when S_SW1 =>
		-- stocke en mémoire --
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		state_d <= S_Pre_Fetch;
	
	when S_SB =>
		cmd.AD_Y_sel <= AD_Y_immS;
		cmd.AD_we <= '1';
		state_d <= S_SB1;
	when S_SB1 =>
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		cmd.RF_size_sel <= RF_SIZE_byte;
		state_d <= S_Pre_Fetch;		

	when S_SH =>
		cmd.AD_Y_sel <= AD_Y_immS;
		cmd.AD_we <= '1';
		state_d <= S_SH1;
	when S_SH1 =>
		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		cmd.RF_size_sel <= RF_SIZE_half;
		state_d <= S_Pre_Fetch;	
	
	when S_SUB =>
		--rd <- rs1 - rs2
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.ALU_op <= ALU_minus;
		cmd.RF_we <= '1';
		cmd.DATA_sel <= DATA_from_alu;
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_fetch;
	
	when S_OR =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.LOGICAL_op <= LOGICAL_or;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
        cmd.mem_we <= '0';
		state_d <= S_fetch;
	when S_ORI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.LOGICAL_op <= LOGICAL_or;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_fetch;	
	when S_AND =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.LOGICAL_op <= LOGICAL_and;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
        cmd.mem_we <= '0';
		state_d <= S_fetch;
	when S_ANDI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.LOGICAL_op <= LOGICAL_and;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_fetch;	
	when S_XOR =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.LOGICAL_op <= LOGICAL_xor;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
        cmd.mem_we <= '0';
		state_d <= S_fetch;
	when S_XORI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.LOGICAL_op <= LOGICAL_xor;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		state_d <= S_fetch;	


---------- Instructions d'accès aux CSR ----------
	when S_IT2 =>
		if status.IR(31 downto 20) = "001100000100" then
                	cmd.cs.CSR_we <= CSR_mie;
                	cmd.cs.CSR_sel <= CSR_from_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                	cmd.cs.CSR_we <= CSR_mtvec;
                	cmd.cs.CSR_sel <= CSR_from_mtvec;
                elsif status.IR(31 downto 20) = "001101000010" then
                	cmd.cs.CSR_sel <= CSR_from_mcause;
                elsif status.IR(31 downto 20) = "001101000100" then
                	cmd.cs.CSR_sel <= CSR_from_mip;
                elsif status.IR(31 downto 20) = "001101000001" then
                	cmd.cs.CSR_we <= CSR_mepc;
                	cmd.cs.CSR_sel <= CSR_from_mepc;
                	cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001100000000" then
                	cmd.cs.CSR_we <= CSR_mstatus;
                	cmd.cs.CSR_sel <= CSR_from_mstatus;
                end if;
                if status.IR(14) = '0' then
               	cmd.cs.TO_csr_sel <= TO_CSR_from_rs1;
            	else 
			cmd.cs.TO_csr_sel <= TO_CSR_from_imm;
            	end if;
            	
            	-- CSRRW
         	if status.IR(14 downto 12) = "001" then
                	cmd.RF_we <= '1';
                	cmd.DATA_sel <= DATA_from_csr;
                	cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                	state_d <= S_Pre_fetch;
               --CSRRWI
               elsif status.IR(14 downto 12) = "101" then
                	cmd.RF_we <= '1';
                	cmd.DATA_sel <= DATA_from_csr;
                	cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                	state_d <= S_Pre_fetch;
               -- CSRRC
		elsif status.IR(13 downto 12) = "011" then 
                	cmd.RF_we <= '1';
                	cmd.DATA_sel <= DATA_from_csr;
                	cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                	state_d <= S_pre_fetch;
                --CSRRCI
                elsif status.IR(13 downto 12) = "011" then 
                	cmd.RF_we <= '1';
                	cmd.DATA_sel <= DATA_from_csr;
                	cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                	state_d <= S_pre_fetch;
                --CSRRS
                elsif status.IR(14 downto 12) = "010" then 
                	cmd.RF_we <= '1';
                	cmd.DATA_sel <= DATA_from_csr;
                	cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                	state_d <= S_Pre_fetch;
                --CSRRSI
                elsif status.IR(14 downto 12) = "110" then 
                	cmd.RF_we <= '1';
                	cmd.DATA_sel <= DATA_from_csr;
                	cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                	state_d <= S_Pre_fetch;	
                --mret
                elsif status.IR(14 downto 12) = "000" then 
                	cmd.PC_sel <= PC_from_mepc;
        		cmd.PC_we <= '1';
        		cmd.CS.MSTATUS_mie_set <= '1';
        		state_d <= S_Pre_Fetch;
                end if;
                
            when others => null;
            end case;

    end process FSM_comb;

end architecture;
