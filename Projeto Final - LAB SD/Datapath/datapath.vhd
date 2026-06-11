library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
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
end entity;

architecture behavioral of datapath is

component registrador is
    port(
        clk    : in std_logic;
        enable : in std_logic;
        d      : in std_logic_vector(W-1 downto 0);
        q      : out std_logic_vector(W-1 downto 0)
    );
end component;

component comparador is
    port (
        a : in  std_logic_vector (W-1 downto 0);          
        b : in  std_logic_vector (W-1 downto 0);            
 		maior : out  std_logic;
        menor : out  std_logic;
        igual : out  std_logic
    );
end component;

component gerador is
	port(
        clk    : in std_logic;
        enable : in std_logic;
        period_pwm : in std_logic_vector(W-1 downto 0);
        duty : in std_logic_vector (W-1 downto 0);
        pwm  : out std_logic
    );
end component;

signal maior_s : std_logic;
signal menor_s : std_logic;
signal igual_s : std_logic;
signal reg_period_pwm : std_logic_vector(W-1 downto 0) := (others => '0');
signal reg_duty : std_logic_vector(W-1 downto 0) := (others => '0');
signal pwm_signal : std_logic;



begin
    REG1 : registrador port map (clk => clk, enable => enable_reg_period, d => period_pwm, q => reg_period_pwm);

    REG2 : registrador port map (clk => clk, enable => enable_reg_duty, d => duty, q => reg_duty);

    COM : comparador port map (a => reg_duty, b => reg_period_pwm, maior => maior_s, menor => menor_s, igual => igual_s);

    GER : gerador port map (clk => clk, enable => enable_Ger, period_pwm => reg_period_pwm, duty => reg_duty, pwm => pwm_signal);

    pwm <= pwm_signal;
    maior <= maior_s;
    menor <= menor_s;
    igual <= igual_s;

end behavioral;