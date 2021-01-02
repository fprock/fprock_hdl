----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Christopher Jones
-- 
-- Create Date: 11/26/2020 06:04:55 PM
-- Design Name: 
-- Module Name: display_driver - Behavioral
-- Project Name: 
-- Target Devices: Digilent Basys3
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_driver is
	Port (	dat_in		:	in std_logic_vector(15 downto 0);
			clk_in		:	in std_logic;
			seg			:	out	std_logic_vector(0 to 6);
			dp			:	out  STD_LOGIC;
			an			:	out  STD_LOGIC_VECTOR(3 downto 0)
			 );
end display_driver;

architecture Behavioral of display_driver is

type lcd_output is array (0 to 15) of std_logic_vector(0 to 6);
signal lcd_output_lut : lcd_output := (
-- "CA CB CC CD CE CF CG"
--driven low
   "0000001",   -- 0
   "1001111",   -- 1
   "0010010",   -- 2
   "0000110",   -- 3
   "1001100",   -- 4
   "0100100",   -- 5
   "0100000",   -- 6
   "0001111",   -- 7
   "0000000",   -- 8
   "0001100",   -- 9
   
   "0001000",   -- A
   "1100000",   -- b
   "0110001",   -- C
   "1000010",   -- d
   "0110000",   -- E
   "0111000"   	-- F
   
);

type dp_mask is array (0 to 3) of std_logic;
signal decimal_pt : dp_mask := (
	'1',
	'1',
	'1',
	'1'
);

type anode_mask is array (0 to 3) of std_logic_vector(3 downto 0);
signal display : anode_mask := (
	"1110",
	"1101",
	"1011",
	"0111"
);

signal msb_msnib, msb_lsnib, lsb_msnib, lsb_lsnib : std_logic_vector(0 to 6);
signal position : integer := 0;

type output_buffer is array (0 to 3) of std_logic_vector(0 to 6);
signal buff : output_buffer := (others=>(others=>'0'));

begin

	
	buff(0) <= lcd_output_lut(to_integer(unsigned(dat_in(3 downto 0))));
	buff(1) <= lcd_output_lut(to_integer(unsigned(dat_in(7 downto 4))));
	buff(2) <= lcd_output_lut(to_integer(unsigned(dat_in(11 downto 8))));
	buff(3) <= lcd_output_lut(to_integer(unsigned(dat_in(15 downto 12))));
	
	seg <= buff(position);
	dp	<= decimal_pt(position);
	an <= display(position);
	
	
	pos : process(clk_in)
		variable position1 : integer := 0;
		BEGIN
			IF (rising_edge(clk_in)) THEN
				position1 := position1 + 1;
				IF position1 = 4 THEN
					position1 := 0;
				ELSE
					position1 := position1;
				END IF;
			END if;
			position <= position1;
		END PROCESS;
		 
end Behavioral;
