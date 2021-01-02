----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2020 08:01:04 PM
-- Design Name: 
-- Module Name: clock_divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
	Generic (
		DIVISOR : 	integer := 20_000_000
		);
	Port (
		mclk	:	in	std_logic;
		sclk	:	out	std_logic
		);
end clock_divider;

architecture Behavioral of clock_divider is
signal sclki : std_logic := '0';

begin

	process (mclk)
	variable count : integer range 0 to DIVISOR/2 := 0;
	begin
		if(rising_edge(mclk)) then
			if(count = (DIVISOR/2)-1) THEN
				sclki <= not sclki;
				count := 0;
			else
				count := count + 1;
			end if;
		end if;
	end process;
	sclk <= sclki;
end Behavioral;
