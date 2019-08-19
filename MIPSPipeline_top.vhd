-- Stalling Unit Not Working, deactivated (commented out)



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPSPipeline_top is
	port (
		i_Clk : in std_logic;
		i_Reset : in std_logic;
		
		o_leds_1, o_leds_2, o_leds_3, o_leds_4 : out std_logic;
		
		-- Testbench signals:
		o_InstruF : out std_logic_vector(31 downto 0);	
		o_ALUResult : out std_logic_vector(31 downto 0);
		o_WriteDataE : out std_logic_vector(31 downto 0);
		o_WriteRegE : out std_logic_vector(4 downto 0);
		o_ALUOutM : out std_logic_vector(3 downto 0);
		o_read_data : out std_logic_vector(3 downto 0);
		o_SignImmE : out std_logic_vector(31 downto 0);
		o_ALUSrcE : out std_logic;
		o_reg0 : out std_logic_vector(31 downto 0);
		o_ResultW : out std_logic_vector(31 downto 0);
		o_WriteDataM : out std_logic_vector(31 downto 0);
		o_RegWriteW : out std_logic
		
		);
end MIPSPipeline_top;

architecture datapath of MIPSPipeline_top is
--signal i_Reset : std_logic := '0';

-- Fetch signals
signal w_PCPlus4F : std_logic_vector(3 downto 0);
signal w_InstruF : std_logic_vector(31 downto 0);
signal w_StallF, not_StallF : std_logic;
-- control F


-- Decode signals
signal w_PCPlus4D : std_logic_vector(3 downto 0);
signal w_reg_read_data1D, w_reg_read_data2D : std_logic_vector(31 downto 0);
signal w_RtD, w_RdD, w_RsD : std_logic_vector(4 downto 0);
signal w_SignImmD, w_InstruD : std_logic_vector(31 downto 0);
signal w_Opcode, w_Func : std_logic_vector(5 downto 0);
signal w_reg0 : std_logic_vector(31 downto 0);
signal w_Clk_not : std_logic;
signal w_StallD, not_StallD : std_logic;
-- control D
signal w_MemWriteD, w_MemToRegD, w_BranchD, w_ALUSrcD, w_RegDstD, w_RegWriteD : std_logic;
signal w_ALUControlD : std_logic_vector(2 downto 0);


-- Execute signals
signal w_PCPlus4E : std_logic_vector(3 downto 0);
signal w_ALU_Result : std_logic_vector(31 downto 0);
signal w_WriteDataE, w_reg_read_data2E : std_logic_vector(31 downto 0);
signal w_WriteRegE : std_logic_vector(4 downto 0);
signal w_RtE, w_RdE, w_RsE : std_logic_vector(4 downto 0);
signal w_SignImmE : std_logic_vector(31 downto 0);
signal w_PCBranchE : std_logic_vector(3 downto 0);
signal w_reg_read_data1E : std_logic_vector(31 downto 0);
signal w_ForwardAE, w_ForwardBE : std_logic_vector(1 downto 0);
signal w_operandAE, w_operandBE : std_logic_vector(31 downto 0);
signal w_FlushE, w_ClearE : std_logic;
-- control E
signal w_MemWriteE, w_MemToRegE, w_BranchE, w_ALUSrcE, w_RegDstE, w_RegWriteE : std_logic;
signal w_ALUControlE : std_logic_vector(2 downto 0);
signal w_ZeroE : std_logic;

-- Memory signals
signal w_PCBranchM : std_logic_vector(3 downto 0);
signal w_ALUOutM : std_logic_vector(31 downto 0);
signal w_WriteDataM, w_ReadDataM : std_logic_vector(31 downto 0);
signal w_WriteRegM : std_logic_vector(4 downto 0);
signal w_leds : std_logic_vector(3 downto 0);
-- control M
signal w_PCSrcM, w_BranchM, w_RegWriteM, w_MemToRegM, w_MemWriteM, w_ZeroM : std_logic;

-- Writeback signals
signal w_ResultW : std_logic_vector(31 downto 0);
signal w_WriteRegW : std_logic_vector(4 downto 0);
signal w_ReadDataW, w_ALUOutW : std_logic_vector(31 downto 0);
-- control W
signal w_RegWriteW, w_MemtoRegW : std_logic;



