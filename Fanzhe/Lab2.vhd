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
      
      sw               :   in  std_logic_vector(17 downto 0); -- 18 dip switches
      
      ledr             :   out std_logic_vector(17 downto 0); -- 18 red LEDs
      hex0, hex1, hex2, hex4, hex5, hex6, hex7 :   out std_logic_vector( 6 downto 0)  -- 7-segment displays
);
end Lab2;

architecture SimpleCircuit of Lab2 is

--
-- In order to use the "SevenSegment" entity, we should declare it first
-- 

   component SevenSegment port (
      dataIn      :  in    std_logic_vector(3 downto 0);
      blanking    :  in    std_logic;
      segmentsOut :  out   std_logic_vector(6 downto 0)
   );
   end component;

-- Create any signals, or temporary variables to be used
--
-- Note that there are two basic types and mixing them is difficult
--  unsigned is a signal which can be used to perform math operations such as +, -, *
--  std_logic_vector is a signal which can be used for logic operations such as OR, AND, NOT, XOR
--
   signal A, B: std_logic_vector(7 downto 0);
   signal R: std_logic_vector(11 downto 0);
   signal S: std_logic_vector(1 downto 0);

-- Here the circuit begins

begin

-- intermediate signal assignments

   A <= sw(7 downto 0);    -- connect the lowest 8 switches to A
   B <= sw(15 downto 8);   -- connect the next 8 switches to B
   S <= sw(17 downto 16);  -- connect the highest 2 switches to S
   
-- multiplexer
   
   with S select
      R   <=   "0000"&A and "0000"&B    when "00",
               "0000"&A or  "0000"&B    when "01",
               "0000"&A xor "0000"&B    when "10",
			   std_logic_vector(unsigned("0000"&A)+unsigned("0000"&B)) when others;
           
-- signal is assigned to LED

   ledr(8 downto 0)    <=  R(8 downto 0);
   ledr(17 downto 16)  <=  S;

-- signal is sidplayed on seven-segment. '0' is concatenated with signal to make a 4-bit input

   D7SH0: SevenSegment port map(R(3 downto 0), '0', hex0 );        -- R(3 downto 0) is diplayed on HEX0, blanking is disabled
   D7SH1: SevenSegment port map(R(7 downto 4), '0', hex1 );        -- R(7 downto 4) is diplayed on HEX1, blanking is disabled
   D7SH2: SevenSegment port map(R(11 downto 8), not R(8), hex2);   -- R(11 downto 8) is displayed on HEX2, blanking is disabled when no carry
   D7SH4: SevenSegment port map(A(3 downto 0), '0', hex4 );        -- A(3 downto 0) is diplayed on HEX4, blanking is disabled
   D7SH5: SevenSegment port map(A(7 downto 4), '0', hex5 );        -- A(7 downto 4) is diplayed on HEX5, blanking is disabled
   D7SH6: SevenSegment port map(B(3 downto 0), '0', hex6 );        -- B(3 downto 0) is diplayed on HEX6, blanking is disabled
   D7SH7: SevenSegment port map(B(7 downto 4), '0', hex7 );        -- B(7 downto 4) is diplayed on HEX7, blanking is disabled

end SimpleCircuit;
