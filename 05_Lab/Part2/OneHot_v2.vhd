library ieee;
use ieee.std_logic_1164.all;

entity OneHot_v2 is
  port( SW0: in std_logic; --resetn
        SW1: in std_logic; --w
        KEY0: in std_logic; --clock
        LEDG0: out std_logic; --z
        LEDR8_0: buffer std_logic_vector (8 downto 0) --states
      );
end OneHot_v2;

architecture Behavior of OneHot_v2 is
  component state_sequential_v2 is
  port( w, resetn, clock: in std_logic;
        idle_out, det0_1_out,det0_2_out,det0_3_out,det0_4_out,det1_1_out,det1_2_out,det1_3_out,det1_4_out: buffer std_logic
      );
  end component;
  
  signal states_vector:std_logic_vector(8 downto 0);
  
  begin
    in_reg: state_sequential_v2 port map(SW1,SW0,KEY0,states_vector(0),states_vector(1),states_vector(2),states_vector(3),states_vector(4),states_vector(5),states_vector(6),states_vector(7),states_vector(8));
	 LEDR8_0 <= states_vector;
	 
	 LEDG0 <= states_vector(4) or states_vector(8);

end Behavior;
