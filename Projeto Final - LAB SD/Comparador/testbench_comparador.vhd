library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench_comparador is
end testbench_comparador;

architecture tb_comparador of testbench_comparador is

constant W : positive := 4;

component comparador is
	generic (W: positive := 4);
	port (
        a  : in  std_logic_vector (W-1 downto 0);          
        b  : in  std_logic_vector (W-1 downto 0);            
 		maior, menor, igual : out  std_logic
    );
end component;

    -- Sinais intermediários para realização dos testes
    signal a, b : std_logic_vector(W-1 downto 0);
    signal maior, menor, igual : std_logic;

begin
    
  	DUT: comparador port map(a => a, b => b, maior => maior, menor => menor, igual => igual);

	stimulation : process

	begin

        -- Teste 1: Verificar comparação onde A é menor que B

        -- Valores de teste onde A = 9 e B = 13
        a <= "1001"; -- 9
        b <= "1101"; -- 13

        wait for 1 ns; -- Espera a propagação dos sinais no comparador

        assert (menor = '1' and maior = '0' and igual = '0')
        report "Erro: Deveria exibir que 9 e menor que 13"
        severity error;

        -- Teste 2: Verificar caso extremo onde A possui o maior valor possível
        -- e B possui o menor valor possível

        a <= "1111"; -- 15
        b <= "0000"; -- 0

        wait for 1 ns;

        assert (menor = '0' and maior = '1' and igual = '0')
        report "Erro: Deveria exibir que 15 e maior que 0"
        severity error;

        -- Teste 3: Verificar igualdade utilizando os maiores valores possíveis

        -- Ambos os operandos recebem o valor máximo representável
        a <= "1111"; -- 15
        b <= "1111"; -- 15

        wait for 1 ns;

        assert (menor = '0' and maior = '0' and igual = '1')
        report "Erro: Deveria exibir que 15 e igual a 15"
        severity error;

        -- Teste 4: Verificar caso extremo onde A possui o menor valor possível
        -- e B possui o maior valor possível

        a <= "0000"; -- 0
        b <= "1111"; -- 15

        wait for 1 ns;

        assert (menor = '1' and maior = '0' and igual = '0')
        report "Erro: Deveria exibir que 0 e menor que 15"
        severity error;

        -- Teste 5: Verificar igualdade utilizando os menores valores possíveis

        a <= "0000"; -- 0
        b <= "0000"; -- 0

        wait for 1 ns;

        assert (menor = '0' and maior = '0' and igual = '1')
        report "Erro: Deveria exibir que 0 e igual a 0"
        severity error;

        -- Teste 6: Verificar comparação onde A é maior que B

        -- Valores de teste onde A = 6 e B = 5
        a <= "0110"; -- 6
        b <= "0101"; -- 5

        wait for 1 ns;

        assert (maior = '1' and menor = '0' and igual = '0')
        report "Erro: Deveria exibir que 6 e maior que 5"
        severity error;

        report "Todos os testes passaram com sucesso"
        severity note;

        wait;

    end process;
end tb_comparador;