component control is
	port (
		i_opcode : in std_logic_vector(5 downto 0);
		
		i_func : in std_logic_vector(5 downto 0);
		
		o_ALU_control : out std_logic_vector(2 downto 0);
		o_reg_write : out std_logic;
		o_reg_dest : out std_logic;
		o_alu_src : out std_logic;
		o_mem_write : out std_logic;
		o_mem_to_reg : out std_logic;
		o_pc_branch : out std_logic
		);
end component;

component pipeline_register is
	generic (SIZE : integer := 30
		);
	
	port (
		i_Clk : in std_logic;
		i_Reset : in std_logic;
		i_Enable : in std_logic;
		
		i_d : in std_logic_vector(SIZE - 1 downto 0);
		
		o_q : out std_logic_vector(SIZE - 1 downto 0)
		);
end component;

component fetch is
	port (
		i_Clk : in std_logic;
		i_Reset : in std_logic;
	
		i_PCBranchM : in std_logic_vector(3 downto 0);
		i_PCSrcM : in std_logic;
		i_Enable : in std_logic;
		
		o_PCPlus4F : out std_logic_vector(3 downto 0);
		o_InstruF : out std_logic_vector(31 downto 0)
	);
end component;

component decode is
	port (
		i_Clk_not : in std_logic;
		i_Reset : in std_logic;
	
		i_InstruD : in std_logic_vector(31 downto 0);
		
		i_RegWriteW : in std_logic;
		i_WriteRegW : in std_logic_vector(4 downto 0);
		
		i_ResultW : in std_logic_vector(31 downto 0);
		
		

		o_reg_read_data1 : out std_logic_vector(31 downto 0);
		o_reg_read_data2 : out std_logic_vector(31 downto 0);
		o_RsD : out std_logic_vector(4 downto 0);
		o_RtD : out std_logic_vector(4 downto 0);
		o_RdD : out std_logic_vector(4 downto 0);
		o_reg0 : out std_logic_vector(31 downto 0);
		o_SignImmD : out std_logic_vector(31 downto 0);
		o_Opcode : out std_logic_vector(5 downto 0);
		o_Func : out std_logic_vector(5 downto 0)
		);
end component;

component execute is
	port (
		i_ALUControlE : in std_logic_vector(2 downto 0);
		i_ALUSrcE : in std_logic;
		i_RegDstE : in std_logic;
		i_SrcAE : in std_logic_vector(31 downto 0);
		i_reg_read_data2E : in std_logic_vector(31 downto 0);
		i_RtE : in std_logic_vector(4 downto 0);
		i_RdE : in std_logic_vector(4 downto 0);
		i_SignImmE : in std_logic_vector(31 downto 0);
		i_PCPlus4E : in std_logic_vector(3 downto 0);
		
		o_ZeroE : out std_logic;
		o_ALUResult : out std_logic_vector(31 downto 0);
		o_WriteDataE : out std_logic_vector(31 downto 0);
		o_WriteRegE : out std_logic_vector(4 downto 0);
		o_PCBranchE : out std_logic_vector(3 downto 0)
	);
end component;

component data_memory is
	port(
		i_Clk : in std_logic;
		i_Reset : in std_logic;
	
		i_access_address : in std_logic_vector (3 downto 0);
		i_write_data : in std_logic_vector(31 downto 0);
		
		i_write_enable : in std_logic;
		
		o_leds : out std_logic_vector(3 downto 0);
		
		o_read_data : out std_logic_vector(31 downto 0)
		
	);
end component;

component hazard_unit is
	port (
		i_RegWriteW : in std_logic;
		i_RegWriteM : in std_logic;
		i_WriteRegW : in std_logic_vector(4 downto 0);
		i_WriteRegM : in std_logic_vector(4 downto 0);
		i_RsE : in std_logic_vector(4 downto 0);
		i_RtE : in std_logic_vector(4 downto 0);
		i_MemToRegE : in std_logic;
		i_RsD, i_RtD : in std_logic_vector(4 downto 0);
		
		o_ForwardAE : out std_logic_vector(1 downto 0);
		o_ForwardBE : out std_logic_vector(1 downto 0);
		o_StallD, o_StallF, o_FlushE : out std_logic
	);
end component;

begin

