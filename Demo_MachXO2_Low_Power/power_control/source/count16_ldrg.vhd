library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity cnter16 is
    port (	CLK	: in STD_LOGIC;
--		RST	: in STD_LOGIC;
		DIR	: in STD_LOGIC;
		COUNT 	: out STD_LOGIC);
end cnter16;

architecture cnter16_design of cnter16 is -- mux
	signal COUNTER1 	: STD_LOGIC_VECTOR(15 DOWNTO 0);
begin
 	cnt: process (CLK) 
	begin
--   		if RST = '0' then
--    			COUNTER1 <= (others => '0');
		if CLK='1' and CLK'event then
			if DIR = '1' then -- count up
				COUNTER1 <= COUNTER1 + 1;
			elsif DIR = '0' then -- count down
				COUNTER1 <= COUNTER1 - 1;
	        	end if;
		end if;
	end process;
	COUNT <= COUNTER1(15);
end cnter16_design;




library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity count16_ldrg is
    port (	CLK_OSC	: in STD_LOGIC;
--		RST	: in STD_LOGIC;
		DIR	: in STD_LOGIC;
		locked 	: out STD_LOGIC;
		Compare	: out STD_LOGIC;
		COUNT 	: out STD_LOGIC;
		Shiftout	: out STD_LOGIC);
end count16_ldrg;

architecture counter_ld_arch of count16_ldrg is
	component cnter16
	    port (	
			CLK	: in STD_LOGIC;
--			RST	: in STD_LOGIC;
			DIR	: in STD_LOGIC;
			COUNT 	: out STD_LOGIC);
	end component;

--	component Clock_PLL
--	PORT (
--		inclk0		: IN STD_LOGIC;
--		c0		: OUT STD_LOGIC;
--		locked		: OUT STD_LOGIC);
--	end component;


	signal CLK 	: STD_LOGIC;
	
-- Make the changes in order to change the resource utilization in the pattern.
-- Change 999 to the desired number of counters.
-- For example if you want 50 counters, then use (49 downto 0)

	signal COUNTER1_array 	: STD_LOGIC_VECTOR(9 DOWNTO 0); -- Change 999 to the desired number of counters. 
	signal ShiftReg		: STD_LOGIC_VECTOR(9 DOWNTO 0); -- Change 999 to the desired number of counters.

ATTRIBUTE SYN_KEEP : integer;
ATTRIBUTE SYN_KEEP OF COUNTER1_array, ShiftReg : SIGNAL IS 1;

--ATTRIBUTE OPT : string;
--ATTRIBUTE OPT OF COUNTER1_array, ShiftReg : SIGNAL IS "KEEP";

ATTRIBUTE NOMERGE : string;
ATTRIBUTE NOMERGE OF COUNTER1_array, ShiftReg : SIGNAL IS "ON";

--ATTRIBUTE NOCLIP : string;
--ATTRIBUTE NOCLIP OF COUNTER1_array, ShiftReg : SIGNAL IS "ON";

begin

CLK <= CLK_OSC;
	-- PLL
--	PLL3: Clock_PLL port map (
--		inclk0 => CLK_OSC, 
--		c0 => CLK, 
--		locked => locked);


	-- Counters
	gen: for C1 in 0 to 9 generate -- Change 999 to the desired number of counters.
		inst3: cnter16 port map (
			CLK => CLK, 
--			RST => RST, 
			DIR => ShiftReg(C1), 
			COUNT => COUNTER1_array(C1));
	end generate;	
	COUNT <= COUNTER1_array(0); -- Make sure something is toggling

	-- Shift Reg
 	shft: process (CLK) 
	begin
		if CLK='1' and CLK'event then
			ShiftReg <= ShiftReg(8 DOWNTO 0) & not ShiftReg(0); -- Change 998 to the desired number of counters minus 2.
--
        	end if;
	end process;
	Shiftout <= ShiftReg(9); -- Change 999 to the desired number of counters.

	-- Compare Data
 	comp: process (CLK) 
	begin
		if CLK='1' and CLK'event then
			if (COUNTER1_array = ShiftReg)  then
				Compare <= '1';
			else
				Compare <= '0';
			end if;
        end if;
	end process;


end counter_ld_arch;


