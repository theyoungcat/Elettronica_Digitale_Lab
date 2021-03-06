library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataPath is
	generic(n: integer:=20);
  port( current_error: in signed(7 downto 0);
        clock, resetn: in std_logic;
        MUX_sel: in std_logic_vector(2 downto 0);
        sub_sumn, LOADe_k, LOADe_k1, LOADP, LOADsum, LOADI, LOADdif, LOADD, LOADS1, LOADS2, LOADu_k, ENABLEcnt: in std_logic;
        controlled_saturation: in std_logic_vector(1 downto 0);
        cnt: buffer signed(9 downto 0);
        check_saturation: out std_logic_vector(1 downto 0);
        current_output: out signed(7 downto 0)
      );
end DataPath;

architecture Structure of DataPath is
  component ALU_power4
	generic(n: integer:=20);
    port(
			a, b: in signed(n-1 downto 0);
			c_in: in std_logic;
			opcode: in std_logic;
			c_carryin_last: buffer std_logic;
			c_out: buffer std_logic;
			status: out std_logic;
			s: out signed(n-1 downto 0)
		 );
  end component;
  
  component regn
	generic(n: integer:=20);
	port(
			R: in signed(n-1 downto 0);
			Clock, Resetn, Load: in std_logic;
			Q: out signed(n-1 downto 0)
		  );
  end component;
  
component MUX6NtoN
	generic(n: integer:=20);
	port(
			u_sig, v_sig, w_sig, x_sig, y_sig, z_sig: in signed(n-1 downto 0); --inputs
			s: in std_logic_vector(2 downto 0); --selectors
			m_sig: out signed(n-1 downto 0) --output
		 );
  end component;
  
  component Saturation
	 port(
			data_in: in signed(19 downto 0); --we take only MSB bits to check overflow
			--00 not overflow, positive number
			--01 not overflow, negative number
			--10 overflow, positive number
			--11 overflow, negative number
			overflow: out std_logic_vector(1 downto 0)
		 );
  end component;
  
  component MUX3NtoN is
	generic(n_out: integer:=8);
	port(
			u_sig, v_sig, w_sig: in signed(n_out-1 downto 0); --inputs
			s: in std_logic_vector(1 downto 0); --selectors
			m_sig: out signed(n_out-1 downto 0) --output
		 );
  end component;
  
  signal resized_error, e_k, e_k1, e_k4, e_k025: signed(n-1 downto 0); --generic signals
  signal left_addend, right_addend, result_adder: signed(n-1 downto 0); -- signals to be selected by the MUXes
  signal P_out, sum_out, sum_out2, I_out, dif_out, dif_out05, D_out, S1_out, S2_out: signed(n-1 downto 0); --output registers
  signal u_k: signed(7 downto 0);--register with data that has to be written in MEM_B
  signal cnt_resized: signed(19 downto 0); --fix it

begin
  --read data from MEM_A
  resized_error <= resize(current_error, n);  -- represent the input number on 20 bits
  REGe_k: regn port map (resized_error, clock, resetn, LOADe_k, e_k); --current input e[k]
  REGe_k1: regn port map (e_k, clock, resetn, LOADe_k1, e_k1); --previous input e[k-1]
  
  --BLOCK P
  e_k4 <= e_k(n-3 downto 0)&"00"; --4*e_k
  e_k025 <= e_k(n-1 downto n-2) & e_k(n-1 downto 2); --0.25*e_k
  REGP: regn port map(result_adder, clock, resetn, LOADP, P_out);
  
  --BLOCK I
  sum_out2 <= sum_out(n-2 downto 0)&"0"; --2*sum_out
  REGsum: regn port map(result_adder, clock, resetn, LOADsum, sum_out);
  REGI: regn port map(sum_out2, clock, resetn, LOADI, I_out); --memorize sum*2
  
  --BLOCK D
  dif_out05 <= dif_out(n-1)&dif_out(n-1 downto 1); --0.5*(e_k - e_k-1)
  REGdif: regn port map(result_adder, clock, resetn, LOADdif, dif_out);
  REGD:regn port map(dif_out05, clock, resetn, LOADD, D_out); --memorize dif*0.5
  
  --BLOCK S1
  REGS1: regn port map(result_adder, clock, resetn, LOADS1, S1_out); --block P + block I
    
  --BLOCK S2
  REGS2: regn port map(result_adder, clock, resetn, LOADS2, S2_out); --block S1 + block D
    
  --OUTPUT
  REGu_k: regn 
        generic map(8)
        port map(u_k, clock, resetn, LOADu_k, current_output); --final output, to be written in MEM_B
    
  --INCREMENT COUNTER
  REGcnt: regn
			 generic map (10)
			 port map(result_adder(9 downto 0), clock, resetn, ENABLEcnt, cnt); --count
  
  --SATURATION
  CONTROL_SAT: Saturation port map(S2_out, check_saturation);
    
  --MUXes
  cnt_resized <= resize(cnt, 20);
  MUX_left: MUX6NtoN port map(e_k4, sum_out, e_k, P_out, S1_out, cnt_resized, MUX_sel, left_addend);--left input of the adder
  MUX_right: MUX6NtoN port map(e_k025, e_k, e_k1, I_out, D_out, "00000000000000000001", MUX_sel, right_addend);--right input of the adder
    
  MUX_saturation: MUX3NtoN port map("01111111", "10000000", S2_out(7 downto 0), controlled_saturation, u_k);--the output is chosen by the CU
  
  --ALU
  ALU_20bit: ALU_power4 port map(left_addend, right_addend, '0', sub_sumn, open, open, open, result_adder);--useless outputs are open
  
end Structure;