hazard_unit_Int : hazard_unit
	port map (
		i_RegWriteW => w_RegWriteW,
		i_RegWriteM => w_RegWriteM,
		i_WriteRegW => w_WriteRegW,
		i_WriteRegM => w_WriteRegM,
		i_RsE => w_RsE,
		i_RtE => w_RtE,
		i_RsD => w_RsD,
		i_RtD => w_RtD,
		i_MemToRegE => w_MemToRegE,
		o_ForwardAE => w_ForwardAE,
		o_ForwardBE => w_ForwardBE,
		o_StallD => w_StallD,
		o_StallF => w_StallF,
		o_FlushE => w_FlushE
		);

control_Inst : control
	port map(
		i_opcode => w_InstruD(31 downto 26),
		i_func => w_InstruD(5 downto 0),
		o_reg_write => w_RegWriteD,
		o_reg_dest => w_RegDstD,
		o_alu_src => w_ALUSrcD,
		o_mem_write => w_MemWriteD,
		o_mem_to_reg => w_MemToRegD,
		o_pc_branch => w_BranchD,
		o_ALU_control => w_ALUControlD
		);

fetch_Inst : fetch
	port map (
		i_Clk => i_Clk,
		i_Reset => i_Reset,
		--i_Enable => not_StallF,
		i_Enable => '1',
		i_PCBranchM => w_PCBranchM,
		i_PCSrcM => w_PCSrcM,
		o_PCPlus4F => w_PCPlus4F,
		o_InstruF => w_InstruF
		);
		
pipeline_register_F_to_D_Inst : pipeline_register
	generic map (36)
	port map (
		i_Clk => i_Clk,
		i_Reset => i_Reset,
		--i_Enable => not_StallD,
		i_Enable => '1',
		i_d(35 downto 4) => w_InstruF,
		i_d(3 downto 0) => w_PCPlus4F,
		o_q(35 downto 4) => w_InstruD,
		o_q(3 downto 0) => w_PCPlus4D
		);		
		
decode_Inst : decode
	port map (
		i_Clk_not => w_Clk_not,
		i_Reset => i_Reset,
		i_InstruD => w_InstruD,
		i_RegWriteW => w_RegWriteW,
		i_WriteRegW => w_WriteRegW,
		i_ResultW => w_ResultW,
		o_reg_read_data1 => w_reg_read_data1D,
		o_reg_read_data2 => w_reg_read_data2D,
		o_RsD => w_RsD,
		o_RtD => w_RtD,
		o_RdD => w_RdD,
		o_SignImmD => w_SignImmD,
		o_Opcode => w_Opcode,
		o_reg0 => w_reg0,
		o_Func => w_Func
		);
		

		
pipeline_register_D_to_E_Inst : pipeline_register
	generic map(124)
	port map (
		i_Clk => i_Clk,
		--i_Reset => w_ClearE,
		i_Reset => i_Reset,
		i_Enable => '1',
		i_d(123 downto 119) => w_RsD,
		i_d(118) => w_RegWriteD,
		i_d(117) => w_MemToRegD,
		i_d(116) => w_MemWriteD,
		i_d(115) => w_BranchD,
		i_d(114 downto 112) => w_ALUControlD,
		i_d(111) => w_ALUSrcD,
		i_d(110) => w_RegDstD,
		i_d(109 downto 78) => w_reg_read_data1D,
		i_d(77 downto 46) => w_reg_read_data2D,
		i_d(45 downto 41) => w_RtD,
		i_d(40 downto 36) => w_RdD,
		i_d(35 downto 4) => w_SignImmD, 
		i_d(3 downto 0) => w_PCPlus4D,
		o_q(123 downto 119) => w_RsE,
		o_q(118) => w_RegWriteE,
		o_q(117) => w_MemToRegE,
		o_q(116) => w_MemWriteE,
		o_q(115) => w_BranchE,
		o_q(114 downto 112) => w_ALUControlE,
		o_q(111) => w_ALUSrcE,
		o_q(110) => w_RegDstE,
		o_q(109 downto 78) => w_reg_read_data1E,
		o_q(77 downto 46) => w_reg_read_data2E,
		o_q(45 downto 41) => w_RtE,
		o_q(40 downto 36) => w_RdE,
		o_q(35 downto 4) => w_SignImmE,
		o_q(3 downto 0) => w_PCPlus4E
		);
		
