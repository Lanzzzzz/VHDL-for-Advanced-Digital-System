library ieee; use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY TxSystemRTL IS 
	PORT( clock, reset,odd_noteven, write_l : IN STD_LOGIC; 
			Datain : IN std_logic_vector (7 downto 0);
			state, n_state : buffer std_logic_vector (2 downto 0);
			T, B : buffer std_logic_vector (5 downto 0);
			busy, TxData : OUT STD_LOGIC
			); 
END TxSystemRTL; 

ARCHITECTURE RTL OF TxSystemRTL IS
	constant CLKSPERBIT : integer := 18;
	constant	BITSPERCHAR : integer := 11;
	--signal BT : integer range 0 to 18;
	--signal BC : integer range 0 to 11;
	signal BT : integer :=0;
	signal BC : integer :=0;
	signal SR : std_logic_vector (10 downto 0);
	signal parity : std_logic;
	
	signal BT_n : integer :=0;
	signal BC_n : integer :=0;
	
	
-- Declare a state type
type state_type is (IDLE, S1, S2);
-- Declare current and next state variables .
-- Init to NS_GREEN since we don ’t have a reset state .
signal current_state , next_state : state_type := IDLE ;
BEGIN
-- the state information .
parity <= odd_noteven XOR (datain(7) xor datain(6) xor datain(5) xor datain(4) xor datain(3) xor datain(2) xor datain(1) xor datain(0)); 
process ( clock )
begin
	if (clock'event and clock='1') then
		if (reset = '1') then
		current_state <= IDLE ;
		else
		current_state <= next_state ;
		end if; 
	end if ;
end process ;
-- Process to determine next state

process ( write_l, BT, BC)
begin
	case (current_state) is
		when IDLE => if (write_l = '1') then 
								next_state <= S1; 
						else next_state <= IDLE;
						end if;
						
		when S1 => next_state <= S2;
		
		when S2 =>  if (BT = 0) then 
							next_state <= IDLE;  
						else next_state <= S2;
						end if;
						
--		when S3 =>  if (BC = 0) then 
--							next_state <= IDLE; 
--						else next_state <= S2;
--					   end if;
end case ;
end process ;
-- Conditional assignments for outputs:
process (current_state)
begin 
	case (current_state) is
	when IDLE => 
		busy <= '0';
	--	BC_n <= BITSPERCHAR;
		BT_n <= CLKSPERBIT - 2;
		SR <= '1'& SR(BITSPERCHAR-1 downto 1);
		
	When S1 =>
		busy <= '1';
		SR <= '1' & parity & Datain & '0';
		
	when S2 =>
		BT_n <= BT_n -1;
		if (BT_n = 0) then
			BT	<=0; 
		--	BC_n <= BC_n - 1; 
		--	SR <= '1'& SR(BITSPERCHAR-1 downto 1);
		end if;
--	when S3 =>
--		if (BC_n /= 0) then BT_n <= CLKSPERBIT - 2;
--		else BC <= 0;
--		end if;
	end case;
end process;

TxData <= SR(0);

state <= "001"	when (Current_state = IDLE ) else
			"010"	when (Current_state = S1) else
			"011"	when (Current_state = S2) else
		--	"100"	when (Current_state = S3) else 
			"111";
			
n_state <= "001"	when (next_state = IDLE ) else
			"010"	when (next_state = S1) else
			"011"	when (next_state = S2) else
		--	"100"	when (next_state = S3) else 
			"111";
			
--T<= std_logic_vector(to_unsigned(Test, 6));
B<= std_logic_vector(to_unsigned(BT_n, 6));
END RTL ;