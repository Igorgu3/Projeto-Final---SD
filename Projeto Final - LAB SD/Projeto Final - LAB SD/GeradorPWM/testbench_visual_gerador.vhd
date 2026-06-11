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

            period_pwm <= "1010"; -- período = 10
            enable <= '1';

            -- 0%
            duty <= "0000";
            wait for 120 ns;

            assert pwm = '0'
            report "Erro: duty = 0 deveria manter PWM em 0"
            severity error;

            -- 10%
            duty <= "0001";
            wait for 120 ns;

            -- 20%
            duty <= "0010";
            wait for 120 ns;

            -- 30%
            duty <= "0011";
            wait for 120 ns;

            -- 40%
            duty <= "0100";
            wait for 120 ns;

            -- 50%
            duty <= "0101";
            wait for 120 ns;

            -- 60%
            duty <= "0110";
            wait for 120 ns;

            -- 70%
            duty <= "0111";
            wait for 120 ns;

            -- 80%
            duty <= "1000";
            wait for 120 ns;

            -- 90%
            duty <= "1001";
            wait for 120 ns;

            -- 100%
            duty <= "1010";
            wait for 120 ns;

            report "Teste visual concluido"
            severity note;

            CLK_ENABLE <= '0';

            wait;
    end process;
end tb;