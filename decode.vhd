 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode is
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
		o_SignImmD : out std_logic_vector(31 downto 0);
		o_Opcode : out std_logic_vector(5 downto 0);
		o_Func : out std_logic_vector(5 downto 0);
		
		-- for test bench:
		o_reg0 : out std_logic_vector(31 downto 0)
		);
end decode;

architecture beh of decode is
type register_file is array (0 to 31) of std_logic_vector(31 downto 0);

signal register_array : register_file;

begin
	process (i_Clk_not, i_Reset) is
	begin
		if (i_Reset = '1') then
			register_array <= (14 => X"0000000A", others => X"00000000");
		else
			if (rising_edge(i_Clk_not)) then
				if (i_RegWriteW = '1') then
					register_array(to_integer(unsigned(i_WriteRegW))) <= i_ResultW;
				end if;
			end if;
		end if;
	end process;
	
	o_reg_read_data1 <= register_array(to_integer(unsigned(i_InstruD(25 downto 21))));
	o_reg_read_data2 <= register_array(to_integer(unsigned(i_InstruD(20 downto 16))));
	
	o_RsD <= i_InstruD(25 downto 21);
	o_RtD <= i_InstruD(20 downto 16);
	o_RdD <= i_InstruD(15 downto 11);
	o_SignImmD <= ((31 downto 16 => i_InstruD(15)) & i_InstruD(15 downto 0));
	o_Opcode <= i_InstruD(31 downto 26);
	o_Func <= i_InstruD(5 downto 0);
	
	-- test bench
	o_reg0 <= register_array(0);
		
end beh;