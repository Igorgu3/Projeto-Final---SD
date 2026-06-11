library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
    generic(W : positive := 4);
    port(
        clk    : in std_logic;
        enable : in std_logic;
        d      : in std_logic_vector(W-1 downto 0);
        q      : out std_logic_vector(W-1 downto 0)
    );
end entity;

architecture behavioral of registrador is
    signal reg : std_logic_vector(W - 1 downto 0) := (others => '0');
    begin
        process(clk)
            begin
	            if rising_edge(clk) then
                    if enable = '1' then
                        reg <= d;
                    end if;
                end if;
        end process;
        q <= reg;
end behavioral;