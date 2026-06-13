-- Testbench para a controladora
--
-- Nesse testbench, vamos verificar o funcionamento da máquina de estados
-- responsavel por controlar o datapath do projeto.
--
-- Serao testadas as transicoes entre os estados INICIO, ESPERA,
-- VERIFICACAO, RUN e ERRO, verificando se os sinais de controle
-- gerados pela FSM estao de acordo com o comportamento esperado.
--
-- Tambem serao considerados casos extremos, como tentativa de iniciar
-- o sistema com parametros invalidos e recuperacao atraves de reset.

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 

entity testbench_controladora is
end testbench_controladora;

architecture tb_controladora of testbench_controladora is

constant W : positive := 4;

-- Instanciação da controladora
component controladora is
	generic(W : positive := 4);
    port(
	    CLK : in std_logic;
        RST : in std_logic;
        enable_project : in std_logic; 
        maior : in std_logic;
        menor : in std_logic;
        igual : in std_logic;
        enable_reg_period : out std_logic; 
        enable_reg_duty : out std_logic; 
        enable_Ger : out std_logic; 
        busy : out std_logic; 
        overflow : out std_logic; 
        state_fsm : out std_logic_vector (6 downto 0) 
    );
end component;

    -- Sinais intermediários para realização dos testes
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal enable_project : std_logic := '0';
    signal maior      : std_logic := '0';
    signal menor      : std_logic := '0';
    signal igual      : std_logic := '0';
    signal enable_reg_period : std_logic;
    signal enable_reg_duty : std_logic;
    signal enable_Ger : std_logic;
    signal busy       : std_logic;
    signal overflow   : std_logic;
    signal state_fsm  : std_logic_vector(6 downto 0);

    signal CLK_ENABLE : std_logic := '1';

    constant CLK_PERIOD : time := 10 ns;

