library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_unit is
	port (
		i_RegWriteW : in std_logic;
		i_RegWriteM : in std_logic;
		i_WriteRegW : in std_logic_vector(4 downto 0);
		i_WriteRegM : in std_logic_vector(4 downto 0);
		i_RsE : in std_logic_vector(4 downto 0);
		i_RtE : in std_logic_vector(4 downto 0);
		i_RsD, i_RtD : in std_logic_vector(4 downto 0);
		i_MemToRegE : std_logic;
		
		o_ForwardAE : out std_logic_vector(1 downto 0);
		o_ForwardBE : out std_logic_vector(1 downto 0);
		
		o_StallD, o_StallF, o_FlushE : out std_logic
	);
end hazard_unit;

architecture beh of hazard_unit is

signal lwstall : std_logic;

begin

	-- Forwarding Unit
	o_ForwardAE <= "10" when ((i_RsE = i_WriteRegM) and i_RegWriteM = '1') else
				   "01" when ((i_RsE = i_WriteRegW) and i_RegWriteW = '1') else
				   "00";
				   
	o_ForwardBE <= "10" when ((i_RtE = i_WriteRegM) and i_RegWriteM = '1') else
				   "01" when ((i_RtE = i_WriteRegW) and i_RegWriteW = '1') else
				   "00";
				   
	-- Stall Unit
	lwstall <= '1' when (((i_RsD = i_RtE) or (i_RtD = i_RtE)) and i_MemToRegE = '1') else '0';
	o_StallD <= lwstall;
	o_StallF <= lwstall;
	o_FlushE <= lwstall;


end beh;