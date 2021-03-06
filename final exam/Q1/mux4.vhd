library ieee;
use ieee.std_logic_1164.all;

entity mux4 is
	port (s0, s1			:	in	 std_logic;
			d0, d1, d2, d3	: 	in	 std_logic;
			F_mux4			:	out std_logic );
end mux4;

architecture design_mux4 of mux4 is
signal s0s1 : std_logic_vector(1 downto 0);
begin 
	s0s1  <= s0 & s1;
	F_mux4 <= d0 when s0s1 = "00" else
	          d1 when s0s1 = "01" else
				 d2 when s0s1 = "10" else
				 d3;
end design_mux4;