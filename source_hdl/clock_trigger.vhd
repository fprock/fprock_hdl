----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Christopher Jones
-- 
-- Create Date: 01/02/2021 01:53:27 PM
-- Design Name: 
-- Module Name: clock_trigger - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 2019.2
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

entity clock_trigger is
    Generic(
        DIVISOR     :   integer := 1_000_000
        );
    Port(
        clk_in      :   in std_logic;
        trigger     :   out std_logic
        );
end clock_trigger;

architecture Behavioral of clock_trigger is
signal triggeri : std_logic := '0';
begin
    
    process(clk_in)
        variable count : integer range 0 to (DIVISOR + 1):= 0;
    begin
        if(rising_edge(clk_in)) then
            count := count + 1;
            if(count = DIVISOR) then
                triggeri <= '1';
            elsif(count > DIVISOR) then
                triggeri <= '0';
                count := 0;
            end if;
            
        end if;
        trigger <= triggeri;
    end process;


end Behavioral;
