library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity contador is
    generic (W: positive := 4);
	port (
        clk     : in    std_logic; -- Clock signal do sistema
        enable  : in    std_logic; -- Sinal de habilitação para o contador (Virá da controladora e será repassada pelo Datapath)
        period_pwm   : in std_logic_vector(W - 1 downto 0); -- Entrada para o período do PWM (Virá do registrador de período do Datapath)
        count   : out   std_logic_vector(W - 1 downto 0) -- Saída do valor atual do contador, que será comparado com o duty cycle para gerar o sinal PWM
    );
end entity contador;


architecture behavioral of contador is
    signal counter : unsigned(W - 1 downto 0) := (others => '0'); -- Sinal intermediário para armazenar o valor do contador como um número sem sinal
    begin
        process(clk)
            begin
	            if rising_edge(clk) then
                    if enable = '1' then
                        if unsigned(period_pwm) = 0 then -- Caso o período seja igual a 0, o contador deve permanecer em 0, já que é um valor inválido!
                            counter <= (others => '0');
                        elsif counter = unsigned(period_pwm) - 1 then -- O contador deve contar até o valor do período menos 1, pois o contador começa em 0. Quando atingir esse valor, ele deve ser resetado para 0 no próximo ciclo.
                            counter <= (others => '0');
                        else
                            counter <= counter + 1; -- Incrementa o contador a cada ciclo de clock enquanto estiver habilitado e o contador ainda não atingiu o valor do período.
                        end if;
                    else
                        counter <= (others => '0'); -- Se o contador não estiver habilitado, ele deve ser resetado para 0, independentemente do valor do período.
                    end if;
                end if;
    end process;

    count <= std_logic_vector(counter); -- Atribui o valor do contador convertido para std_logic_vector à saída count, que será usada para comparação com o duty cycle no gerador de PWM.
end behavioral;