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
      
      key              :   in  std_logic_vector( 3 downto 0); -- 4 push buttons
      sw               :   in  std_logic_vector(17 downto 0); -- 18 dip switches

      ledr             :   out std_logic_vector(8 downto 0); -- 18 red LEDs
      hex0, hex1, hex3 :   out std_logic_vector( 6 downto 0)  -- 7-segment desplays
);
end Lab2;

architecture SimpleCircuit of Lab2 is

--
-- In order to use the "SevenSegment" entity, we should declare it with first
-- 

   component SevenSegment port (
      dataIn      :  in    std_logic_vector(3 downto 0);
      blanking    :  in    std_logic;
      segmentsOut :  out   std_logic_vector(6 downto 0)
   );
   end component;
	
-- Create any signals, or temporary variables to be used
--
-- 
--  unsigned is a signal which can be used to perform math operations such as +, -, *
--  std_logic_vector is a signal which can be used for logic operations such as OR, AND, NOT, XOR
--
   signal operand1, operand2: std_logic_vector(7 downto 0); -- 8-bit intermediate signals (wires)
   signal R: std_logic_vector(11 downto 0); /-- output signal for the three 7segment displays
   signal S: std_logic_vector(1 downto 0); -- input signal represents operator
   
-- Here the circuit begins

begin

-- intermediate signal assignments

   operand1 <= sw(7 downto 0);  -- connect the lowest 4 switches to operand1
   operand2 <= sw(15 downto 8);  -- connect the highest 4 switches to operand2
   S <= sw(17 downto 16); -- connect switches to input operator signal
   
   -- concatenate for 12 bits
   operand1 <= "0000"&operand1;
   operand2 <= "0000"&operand2;
   

-- 2x1 multiplexer
   
with S select     -- depending on the operator input signal
	R <= A and B   			when "00",      
         A or B          	when "01",
		 A XOR B	        when "10",
		 std_logic_vector(unsigned(A) + unsigned(B))     when "11";         
-- signal is assigned to LED outputs

   ledr(7 downto  0) <= A;
   ledr(15 downto  8) <= B;
   
   -- light up LED to display operator
   ledr(17 downto 16) <= S;

	--R<=std_logic_vector(unsigned("0000"&A)+unsigned("0000"&B));
	R<= "0000"&A and "0000"&B;
	
-- signal is displayed on seven-segment. '0' is concatenated with signal to make a 4-bit input
-- instantiate instants of SevenSegment components
-- think of the instantiation as taking in those inputs
-- assuming that A(0) is the least sig bit

   Operand1_MSB_display: SevenSegment port map(A(7 downto 4), '0', hex5);
   Operand1_LSB_display: SevenSegment port map(A(3 downto 0), '0', hex4);
   Operand2_MSB_display: SevenSegment port map(A(7 downto 4), '0', hex7);
   Operand2_LSB_display: SevenSegment port map(A(3 downto 0), '0', hex6);
   
   R_ones: SevenSegment port map(R(3 downto 0), '0', hex0 ); -- A is diplayed on HEX0, blanking is disabled
   R_tens: SevenSegment port map(R(7 downto 4), '0', hex1 ); -- B is diplayed on HEX1, blanking is disabled
   R_hundreds: SevenSegment port map(R(11 downto 8), '0', hex2 ); -- S is diplayed on HEX3, blanking is disabled
	
   ledr(8 downto 0) <= R(8 downto 0); -- assign output to LEDs

end SimpleCircuit;
