library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
    generic(W : positive := 4);
    port(
        clk    : in std_logic; -- Clock signal do sistema
        enable : in std_logic; -- Sinal de habilitação para o registrador (Virá da controladora)
        d      : in std_logic_vector(W-1 downto 0); -- Entrada de dados para o registrador
        q      : out std_logic_vector(W-1 downto 0) -- Sinal de saída armazenado no registrador
    );
end entity;

architecture behavioral of registrador is
    signal reg : std_logic_vector(W - 1 downto 0) := (others => '0'); -- Sinal intermediário para armazenar o valor do registrador
    begin
        process(clk)
            begin
	            if rising_edge(clk) then
                    if enable = '1' then -- A cada subida de clock, se o sinal de habilitação estiver ativo, o valor da entrada de dados é armazenado no registrador
                        reg <= d;
                    end if;
                end if;
        end process;
        q <= reg; -- A saída do registrador é atribuída ao sinal de saída do componente
end behavioral;