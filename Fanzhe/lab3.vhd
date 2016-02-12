library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Lab3 is port (

      ledr: out std_logic_vector(1 downto 0); -- displays the operator and result on the other end 
      ledg: out std_logic_vector(0 downto 0);
      
      sw  :   in  std_logic_vector(3 downto 0); -- 4 dip switches
	 
);
end Lab3;

architecture SimpleCircuit of Lab3 is

-- signal declaration 
	signal Current, NextF: std_logic_vector(1 downto 0);
	signal Enable, Down, Up: std_logic_vector(0 downto 0);
	begin
		CurrentFloor <= sw(1 downto 0);
		NextFloor <= sw(3 downto 2);
		
		-- w is current[1]
		-- x is current[0]
		-- y is next[1]
		-- z is next[0]

		Down <= (Current(1) and not NextF and NextF(0)) or 
			(Current(1) and Current(0)and NextF(1) and not NextF(0));
		Up <= (not Current(1) and Current(0) and NextF(1)) or 
			(current(1) and not Current(0) and NextF(1) and NextF(0));
	-- motor = (w'x' + y'z')'   is this correct?  consider when Current == NextF
	-- down = w y' z + w x y z'
	-- up = w'xy + wx'yz
end SimpleCircuit
