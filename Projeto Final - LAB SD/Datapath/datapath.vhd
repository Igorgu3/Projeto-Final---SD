library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    generic(W : positive := 4);
    port(
        clk    : in std_logic; -- Clock signal do sistema
        enable_project : in std_logic; -- Sinal de habilitação para o projeto (Virá da controladora)
        enable_reg_period : in std_logic; -- Sinal de habilitação para o registrador de período do PWM (Virá da controladora)
        enable_reg_duty : in std_logic; -- Sinal de habilitação para o registrador de duty cycle do PWM (Virá da controladora)
        enable_Ger : in std_logic; -- Sinal de habilitação para o gerador de PWM (Virá da controladora)
        period_pwm : in std_logic_vector(W-1 downto 0); -- Entrada para o período do PWM 
        duty : in std_logic_vector (W-1 downto 0); -- Entrada para o duty cycle do PWM
        pwm  : out std_logic; -- Saída do sinal PWM gerado
        maior : out std_logic; -- Saída do comparador indicando se o duty cycle é maior que o período
        menor : out std_logic; -- Saída do comparador indicando se o duty cycle é menor que o período
        igual : out std_logic -- Saída do comparador indicando se o duty cycle é igual ao período
    );
end entity;

architecture behavioral of datapath is

-- Instanciação dos registradores
component registrador is
    port(
        clk    : in std_logic;
        enable : in std_logic;
        d      : in std_logic_vector(W-1 downto 0);
        q      : out std_logic_vector(W-1 downto 0)
    );
end component;

-- Instanciação do comparador (para comparar o duty cycle com o período)
component comparador is
    port (
        a : in  std_logic_vector (W-1 downto 0);          
        b : in  std_logic_vector (W-1 downto 0);            
 		maior : out  std_logic;
        menor : out  std_logic;
        igual : out  std_logic
    );
end component;

-- Instanciação do gerador de PWM
component gerador is
	port(
        clk    : in std_logic;
        enable : in std_logic;
        period_pwm : in std_logic_vector(W-1 downto 0);
        duty : in std_logic_vector (W-1 downto 0);
        pwm  : out std_logic
    );
end component;

signal maior_s : std_logic; -- Sinal para armazenar a saída do comparador indicando se o duty cycle é maior que o período
signal menor_s : std_logic; -- Sinal para armazenar a saída do comparador indicando se o duty cycle é menor que o período
signal igual_s : std_logic; -- Sinal para armazenar a saída do comparador indicando se o duty cycle é igual ao período
signal reg_period_pwm : std_logic_vector(W-1 downto 0) := (others => '0'); -- Sinal para armazenar o valor do período do PWM a partir do registrador
signal reg_duty : std_logic_vector(W-1 downto 0) := (others => '0'); -- Sinal para armazenar o valor do duty cycle do PWM a partir do registrador
signal pwm_signal : std_logic; -- Sinal para armazenar a saída do gerador de PWM antes de ser atribuída à saída do datapath

begin
    REG1 : registrador port map (clk => clk, enable => enable_reg_period, d => period_pwm, q => reg_period_pwm); -- Registrador para armazenar o período do PWM

    REG2 : registrador port map (clk => clk, enable => enable_reg_duty, d => duty, q => reg_duty); -- Registrador para armazenar o duty cycle do PWM

    COM : comparador port map (a => reg_duty, b => reg_period_pwm, maior => maior_s, menor => menor_s, igual => igual_s); -- Comparador para comparar o duty cycle com o período

    GER : gerador port map (clk => clk, enable => enable_Ger, period_pwm => reg_period_pwm, duty => reg_duty, pwm => pwm_signal); -- Gerador de PWM

    pwm <= pwm_signal; -- Atribuição da saída do gerador de PWM à saída do datapath

    -- Necessário atribuir as saídas do comparador às saídas do datapath para que a controladora leia os resultados da comparação
    maior <= maior_s; -- Atribuição da saída do comparador indicando se o duty cycle é maior que o período
    menor <= menor_s; -- Atribuição da saída do comparador indicando se o duty cycle é menor que o período
    igual <= igual_s; -- Atribuição da saída do comparador indicando se o duty cycle é igual ao período

end behavioral;