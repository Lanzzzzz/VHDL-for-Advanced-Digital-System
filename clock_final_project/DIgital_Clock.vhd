library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
--Digital Clock project

--201991139 WANG ZHONGTIAN
--201990309 LAN ZHIJIE

entity DIgital_Clock is
port (
		clk_in 			: in std_logic;
		switch_mode		: in std_logic := '1';--switch between clock,chronometer and alarm
		operate			: in std_logic := '1';--select min or hour when in clock or alarm. start/stop when in chronometer
		increase 		: in std_logic := '1';--time + 1 when select min or hour
		buzz				: out std_logic;-- buzzing when clock time is same with alarm time
		display_hour1	: out std_logic_vector(6 downto 0);--display on 6 bits 7-segement LED 
		display_hour2	: out std_logic_vector(6 downto 0);
		display_min1	: out std_logic_vector(6 downto 0);
		display_min2	: out std_logic_vector(6 downto 0);
      display_sec1	: out std_logic_vector(6 downto 0);
     	display_sec2	: out std_logic_vector(6 downto 0)
     );
end DIgital_Clock;

architecture design of DIgital_Clock is
	type states is (clock, clk_min, clk_hour, chrono, chr_start, chr_stop, alarm, alm_min, alm_hour);
	--state signal
	signal state					: states := clock;

	--time in clock state
	signal timing_sec1			: integer := 0;
	signal timing_sec2			: integer := 0;
	signal timing_min1 			: integer := 0;
	signal timing_min2 			: integer := 0;
	signal timing_hour1 			: integer := 0;
	signal timing_hour2 			: integer := 0;

	--time in setting clock or alarm
	signal timing_set_alarm_min1			: integer := 0;
	signal timing_set_alarm_min2 			: integer := 0;
	signal timing_set_alarm_hour1 		: integer := 0;
	signal timing_set_alarm_hour2 		: integer := 0;
	signal timing_set_clk_min1				: integer := 0;
	signal timing_set_clk_min2 			: integer := 0;
	signal timing_set_clk_hour1 			: integer := 0;
	signal timing_set_clk_hour2 			: integer := 0;

	--time in chronometer
	signal timing_chrono_mili1			: integer := 0;
	signal timing_chrono_mili2			: integer := 0;
	signal timing_chrono_sec1			: integer := 0;
	signal timing_chrono_sec2			: integer := 0;
	signal timing_chrono_min1			: integer := 0;
	signal timing_chrono_min2			: integer := 0;

	--setting min or hour of clock time
	signal set_min			: std_logic := '0';
	signal set_hour		: std_logic := '0';

	--setting min or hour of alarm time
	signal set_alm_min	: std_logic := '0';
	signal set_alm_hour	: std_logic := '0';

	--chronometer start signal
	signal chrono_start	: std_logic := '0';

	-- clock display
	signal display_clk_sec1			: std_logic_vector(6 downto 0);
	signal display_clk_sec2			: std_logic_vector(6 downto 0);
	signal display_clk_min1			: std_logic_vector(6 downto 0);
	signal display_clk_min2			: std_logic_vector(6 downto 0);
	signal display_clk_hour1		: std_logic_vector(6 downto 0);
	signal display_clk_hour2		: std_logic_vector(6 downto 0);

	--setting clock display
	signal display_set_clk_min1		: std_logic_vector(6 downto 0);
	signal display_set_clk_min2		: std_logic_vector(6 downto 0);
	signal display_set_clk_hour1		: std_logic_vector(6 downto 0);
	signal display_set_clk_hour2		: std_logic_vector(6 downto 0);

	--chronometer display
	signal display_chrono_mili1		: std_logic_vector(6 downto 0);
	signal display_chrono_mili2		: std_logic_vector(6 downto 0);
	signal display_chrono_sec1			: std_logic_vector(6 downto 0);
	signal display_chrono_sec2			: std_logic_vector(6 downto 0);
	signal display_chrono_min1			: std_logic_vector(6 downto 0);
	signal display_chrono_min2			: std_logic_vector(6 downto 0);

	--setting alarm display
	signal display_set_alarm_min1			: std_logic_vector(6 downto 0);
	signal display_set_alarm_min2			: std_logic_vector(6 downto 0);
	signal display_set_alarm_hour1		: std_logic_vector(6 downto 0);
	signal display_set_alarm_hour2		: std_logic_vector(6 downto 0);

	--alarm and clock
	signal clk 				: std_logic :='0';

	--high frequency clock
	signal chronoclk 		: std_logic :='0';
	
