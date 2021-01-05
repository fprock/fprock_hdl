----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Christopher Jones
-- 
-- Create Date: 12/14/2020 07:08:15 PM
-- Design Name: 
-- Module Name: NEO-M9N_UART_SIM - Simulator
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use std.textio.all;

entity NEO_M9N_UART_SIM is
    Port (
        rx  :   in  std_logic;
        tx  :   out std_logic;
        tx_data : out std_logic_vector(7 downto 0)
        );
end NEO_M9N_UART_SIM;

architecture Simulator of NEO_M9N_UART_SIM is

component uart is 
GENERIC(
		clk_freq	:	INTEGER;	--frequency of system clock in Hertz
		baud_rate	:	INTEGER;		--data link baud rate in bits/second
		os_rate		:	INTEGER;			--oversampling rate to find center of receive bits (in samples per baud period)
		d_width		:	INTEGER; 			--data bus width
		parity		:	INTEGER;				--0 for no parity, 1 for parity
		parity_eo	:	STD_LOGIC);			--'0' for even, '1' for odd parity
	PORT(
		clk		:	IN	STD_LOGIC;										--system clock
		reset_n	:	IN	STD_LOGIC;										--ascynchronous reset
		tx_ena	:	IN	STD_LOGIC;										--initiate transmission
		tx_data	:	IN	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
		rx		:	IN	STD_LOGIC;										--receive pin
		rx_busy	:	OUT	STD_LOGIC;										--data reception in progress
		rx_error:	OUT	STD_LOGIC;										--start, parity, or stop bit error detected
		rx_data	:	OUT	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data received
		tx_busy	:	OUT	STD_LOGIC;  									--transmission in progress
		tx		:	OUT	STD_LOGIC);										--transmit pin
end component;

constant data_width : integer := 8; 
signal reset_sig : std_logic:='0';
signal tx_ena_sig : std_logic:='0';
signal tx_data_sig : std_logic_vector(data_width-1 downto 0);
signal rx_sig : std_logic := '1';
signal rx_busy_sig : std_logic;
signal rx_error_sig : std_logic;
signal rx_data_sig : std_logic_vector(data_width-1 downto 0) := x"00";
signal tx_busy_sig : std_logic;
signal tx_sig : std_logic;

component clock_trigger is 
    generic(
        DIVISOR     :   integer
        );
    port(
        clk_in      :   in std_logic;
        trigger     :   out std_logic
        );
end component;

signal trigger_sig : std_logic;

constant clock_period : time := 1 us;
signal sysclk : std_logic := '0';

begin


reset_sig <= '1' after clock_period;

clock : process(sysclk)
    begin
	sysclk <= not sysclk after clock_period / 2;
end process clock;

trig_gen : clock_trigger
    generic map(
        DIVISOR     =>  1_000_000
    )
    port map(
        clk_in      =>  sysclk,
        trigger     =>  trigger_sig
    );



file_feed : process(sysclk)
    file file_object : text open read_mode is "/home/chrispy/workspace/fprock_hdl/util/NEO_M9N_UART_STIMULUS.txt";
    variable mesg : line;
    variable count : integer := 0;
    variable hold : boolean := false;
    variable changed : boolean := false;
    variable dat : bit_vector(7 downto 0);
    variable ok : boolean;

    begin
   
        if rising_edge(sysclk) then
            if tx_busy_sig = '1' then
                tx_ena_sig <= '0';
            end if;
            
            if trigger_sig = '1' then
                hold := false;
            end if;
            
            if tx_busy_sig = '0' and not hold and not changed then
                if count = 0 then
                    readline(file_object, mesg);
                    count := (mesg.all'length + 1) / 9;
    
                end if;
                
                if mesg.all(1) = '#' then
                    hold := true;
                    count := 0;
                end if;
                
                if not hold then
                    read(mesg, dat, ok);
                    assert ok report "bad read" & mesg.all severity warning;
                    tx_data_sig <= To_StdLogicVector(dat);
                    tx_ena_sig <= '1';
                    changed := true;
                    count := count - 1;
                end if;
                
            elsif tx_busy_sig = '0' and changed then
                tx_ena_sig <= '0';
            else
                changed := false;    
            end if;
            
        end if;
    
    end process file_feed;
    
    
    
    module_uart : uart 
    generic map(
    clk_freq    => 1_000_000,
    baud_rate	=> 38_400,
    os_rate		=> 16,
    d_width		=> 8,
    parity		=> 0,
    parity_eo	=> '0'
    )
    port map(
    clk		=> sysclk,
    reset_n	=> reset_sig,
    tx_ena	=> tx_ena_sig,
    tx_data	=> tx_data_sig,
    rx		=> rx_sig,
        rx_busy	=> rx_busy_sig,
        rx_error=> rx_error_sig,
		rx_data	=> rx_data_sig,
		tx_busy	=> tx_busy_sig,
		tx		=> tx_sig
		);
    
    rx_sig <= rx;
    tx <= tx_sig;
    tx_data <= tx_data_sig;
    
end Simulator;
