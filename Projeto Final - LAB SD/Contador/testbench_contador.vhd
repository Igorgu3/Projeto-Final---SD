-- Testbench para o contador do projeto de Gerador de sinal PWM

-- Nesse testbench, vamos verificar o funcionamento do contador.

-- O testbench irá simular diferentes cenários de entrada para o contador, 
-- e verificará as saídas para garantir que estão de acordo com o esperado.


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench_contador is
end testbench_contador;

architecture tb_contador of testbench_contador is

constant W : positive := 4;

-- Instanciação do contador

component contador is
	generic (W: positive := 4);
	port (
		clk     : in    std_logic;
        enable  : in    std_logic;
        period_pwm   : in std_logic_vector(W - 1 downto 0);
        count   : out   std_logic_vector(W - 1 downto 0)
    );
end component;

    -- Sinais intermediários para realização dos testes
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal period_pwm : std_logic_vector(W - 1 downto 0) := (others => '0');
    signal count : std_logic_vector(W - 1 downto 0);
	signal CLK_ENABLE: std_logic := '1';
    constant CLK_PERIOD : time := 10 ns; -- Constante para o período do clock

begin

	-- Gerador de clock
    clk <= CLK_ENABLE and not clk after CLK_PERIOD/2;

  	DUT: contador port map(clk => clk, enable => enable, period_pwm => period_pwm, count => count);

stimulation : process

	begin

        -- Teste 1: Verificar contagem normal

        -- Configuração de um período de 10 ciclos para o contador
        period_pwm <= "1010"; -- 10
        enable <= '1'; -- Habilita o contador para iniciar a contagem

        wait for CLK_PERIOD; -- Espera um ciclo de clock

        assert (count = "0001")
        report "Erro: contador deveria valer 1"
        severity error;

        wait for CLK_PERIOD; -- Espera mais um ciclo de clock

        assert (count = "0010")
        report "Erro: contador deveria valer 2"
        severity error;

        wait for CLK_PERIOD; -- Espera mais um ciclo de clock

        assert (count = "0011")
        report "Erro: contador deveria valer 3"
        severity error;

        -- Teste 2: Verificar retorno para zero ao atingir o período

        -- Como o período configurado é 10, o contador deve voltar para 0
        -- após atingir o valor 9
        wait for 7 * CLK_PERIOD;

        assert count = "0000"
        report "Erro: contador deveria retornar para 0 ao atingir o periodo"
        severity error;

        -- Teste 3: Verificar desabilitação do contador

        -- Desabilita o contador e verifica se ele permanece em zero
        enable <= '0';

        wait for CLK_PERIOD;

        assert count = "0000"
        report "Erro: contador deveria permanecer em 0 quando desabilitado"
        severity error;

        -- Teste 4: Verificar reinício da contagem após reabilitação

        -- Habilita novamente o contador para verificar se a contagem
        -- reinicia corretamente a partir de zero
        enable <= '1';

        wait for CLK_PERIOD;

        assert count = "0001"
        report "Erro: contador deveria reiniciar a contagem em 1"
        severity error;

        -- Teste 5: Caso extremo - período mínimo igual a 1

        -- Com período igual a 1, o contador deve permanecer sempre em zero,
        -- pois o valor máximo permitido antes do retorno já é o próprio zero
        enable <= '0';

        wait for CLK_PERIOD;

        period_pwm <= "0001";
        enable <= '1';

        wait for CLK_PERIOD;

        assert count = "0000"
        report "Erro: com periodo 1 o contador deve permanecer em 0"
        severity error;

        -- Teste 6: Caso extremo - período máximo representável (15)

        -- Configura o maior período possível para um contador de 4 bits
        enable <= '0';

        wait for CLK_PERIOD;

        period_pwm <= "1111"; -- 15
        enable <= '1';

        -- Espera até que o contador alcance o valor máximo válido (14)
        wait for 14 * CLK_PERIOD;

        assert count = "1110"
        report "Erro: contador deveria valer 14"
        severity error;

        -- Após atingir 14, o próximo ciclo deve provocar o retorno para zero
        wait for CLK_PERIOD;

        assert count = "0000"
        report "Erro: contador deveria retornar para 0 após atingir 14"
        severity error;

        -- Teste 7: Caso extremo - período igual a zero

        -- Esse caso foi tratado no projeto para evitar comportamentos
        -- indefinidos. O contador deve permanecer em zero.
        enable <= '0';

        wait for CLK_PERIOD;

        period_pwm <= "0000";
        enable <= '1';

        wait for 3 * CLK_PERIOD;

        assert count = "0000"
        report "Erro: com periodo 0 o contador deve permanecer em 0"
        severity error;

        report "Testes concluídos"
        severity note;

        -- Desabilita o clock para finalizar a simulação
        CLK_ENABLE <= '0';

        wait;

    end process;
		
end tb_contador;