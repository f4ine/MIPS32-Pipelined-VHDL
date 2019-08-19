library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_register is
	generic (SIZE : integer := 30
		);
	
	port (
		i_Clk : in std_logic;
		i_Reset : in std_logic;
		i_Enable : in std_logic;
		
		i_d : in std_logic_vector(SIZE - 1 downto 0);
		
		o_q : out std_logic_vector(SIZE - 1 downto 0)
		);
end pipeline_register;

architecture beh of pipeline_register is
begin
	
	process (i_Clk, i_Reset) is
	begin
		if (i_Reset = '1') then
			o_q <= (others => '0');
		else
			if (rising_edge(i_Clk)) then
				if (i_Enable = '1') then
					o_q <= i_d;
				end if;
			end if;
		end if;
	end process;

end beh;