----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Christopher Jones
-- 
-- Create Date: 01/04/2021 05:30:37 PM
-- Design Name: 
-- Module Name: gps_datahandler - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 2019.2
-- Description: 
-- 
-- Dependencies: uart.vhdl
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library libfprock;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gps_datahandler is
    Port ( rx           : in STD_LOGIC;
           tx           : out STD_LOGIC;
           sysclk       : in STD_LOGIC;
           
           reset        :  in std_logic;
           tx_ena_uart       :	IN	STD_LOGIC;										
		   tx_data_uart      :	IN	STD_LOGIC_VECTOR(7 DOWNTO 0);  
		   rx_busy_uart      :	OUT	STD_LOGIC;
		   rx_error_uart     :	OUT	STD_LOGIC;
		   rx_data_uart      :	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		   tx_busy_uart      :	OUT	STD_LOGIC
		   
           
           );
end gps_datahandler;

architecture Behavioral of gps_datahandler is

--***************************************************************************************************************
--**********    UART COMPONENT DEFINITION   *****************************************************************
component uart is 
    GENERIC(
		  clk_freq    :	INTEGER;	--frequency of system clock in Hertz
		  baud_rate   :	INTEGER;		--data link baud rate in bits/second
		  os_rate     :	INTEGER;			--oversampling rate to find center of receive bits (in samples per baud period)
		  d_width     :	INTEGER; 			--data bus width
		  parity      :	INTEGER;				--0 for no parity, 1 for parity
		  parity_eo   :	STD_LOGIC);			--'0' for even, '1' for odd parity
	PORT(
		  clk         :	IN	STD_LOGIC;										--system clock
		  reset_n     :	IN	STD_LOGIC;										--ascynchronous reset
		  tx_ena      :	IN	STD_LOGIC;										--initiate transmission
		  tx_data     :	IN	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
		  rx          :	IN	STD_LOGIC;										--receive pin
		  rx_busy     :	OUT	STD_LOGIC;										--data reception in progress
		  rx_error    :	OUT	STD_LOGIC;										--start, parity, or stop bit error detected
		  rx_data     :	OUT	STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);	--data received
		  tx_busy     :	OUT	STD_LOGIC;  									--transmission in progress
		  tx          :	OUT	STD_LOGIC);										--transmit pin
end component;

constant    data_width      : integer := 8;

signal      tx_ena_sig      : std_logic;
signal      tx_data_sig     : std_logic_vector(data_width-1 downto 0);
signal      rx_busy_sig     : std_logic;
signal      rx_error_sig    : std_logic;
signal      rx_data_sig     : std_logic_vector(data_width-1 downto 0);
signal      tx_busy_sig     : std_logic;

--***************************************************************************************************************
--**********    RAM COMPONENT DEFINITION    *****************************************************************
component ram_bank is 
    generic(
        BLOCK_WIDTH         :   INTEGER; -- how wide is each data block (number of bits)
        BANK_WIDTH          :   INTEGER; -- number of columns
        BANK_HIGHT          :   INTEGER;   -- number of rows
        ROW_ADDR_WIDTH      :   INTEGER; -- how wide is the address line in bits
        COL_ADDR_WIDTH      :   INTEGER
        );
    port(
        clk : in std_logic;
        rowaddr : in std_logic_vector(ROW_ADDR_WIDTH -1 downto 0);
        coladdr : in std_logic_vector(COL_ADDR_WIDTH -1 downto 0);
        wena : in std_logic;
        rena : in std_logic;
        wdata : in std_logic_vector(BLOCK_WIDTH -1 downto 0);
        rdata : out std_logic_vector(BLOCK_WIDTH -1 downto 0);
        reset : in std_logic              
        );
end component;

constant MEM_BLOCK_WIDTH : integer := 8;
constant MEM_BANK_WIDTH : integer := 128;
constant MEM_BANK_HIGHT : integer := 16;
constant MEM_ROW_ADDR_WIDTH : integer := 4;
constant MEM_COL_ADDR_WIDTH : integer := 7;


signal memclk : std_logic;
signal memrowaddr : std_logic_vector(MEM_ROW_ADDR_WIDTH -1 DOWNTO 0) := (others => '0');
signal memcoladdr : std_logic_vector(MEM_COL_ADDR_WIDTH -1 DOWNTO 0) := (others => '0');
signal memwena : std_logic := '1';
signal memrena : std_logic := '0';
signal memwdata : std_logic_vector(MEM_BLOCK_WIDTH -1 downto 0);
signal memrdata : std_logic_vector(MEM_BLOCK_WIDTH -1 downto 0);
signal memreset : std_logic;

-----------------------------------------------------------------------------------------------------------------
begin -----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

--***************************************************************************************************************
--**********    RAM COMPONENT INSTANTIATION   *****************************************************************
uart_data_buffer : ram_bank
    generic map(
        BLOCK_WIDTH         => MEM_BLOCK_WIDTH, -- how wide is each data block (number of bits)
        BANK_WIDTH          => MEM_BANK_WIDTH, -- number of columns
        BANK_HIGHT          => MEM_BANK_HIGHT,   -- number of rows
        ROW_ADDR_WIDTH      => MEM_ROW_ADDR_WIDTH, -- how wide is the address line in bits
        COL_ADDR_WIDTH      => MEM_COL_ADDR_WIDTH
    )
    port map(
        clk => memclk,
        rowaddr => memrowaddr,
        coladdr => memcoladdr,
        wena => memwena,
        rena => memrena,
        wdata => memwdata,
        rdata => memrdata,
        reset => memreset 
    );
    
--***************************************************************************************************************
--**********    RAM COMPONENT INSTANTIATION   *****************************************************************
module_uart : uart 
    generic map(
        clk_freq    => 100_000_000,
        baud_rate	=> 38_400,
        os_rate		=> 16,
        d_width		=> 8,
        parity		=> 0,
        parity_eo	=> '0'
        )
    port map(
        clk         => sysclk,
        reset_n	    => reset,
        tx_ena      => tx_ena_sig,
        tx_data     => tx_data_sig,
        rx          => rx,
        rx_busy     => rx_busy_sig,
        rx_error    => rx_error_sig,
		rx_data     => rx_data_sig,
		tx_busy     => tx_busy_sig,
		tx		    => tx
		);

--***************************************************************************************************************
--**********    SIGNAL MAPPING   *****************************************************************		

    tx_ena_sig <= tx_ena_uart;										
	tx_data_sig <= tx_data_uart;  	
    
    rx_busy_uart <= rx_busy_sig;
    rx_error_uart <= rx_error_sig;
    rx_data_uart <= rx_data_sig;
	tx_busy_uart <= tx_busy_sig;
	
	memclk <= sysclk;
	memreset <= reset;
	

memory_controller : process(memclk)
begin
    if rising_edge(memclk) then
        if ((to_integer(unsigned(memcoladdr))) = MEM_BANK_WIDTH) then
            memcoladdr <= "0000000";
        else
            memcoladdr <= memcoladdr + "0000001";
        end if;
    end if;
end process memory_controller;
	
end Behavioral;
