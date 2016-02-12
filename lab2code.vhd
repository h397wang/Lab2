library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- 7-segment display driver. It displays a 4-bit number on 7-segments 
-- This is created as an entity so that it can be reused many times easily
--

entity SevenSegment is port (
   
   dataIn      :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   blanking    :  in  std_logic;                      -- This bit turns off all segments
   
   segmentsOut :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end SevenSegment;

architecture Behavioral of SevenSegment is

-- 
-- The following statements convert a 4-bit input, called dataIn to a pattern of 7 bits
-- The segment turns on when it is '0' otherwise '1'
-- The blanking input is added to turns off the all segments
--

begin

   with blanking & dataIn select --  gfedcba        b3210      -- D7S
      segmentsOut(6 downto 0) <=    "1000000" when "00000",    -- [0]
                                    "1111001" when "00001",    -- [1]
                                    "0100100" when "00010",    -- [2]      +---- a ----+
                                    "0110000" when "00011",    -- [3]      |           |
                                    "0011001" when "00100",    -- [4]      |           |
                                    "0010010" when "00101",    -- [5]      f           b
                                    "0000010" when "00110",    -- [6]      |           |
                                    "1111000" when "00111",    -- [7]      |           |
                                    "0000000" when "01000",    -- [8]      +---- g ----+
                                    "0010000" when "01001",    -- [9]      |           |
                                    "0001000" when "01010",    -- [A]      |           |
                                    "0000011" when "01011",    -- [b]      e           c
                                    "1000110" when "01100",    -- [c]      |           |
                                    "0100001" when "01101",    -- [d]      |           |
                                    "0000110" when "01110",    -- [E]      +---- d ----+
                                    "0001110" when "01111",    -- [F]
                                    "1111111" when others;     -- [ ]

end Behavioral;

--------------------------------------------------------------------------------
-- Main entity
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Lab2 is port (

      ledr : out std_logic_vector(17 downto 0); -- displays the operator and result on the other end 
      sw  :   in  std_logic_vector(17 downto 0); -- 18 dip switches
	  hex6,hex7		:  	out std_logic_vector(6 downto 0); -- display for operand 2
      hex4,hex5 	:   out std_logic_vector(6 downto 0); -- display for operand 1
      hex0, hex1, hex2 :   out std_logic_vector(6 downto 0)  -- display for the result
);
end Lab2;

architecture SimpleCircuit of Lab2 is

--
-- In order to use the "SevenSegment" entity, we have to use this declaration
-- It's signals have to correspond to the entity declared above
-- 

   component SevenSegment port (
      dataIn      :  in    std_logic_vector(3 downto 0);
      blanking    :  in    std_logic;
      segmentsOut :  out   std_logic_vector(6 downto 0)
   );
   end component;
	
-- Create any signals, or temporary variables to be used
-- Unsigned is a signal which can be used to perform math operations such as +, -, *
-- std_logic_vector is a signal which can be used for logic operations such as OR, AND, NOT, XOR
--
   signal operand1, operand2: std_logic_vector(7 downto 0); -- 8-bit intermediate signals (wires)
   signal operand1_mod, operand2_mod: std_logic_vector(11 downto 0);
   signal result: std_logic_vector(11 downto 0); -- output signal for the three 7segment displays
   signal operator: std_logic_vector(1 downto 0); -- input signal represents operator
  

begin

-- Intermediate signal assignments

   operand1 <= sw(7 downto 0);  -- connect the lowest 8 switches to operand1
   operand2 <= sw(15 downto 8);  -- connect the highest 8 switches to operand2
   operator <= sw(17 downto 16); -- connect 2 switches to input operator signal
   
   -- concatenate for 12 bits
   -- apparently you can't just re-assign the signal variable in this case because the signal vector
   -- is declared to be a fixed length
   operand1_mod <= "0000"&operand1;
   operand2_mod <= "0000"&operand2;
   
-- implementing a multiplexer, dependent on the operator input signal
   
with operator select    
	result <= 	operand1_mod and operand2_mod			when "00",      
				operand1_mod or operand2_mod          	when "01",
				operand1_mod xor operand2_mod	        when "10",
				std_logic_vector(unsigned(operand1_mod) + unsigned(operand2_mod)) when "11"; 
				-- note that the + operator only supports unsigned vector types
				-- the input signals are cast to type, then cast back to std_logic_vector
		 
   
-- light up LED to display operator
   ledr(17 downto 16) <= operator;
   
-- light up the 9 red LEDs to display the result 
   ledr(11 downto 0) <= result(11 downto 0); -- s was the source of error

-- Instantiate instants of each SevenSegment components
-- Think of the instantiation as a constructor that takes in signal inputs and maps it to the corresponding
-- "member" signals within that component

   Operand1_MSD_display: SevenSegment port map(operand1(7 downto 4), '0', hex5);
   Operand1_LSD_display: SevenSegment port map(operand1(3 downto 0), '0', hex4);
   
   Operand2_MSD_display: SevenSegment port map(operand2(7 downto 4), '0', hex7);
   Operand2_LSD_display: SevenSegment port map(operand2(3 downto 0), '0', hex6);
   
   
   result_MSD: SevenSegment port map(result(11 downto 8), not result(8), hex2 ); --
   result_2ndD: SevenSegment port map(result(7 downto 4), '0', hex1 ); -- display the second digit
   result_LSD: SevenSegment port map(result(3 downto 0), '0', hex0 ); -- dispaly the least significant digit
  
end SimpleCircuit;