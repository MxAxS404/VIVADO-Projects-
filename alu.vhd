--   op  operation                         Y              Y_hi          flag set
--   --  --------------------------------  -------------  ------------  -------------
--   12  A + 1                             result         0             carry  = carry out
--   13  A - 1                             result         0             borrow = 1 when A = 0
--   14  A + B                             sum[31:0]      0             carry  = carry out
--   15  A - B                             diff[31:0]     0             borrow = 1 when A < B
--   16  A * B                             prod[31:0]     prod[63:32]   0
--   17  A / B                             quotient       remainder     0
--   div_by_zero = '1' only for op 17 with B = 0 (Y = Y_hi = 0 in that case).
--   zero = '1' when Y = 0 and Y_hi = 0.
--   carry  flag: set only by op 12 (A+1) and op 14 (A+B)   -> carry out.
--   borrow flag: set only by op 13 (A-1) and op 15 (A-B)   -> unsigned underflow.
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity alu is
    Port ( A: in  STD_LOGIC_VECTOR (31 downto 0);
           B: in  STD_LOGIC_VECTOR (31 downto 0);
           op: in  STD_LOGIC_VECTOR (4 downto 0);
           Y: out STD_LOGIC_VECTOR (31 downto 0);
           Y_hi: out STD_LOGIC_VECTOR (31 downto 0);
           carry: out STD_LOGIC;
           borrow: out STD_LOGIC;
           zero: out STD_LOGIC;
           div_by_zero : out STD_LOGIC);
end alu;

architecture Behavioral of alu is

    constant OP_NOT_A: integer := 1;
    constant OP_NOT_B: integer := 2;
    constant OP_AND: integer := 3;
    constant OP_NAND: integer := 4;
    constant OP_OR: integer := 5;
    constant OP_XOR: integer := 6;
    constant OP_XNOR: integer := 7;
    constant OP_NOTA_AND_B: integer := 8;
    constant OP_A_AND_NOTB: integer := 9;
    constant OP_LSL: integer := 10;
    constant OP_ROL: integer := 11;
    constant OP_INC: integer := 12;
    constant OP_DEC: integer := 13;
    constant OP_ADD: integer := 14;
    constant OP_SUB: integer := 15;
    constant OP_MUL     : integer := 16;
    constant OP_DIV        : integer := 17;


    ------------------------------------------------------------------
    -- Internal signals  (bit 32 of the *33 signals = carry/borrow)  
    ------------------------------------------------------------------
    signal a_u, b_u    : unsigned(31 downto 0);
    signal sum33       : unsigned(32 downto 0);   -- bit 32 = carry out
    signal diff33      : unsigned(32 downto 0);   -- bit 32 = borrow
    signal inc33       : unsigned(32 downto 0);
    signal dec33       : unsigned(32 downto 0);
    signal prod64      : unsigned(63 downto 0);
    signal div32       : unsigned(31 downto 0);   -- remainder & quotient
    signal b_is_zero   : std_logic;

    signal y_i         : std_logic_vector(31 downto 0);
    signal yhi_i       : std_logic_vector(31 downto 0);
    signal carry_i     : std_logic;
    signal borrow_i    : std_logic;
    signal div0_i      : std_logic;

begin

    ------------------------------------------------------------------
    -- Functional units: all compute in parallel from A and B
    ------------------------------------------------------------------
    a_u <= unsigned(A);
    b_u <= unsigned(B);

    sum33 <= ('0' & a_u) + ('0' & b_u);
    diff33 <= ('0' & a_u) - ('0' & b_u);
    inc33 <= ('0' & a_u) + 1;
    dec33 <= ('0' & a_u) - 1;
    prod64 <= a_u * b_u;
    div32 <= a_u / b_u;
    b_is_zero <= '1' when b_u = 0 else '0';

    ------------------------------------------------------------------
    -- Output mux (purely combinational, defaults first -> no latches) 
    ------------------------------------------------------------------
    alu_mux : process (All)
    begin
        y_i <= (others => '0');
        yhi_i <= (others => '0');
        carry_i <= '0';
        borrow_i <= '0';
        div0_i <= '0';

        case to_integer(unsigned(op)) is
            when OP_NOT_A => 
                y_i <= not A;
                
            when OP_NOT_B =>
                y_i <= not B;
                
            when OP_AND => 
                y_i <= A and B;
                
            when OP_NAND => 
                y_i <= A nand B;
                
            when OP_OR => 
                y_i <= A or B;
                
            when OP_XOR  => 
                y_i <= A xor B;
                
            when OP_XNOR => 
                y_i <= A xnor B;
                
            when OP_NOTA_AND_B => 
                y_i <= (not A) and B;
                
            when OP_A_AND_NOTB => 
                y_i <= A and (not B);
                
            when OP_LSL => 
                y_i <= A(30 downto 0) & '0';
                
            when OP_ROL => 
                y_i <= A(30 downto 0) & A(31);
                
            when OP_INC =>
                y_i     <= std_logic_vector(inc33(31 downto 0));
                carry_i <= inc33(32);
                
            when OP_DEC =>
                y_i     <= std_logic_vector(dec33(31 downto 0));
                borrow_i <= dec33(32);

            when OP_ADD =>
                y_i     <= std_logic_vector(sum33(31 downto 0));
                carry_i <= sum33(32);

            when OP_SUB =>
                y_i     <= std_logic_vector(diff33(31 downto 0));
                borrow_i <= diff33(32);

            when OP_MUL =>
                y_i   <= std_logic_vector(prod64(31 downto 0));
                yhi_i <= std_logic_vector(prod64(63 downto 32));

            when OP_DIV =>
                if b_is_zero = '1' then
                    div0_i <= '1';
                else
                    y_i   <= std_logic_vector(div32(31 downto 0));    -- quotient
--                    yhi_i <= std_logic_vector(div32(63 downto 32));   -- remainder
                end if;

            when others => null;
        end case;
    end process alu_mux;

    ------------------------------------------------------------------
    -- Outputs and flags
    ------------------------------------------------------------------
    Y           <= y_i;
    Y_hi        <= yhi_i;
    carry       <= carry_i;
    borrow      <= borrow_i;
    div_by_zero <= div0_i;
    zero        <= '1' when (y_i = x"00000000" and yhi_i = x"00000000") else '0';

end Behavioral;

-- ~ zedi ~
