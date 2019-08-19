library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
	port(
		i_Clk : in std_logic;
		i_Reset : in std_logic;
	
		i_access_address : in std_logic_vector (3 downto 0);
		i_write_data : in std_logic_vector(31 downto 0);
		
		i_write_enable : in std_logic;
		
		o_leds : out std_logic_vector(3 downto 0);
		
		o_read_data : out std_logic_vector(31 downto 0)
		
	);
end data_memory;

architecture beh of data_memory is
type mem_array is array (0 to (2**10)-1) of std_logic_vector(7 downto 0);
signal ram : mem_array;

begin
	process(i_Clk, i_Reset) is
	begin
		if (i_Reset = '1') then
			ram <= (6 => X"0B", others => X"00");
		else
			if (rising_edge(i_Clk)) then
				if (i_write_enable = '1') then
					ram(to_integer(unsigned(i_access_address))) <= i_write_data(31 downto 24);
					ram(to_integer(unsigned(i_access_address))+1) <= i_write_data(23 downto 16);
					ram(to_integer(unsigned(i_access_address))+2) <= i_write_data(15 downto 8);
					ram(to_integer(unsigned(i_access_address))+3) <= i_write_data(7 downto 0);
				end if;
			end if;
		end if;
	end process;
	
	o_read_data <= ram(to_integer(unsigned(i_access_address))) & 
				   ram(to_integer(unsigned(i_access_address))+1) &
				   ram(to_integer(unsigned(i_access_address))+2) &
				   ram(to_integer(unsigned(i_access_address))+3);
				   
	o_leds <= ram(3)(3 downto 0);
	
end beh;