execute_Inst : execute
	port map (
		i_ALUControlE => w_ALUControlE,
		i_ALUSrcE => w_ALUSrcE,
		i_RegDstE => w_RegDstE,
		i_SrcAE => w_operandAE,
		i_reg_read_data2E => w_operandBE,
		i_RtE => w_RtE,
		i_RdE => w_RdE,
		i_SignImmE => w_SignImmE,
		i_PCPlus4E => w_PCPlus4E,
		o_ZeroE => w_ZeroE,
		o_ALUResult => w_ALU_Result,
		o_WriteDataE => w_WriteDataE,
		o_WriteRegE => w_WriteRegE,
		o_PCBranchE => w_PCBranchE
		);

pipeline_register_E_to_M_Inst : pipeline_register
	generic map(78)
	port map (
		i_Clk => i_Clk,
		i_Reset => i_Reset,
		i_Enable => '1',
		i_d(77) => w_RegWriteE,
		i_d(76) => w_MemToRegE,
		i_d(75) => w_MemWriteE,
		i_d(74) => w_BranchE,
		i_d(73) => w_ZeroE,
		i_d(72 downto 41) => w_ALU_Result,
		i_d(40 downto 9) => w_WriteDataE,
		i_d(8 downto 4) => w_WriteRegE,
		i_d(3 downto 0) => w_PCBranchE,
		o_q(77) => w_RegWriteM,
		o_q(76) => w_MemToRegM,
		o_q(75) => w_MemWriteM,
		o_q(74) => w_BranchM,
		o_q(73) => w_ZeroM,
		o_q(72 downto 41) => w_ALUOutM,
		o_q(40 downto 9) => w_WriteDataM,
		o_q(8 downto 4) => w_WriteRegM,
		o_q(3 downto 0) => w_PCBranchM
		); 
		
pipeline_register_M_to_W_Inst : pipeline_register
	generic map(71)
	port map (
		i_Clk => i_Clk,
		i_Reset => i_Reset,
		i_Enable => '1',
		i_d(70) => w_RegWriteM,
		i_d(69) => w_MemToRegM,
		i_d(68 downto 37) => w_ALUOutM,
		i_d(36 downto 5) => w_ReadDataM,
		i_d(4 downto 0) => w_WriteRegM,
		o_q(70) => w_RegWriteW,
		o_q(69) => w_MemToRegW,
		o_q(68 downto 37) => w_ALUOutW,
		o_q(36 downto 5) => w_ReadDataW,
		o_q(4 downto 0) => w_WriteRegW
		);
		
data_memory_Inst : data_memory
	port map (
		i_Clk => i_Clk,
		i_Reset => i_Reset,
		i_access_address => w_ALUOutM(3 downto 0),
		i_write_data => w_WriteDataM,
		i_write_enable => w_MemWriteM,
		o_leds => w_leds,
		o_read_data => w_ReadDataM
		);
		
	-- ALU Operand Muxes
	w_operandAE <= w_ALUOutM when w_ForwardAE = "10" else w_ResultW when w_ForwardAE = "01" else w_reg_read_data1E;
	w_operandBE <= w_ALUOutM when w_ForwardBE = "10" else w_ResultW when w_ForwardBE = "01" else w_reg_read_data2E;
		
	-- inverted clock for register file
	w_Clk_not <= not i_Clk;
		
	-- Mem to Reg Mux
	w_ResultW <= w_ReadDataW when w_MemToRegW = '1' else w_ALUOutW;
	
	-- PC Next Mux
	w_PCSrcM <= w_BranchM and w_ZeroM;
	
	-- For Flushing Execute
	w_ClearE <= i_Reset or w_FlushE;
	
	not_StallD <= not w_StallD;
	not_StallF <= not w_StallF;
	
		o_leds_1 <= w_leds(0);
		o_leds_2 <= w_leds(1);
		o_leds_3 <= w_leds(2);
		o_leds_4 <= w_leds(3);
		
		-- For Testbench:
		o_instruF <= w_InstruF;
		o_ALUResult <= w_ALU_Result;
		o_WriteDataE <= w_WriteDataE;
		o_WriteRegE <= w_WriteRegE;
		o_read_data <= w_ReadDataM(3 downto 0);
		o_ALUOutM <= w_ALUOutM(3 downto 0);
		o_WriteDataM <= w_WriteDataM;
		o_SignImmE <= w_SignImmE;
		o_ALUSrcE <= w_ALUSrcE;
		o_reg0 <= w_reg0;
		o_ResultW <= w_ResultW;
		o_RegWriteW <= w_RegWriteW;

end datapath;