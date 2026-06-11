library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gerador is
    generic(W : positive := 4);
    port(
        clk    : in std_logic; -- Clock signal do sistema
        enable : in std_logic; -- Sinal de habilitação para o gerador de PWM (Virá da controladora)
        period_pwm : in std_logic_vector(W-1 downto 0); -- Entrada para o período do PWM 
        duty : in std_logic_vector (W-1 downto 0); -- Entrada para o duty cycle do PWM
        pwm  : out std_logic -- Saída do sinal PWM gerado
    );
end entity;

architecture behavioral of gerador is

    -- Instanciação do comparador (para comparar o contador com o duty cycle)
    component comparador is
    port (
        a : in  std_logic_vector (W-1 downto 0);          
        b : in  std_logic_vector (W-1 downto 0);            
 		maior : out  std_logic;
        menor : out  std_logic;
        igual : out  std_logic
    );
    end component;

    -- Instanciação do contador para contar o tempo do PWM
    component contador is
	port (
        clk     : in    std_logic;
        enable  : in    std_logic;
        period_pwm : in std_logic_vector(W - 1 downto 0);
        count   : out   std_logic_vector(W - 1 downto 0)
    );
    end component;

    signal maior : std_logic; -- Sinal para armazenar a saída do comparador indicando se o contador é maior que o duty cycle
    signal menor : std_logic; -- Sinal para armazenar a saída do comparador indicando se o contador é menor que o duty cycle
    signal igual : std_logic; -- Sinal para armazenar a saída do comparador indicando se o contador é igual ao duty cycle
    signal reg_count : std_logic_vector(W-1 downto 0) := (others => '0'); -- Sinal para armazenar o valor do contador

    begin
        
        CON : contador port map (clk => clk, enable => enable, period_pwm => period_pwm, count => reg_count);
                        
        COM : comparador port map (a => reg_count, b => duty, maior => maior, menor => menor, igual => igual);
       
        pwm <= '1' when enable = '1' and menor = '1' else '0'; -- Geração do sinal PWM: quando estiver habilitado e o contador for menor que o duty cycle, o sinal é '1', caso contrário, é '0'.
end behavioral; 