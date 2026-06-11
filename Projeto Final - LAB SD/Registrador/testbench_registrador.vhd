library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture tb of testbench is

    constant W : positive := 4;

    component registrador is
        generic(W : positive := 4);

        port(
            clk    : in std_logic;
            enable : in std_logic;
            d      : in std_logic_vector(W-1 downto 0);
            q      : out std_logic_vector(W-1 downto 0)
        );
    end component;

    signal clk        : std_logic := '0';
    signal enable     : std_logic := '0';
    signal d          : std_logic_vector(W-1 downto 0) := (others => '0');
    signal q          : std_logic_vector(W-1 downto 0);

    signal CLK_ENABLE : std_logic := '1';

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Gerador de clock
    clk <= CLK_ENABLE and not clk after CLK_PERIOD/2;

    DUT : registrador
    port map( clk => clk, enable => enable, d => d, q => q);

    stimulation : process
    begin

        -- Teste 1: Verificar inicialização

        wait for 1 ns;

        assert (q = "0000")
        report "Erro: registrador deveria iniciar em 0000"
        severity error;

        -- Teste 2: Verificar armazenamento normal

        d <= "1010";
        enable <= '1';

        wait for CLK_PERIOD;

        assert (q = "1010")
        report "Erro: registrador deveria valer 1010"
        severity error;

        d <= "0101";

        wait for CLK_PERIOD;

        assert (q = "0101")
        report "Erro: registrador deveria valer 0101"
        severity error;

        -- Teste 3: Verificar retenção com enable = 0

        enable <= '0';
        d <= "1111";

        wait for CLK_PERIOD;

        assert (q = "0101")
        report "Erro: registrador deveria manter o valor 0101 quando desabilitado"
        severity error;

        -- Teste 4: Caso extremo - valor mínimo (0000)

        enable <= '1';
        d <= "0000";

        wait for CLK_PERIOD;

        assert (q = "0000")
        report "Erro: registrador deveria armazenar 0000"
        severity error;

        -- Teste 5: Valor baixo (0001)

        d <= "0001";

        wait for CLK_PERIOD;

        assert (q = "0001")
        report "Erro: registrador deveria armazenar 0001"
        severity error;

        -- Teste 6: Caso extremo - valor máximo (1111)

        d <= "1111";

        wait for CLK_PERIOD;

        assert (q = "1111")
        report "Erro: registrador deveria armazenar 1111"
        severity error;

        -- Finalização

        report "Todos os testes passaram com sucesso"
        severity note;

        CLK_ENABLE <= '0';

        wait;

    end process;

end tb;