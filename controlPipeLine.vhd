library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
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
end control;

architecture behave of control is
signal ALU_Op : std_logic_vector(1 downto 0);
begin
	process (i_opcode, i_func, ALU_Op) is
	begin
	case i_opcode is
		when "000000" => -- R Type 
			o_reg_write <= '1';
			o_reg_dest <= '1';
			o_alu_src <= '0';
			o_mem_write <= '0';
			o_mem_to_reg <= '0';
			o_pc_branch <= '0';
			ALU_Op <= "10";
		when "001000" => -- addi
			o_reg_write <= '1';
			o_reg_dest <= '0';
			o_alu_src <= '1';
			o_mem_write <= '0';
			o_mem_to_reg <= '0';
			o_pc_branch <= '0';
			ALU_Op <= "00";
		when "100011" => -- lw
			o_reg_write <= '1';
			o_reg_dest <= '0';
			o_alu_src <= '1';
			o_mem_write <= '0';
			o_mem_to_reg <= '1';
			o_pc_branch <= '0';
			ALU_Op <= "00";
		when "101011" => -- sw
			o_reg_write <= '0';
			o_reg_dest <= '0';
			o_alu_src <= '1';
			o_mem_write <= '1';
			o_mem_to_reg <= '0';
			o_pc_branch <= '0';
			ALU_Op <= "00";
		when "000100" => -- beq
			o_reg_write <= '0';
			o_reg_dest <= '0';
			o_alu_src <= '0';
			o_mem_write <= '0';
			o_mem_to_reg <= '0';
			o_pc_branch <= '1';
			ALU_Op <= "01";
		when "000010" => -- jump (j)
			o_reg_write <= '0';
			o_reg_dest <= '0';
			o_alu_src <= '0';
			o_mem_write <= '0';
			o_mem_to_reg <= '0';
			o_pc_branch <= '0';
			ALU_Op <= "00";
		when others =>
			o_reg_write <= '0';
			o_reg_dest <= '0';
			o_alu_src <= '0';
			o_mem_write <= '0';
			o_mem_to_reg <= '0';
			o_pc_branch <= '0';
			ALU_Op <= "00";
	end case;
	
	case ALU_Op is
		when "00" =>
			o_ALU_control <= "010";
		when "01" =>
			o_ALU_control <= "110";
		when "10" =>
			case i_func is
				when "100000" =>
					o_ALU_control <= "010";
				when "100010" =>
					o_ALU_control <= "110";
				when "100100" =>
					o_ALU_control <= "000";
				when "100101" =>
					o_ALU_control <= "001";
				when "101010" =>
					o_ALU_control <= "111";
				when others =>
					o_ALU_control <= "010";
			end case;
		when others =>
			o_ALU_control <= "000";
	end case;
	end process;
end behave;

