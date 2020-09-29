library ieee;
use ieee.std_logic_1164.all;

entity encoder_16_4 is
	port (encoder_in:		in		std_logic_vector(15 downto 0);
			encoder_out:	out	std_logic_vector(3 downto 0));
end encoder_16_4;

architecture design_encoder_16_4 of encoder_16_4 is
begin
	
		encoder_out <= "0000" when encoder_in(15) = '1' else
							"1111" when encoder_in(14) = '1' else
							"1110" when encoder_in(13) = '1' else
							"1101" when encoder_in(12) = '1' else
							"1100" when encoder_in(11) = '1' else
							"1011" when encoder_in(10) = '1' else
							"1010" when encoder_in(9) = '1' else
							"1001" when encoder_in(8) = '1' else
							"1000" when encoder_in(7) = '1' else
							"0111" when encoder_in(6) = '1' else
							"0110" when encoder_in(5) = '1' else
							"0101" when encoder_in(4) = '1' else
							"0100" when encoder_in(3) = '1' else	
							"0011" when encoder_in(2) = '1' else	
							"0010" when encoder_in(1) = '1' else
							"0001" when encoder_in(0) = '1' else
							"0000";
	
end design_encoder_16_4;

library ieee;
use ieee.std_logic_1164.all;

entity decoder_4_14 is
	port (decoder_in:		in		std_logic_vector(3 downto 0);
			decoder_out:	out	std_logic_vector(13 downto 0));
end decoder_4_14;

architecture design_decoder_4_14 of decoder_4_14 is
begin
with decoder_in select
	decoder_out <= "11111101111110" when "0000",
						"11111100110000" when "0001",
						"11111101101101" when "0010",
						"11111101111001" when "0011",
						"11111100110011" when "0100",
						"11111101011011" when "0101",
						"11111101011111" when "0110",
						"11111101110000" when "0111",
						"11111101111111" when "1000",
						"11111101111011" when "1001",
						
						"01100001111110" when "1010",
						"01100000110000" when "1011",
						"01100001101101" when "1100",
						"01100001111001" when "1101",
						"01100000110011" when "1110",
						"01100001011011" when "1111",
						
						"00000000000000" when others;
end design_decoder_4_14;

library ieee; 
use ieee.std_logic_1164.all;

entity ward_switch_15 is
	port( input:	in		std_logic_vector(15 downto 0);
			output:	out 	std_logic_vector(13 downto 0);
			signal_4: out	std_logic_vector(3 downto 0));
end ward_switch_15;

architecture design_ward of ward_switch_15 is

component encoder_16_4 is
	port (encoder_in:		in		std_logic_vector(15 downto 0);
			encoder_out:	out	std_logic_vector(3 downto 0));
end component;

component decoder_4_14 is
	port (decoder_in:		in		std_logic_vector(3 downto 0);
			decoder_out:	out	std_logic_vector(13 downto 0));
end component;

signal encoder_4	:	std_logic_vector(3 downto 0);

begin
encoder:	encoder_16_4 port map (input, encoder_4);
decoder: decoder_4_14 port map (encoder_4, output);

signal_4 <= encoder_4;

end design_ward;