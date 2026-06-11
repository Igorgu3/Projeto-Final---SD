library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gerador is
    generic(W : positive := 4);
    port(
        clk    : in std_logic;
        enable : in std_logic;
        period_pwm : in std_logic_vector(W-1 downto 0);
        duty : in std_logic_vector (W-1 downto 0);
        pwm  : out std_logic
    );
end entity;

architecture behavioral of gerador is

    component comparador is
    port (
        a : in  std_logic_vector (W-1 downto 0);          
        b : in  std_logic_vector (W-1 downto 0);            
 		maior : out  std_logic;
        menor : out  std_logic;
        igual : out  std_logic
    );
    end component;

    component contador is
	port (
        clk     : in    std_logic;
        enable  : in    std_logic;
        period_pwm : in std_logic_vector(W - 1 downto 0);
        count   : out   std_logic_vector(W - 1 downto 0)
    );
    end component;

    signal maior : std_logic;
    signal menor : std_logic;
    signal igual : std_logic;
    signal reg_count : std_logic_vector(W-1 downto 0) := (others => '0');

    begin
        
        CON : contador port map (clk => clk, enable => enable, period_pwm => period_pwm, count => reg_count);
                        
        COM : comparador port map (a => reg_count, b => duty, maior => maior, menor => menor, igual => igual);
       
        pwm <= '1' when enable = '1' and menor = '1' else '0';
end behavioral;