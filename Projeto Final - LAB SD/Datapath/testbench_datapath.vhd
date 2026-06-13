-- Testbench para o datapath do projeto de Gerador de sinal PWM

-- Nesse testbench, vamos verificar o funcionamento dos registradores,
-- do comparador e do gerador de PWM integrados no datapath,
-- porém, de maneira isolada, ou seja, sem a presença da controladora.

-- O testbench irá simular diferentes cenários de entrada para os registradores de período e duty cycle, 
-- e verificar as saídas do comparador e do gerador de PWM para garantir que estão de acordo com o esperado, 
-- mas de maneira resumida, já que o testbench de cada componente já testou exaustivamente cada um deles.

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench_datapath is
end testbench_datapath;

architecture tb_datapath of testbench_datapath is

constant W : positive := 4;

-- Instanciação do datapath

component datapath is
	generic(W : positive := 4);
    port(
        clk    : in std_logic;
        enable_reg_period : in std_logic;
        enable_reg_duty : in std_logic;
        enable_Ger : in std_logic;
        period_pwm : in std_logic_vector(W-1 downto 0);
        duty : in std_logic_vector (W-1 downto 0);
        pwm  : out std_logic;
        maior : out std_logic;
        menor : out std_logic;
        igual : out std_logic
    );
end component;

	-- Sinais intermediários para realização dos testes
    signal clk : std_logic := '0';
    signal enable_reg_period : std_logic := '0';
    signal enable_reg_duty : std_logic := '0';
    signal enable_Ger : std_logic := '0';
    signal period_pwm : std_logic_vector(W - 1 downto 0) := (others => '0');
    signal duty : std_logic_vector(W - 1 downto 0) := (others => '0');
    signal pwm : std_logic;
    signal maior : std_logic;
    signal menor : std_logic;
    signal igual : std_logic;
	signal CLK_ENABLE: std_logic := '1';

    constant CLK_PERIOD : time := 10 ns; -- Constante para o período do clock

begin
    -- Gerador de clock
    clk <= CLK_ENABLE and not clk after CLK_PERIOD/2;

  	DUT: datapath port map(
        clk => clk,
        enable_reg_period => enable_reg_period,
        enable_reg_duty => enable_reg_duty,
        enable_Ger => enable_Ger,
        period_pwm => period_pwm,
        duty => duty,
        pwm => pwm,
        maior => maior,
        menor => menor,
        igual => igual
    );

stimulation : process

	begin
    	
        -- Teste 1: Verificar funcionamento dos registradores e comparador

    	-- Valores de teste para o período e duty cycle, onde o duty cycle é menor que o período
		period_pwm <= "1101"; -- 13  
    	duty <= "1001";       -- 9

		-- Habilitação dos registradores para armazenar os valores de período e duty cycle
    	enable_reg_period <= '1'; 
    	enable_reg_duty <= '1'; 

    	wait for CLK_PERIOD; -- Espera um ciclo de clock para os registradores armazenarem os valores

    	-- Desabilitação dos registradores para manter os valores armazenados (simulando a situação onde a controladora já configurou os valores e agora apenas queremos verificar as saídas do comparador e do gerador de PWM)
		enable_reg_period <= '0'; 
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '1' and maior = '0' and igual = '0') -- Verifica se o comparador indica corretamente que o duty cycle é menor que o período
    	report "Erro: Deveria exibir que 9 e menor que 13"
    	severity error;

    	-- Teste 2: Verificar geracao do PWM

    	enable_Ger <= '1'; -- Habilita o gerador de PWM para começar a gerar o sinal de acordo com os valores armazenados nos registradores

    	report "Teste visual: observar a geracao do PWM para periodo = 13 e duty = 9" -- O sinal PWM deve estar em nível alto por 9 ciclos de clock e em nível baixo por 4 ciclos de clock, formando um ciclo completo de 13 ciclos de clock
    	severity note;

    	wait for 120 ns; -- Espera um tempo suficiente para observar vários ciclos do sinal PWM gerado

    	enable_Ger <= '0'; -- Desabilita o gerador de PWM para parar a geração do sinal, e testar outros cenários de período e duty cycle

    	-- Teste 3: Verificar comparacao de overflow

		-- Novos valores de teste para o período e duty cycle, onde o duty cycle é maior que o período
    	period_pwm <= "0111"; -- 7
    	duty <= "1111";       -- 15

		-- Habilitação dos registradores para armazenar os novos valores de período e duty cycle
    	enable_reg_period <= '1'; 
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '0' and maior = '1' and igual = '0') -- Verifica se o comparador indica corretamente que o duty cycle Ã© maior que o perÃ­odo
    	report "Erro: Deveria exibir que 15 e maior que 7"
    	severity error;

    	-- Teste 4: Verificar comparacao de igualdade

		-- Novos valores de teste para o perÃ­odo e duty cycle, onde o duty cycle Ã© igual ao perÃ­odo
    	period_pwm <= "0111"; -- 7
    	duty <= "0111";       -- 7

		-- Habilitação dos registradores para armazenar os novos valores de período e duty cycle
    	enable_reg_period <= '1';
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '0' and maior = '0' and igual = '1') -- Verifica se o comparador indica corretamente que o duty cycle Ã© igual ao perÃ­odo
    	report "Erro: Deveria exibir que 7 e igual a 7"
    	severity error;

    	-- Teste 5: Verificar comparacao valida (duty < periodo)

		-- Novos valores de teste para o período e duty cycle, onde o duty cycle é menor que o período
    	period_pwm <= "1110"; -- 14
    	duty <= "0100";       -- 4

		-- Habilitação dos registradores para armazenar os novos valores de período e duty cycle
    	enable_reg_period <= '1';
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '1' and maior = '0' and igual = '0') -- Verifica se o comparador indica corretamente que o duty cycle é menor que o período
    	report "Erro: Deveria exibir que 4 e menor que 14"
    	severity error;

        report "Todos os testes passaram com sucesso" -- Caso nenhum erro tenha sido reportado, significa que o datapath está funcionando corretamente para os cenários testados
		severity note;

		CLK_ENABLE <= '0'; -- Desabilita o clock para finalizar a simulação
    
    	wait;
    end process;
end tb_datapath;