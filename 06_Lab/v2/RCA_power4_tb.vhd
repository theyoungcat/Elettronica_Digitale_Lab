library ieee;
use ieee.std_logic_1164.all;

entity RCA_power4_tb is
end RCA_power4_tb;

architecture Behavior of RCA_power4_tb is

component RCA_power4
  generic(n: integer:=20); --n bits MUST BE MULTIPLE OF 4!!
  port(
      a, b: in std_logic_vector(n-1 downto 0);
			c_in: in std_logic;
			c_carryin_last: out std_logic; -- last carry in (useful for overflow detection)
			c_out: out std_logic;
			s: out std_logic_vector(n-1 downto 0)
		 );
end component;

constant n: integer := 20;
signal A_IN: std_logic_vector(n-1 downto 0);
signal B_IN: std_logic_vector(n-1 downto 0);
signal S_OUT: std_logic_vector(n-1 downto 0);
signal C_IN_SIM: std_logic;
signal C_LAST: std_logic;
signal C_OUT_SIM: std_logic;

begin

  DUT: RCA_power4 port map (a => A_in, b => B_IN, c_in => C_IN_SIM, c_carryin_last => C_LAST, s => S_OUT, c_out => C_OUT_SIM);
    
process
begin
  
  A_IN <= "00000000000000000000";
  B_IN <= "00000000000000000000";
  C_IN_SIM <= '0';
  wait for 4 ns; -- S_OUT = "00000000000000000000", C_OUT_SIM = '0'
  
  A_IN <= "00000000000000000000";
  B_IN <= "00000000000000000000";
  C_IN_SIM <= '1';
  wait for 4 ns; -- S_OUT = "00000000000000000001", C_OUT_SIM = '0'
  
  A_IN <= "00000000000000000101";
  B_IN <= "00000000000000001010";
  C_IN_SIM <= '0';
  wait for 4 ns; -- S_OUT = "00000000000000001111", C_OUT_SIM = '0'
  
  A_IN <= "00000000000000000101";
  B_IN <= "00000000000000001010";
  C_IN_SIM <= '1';
  wait for 4 ns; -- S_OUT = "00000000000000010000", C_OUT_SIM = '0'
  
  A_IN <= "00000000111111111111";
  B_IN <= "00000000111111111111";
  C_IN_SIM <= '1';
  wait for 4 ns; -- S_OUT = "00000001111111111111", C_OUT_SIM = '0'


end process;
end Behavior;
