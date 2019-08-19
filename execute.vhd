library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execute is
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
end execute;

architecture beh of execute is
signal SrcBE, SrcAE : std_logic_vector(31 downto 0);
signal output : signed(31 downto 0);

begin

	-- Write Data redirected to memory.
	o_WriteDataE <= i_reg_read_data2E;
	
	-- Reg dest Mux
	o_WriteRegE <= i_RdE when i_RegDstE = '1' else i_RtE;
	
	-- Source B Mux
	SrcBE <= i_SignImmE when i_ALUSrcE = '1' else i_reg_read_data2E;
	
	-- Branch address calculation
	o_PCBranchE <= std_logic_vector(unsigned(i_PCPlus4E) + unsigned(i_SignImmE(1 downto 0) & '0' & '0'));
	
	process (i_ALUControlE, i_SrcAE, SrcBE) is
	begin
		case i_ALUControlE is
			when "010" =>
				output <= signed(i_SrcAE) + signed(SrcBE);
			when "110" =>
				output <= signed(i_SrcAE) - signed(SrcBE);
			when "000" =>
				output <= signed(i_SrcAE) and signed(SrcBE);
			when "001" =>
				output <= signed(i_SrcAE) or signed(SrcBE);
			when others =>
				output <= X"00000000";
		end case;
	end process;
	
	o_ALUResult <= std_logic_vector(output);
	
	o_ZeroE <= '1' when output = X"00000000" else '0';

end beh;