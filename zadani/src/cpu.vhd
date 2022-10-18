-- cpu.vhd: Simple 8-bit CPU (BrainFuck interpreter)
-- Copyright (C) 2022 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Jakub Kratochvil <xkrato67@stud.fit.vutbr.cz>
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
    CLK   : in std_logic;  -- hodinovy signal
    RESET : in std_logic;  -- asynchronni reset procesoru
    EN    : in std_logic;  -- povoleni cinnosti procesoru

    -- synchronni pamet RAM
    DATA_ADDR  : out std_logic_vector(12 downto 0); -- adresa do pameti
    DATA_WDATA : out std_logic_vector(7 downto 0); -- mem[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
    DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
    DATA_RDWR  : out std_logic;                    -- cteni (0) / zapis (1)
    DATA_EN    : out std_logic;                    -- povoleni cinnosti
   
    -- vstupni port
    IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA <- stav klavesnice pokud IN_VLD='1' a IN_REQ='1'
    IN_VLD    : in std_logic;                      -- data platna
    IN_REQ    : out std_logic;                     -- pozadavek na vstup data
   
    -- vystupni port
    OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
    OUT_BUSY : in std_logic;                       -- LCD je zaneprazdnen (1), nelze zapisovat
    OUT_WE   : out std_logic                       -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cnt is 
  port (
    CLK   : in std_logic;
    RESET : in std_logic;
    -- vstupni port
    IN_INC  : in std_logic;
    IN_DEC  : in std_logic;
    -- vystupni port
    OUT_CNT : out std_logic_vector(10 downto 0)
  );
end cnt;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pc is
  port (
    CLK   : in std_logic;
    RESET : in std_logic;
    -- vstupni port
    IN_INC : in std_logic;
    IN_DEC : in std_logic;
    -- vystupni port
    OUT_PC  : out std_logic_vector(12 downto 0)
  );
end pc;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ptr is
  port (
    CLK   : in std_logic;
    RESET : in std_logic;
    -- vstupni port
    IN_INC  : in std_logic;
    IN_DEC  : in std_logic;
    -- vystupni port
    OUT_PTR : out std_logic_vector(12 downto 0)
  );
end ptr;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mx1 is
  port (
    SEL : in std_logic;
    -- vstupni port
    IN_DATA_PC   : in std_logic_vector(12 downto 0);
    IN_DATA_PTR  : in std_logic_vector(12 downto 0);
    -- vystupni port
    OUT_MX1 : out std_logic_vector(12 downto 0)
  );
end mx1;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mx2 is
  port (
    SEL : in std_logic_vector(1 downto 0);
    -- vstupni port
    IN_DATA      : in std_logic_vector(7 downto 0);
    IN_DATA_INC  : in std_logic_vector(7 downto 0);
    IN_DATA_DEC  : in std_logic_vector(7 downto 0);
    -- vystupni port
    OUT_MX2 : out std_logic_vector(7 downto 0)
  );
end mx2;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fsm is
  port (
    CLK   : in std_logic;
    RESET : in std_logic;
    EN    : in std_logic;

    -- vstupni port
    IN_VLD        : in std_logic;
    OUT_BUSY       : in std_logic;
    IN_CNT        : in std_logic_vector(10 downto 0);
    IN_RDATA      : in std_logic_vector(7 downto 0);

    -- vystupni port
    IN_REQ       : out std_logic;
    OUT_DATA      : out std_logic_vector(7 downto 0);
    OUT_WE        : out std_logic;
    OUT_INC_CNT   : out std_logic;
    OUT_DEC_CNT   : out std_logic;
    OUT_INC_PC    : out std_logic;
    OUT_DEC_PC    : out std_logic;
    OUT_INC_PTR   : out std_logic;
    OUT_DEC_PTR   : out std_logic;
    OUT_SEL_MX1   : out std_logic;
    OUT_SEL_MX2   : out std_logic_vector(1 downto 0);
    OUT_DATA_RDWR : out std_logic;
    OUT_DATA_EN   : out std_logic
  );
end fsm;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is
  -- CNT
  signal cnt_val  : std_logic_vector(10 downto 0);
  signal inc_cnt  : std_logic;
  signal dec_cnt  : std_logic;
  -- PC
  signal pc_adr   : std_logic_vector(12 downto 0);
  signal inc_pc   : std_logic;
  signal dec_pc   : std_logic;
  -- PTR
  signal ptr_adr  : std_logic_vector(12 downto 0);
  signal inc_ptr  : std_logic;
  signal dec_ptr  : std_logic;
  -- MX1
  signal sel_mx1  : std_logic;
  -- MX2
  signal sel_mx2  : std_logic_vector(1 downto 0);
  
begin
  i_cnt : entity work.cnt(behavioral)
    port map(
      CLK   => CLK,
      RESET => RESET,
      -- vstupni port
      IN_INC  => inc_cnt,
      IN_DEC  => dec_cnt,
      -- vystupni port
      OUT_CNT => cnt_val
    );

  i_pc : entity work.pc(behavioral)
    port map(
      CLK   => CLK,
      RESET => RESET,
      -- vstupni port
      IN_INC  => inc_pc,
      IN_DEC  => dec_pc,
      -- vystupni port
      OUT_PC  => pc_adr
    );

  i_ptr : entity work.ptr(behavioral)
    port map(
      CLK   => CLK,
      RESET => RESET,
      -- vstupni port
      IN_INC  => inc_ptr,
      IN_DEC  => dec_ptr,
      -- vystupni port
      OUT_PTR => ptr_adr
    );

  i_mx1 : entity work.mx1(dataflow)
    port map(
      SEL => sel_mx1,
      -- vstupni port
      IN_DATA_PC  => pc_adr, 
      IN_DATA_PTR => ptr_adr,
      -- vystupni port
      OUT_MX1 => DATA_ADDR
    );

  i_mx2 : entity work.mx2(dataflow)
    port map(
      SEL => sel_mx2, 
      -- vstupni port
      IN_DATA     => IN_DATA,
      IN_DATA_INC => DATA_RDATA,
      IN_DATA_DEC => DATA_RDATA,
      -- vystupni port
      OUT_MX2 => DATA_WDATA
    );

  i_fsm : entity work.fsm(behavioral)
    port map (
      CLK   => CLK,
      RESET => RESET,
      EN    => EN, 
      -- vstupni port
      IN_VLD    => IN_VLD,
      OUT_BUSY  => OUT_BUSY,
      IN_CNT    => cnt_val, 
      IN_RDATA  => DATA_RDATA,
      -- vystupni port
      IN_REQ        => IN_REQ,
      OUT_DATA      => OUT_DATA,
      OUT_WE        => OUT_WE,
      OUT_INC_CNT   => inc_cnt,
      OUT_DEC_CNT   => dec_cnt,
      OUT_INC_PC    => inc_pc, 
      OUT_DEC_PC    => dec_pc,
      OUT_INC_PTR   => inc_ptr,
      OUT_DEC_PTR   => dec_ptr,
      OUT_SEL_MX1   => sel_mx1,
      OUT_SEL_MX2   => sel_mx2,
      OUT_DATA_RDWR => DATA_RDWR,
      OUT_DATA_EN   => DATA_EN
    );
end behavioral;

architecture behavioral of cnt is
  signal cnt_val: std_logic_vector(10 downto 0);
begin
  cnt: process(CLK, RESET)
  begin
    if RESET = '1' then
      cnt_val <= "00000000000";
    elsif rising_edge(CLK) then
      if IN_INC = '1' then
        cnt_val <= cnt_val + 1;
      elsif IN_DEC = '1' then
        cnt_val <= cnt_val - 1;
      end if;
    end if;
  end process;
  OUT_CNT <= cnt_val;
end behavioral;

architecture behavioral of pc is
  signal pc_val: std_logic_vector(12 downto 0);
begin
  pc: process(CLK, RESET)
  begin
    if RESET = '1' then
      pc_val <= "0000000000000";
    elsif rising_edge(CLK) then
      if IN_INC = '1' then
        pc_val <= pc_val + 1;
      elsif IN_DEC = '1' then
        pc_val <= pc_val - 1;
      end if;
    end if;
  end process;
  OUT_PC <= pc_val;
end behavioral;

architecture behavioral of ptr is
  signal ptr_val: std_logic_vector(12 downto 0);
begin
  ptr: process(CLK, RESET)
  begin
    if RESET = '1' then
      ptr_val <= "1000000000000";
    elsif rising_edge(CLK) then
      if IN_INC = '1' then
        ptr_val <= ptr_val + 1;
      elsif IN_DEC = '1' then
        ptr_val <= ptr_val - 1;
      end if;
    end if;
  end process;
  OUT_PTR <= ptr_val;
end behavioral;

architecture dataflow of mx1 is
begin
  OUT_MX1 <= IN_DATA_PC when (SEL = '0') else IN_DATA_PTR;
end dataflow;

architecture dataflow of mx2 is
begin
  OUT_MX2 <= IN_DATA          when (SEL = "00") else
             IN_DATA_DEC - 1  when (SEL = "01") else
             IN_DATA_INC + 1  when (SEL = "10");
end dataflow;

architecture behavioral of fsm is
  type fsm_state is (
    sIdle, 
    sFetch,
    sDecode, 
    sInc_ptr, 
    sDec_ptr, 
    sInc_data0, sInc_data1, 
    sDec_data0, sDec_data1, 
    sLeft_sq0, sLeft_sq1, sLeft_sq2, sLeft_sq3,
    sRight_sq0, sRight_sq1, sRight_sq2, sRight_sq3, sRight_sq4, 
    sLeft_pa0, 
    sRight_pa0, sRight_pa1, sRight_pa2, sRight_pa3, sRight_pa4, 
    sPrint_data0, sPrint_data1, sPrint_data2, 
    sLoad_save0, sLoad_save1, 
    sHalt,
    sOther
    );
  signal pstate   : fsm_state;
  signal nstate   : fsm_state;
begin
  pstate_reg: process(CLK, RESET)
  begin
    if RESET = '1' then
      pstate <= sIdle;
    elsif rising_edge(CLK) and en = '1' then
      pstate <= nstate;
    end if;
  end process;

  nstate_lgc: process(pstate, IN_VLD, OUT_BUSY, IN_CNT, IN_RDATA)
  begin
    IN_REQ       <= '0';   
    OUT_DATA      <= x"00";
    OUT_WE        <= '0';
    OUT_INC_CNT   <= '0';
    OUT_DEC_CNT   <= '0';
    OUT_INC_PC    <= '0';
    OUT_DEC_PC    <= '0';
    OUT_INC_PTR   <= '0';
    OUT_DEC_PTR   <= '0';
    OUT_SEL_MX1   <= '0';
    OUT_SEL_MX2   <= "00";
    OUT_DATA_RDWR <= '0';
    OUT_DATA_EN   <= '0';

    case pstate is
      when sIdle =>
        nstate <= sFetch;
      
      when sFetch =>
        nstate <= sDecode;
        OUT_SEL_MX1   <= '0';
        OUT_DATA_EN   <= '1';

      when sDecode =>
        case IN_RDATA is
          when x"3E" =>            -- ">"
            nstate <= sInc_ptr;   
          when x"3C" =>            -- "<"    
            nstate <= sDec_ptr;
          when x"2B" =>            -- "+"
            nstate <= sInc_data0;
          when x"2D" =>            -- "-"
            nstate <= sDec_data0;
          when x"5B" =>            -- "["
            nstate <= sLeft_sq0;
          when x"5D" =>            -- "]"
            nstate <= sRight_sq0;
          when x"28" =>            -- "("
            nstate <= sLeft_pa0;
          when x"29" =>            -- ")"
            nstate <= sRight_pa0;
          when x"2E" =>            -- "."
            nstate <= sPrint_data0;  
          when x"2C" =>            -- ","
            nstate <= sLoad_save0;
          when x"00" =>            -- null
            nstate <= sHalt;
          when others =>           -- ostatni
            nstate <= sOther;
        end case;
      
      -- ">"
      when sInc_ptr =>
        nstate <= sFetch;
        OUT_INC_PTR <= '1';
        OUT_INC_PC <= '1';

      -- "<"
      when sDec_ptr =>
        nstate <= sFetch;
        OUT_DEC_PTR <= '1';
        OUT_INC_PC <= '1';
      
      -- "+"
      when sInc_data0 =>
        nstate <= sInc_data1;
        OUT_SEL_MX1 <= '1';
        OUT_DATA_EN <= '1';

      when sInc_data1 =>
        nstate <= sFetch;
        OUT_SEL_MX1 <= '1';
        OUT_SEL_MX2 <= "10";
        OUT_DATA_EN <= '1';
        OUT_DATA_RDWR <= '1';
        OUT_INC_PC <= '1';

      -- "-"
      when sDec_data0 =>
        nstate <= sDec_data1;
        OUT_SEL_MX1 <= '1';
        OUT_DATA_EN <= '1';
          
      when sDec_data1 =>
        nstate <= sFetch;
        OUT_SEL_MX1 <= '1';
        OUT_SEL_MX2 <= "01";
        OUT_DATA_EN <= '1';
        OUT_DATA_RDWR <= '1';
        OUT_INC_PC <= '1';

      -- "["
      when sLeft_sq0 =>
        nstate <= sLeft_sq1;
        OUT_INC_PC <= '1';
        OUT_SEL_MX1 <= '1';
        OUT_DATA_EN <= '1';

      when sLeft_sq1 =>
        if IN_RDATA = x"00" then
          nstate <= sLeft_sq2;
        else 
          nstate <= sFetch;
        end if;
      
      when sLeft_sq2 =>
          nstate <= sLeft_sq3;
          OUT_SEL_MX1 <= '0';
          OUT_DATA_EN <= '1';
          OUT_INC_PC <= '1';

      when sLeft_sq3 =>
        if IN_RDATA = x"5D" then
          nstate <= sFetch;
        else
          nstate <= sLeft_sq2;
        end if;

      -- "]"
      when sRight_sq0 =>
        nstate <= sRight_sq1;
        OUT_SEL_MX1 <= '1';
        OUT_DATA_EN <= '1';

      when sRight_sq1 =>
        if IN_RDATA /= x"00" then
          nstate <= sRight_sq2;
        else 
          nstate <= sRight_sq4;
        end if;
      
      when sRight_sq2 =>
        nstate <= sRight_sq3;
        OUT_DEC_PC <= '1';
        OUT_SEL_MX1 <= '0';
        OUT_DATA_EN <= '1';

      when sRight_sq3 =>
        if IN_RDATA = x"5B" then
          nstate <= sRight_sq4;
        else
          nstate <= sRight_sq2;
        end if;

      when sRight_sq4 =>
        nstate <= sFetch;
        OUT_INC_PC <= '1';

      -- "("
      when sLeft_pa0 =>
        nstate <= sFetch;
        OUT_INC_PC <= '1';

      -- ")"
      when sRight_pa0 =>
        nstate <= sRight_pa1;
        OUT_SEL_MX1 <= '1';
        OUT_DATA_EN <= '1';

      when sRight_pa1 =>
        if IN_RDATA /= x"00" then
          nstate <= sRight_pa2;
        else
          nstate <= sRight_pa4;
        end if;

      when sRight_pa2 =>
        nstate <= sRight_pa3;
        OUT_DEC_PC <= '1';
        OUT_SEL_MX1 <= '0';
        OUT_DATA_EN <= '1';

      when sRight_pa3 =>
        if IN_RDATA = x"28" then
          nstate <= sRight_pa4;
        else
          nstate <= sRight_pa2;
        end if;
      
      when sRight_pa4 =>
        nstate <= sFetch;
        OUT_INC_PC <= '1';

      -- "."
      when sPrint_data0 =>
        if OUT_BUSY = '1' then
          nstate <= sPrint_data0;
        else
          nstate <= sPrint_data1;
        end if;

      when sPrint_data1 =>
        nstate <= sPrint_data2;
        OUT_SEL_MX1 <= '1';
        OUT_DATA_EN <= '1';

      when sPrint_data2 =>
        nstate <= sFetch;
        OUT_WE <= '1';
        OUT_DATA <= IN_RDATA;
        OUT_INC_PC <= '1';

      -- ","
      when sLoad_save0 =>
        IN_REQ <= '1';
        if IN_VLD = '0' then
          nstate <= sLoad_save0;
        else
          nstate <= sLoad_save1;
        end if;

      when sLoad_save1 =>
        nstate <= sFetch;
        OUT_SEL_MX1   <= '1';
        OUT_SEL_MX2   <= "00";
        OUT_DATA_EN   <= '1';
        OUT_DATA_RDWR <= '1';
        OUT_INC_PC <= '1';

      -- null
      when sHalt =>
        nstate <= sHalt;
      
      -- ostatni
      when sOther =>
        nstate <= sFetch;
        OUT_INC_PC <= '1';

    end case;  
  end process;
end behavioral;
