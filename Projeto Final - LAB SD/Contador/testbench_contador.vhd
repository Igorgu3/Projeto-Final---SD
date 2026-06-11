library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench is
end testbench;

architecture tb of testbench is

constant W : positive := 4;

component contador is
	generic (W: positive := 4);
	port (
		clk     : in    std_logic;
        enable  : in    std_logic;
        period_pwm   : in std_logic_vector(W - 1 downto 0);
        count   : out   std_logic_vector(W - 1 downto 0)
    );
end component;

    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal period_pwm : std_logic_vector(W - 1 downto 0) := (others => '0');
    signal count : std_logic_vector(W - 1 downto 0);
	signal CLK_ENABLE: std_logic := '1';
    constant CLK_PERIOD : time := 10 ns;

begin

	-- Gerador de clock
    clk <= CLK_ENABLE and not clk after CLK_PERIOD/2;

  	DUT: contador port map(clk => clk, enable => enable, period_pwm => period_pwm, count => count);

stimulation : process

	begin
		-- Teste 1: Verificar contagem normal
		period_pwm <= "1010"; -- Período de 10
		enable <= '1';
		wait for CLK_PERIOD; -- Espera um ciclo de clock

		assert (count = "0001");
        report "Erro: contador deveria valer 1"
        severity error;

		wait for CLK_PERIOD; -- Espera um ciclo de clock

		assert (count = "0010");
		report "Erro: contador deveria valer 2"
		severity error;

		wait for CLK_PERIOD; -- Espera um ciclo de clock
		assert (count = "0011");
		report "Erro: contador deveria valer 3"
		severity error;

		-- Teste 2: Verificar se após 9 ciclos o contador retorna para 0
		wait for 7 * CLK_PERIOD;

        assert count = "0000"
        report "Erro: contador deveria retornar para 0 ao atingir o periodo"
        severity error;

		-- Teste 3: Verificar desabilitação do contador
		enable <= '0'; -- Desabilita o contador

		wait for CLK_PERIOD;
		
		assert count = "0000"
        report "Erro: contador deveria permanecer em 0 quando desabilitado"
        severity error;

		-- Teste 4: Verificar comportamento com período diferente

		enable <= '1'; -- Habilita o contador novamente

		wait for CLK_PERIOD; -- Espera um ciclo de clock para garantir que o contador esteja habilitado

		assert count = "0001"
        report "Erro: contador deveria reiniciar a contagem em 1"
        severity error;

		-- Teste 5: Caso extremo - período mínimo = 1
		enable <= '0';
        wait for CLK_PERIOD;

        period_pwm <= "0001";
        enable <= '1';

        wait for CLK_PERIOD;

        assert count = "0000"
        report "Erro: com periodo 1 o contador deve permanecer em 0"
        severity error;

		-- Teste 6: Caso extremo - período máximo = 15

		enable <= '0';
        wait for CLK_PERIOD;

        period_pwm <= "1111"; -- 15
        enable <= '1';

        wait for 14 * CLK_PERIOD;

        assert count = "1110"
        report "Erro: contador deveria valer 14"
        severity error;

        wait for CLK_PERIOD;

        assert count = "0000"
        report "Erro: contador deveria retornar para 0 após atingir 14"
        severity error;

		-- Teste 7: Caso extremo - período = 0
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

		CLK_ENABLE <= '0';
		wait;

	end process;
		
end tb;