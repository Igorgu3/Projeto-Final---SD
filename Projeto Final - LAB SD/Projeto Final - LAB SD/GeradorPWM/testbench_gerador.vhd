library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture tb of testbench is

    constant W : positive := 4;

    component gerador is
        generic(W : positive := 4);
        port(
            clk    : in std_logic;
            enable : in std_logic;
            period_pwm : in std_logic_vector(W-1 downto 0);
            duty : in std_logic_vector (W-1 downto 0);
            pwm  : out std_logic
        );
    end component;

    signal clk        : std_logic := '0';
    signal enable     : std_logic := '0';
    signal period_pwm : std_logic_vector(W-1 downto 0) := (others => '0');
    signal duty       : std_logic_vector(W-1 downto 0);
    signal pwm : std_logic;

    signal CLK_ENABLE : std_logic := '1';

    constant CLK_PERIOD : time := 10 ns;

    begin

        -- Gerador de clock
        clk <= CLK_ENABLE and not clk after CLK_PERIOD/2;

        DUT : gerador port map( clk => clk, enable => enable, period_pwm => period_pwm, duty => duty, pwm => pwm);

        stimulation : process
        begin

            -- Teste 1: Verificar inicialização

            wait for 1 ns;

            assert (pwm = '0')
            report "Erro: PWM deveria iniciar em 0"
            severity error;

            -- Teste 2: Duty = 0 (0%)

            period_pwm <= "1010"; -- 10
            duty <= "0000";       -- 0
            enable <= '1';

            wait for 5 * CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: Duty 0 deveria manter PWM sempre em 0"
            severity error;

            -- Teste 3: Duty = 1

            duty <= "0001";

            wait for 1 ns;

            assert (pwm = '1')
            report "Erro: Duty 1 deveria iniciar com PWM em 1"
            severity error;

            wait for CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: Duty 1 deveria permanecer em 1 apenas durante count = 0"
            severity error;

            -- Teste 4: Duty = 5 (50%)

            duty <= "0101";

            wait for 1 ns;

            assert (pwm = '1')
            report "Erro: PWM deveria iniciar em 1 para duty 5"
            severity error;

            wait for 5 * CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: PWM deveria ir para 0 ao atingir duty 5"
            severity error;

            -- Teste 5: Duty = 9 (90%)

            period_pwm <= "1010";
            duty <= "1001";

            wait until pwm = '0';

            assert (pwm = '0')
            report "Erro: PWM deveria eventualmente ir para 0 para duty 9"
            severity error;

            -- Teste 6: Duty = Periodo (100%)

            duty <= "1010";

            wait for 5 * CLK_PERIOD;

            assert (pwm = '1')
            report "Erro: Duty igual ao periodo deveria manter PWM sempre em 1"
            severity error;

            -- Teste 7: Periodo minimo

            period_pwm <= "0001";
            duty <= "0001";

            wait for 3 * CLK_PERIOD;

            assert (pwm = '1')
            report "Erro: Com periodo minimo e duty igual ao periodo o PWM deveria permanecer em 1"
            severity error;

            -- Teste 8: Periodo maximo e duty minimo

            period_pwm <= "1111"; -- 15
            duty <= "0001";

            wait for 1 ns;

            assert (pwm = '1')
            report "Erro: PWM deveria iniciar em 1"
            severity error;

            wait for CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: PWM deveria voltar para 0 apos count = 0"
            severity error;

            -- Teste 9: Desabilitacao do PWM

            enable <= '0';

            wait for CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: PWM deveria ficar em 0 quando desabilitado"
            severity error;

            report "Todos os testes passaram com sucesso"
            severity note;

            CLK_ENABLE <= '0';

            wait;

        end process;
end tb;