-- Testbench visual para o gerador de sinal PWM

-- Nesse testbench, vamos observar visualmente o comportamento do sinal PWM
-- para diferentes valores de duty cycle, mantendo o período fixo.
-- O objetivo é verificar se a largura do pulso em nível alto aumenta
-- conforme o duty cycle é incrementado.

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_visual_gerador is
end testbench_visual_gerador;

architecture tb_visual of testbench_visual_gerador is

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

            -- Configuração inicial do gerador
            period_pwm <= "1010"; -- Período = 10
            enable <= '1'; -- Habilita o gerador para começar a gerar o sinal PWM

            -- Teste 1: Duty cycle de 0%
            duty <= "0000";
            wait for 120 ns; -- Espera um tempo suficiente para observar o comportamento do sinal PWM

            assert (pwm = '0')
            report "Erro: duty = 0 deveria manter PWM em 0"
            severity error;

            -- Teste 2: Duty cycle de 10%
            duty <= "0001";
            wait for 120 ns;

            -- Teste 3: Duty cycle de 20%
            duty <= "0010";
            wait for 120 ns;

            -- Teste 4: Duty cycle de 30%
            duty <= "0011";
            wait for 120 ns;

            -- Teste 5: Duty cycle de 40%
            duty <= "0100";
            wait for 120 ns;

            -- Teste 6: Duty cycle de 50%
            duty <= "0101";
            wait for 120 ns;

            -- Teste 7: Duty cycle de 60%
            duty <= "0110";
            wait for 120 ns;

            -- Teste 8: Duty cycle de 70%
            duty <= "0111";
            wait for 120 ns;

            -- Teste 9: Duty cycle de 80%
            duty <= "1000";
            wait for 120 ns;

            -- Teste 10: Duty cycle de 90%
            duty <= "1001";
            wait for 120 ns;

            -- Teste 11: Duty cycle de 100%
            duty <= "1010";
            wait for 120 ns;

            report "Teste visual concluido"
            severity note;

            CLK_ENABLE <= '0'; -- Desabilita o clock para parar a simulação

            wait;
    end process;
end tb_visual;