begin
    clk <= CLK_ENABLE and not clk after CLK_PERIOD/2;

  	DUT: controladora port map(CLK => clk, RST => rst, enable_project => enable_project, maior => maior, menor => menor, igual => igual, enable_reg_period => enable_reg_period, enable_reg_duty => enable_reg_duty, enable_Ger => enable_Ger, busy => busy, overflow => overflow, state_fsm => state_fsm);

	stimulation : process

	begin

        -- Teste 1: Verificar estado inicial após reset
    
        RST <= '1';

        wait for CLK_PERIOD;

        RST <= '0';

        wait for 1 ns;

        assert (busy = '0')
        report "Erro: busy deveria iniciar em 0"
        severity error;

        assert (overflow = '0')
        report "Erro: overflow deveria iniciar em 0"
        severity error;

        -- Teste 2: Verificar transicao INICIO -> ESPERA

        wait for CLK_PERIOD;

        assert (state_fsm = "0010010") -- S
        report "Erro: Estado deveria ter ido para o estado de ESPERA"
        severity error;

        -- Teste 3: Verificar carregamento dos registradores
       
        enable_project <= '1';

        wait for CLK_PERIOD;

        assert (enable_reg_period = '1')
        report "Erro: enable_reg_period deveria estar habilitado"
        severity error;

        assert (enable_reg_duty = '1')
        report "Erro: enable_reg_duty deveria estar habilitado"
        severity error;

        -- Teste 4: Verificar transicao VERIFICACAO -> RUN

        maior <= '0';
        menor <= '1';
        igual <= '0';

        wait for CLK_PERIOD;

        assert (busy = '1')
        report "Erro: sistema deveria entrar em RUN"
        severity error;

        assert (enable_Ger = '1')
        report "Erro: gerador PWM deveria estar habilitado"
        severity error;

        assert (state_fsm = "0101111") -- R
        report "Erro: Estado deveria ter ido para o estado de RUN"
        severity error;

        -- Teste 5: Verificar permanencia em RUN
   
        wait for 3 * CLK_PERIOD;

        assert (busy = '1')
        report "Erro: sistema deveria permanecer em RUN"
        severity error;

        assert (state_fsm = "0101111") -- R
        report "Erro: Estado deveria ter ficado no estado de RUN"
        severity error;

        -- Teste 6: Verificar retorno para ESPERA
    
        enable_project <= '0';

        wait for CLK_PERIOD;

        assert (busy = '0')
        report "Erro: busy deveria retornar para 0"
        severity error;

        assert (state_fsm = "0010010") -- S
        report "Erro: Estado deveria ter voltado para o estado de ESPERA"
        severity error;

        -- Teste 7: Verificar deteccao de overflow

        enable_project <= '1';

        wait for CLK_PERIOD;

        maior <= '1';
        menor <= '0';
        igual <= '0';

        wait for CLK_PERIOD;

        assert (overflow = '1')
        report "Erro: overflow deveria estar ativo"
        severity error;

        assert (state_fsm = "0001110") -- E
        report "Erro: Estado deveria ter ido para o estado de ERRO"
        severity error;

        -- Teste 8: Verificar permanencia no estado ERRO
    
        maior <= '0';

        wait for 3 * CLK_PERIOD;

        assert (overflow = '1')
        report "Erro: deveria permanecer no estado ERRO"
        severity error;

        assert (state_fsm = "0001110") -- E
        report "Erro: Estado deveria ter permanecido no estado de ERRO"
        severity error;

        -- Teste 9: Verificar que o estado ERRO ignora alteracoes do comparador

        maior <= '0';
        menor <= '1';
        igual <= '0';

        wait for 2 * CLK_PERIOD;

        assert (overflow = '1')
        report "Erro: deveria permanecer no estado ERRO mesmo apos corrigir os parametros"
        severity error;

        assert (state_fsm = "0001110") -- E
        report "Erro: Estado deveria permanecer em ERRO ate ocorrer reset"
        severity error;

        -- Teste 10: Verificar prioridade do reset

        enable_project <= '1';
        RST <= '1';

        wait for 1 ns;

        assert (state_fsm = "1111001") -- I
        report "Erro: Reset deveria forcar retorno imediato ao estado INICIO"
        severity error;

        RST <= '0';
        enable_project <= '0';

        wait for CLK_PERIOD;

        -- Teste 11: Recuperacao via reset

        assert (overflow = '0')
        report "Erro: overflow deveria ser limpo apos reset"
        severity error;

        assert (state_fsm = "0010010") -- S
        report "Erro: Estado deveria retornar para ESPERA apos reset"
        severity error;

        -- Teste 12: Caso em que comparador indica igualdade

        enable_project <= '1';

        wait for CLK_PERIOD;

        maior <= '0';
        menor <= '0';
        igual <= '1';

        wait for CLK_PERIOD;

        assert (busy = '1')
        report "Erro: igualdade deveria permitir entrada em RUN"
        severity error;

        assert (state_fsm = "0101111") -- R
        report "Erro: Estado deveria ter ido para o estado de RUN"
        severity error;

        -- Teste 13: Verificar que o sistema detecta overflow mesmo com parametros invalidos ja presentes

        -- Parametros invalidos ja presentes antes da verificacao

        -- Sai de RUN

        enable_project <= '0';

        wait for CLK_PERIOD;

        -- Parametros invalidos antes da verificacao

        maior <= '1';
        menor <= '0';
        igual <= '0';

        enable_project <= '1';

        wait for 2 * CLK_PERIOD;

        assert (overflow = '1')
        report "Erro: sistema deveria detectar overflow imediatamente"
        severity error;

        assert (state_fsm = "0001110") -- E
        report "Erro: Estado deveria ter ido para ERRO"
        severity error;

        -- Finalizacao
    
        report "Todos os testes passaram com sucesso"
        severity note;

        CLK_ENABLE <= '0';

        wait;

    end process;

end tb_controladora;