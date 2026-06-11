library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench is
end testbench;

architecture tb of testbench is

constant W : positive := 4;

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

    constant CLK_PERIOD : time := 10 ns;

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

    	period_pwm <= "1101"; -- 13
    	duty <= "1001";       -- 9

    	enable_reg_period <= '1';
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '1' and maior = '0' and igual = '0')
    	report "Erro: Deveria exibir que 9 e menor que 13"
    	severity error;

    	-- Teste 2: Verificar geracao do PWM

    	enable_Ger <= '1';

    	report "Teste visual: observar a geracao do PWM para periodo = 9 e duty = 13"
    	severity note;

    	wait for 120 ns;

    	enable_Ger <= '0';

    	-- Teste 3: Verificar comparacao de erro

    	period_pwm <= "0111"; -- 7
    	duty <= "1111";       -- 15

    	enable_reg_period <= '1';
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '0' and maior = '1' and igual = '0')
    	report "Erro: Deveria exibir que 15 e maior que 7"
    	severity error;

    	-- Teste 4: Verificar comparacao de igualdade

    	period_pwm <= "0111"; -- 7
    	duty <= "0111";       -- 7

    	enable_reg_period <= '1';
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '0' and maior = '0' and igual = '1')
    	report "Erro: Deveria exibir que 7 e igual a 7"
    	severity error;

    	-- Teste 5: Verificar comparacao valida

    	period_pwm <= "1110"; -- 14
    	duty <= "0100";       -- 4

    	enable_reg_period <= '1';
    	enable_reg_duty <= '1';

    	wait for CLK_PERIOD;

    	enable_reg_period <= '0';
    	enable_reg_duty <= '0';

    	wait for 1 ns;

    	assert (menor = '1' and maior = '0' and igual = '0')
    	report "Erro: Deveria exibir que 4 e menor que 14"
    	severity error;

        report "Todos os testes passaram com sucesso"
		severity note;

		CLK_ENABLE <= '0';
    
    	wait;
    end process;
end tb;