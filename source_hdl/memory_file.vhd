----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Christopher Jones
-- 
-- Create Date: 01/05/2021 12:14:34 AM
-- Design Name: 
-- Module Name: ram_bank - Behavioral
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

entity ram_bank is
    generic(
        BLOCK_WIDTH         :   INTEGER     := 8; -- how wide is each data block (number of bits)
        BANK_WIDTH          :   INTEGER     := 16; -- number of columns
        BANK_HIGHT          :   INTEGER     := 16;   -- number of rows
        ROW_ADDR_WIDTH      :   INTEGER     := 4; -- how wide is the address line in bits
        COL_ADDR_WIDTH      :   INTEGER     := 4
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

end ram_bank;

architecture Behavioral of ram_bank is

type BANK is array (0 to BANK_HIGHT-1, 0 to BANK_WIDTH-1) of std_logic_vector(BLOCK_WIDTH -1 downto 0);
signal mem : BANK := (others => (others => (others => '0')));

begin

process(clk)
begin
    if reset = '0' then
        mem <= (others => (others => (others => '0'))); 
    elsif rising_edge(clk) then
        if wena = '1' then
            mem((to_integer(unsigned(rowaddr))),(to_integer(unsigned(coladdr)))) <= wdata;
        end if;
    end if;
end process;

rdata <= mem((to_integer(unsigned(rowaddr))),(to_integer(unsigned(coladdr)))) when rena = '1' else (others => '0');

end Behavioral;
