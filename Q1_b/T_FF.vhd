library ieee;
use ieee.std_logic_1164.all;

entity T_FF is
	port ( clk, T		: in	std_logic;
			 Q, Q_bar	: out	std_logic );
end T_FF;

architecture design_T_FF of T_FF is

component inv is
	port (i1		:	in		std_logic;
			F_inv	:	out	std_logic );
end component;

signal temp_Q, temp_Q_bar : std_logic:='0';
 
begin

	process(clk)
	begin
		if clk'event and clk='1' then
			if T='0' then
				temp_Q <= temp_Q;
			elsif T='1' then
				temp_Q <= temp_Q_bar;
			end if;
		end if;
	end process;
	
iv1: inv port map (temp_Q, temp_Q_bar);
	Q <= temp_Q;
	Q_bar <= temp_Q_bar;
end design_T_FF;