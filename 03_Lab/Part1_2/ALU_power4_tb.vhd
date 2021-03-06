library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_power4_tb is
end ALU_power4_tb;

architecture Behavior of ALU_power4_tb is

component ALU_power4
	generic(n: integer:=8);
	port(
			a, b: in signed(n-1 downto 0);
			c_in: in std_logic;
			opcode: in std_logic;
			c_carryin_last: out std_logic;
			c_out: out std_logic;
			status: out std_logic;
			s: out signed(n-1 downto 0)
		 );
end component;

signal a_in, b_in: signed(7 downto 0);
signal c_in: std_logic := '0';
signal opcode: std_logic;
signal c_carryin_last: std_logic;
signal c_out: std_logic;
signal overflow: std_logic;
signal result: signed(7 downto 0);

begin
	DUT: ALU_power4 
		 generic map (8) 
		 port map (a_in, b_in, c_in, opcode, c_carryin_last, c_out, overflow, result);
	
	process
	begin
		a_in <= to_signed(13, 8);
		b_in <= to_signed(10, 8);
		opcode <= '0'; -- addition
		wait for 10 ns;
		a_in <= to_signed(86, 8);
		b_in <= to_signed(13, 8);
		opcode <= '0'; -- addition 
		wait for 10 ns;
		a_in <= to_signed(127, 8);
		b_in <= to_signed(0, 8);
		opcode <= '0'; -- addition 
		wait for 10 ns;
		a_in <= to_signed(127, 8);
		b_in <= to_signed(2, 8);
		opcode <= '0'; -- addition 
		wait for 10 ns;
		a_in <= to_signed(-50, 8);
		b_in <= to_signed(20, 8);
		opcode <= '0'; -- addition 
		wait for 10 ns;

		a_in <= to_signed(10, 8);
		b_in <= to_signed(8, 8);
		opcode <= '1'; -- subtraction 
		wait for 10 ns;
		a_in <= to_signed(9, 8);
		b_in <= to_signed(15, 8);
		opcode <= '1'; -- subtraction 
		wait for 10 ns;
		a_in <= to_signed(128, 8);
		b_in <= to_signed(0, 8);
		opcode <= '1'; -- subtraction 
		wait for 10 ns;
		a_in <= to_signed(-1, 8);
		b_in <= to_signed(128, 8);
		opcode <= '1'; -- subtraction 
		wait for 10 ns;
		a_in <= to_signed(-50, 8);
		b_in <= to_signed(-20, 8);
		opcode <= '1'; -- subtraction 
		wait for 10 ns;
	end process;
end Behavior;