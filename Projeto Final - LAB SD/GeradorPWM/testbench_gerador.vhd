-- Testbench para o gerador de sinal PWM

-- Nesse testbench, vamos verificar o funcionamento do gerador de sinal PWM,
-- componente responsável por produzir o sinal PWM a partir dos valores de
-- período e duty cycle previamente configurados pelo usuário.

-- Como o gerador utiliza internamente os módulos contador e comparador,
-- este teste também valida a integração entre esses componentes,
-- garantindo que o sinal PWM seja gerado de acordo com os parâmetros fornecidos.

-- O objetivo deste testbench é verificar cenários representativos de operação,
-- incluindo duty cycles mínimos, intermediários e máximos, além de casos
-- extremos de período e da desabilitação do gerador. Os comportamentos internos
-- do contador e do comparador já foram testados individualmente em seus
-- respectivos testbenches.


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_gerador is
end testbench_gerador;

architecture tb_gerador of testbench_gerador is

    constant W : positive := 4;

    -- Instanciação do gerador de PWM
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

    -- Sinais intermediários para realização dos testes
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

            -- Teste 1: Verificar inicialização do gerador

            -- Como o gerador inicia desabilitado, a saída PWM deve permanecer em nível baixo
            wait for 1 ns;

            assert (pwm = '0')
            report "Erro: PWM deveria iniciar em 0"
            severity error;

            -- Teste 2: Verificar duty cycle igual a 0%

            -- Com duty igual a zero, o sinal PWM deve permanecer sempre em nível baixo
            period_pwm <= "1010"; -- 10
            duty <= "0000";       -- 0
            enable <= '1';

            wait for 5 * CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: Duty 0 deveria manter PWM sempre em 0"
            severity error;

            -- Teste 3: Verificar duty cycle mínimo diferente de zero

            -- Com duty igual a 1, o PWM deve permanecer em nível alto
            -- apenas durante a primeira contagem do período
            duty <= "0001";

            wait for 1 ns;

            assert (pwm = '1')
            report "Erro: Duty 1 deveria iniciar com PWM em 1"
            severity error;

            wait for CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: Duty 1 deveria permanecer em 1 apenas durante count = 0"
            severity error;

            -- Teste 4: Verificar duty cycle de aproximadamente 50%

            -- Com período igual a 10 e duty igual a 5, o PWM deve permanecer
            -- em nível alto durante metade do período
            duty <= "0101";

            wait for 1 ns;

            assert (pwm = '1')
            report "Erro: PWM deveria iniciar em 1 para duty 5"
            severity error;

            wait for 5 * CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: PWM deveria ir para 0 ao atingir duty 5"
            severity error;

            -- Teste 5: Verificar duty cycle próximo ao valor máximo

            -- Com duty igual a 9 e período igual a 10, o PWM deve permanecer
            -- em nível alto durante quase todo o período
            period_pwm <= "1010";
            duty <= "1001";

            wait until pwm = '0';

            assert (pwm = '0')
            report "Erro: PWM deveria eventualmente ir para 0 para duty 9"
            severity error;

            -- Teste 6: Verificar duty cycle igual ao período

            -- Nesse caso o PWM deve permanecer continuamente em nível alto
            duty <= "1010";

            wait for 5 * CLK_PERIOD;

            assert (pwm = '1')
            report "Erro: Duty igual ao periodo deveria manter PWM sempre em 1"
            severity error;

            -- Teste 7: Verificar período mínimo

            -- Com período mínimo e duty igual ao período,
            -- o PWM também deve permanecer continuamente em nível alto
            period_pwm <= "0001";
            duty <= "0001";

            wait for 3 * CLK_PERIOD;

            assert (pwm = '1')
            report "Erro: Com periodo minimo e duty igual ao periodo o PWM deveria permanecer em 1"
            severity error;

            -- Teste 8: Verificar período máximo e duty mínimo

            -- Com período máximo e duty mínimo, o PWM deve permanecer
            -- em nível alto apenas durante o primeiro valor da contagem
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

            -- Teste 9: Verificar desabilitação do gerador

            -- Ao desabilitar o gerador, a saída PWM deve retornar para nível baixo
            enable <= '0';

            wait for CLK_PERIOD;

            assert (pwm = '0')
            report "Erro: PWM deveria ficar em 0 quando desabilitado"
            severity error;

            report "Todos os testes passaram com sucesso"
            severity note;

            CLK_ENABLE <= '0'; -- Desabilita o clock para parar a simulação

            wait;

        end process;
end tb_gerador;