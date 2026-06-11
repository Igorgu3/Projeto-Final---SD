library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity comparador is
	generic (W: positive := 4);
    port (
        a       : in  std_logic_vector (W-1 downto 0);          
        b       : in  std_logic_vector (W-1 downto 0);            
 		maior, menor, igual    : out  std_logic
    );
end entity comparador;


architecture behavioral of comparador is
    begin
	    maior <= '1' when unsigned(a) > unsigned(b) else '0';
	    igual <= '1' when unsigned(a) = unsigned(b) else '0';
	    menor <= '1' when unsigned(a) < unsigned(b) else '0';
end behavioral;   