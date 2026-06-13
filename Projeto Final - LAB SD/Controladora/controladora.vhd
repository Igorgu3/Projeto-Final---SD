library IEEE;
use IEEE.std_logic_1164.all;

entity controladora is
    generic(W : positive := 4);
    port(
	    CLK : in std_logic;
        RST : in std_logic;
        enable_project : in std_logic; -- Sinal de habilitação para o projeto

        -- Entradas vindas do datapath
        maior : in std_logic;
        menor : in std_logic;
        igual : in std_logic;

        -- Saídas para o datapath
        enable_reg_period : out std_logic; -- Sinal de habilitação para o registrador de período do PWM 
        enable_reg_duty : out std_logic; -- Sinal de habilitação para o registrador de duty cycle do PWM 
        enable_Ger : out std_logic; -- Sinal de habilitação para o gerador de PWM 

        busy : out std_logic; -- Sinal para indicar que o projeto está em funcionamento
        overflow : out std_logic; -- Sinal para indicar que houve um erro de overflow (quando o duty cycle é maior que o período)
        state_fsm : out std_logic_vector (6 downto 0) -- Saída para exibir o estado atual da FSM em um display de 7 segmentos
    );
end controladora;

architecture control of controladora is

    -- Definição dos estados da FSM
	type state_type is (
        INICIO, 
        ESPERA, 
        VERIFICACAO,
        RUN,
        ERRO
    );

	signal state, next_state : state_type;
    signal hex_result: std_logic_vector (6 downto 0);

begin

    -- Processo inicial e de transição de estados
	sync_proc : process(CLK, RST)
	    begin
		    if RST = '1' then
			    state <= INICIO;
		    elsif rising_edge(CLK) then
			    state <= next_state;
		    end if;
	end process;

    -- Processo combinacional para determinar o próximo estado e as saídas com base no estado atual e nas entradas
	
    comb_proc : process(state, enable_project, maior, menor, igual)
	    begin

            -- Valores padroes para evitar latches
            enable_reg_period <= '0';
            enable_reg_duty <= '0';
            enable_Ger <= '0';
            overflow <= '0';
            busy <= '0';

		    next_state <= state; 

		    case state is

			    when INICIO =>

                    enable_reg_period <= '0';
                    enable_reg_duty <= '0';
                    enable_Ger <= '0';
                    overflow <= '0';
                    busy <= '0';

				    if enable_project = '0' then
					    next_state <= ESPERA;
                    else
                        next_state <= INICIO;
				    end if;

			    when ESPERA =>
				    if enable_project = '1' then
					    next_state <= VERIFICACAO;
                        enable_reg_period <= '1';
                        enable_reg_duty <= '1';
                    else
                        next_state <= ESPERA;
                    end if;

			    when VERIFICACAO =>
                    if maior = '1' then
                        next_state <= ERRO;
                    else 
                        next_state <= RUN;
                        enable_reg_period <= '0';
                        enable_reg_duty <= '0';
                    end if;
                when RUN =>
                    enable_Ger <= '1';
                    busy <= '1';

                    if enable_project = '0' then
                        next_state <= ESPERA;
                    end if;

                when ERRO =>
                    overflow <= '1';
                    next_state <= ERRO;
			    when others =>
					next_state <= INICIO;
		    end case;
	end process;

	hexprocess : process(state)
        begin
            case state is

            when INICIO =>
                hex_result <= "1111001"; -- I

            when ESPERA =>
                hex_result <= "0010010"; -- S

            when VERIFICACAO =>
                hex_result <= "1000001"; -- V

            when RUN =>
                hex_result <= "0101111"; -- r

            when ERRO =>
                hex_result <= "0000110"; -- E

            when others =>
                hex_result <= "1111111"; -- Desligado
        end case;
    end process;
    
    state_fsm <= hex_result;
    
end architecture;