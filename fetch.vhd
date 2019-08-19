library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	port (
		i_Clk : in std_logic;
		i_Reset : in std_logic;
	
		i_PCBranchM : in std_logic_vector(3 downto 0);
		i_PCSrcM : in std_logic;
		i_Enable : in std_logic;
		
		o_PCPlus4F : out std_logic_vector(3 downto 0);
		o_InstruF: out std_logic_vector(31 downto 0)
	);
end fetch;

architecture beh of fetch is
signal PC_next, PCF, w_PCPlus4F : std_logic_vector(3 downto 0);
type mem_array is array (0 to 15) of std_logic_vector(7 downto 0);

constant instruction_rom : mem_array := (
	"10001100",
	"00000000",
	"00000000",
	"00000011",
	"01110000",
	"00000000",
	"00000000",
	"00000000",
	"01110000",
	"00000000",
	"00000000",
	"00000000",
	"00100000",
	"01000000",
	"00000000",
	"00000000"
	); -- 16 bytes of rom, 4 instructions

begin
	
	process(i_Clk, i_Reset) is
	begin
		if (i_reset = '1') then
			PCF <= "0000";
		else
			if (rising_edge(i_Clk)) then
				if (i_Enable = '1') then
					PCF <= PC_next;
				end if;
			end if;
		end if;
	end process;
				

	o_InstruF <= instruction_rom(to_integer(unsigned(PCF))) &
				 instruction_rom(to_integer(unsigned(PCF))+1) &
			     instruction_rom(to_integer(unsigned(PCF))+2) &
			     instruction_rom(to_integer(unsigned(PCF))+3);
	
	-- PC Increment by 4
	w_PCPlus4F <= std_logic_vector(unsigned(PCF) + "0100");
	o_PCPlus4F <=w_PCPlus4F;
	
	-- PC Branch Mux
	PC_next <= i_PCBranchM when i_PCSrcM = '1' else w_PCPlus4F;
	
end beh;