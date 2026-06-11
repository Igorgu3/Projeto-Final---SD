library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity contador is
    generic (W: positive := 4);
	port (
        clk     : in    std_logic;
        enable  : in    std_logic;
        period_pwm   : in std_logic_vector(W - 1 downto 0);
        count   : out   std_logic_vector(W - 1 downto 0)
    );
end entity contador;


architecture behavioral of contador is
    signal counter : unsigned(W - 1 downto 0) := (others => '0');
    begin
        process(clk)
            begin
	            if rising_edge(clk) then
                    if enable = '1' then
                        if unsigned(period_pwm) = 0 then -- Período igual a 0, o contador deve permanecer em 0, já que é um valor inválido!
                            counter <= (others => '0');
                        elsif counter = unsigned(period_pwm) - 1 then
                            counter <= (others => '0');
                        else
                            counter <= counter + 1;
                        end if;
                    else
                        counter <= (others => '0');
                    end if;
                end if;
    end process;

    count <= std_logic_vector(counter);
end behavioral;