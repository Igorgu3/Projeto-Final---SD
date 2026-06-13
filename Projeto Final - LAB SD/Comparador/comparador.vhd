library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity comparador is
	generic (W: positive := 4);
    port (
        a       : in  std_logic_vector (W-1 downto 0); -- Entrada do primeiro valor a ser comparado           
        b       : in  std_logic_vector (W-1 downto 0); -- Entrada do segundo valor a ser comparado
 		maior, menor, igual    : out  std_logic -- Saídas indicando o resultado da comparação: maior, menor ou igual
    );
end entity comparador;


architecture behavioral of comparador is
    begin
	    maior <= '1' when unsigned(a) > unsigned(b) else '0'; -- Atribuição da saída 'maior' com base na comparação entre 'a' e 'b', ambos em formato unsigned
	    igual <= '1' when unsigned(a) = unsigned(b) else '0'; -- Atribuição da saída 'igual' com base na comparação entre 'a' e 'b', ambos em formato unsigned
	    menor <= '1' when unsigned(a) < unsigned(b) else '0'; -- Atribuição da saída 'menor' com base na comparação entre 'a' e 'b', ambos em formato unsigned
end behavioral;   