library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is
component alu is
    Port ( A: in  STD_LOGIC_VECTOR (31 downto 0);
           B: in  STD_LOGIC_VECTOR (31 downto 0);
           op: in  STD_LOGIC_VECTOR (4 downto 0);
           Y: out STD_LOGIC_VECTOR (31 downto 0);
           Y_hi: out STD_LOGIC_VECTOR (31 downto 0);
           carry: out STD_LOGIC;
           borrow: out STD_LOGIC;
           zero: out STD_LOGIC;
           div_by_zero : out STD_LOGIC);
end component;

    signal A     : std_logic_vector(31 downto 0) := x"F0F0F0F0";
    signal B     : std_logic_vector(31 downto 0) := x"0FF00FF0";
    signal op          : std_logic_vector(4 downto 0)  := (others => '0');
    signal Y, Y_hi     : std_logic_vector(31 downto 0);
    signal carry       : std_logic;
    signal borrow      : std_logic;
    signal zero        : std_logic;
    signal div_by_zero : std_logic;

    constant ZERO32 : std_logic_vector(31 downto 0) := (others => '0');


begin

    uut : entity work.alu
        port map (
            A           => A,
            B           => B,
            op          => op,
            Y           => Y,
            Y_hi        => Y_hi,
            carry       => carry,
            borrow      => borrow,
            zero        => zero,
            div_by_zero => div_by_zero
        );

    stim : process

    begin
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00001";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00010";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00011";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00100";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00101";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00110";
        wait for 10 ns;
    
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "00111";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01000";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01001";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01010";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01011";
        wait for 10 ns;
        
    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01100";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01101";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01110";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "01111";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "10000";
        wait for 10 ns;

    A <= X"0000ABCD";
    B <= X"0000DCBA";
    op <= "10001";
        wait for 10 ns;

        wait;
    end process stim;

end Behavioral;

-- ~ nima ~
