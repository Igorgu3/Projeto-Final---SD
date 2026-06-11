library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench is
end testbench;

architecture tb of testbench is

constant W : positive := 4;

component comparador is
	generic (W: positive := 4);
	port (
        a  : in  std_logic_vector (W-1 downto 0);          
        b  : in  std_logic_vector (W-1 downto 0);            
 		maior, menor, igual : out  std_logic
    );
end component;

    signal a, b : std_logic_vector(W-1 downto 0);
    signal maior, menor, igual : std_logic;

begin
    
  	DUT: comparador port map(a => a, b => b, maior => maior, menor => menor, igual => igual);

stimulation : process

	begin
    	
        -- Caso: A < B
    	a <= "1001";
    	b <= "1101";
    
    	wait for 1 ns;
        
        assert (menor = '1' and maior = '0' and igual = '0')
		report "Erro: Deveria exibir que 9 é menor que 13"
		severity error;
    	
        -- Caso extremo: máx A > min B
    	a <= "1111";
    	b <= "0000";
    
    	wait for 1 ns;

		assert (menor = '0' and maior = '1' and igual = '0')
		report "Erro: Deveria exibir que 15 é maior que 0"
		severity error;

        -- Caso extremo: máx A = máx B
        a <= "1111";
    	b <= "1111";
    
    	wait for 1 ns;
       
        assert (menor = '0' and maior = '0' and igual = '1')
		report "Erro: Deveria exibir que 15 é igual a 15"
		severity error;
        
        -- Caso extremo: min A < máx B
        a <= "0000"; 
		b <= "1111";
        
        wait for 1 ns;
        
        assert (menor = '1' and maior = '0' and igual = '0')
		report "Erro: Deveria exibir que 0 é menor que 15"
		severity error;

        -- Caso extremo: min A = min B
        a <= "0000";
    	b <= "0000";
    
    	wait for 1 ns;
       
        assert (menor = '0' and maior = '0' and igual = '1')
		report "Erro: Deveria exibir que 0 é igual a 0"
		severity error;
        
         -- Caso: A > B
        a <= "0110"; 
		b <= "0101"; 

		wait for 1 ns;

		assert (maior = '1' and menor = '0' and igual = '0')
		report "Erro: Deveria exibir que 6 é maior que 5"
		severity error;
        
        report "Todos os testes passaram com sucesso"
		severity note;
    
    	wait;
    end process;
end tb;