----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Christopher Jones
-- 
-- Create Date: 01/04/2021 06:16:27 PM
-- Design Name: 
-- Module Name: gps_datahandler_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 2019.2
-- Description: 
-- 
-- Dependencies: NEO-M9N_UART_SIM.vhd
--              gps_datahandler.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library libfprock;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gps_datahandler_sim is

end gps_datahandler_sim;

architecture Behavioral of gps_datahandler_sim is

signal sysclk : std_logic := '0';
constant CLOCK_PERIOD : time := 10 ns;

signal gpsrx : std_logic;
signal gpstx : std_logic;

signal dhrst : std_logic;
signal dhtxena : std_logic;
signal dhtxdata : std_logic_vector(7 downto 0);
signal dhrxbusy : std_logic;
signal dhrxerr : std_logic;
signal dhrxdata : std_logic_vector(7 downto 0);
signal dhtxbusy : std_logic;

signal gpstxdata : std_logic_vector(7 downto 0);
signal gpstxdata_last : std_logic_vector(7 downto 0);


begin

dhrst <= '0', '1' after 10 ns;
dhtxena <= '0';
dhtxdata <= x"00";


BOARD_CLOCK : process(sysclk)
    begin
	sysclk <= not sysclk after clock_period / 2;
end process BOARD_CLOCK;

GPS_SIMULATOR : ENTITY libfprock.NEO_M9N_UART_SIM(Simulator)
    port map( 
        rx => gpsrx,
        tx => gpstx,
        tx_data => gpstxdata
        );
        
DUT : ENTITY libfprock.gps_datahandler(Behavioral)
    port map(
        rx => gpstx,
        tx => gpsrx,
        sysclk => sysclk,
        
        reset_uart        => dhrst,
        tx_ena_uart       => dhtxena,						
		tx_data_uart      => dhtxdata,
		rx_busy_uart      => dhrxbusy,
		rx_error_uart     => dhrxerr,
		rx_data_uart      => dhrxdata,
		tx_busy_uart      => dhtxbusy
		);


CHECKER : process(dhrxbusy)
    variable txdata_hold : std_logic_vector(7 downto 0) := x"00";
    begin
    if rising_edge(dhrxbusy) then
        txdata_hold := gpstxdata;
         assert to_integer(unsigned(dhrxdata xor gpstxdata_last)) = 0
    report "***** REVIEVED DATA DOES NOT MATCH TRANSMITTED DATA! *****"
    severity warning;
    end if;
    if falling_edge(dhrxbusy)then
        gpstxdata_last <= txdata_hold;
       
    end if;

end process CHECKER;


    
end Behavioral;