begin

	--states
	States_process: process(chronoclk)
	begin
		if rising_edge(chronoclk) then
			case state is
				when clock =>
					if switch_mode = '0' then
						state <= chrono;
					elsif operate <= '0' then
						state <= clk_min;
					else
						state <= clock;
					end if;
					
				when clk_min =>
					if operate = '0' then
						state <= clk_hour;
					else
						state <= clk_min;
					end if;
					
				when clk_hour =>
					if operate = '0' then
						state <= clock;
					else
						state <= clk_hour;
					end if;
					
				when chrono =>
					if switch_mode = '0' then
						state <= alarm;
					elsif operate = '0' then
						state <= chr_start;
					else
						state <= chrono;
					end if;
					
				when chr_start =>
					if operate = '0' then
						state <= chr_stop;
					else
						state <= chr_start;
					end if;
					
				when chr_stop =>
					if operate = '0' then
						state <= chrono;
					else
						state <= chr_stop;
					end if;
					
				when alarm =>
					if switch_mode = '0' then
						state <= clock;
					elsif operate = '0' then
						state <= alm_min;
					else
						state <= alarm;
					end if;
					
				when alm_min =>
					if operate = '0' then
						state <= alm_hour;
					else
						state <= alm_min;
					end if;
						
				when alm_hour =>
					if operate = '0' then
						state <= alarm;
					else
						state <= alm_hour;
					end if;
			end case;
		end if;
	end process states_process;
	
	--state behavior
	displays: process(state, chronoclk)
	begin
		if rising_edge(chronoclk) then
			case state is
				when clock => --display clock time
					display_sec1 <= display_clk_sec1;
					display_sec2 <= display_clk_sec2;
					display_min1 <= display_clk_min1;
					display_min2 <= display_clk_min2;
					display_hour1 <= display_clk_hour1;
					display_hour2 <= display_clk_hour2;
					set_min <= '0';
					set_hour <= '0';
				when clk_min => -- display min set
					display_min1 <= display_set_clk_min1;
					display_min2 <= display_set_clk_min2;
					display_sec1 <= display_clk_sec1;
					display_sec2 <= display_clk_sec2;
					display_hour1 <= display_clk_hour1;
					display_hour2 <= display_clk_hour2;
					set_min <= '1';
					set_hour <= '0';
				when clk_hour => -- display hour set
					display_hour1 <= display_set_clk_hour1;
					display_hour2 <= display_set_clk_hour2;
					display_sec1 <= display_clk_sec1;
					display_sec2 <= display_clk_sec2;
					display_min1 <= display_clk_min1;
					display_min2 <= display_clk_min2;
					set_hour <= '1';
					set_min <= '0';
				when chrono => -- display chronometer
					display_sec1 <= "1000000";
					display_sec2 <= "1000000";
					display_min1 <= "1000000";
					display_min2 <= "1000000";
					display_hour1 <= "1000000";
					display_hour2 <= "1000000";
				when chr_start => -- start timing
					display_sec1 <= display_chrono_mili1;
					display_sec2 <= display_chrono_mili2;
					display_min1 <= display_chrono_sec1;
					display_min2 <= display_chrono_sec2;
					display_hour1 <= display_chrono_min1;
					display_hour2 <= display_chrono_min2;
					chrono_start <= '1';
				when chr_stop => --show stop time
					display_sec1 <= display_chrono_mili1;
					display_sec2 <= display_chrono_mili2;
					display_min1 <= display_chrono_sec1;
					display_min2 <= display_chrono_sec2;
					display_hour1 <= display_chrono_min1;
					display_hour2 <= display_chrono_min2;
					chrono_start <= '0';
				when alarm => -- display alarm time
					display_sec1 <= "1000000";
					display_sec2 <= "1000000";
					display_min1 <= display_set_alarm_min1;
					display_min2 <= display_set_alarm_min2;
					display_hour1 <= display_set_alarm_hour1;
					display_hour2 <= display_set_alarm_hour2;
					set_alm_min <= '0';
					set_alm_hour <= '0';
				when alm_min => --display set alarm
					display_sec1 <= "1000000";
					display_sec2 <= "1000000";
					display_min1 <= display_set_alarm_min1;
					display_min2 <= display_set_alarm_min2;
					display_hour1 <= display_set_alarm_hour1;
					display_hour2 <= display_set_alarm_hour2;
					set_alm_min <= '1';
					set_alm_hour <= '0';
				when alm_hour => -- display set alarm
					display_sec1 <= "1000000";
					display_sec2 <= "1000000";
					display_min1 <= display_set_alarm_min1;
					display_min2 <= display_set_alarm_min2;
					display_hour1 <= display_set_alarm_hour1;
					display_hour2 <= display_set_alarm_hour2;
					set_alm_hour <= '1';
					set_alm_min <= '0';
			end case;
		end if;
	end process displays;
	
	--clock and alarm
	timing: process(clk) --every 1 second.
	variable sec,min,hour 		: integer := 0;
	variable alarm_hour			: integer := 0;
	variable alarm_min			: integer := 0;
	begin
		if(clk'event and clk='1') then
			if set_min = '1' then
				if increase = '0' then
					min := min + 1;
					timing_set_clk_min1 <= min/10;
					timing_set_clk_min2 <= min rem 10;
				end if;
				timing_min1 <= min/10;
				timing_min2 <= min rem 10;
			elsif set_hour = '1' then
				if increase = '0' then
					hour := hour + 1;
					timing_set_clk_hour1 <= hour/10;
					timing_set_clk_hour2 <= hour rem 10;
				end if;
				timing_hour1 <= hour/10;
				timing_hour2 <= hour rem 10;
			end if;
			
			if min = alarm_min and hour = alarm_hour then
				buzz <= '1';
			else
				buzz <= '0';
			end if;
			
			sec := sec + 1;
			if(sec > 59) then
				sec	:= 0;
				min := min + 1;
				if(min > 59) then
					hour 	:= hour + 1;
					min 	:= 0;
					if(hour > 23) then
						hour := 0;
					end if;
				end if;
			end if;
			timing_sec1 <= sec/10;
			timing_sec2 <= sec rem 10;
			timing_min1 <= min/10;
			timing_min2 <= min rem 10;
			timing_hour1 <= hour/10;
			timing_hour2 <= hour rem 10;
		end if;
		if(clk'event and clk='0') then
			if set_alm_min = '1' then
				if increase = '0' then
					alarm_min := alarm_min + 1;
					timing_set_alarm_min1 <= alarm_min/10;
					timing_set_alarm_min2 <= alarm_min rem 10;
				end if;
			elsif set_alm_hour = '1' then
				if increase = '0' then
					alarm_hour := alarm_hour + 1;
					timing_set_alarm_hour1 <= alarm_hour/10;
					timing_set_alarm_hour2 <= alarm_hour rem 10;
				end if;
			end if;
		end if;
	end process timing;
	
	--chronometer
	chrono_timing: process(chronoclk, clk, chrono_start)
	variable mili,sec,min 	: integer := 0;
	begin
		if chrono_start = '1' then
			if(chronoclk'event and chronoclk='1') then
				mili := mili + 1;
				if(mili > 99) then
					mili	:= 0;
				end if;
				timing_chrono_mili1 <= mili/10;
				timing_chrono_mili2 <= mili rem 10;
			end if;
			if(clk'event and clk='1') then
				sec 	:= sec + 1;
				if(sec > 59) then
					sec 	:= 0;
					min 	:= min + 1;
				end if;
				timing_chrono_sec1 <= sec/10;
				timing_chrono_sec2 <= sec rem 10;
				timing_chrono_min1 <= min/10;
				timing_chrono_min2 <= min rem 10;
			end if;
		else
			mili 		:= mili;
			sec		:= sec;
			min		:= min;
			timing_chrono_mili1 	<= mili/10;
			timing_chrono_mili2 	<= mili rem 10;
			timing_chrono_sec1 	<= sec/10;
			timing_chrono_sec2 	<= sec rem 10;
			timing_chrono_min1 	<= min/10;
			timing_chrono_min2 	<= min rem 10;
			if operate = '0' then
				mili		:= 0;
				sec		:= 0;
				min		:= 0;
				timing_chrono_mili1 	<= mili/10;
				timing_chrono_mili2 	<= mili rem 10;
				timing_chrono_sec1 	<= sec/10;
				timing_chrono_sec2 	<= sec rem 10;
				timing_chrono_min1 	<= min/10;
				timing_chrono_min2 	<= min rem 10;
			end if;
		end if;
	end process chrono_timing;
	
	--nomal clk.
	--produces 1 Hz clock from 50MHz.
	clocking: process(clk_in)
	variable count : integer := 1;
	begin
		if(clk_in'event and clk_in = '1') then
			count := count + 1;
		--	if(count = 25000000) then
		-- set the count as a small number for testing
			if(count = 10) then
				clk <= not clk;
				count := 1;
			end if;
		end if;
	end process clocking;
	
	--high frequency clk.
	--produces 1000 Hz clock from 50MHz.
	chrono_clocking: process(clk_in)
	variable count : integer := 1;
	begin
		if(clk_in'event and clk_in='1') then
			count := count + 1;
		--	if(count = 25000) then
		-- set the count as a small number for testing
			if(count = 2) then
				chronoclk <= not chronoclk;
				count := 1;
			end if;
		end if;
	end process chrono_clocking;

	--display output:
	WITH timing_sec1 SELECT
		display_clk_sec1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_sec2 SELECT
		display_clk_sec2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_min1 SELECT
		display_clk_min1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;					
	WITH timing_min2 SELECT
		display_clk_min2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_hour1 SELECT
	display_clk_hour1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_hour2 SELECT
	display_clk_hour2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_alarm_min1 SELECT
display_set_alarm_min1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_alarm_min2 SELECT
display_set_alarm_min2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_alarm_hour1 SELECT
display_set_alarm_hour1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_alarm_hour2 SELECT
display_set_alarm_hour2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_clk_min1 SELECT
display_set_clk_min1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_clk_min2 SELECT
display_set_clk_min2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_clk_hour1 SELECT
display_set_clk_hour1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_set_clk_hour2 SELECT
display_set_clk_hour2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_chrono_mili1 SELECT
display_chrono_mili1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_chrono_mili2 SELECT
	display_chrono_mili2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_chrono_sec1 SELECT
	display_chrono_sec1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;					
	WITH timing_chrono_sec2 SELECT
	display_chrono_sec2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_chrono_min1 SELECT
	display_chrono_min1 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
	WITH timing_chrono_min2 SELECT
	display_chrono_min2 <= 	"1000000" WHEN 0,
									"1111001" WHEN 1,
									"0100100" WHEN 2,
									"0110000" WHEN 3,
									"0011001" WHEN 4,
									"0010010" WHEN 5,
									"0000010" WHEN 6,
									"1111000" WHEN 7,
									"0000000" WHEN 8,
									"0010000" WHEN 9,
									"0000000" WHEN OTHERS;
									

end design;