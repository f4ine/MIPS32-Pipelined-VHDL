library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPSPipeline_top_tb is
end MIPSPipeline_top_tb;

architecture beh of MIPSPipeline_top_tb is
signal InstruF : std_logic_vector(31 downto 0);
signal Clk, Reset : std_logic;
signal led1, led2, led3, led4 : std_logic;
signal ALUResult : std_logic_vector(31 downto 0);
signal WriteDataE, WriteDataM : std_logic_vector(31 downto 0);
signal WriteRegE : std_logic_vector(4 downto 0);
signal read_data : std_logic_vector(3 downto 0);
signal ALUOutM : std_logic_vector(3 downto 0);
signal ALUSrcE : std_logic;
signal SignImmE : std_logic_vector(31 downto 0);
signal reg0 : std_logic_vector(31 downto 0);
signal ResultW : std_logic_vector(31 downto 0);
signal RegWriteW : std_logic;

constant clock_period : time := 40 ns;

component MIPSPipeline_top is
	port (
		i_Clk : in std_logic;
		i_Reset : in std_logic;
		
		o_leds_1, o_leds_2, o_leds_3, o_leds_4 : out std_logic;
		o_ALUResult : out std_logic_vector(31 downto 0);
		o_WriteDataE : out std_logic_vector(31 downto 0);
		o_WriteRegE : out std_logic_vector(4 downto 0);
		o_read_data : out std_logic_vector(3 downto 0);
		o_ALUOutM : out std_logic_vector(3 downto 0);
		o_WriteDataM : out std_logic_vector(31 downto 0);
		o_SignImmE : out std_logic_vector(31 downto 0);
		o_ALUSrcE : out std_logic;
		o_reg0 : out std_logic_vector(31 downto 0);
		o_ResultW : out std_logic_vector(31 downto 0);
		o_InstruF : out std_logic_vector(31 downto 0);
		o_RegWriteW : out std_logic
		);
end component;

begin

	uut : MIPSPipeline_top
	port map (
		i_Clk => Clk,
		i_Reset => Reset,
		o_leds_1 => led1,
		o_leds_2 => led2,
		o_leds_3 => led3,
		o_leds_4 => led4,
		o_ALUResult => ALUResult,
		o_WriteDataE => WriteDataE,
		o_WriteRegE => WriteRegE,
		o_read_data => read_data,
		o_ALUOutM => ALUOutM,
		o_ALUSrcE => ALUSrcE,
		o_SignImmE => SignImmE,
		o_WriteDataM => WriteDataM,
		o_ResultW => ResultW,
		o_InstruF => InstruF,
		o_RegWriteW => RegWriteW,
		o_reg0 => reg0
		);

	process is
	begin
		Clk <= '0';
		wait for clock_period/2;
		Clk <= '1';
		wait for clock_period/2;
	end process;
	
	process is
	begin
		Reset <= '1';
		wait for clock_period*10;
		Reset <= '0';
		wait;
	end process;
	
end beh;