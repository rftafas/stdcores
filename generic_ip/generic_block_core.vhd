----------------------------------------------------------------------------------------------------------
-- Gneric AXI buffered machine.
-- This is open source code licensed under LGPL.
-- By using it on your system you agree with all LGPL conditions.
-- This code is provided AS IS, without any sort of warranty.
-- Author: Ricardo F Tafas Jr
-- 2019
---------------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
library stdcores;
    use stdcores.genecic_block_pkg.all;

entity genecic_block_core is
    generic (
        ram_addr     : integer;
        pipe_num     : integer;
        data_size    : integer
    );
    port (
        mclk_i       : in  std_logic;
        arst_i       : in  std_logic;

        --gets data
        tready_o     : out std_logic;
        tdata_i      : in  std_logic_vector(data_size-1 downto 0);
        tvalid_i     : in  std_logic;
        tlast_i      : in  std_logic;
        tuser_i      : in  std_logic_vector;
        tdest_i      : in  std_logic_vector;
        --puts data
        tvalid_o     : out std_logic;
        tdata_o      : out std_logic_vector(data_size-1 downto 0);
        tlast_o      : out std_logic;
        tready_i     : in  std_logic;
        tuser_o      : out std_logic_vector;
        tdest_o      : out std_logic_vector;


        --status and configuration registers
        packet_size  : in  std_logic_vector(31 downto 0);
        busy_o       : out std_logic
    );
end genecic_block_core;

architecture behavioral of genecic_block_core is


    signal rx_ok   : std_logic;
    signal px_ok   : std_logic;
    signal rx_done : std_logic;
    signal px_done : std_logic;
    signal tx_done : std_logic;

    signal aux_valid : std_logic;

    signal data1_s       : std_logic_vector(127 downto 0);
    signal data2_s       : std_logic_vector(127 downto 0);

    signal write1_cnt   : unsigned(ram_addr-1 downto 0);
    signal read1_cnt    : unsigned(ram_addr-1 downto 0);
    signal write2_cnt   : unsigned(ram_addr-1 downto 0);
    signal read2_cnt    : unsigned(ram_addr-1 downto 0);

    type ram_type is array (0 to 2**ram_addr-1) of std_logic_vector(127 downto 0);
    signal ram1_s : ram_type;
    signal ram2_s : ram_type;

    type control_t is (
        idle,   --waiting data.
        halt,   --timing adjustment to start processing accumulated data.
        set,    --processing accumulated data.
        run,    --processing accumulated data.
        reload,  --somehow, it was slower to deliver than to get new data. system is clogged.
        exception
    );

    signal rx_control_mq : control_t;
    signal px_control_mq : control_t;
    signal tx_control_mq : control_t;

    type tuser_type is array (pipe_num-1 downto 0) of std_logic_vector(tuser_i'range);
    signal tuser_s : tuser_type;

    type tdest_type is array (pipe_num-1 downto 0) of std_logic_vector(tdest_i'range);
    signal tdest_s : tdest_type;

    signal index_t : integer;

begin

    --this block is an example. it could contain a lot more blocks than this.
    --the architecture here just explains hou to gererate signal for the interface controllers using
    --much more simplified bus of data and enable.
    --it has a master that gets data from AXI-S controller whenever it has data.
    --it is not so forgiving then AXI-Stream bus cannot get its output.

    ---------------------------------------------------------------------------------------------------------------------
    -- Global outputs
    ---------------------------------------------------------------------------------------------------------------------
    busy_o <= '1' when rx_control_mq = exception else '0';


    ---------------------------------------------------------------------------------------------------------------------
    -- INPUT CONTROL
    ---------------------------------------------------------------------------------------------------------------------
    process(mclk_i)
      variable start_pointer_v : unsigned(write1_cnt'range) := (others=>'0');
      variable end_pointer_v   : unsigned(write1_cnt'range) := (others=>'0');
    begin
      if arst_i = '0' then
          rx_control_mq <= idle;
          start_pointer_v := (others=>'0');
          end_pointer_v   := (others=>'1');
          write1_cnt      <= (others=>'0');
      elsif rising_edge(mclk_i) then

                case rx_control_mq is
                    when idle =>
                      if tvalid_i = '1' and index_t < pipe_num-1 then
                        rx_control_mq <= set;
                      end if;

                    when set =>
                      if start_pointer_v = end_pointer_v then
                        rx_control_mq <= exception;
                      else
                        rx_control_mq <= run;
                      end if;

                    when halt =>
                      --must have data and spare space.
                      write1_cnt <= end_pointer_v;
                      if tvalid_i = '1' then
                        rx_control_mq <= run;
                      end if;

                    when run =>
                      end_pointer_v := write1_cnt;
                      write1_cnt    <= write1_cnt + 1;
                      ram1_s(to_integer(write1_cnt)) <= tdata_i;
                      if tvalid_i = '0' then
                        rx_control_mq <= halt;
                      elsif tlast_i = '1' then
                        rx_control_mq <= reload;
                      elsif write1_cnt = start_pointer_v-1 then
                        rx_control_mq <= exception;
                      end if;

                    when exception =>
                      --we fall here if our machine is clogged, this means that its output is slower than
                      --input.
                      end_pointer_v := start_pointer_v-1;
                      if rx_ok = '1' then
                        rx_control_mq <= run;
                      end if;

                    when reload =>
                      --future improvement: não preciso passar por idle.
                      --posso ir direto para receber o dado.
                      end_pointer_v     := start_pointer_v;
                      start_pointer_v   := write1_cnt;
                      if rx_ok = '1' then
                        rx_control_mq <= idle;
                      end if;

                    when others =>
                        rx_control_mq <= idle;

                end case;
        end if;
     end process;

    --getting data to place on the working memory.
    tready_o <= '1' when rx_control_mq = run    else
                '0';

    aux_valid <= '1' when rx_control_mq = set    else
                 '0';

    rx_done <= '1' when rx_control_mq = reload else
               '0';
    ---------------------------------------------------------------------------------------------------------------------
    -- Processing CONTROL
    ---------------------------------------------------------------------------------------------------------------------
    process(mclk_i)
      variable end_pointer_v   : unsigned(write1_cnt'range) := (others=>'0');
      variable start_pointer_v : unsigned(write1_cnt'range) := (others=>'0');
      variable last_pointer_v  : unsigned(write1_cnt'range) := (others => '0');
    begin
      if arst_i = '0' then
          px_control_mq <= idle;
          end_pointer_v   := (others=>'1');
          start_pointer_v := (others=>'0');
          read1_cnt       <= (others=>'0');
          write2_cnt      <= (others=>'0');
      elsif rising_edge(mclk_i) then

                case px_control_mq is
                    when idle =>
                      --diferente da entrada, o fim de pacote é sempre variável.
                      last_pointer_v   := write1_cnt;
                      --start_pointer_v
                      if rx_done = '1' then
                        px_control_mq   <= set;
                      end if;

                    when  set =>
                      if start_pointer_v = end_pointer_v then
                        px_control_mq <= exception;
                      else
                        px_control_mq <= run;
                      end if;
                      read1_cnt  <= read1_cnt + 1;
                      data1_s    <= ram1_s(to_integer(read1_cnt));

                    when run =>
                      --THIS STATE MAY HAVE AN INTERNAL CASE/LOOP REGARDING ROUNDS.
                      --whatever it does, it should do between start and end pointer.
                      read1_cnt  <= read1_cnt + 1;
                      data1_s    <= ram1_s(to_integer(read1_cnt));
                      write2_cnt <= write2_cnt + 1;
                      ram2_s(to_integer(write2_cnt)) <= data2_s;
                      if read1_cnt = last_pointer_v then
                        px_control_mq <= reload;
                      elsif write2_cnt = start_pointer_v-1 then
                        px_control_mq <= exception;
                      end if;

                    when exception =>
                      --we fall here if our machine is clogged, this means that its output is slower than
                      --input.
                      end_pointer_v := start_pointer_v-1;
                      if px_ok = '1' then
                        px_control_mq <= run;
                      end if;

                    when reload =>
                      end_pointer_v     := start_pointer_v;
                      start_pointer_v   := write2_cnt;
                      read1_cnt         <= start_pointer_v;
                      if px_ok = '1' then
                        px_control_mq <= idle;
                      end if;

                    when others =>
                        --if we get here, something really bogus has happened.
                        --we then kick everything out.
                        px_control_mq    <= idle;
                        end_pointer_v   := (others=>'0');
                        start_pointer_v := (others=>'0');
                        read1_cnt       <= (others=>'0');

                end case;
            --always reading.

        end if;
     end process;

    -- working memory addressing for output.
    px_done <= '1' when px_control_mq = reload else
               '0';


    rx_ok   <= '1' when px_control_mq = idle else
               '0';


   ---------------------------------------------------------------------------------------------------------------------
   --operation
   ---------------------------------------------------------------------------------------------------------------------
   data2_s <= data1_s;

    ---------------------------------------------------------------------------------------------------------------------
    --OUTPUT CONTROL
    ---------------------------------------------------------------------------------------------------------------------
    process(mclk_i)
      variable start_pointer_v : unsigned(write1_cnt'range) := (others => '0');
      variable end_pointer_v   : unsigned(write1_cnt'range) := (others => '0');
      variable last_pointer_v  : unsigned(write1_cnt'range) := (others => '0');
    begin
      if arst_i = '0' then
        tx_control_mq <= idle;
        end_pointer_v   := (others => '0');
        start_pointer_v := (others => '0');
        read2_cnt       <= (others => '0');
      elsif rising_edge(mclk_i) then

          case tx_control_mq is
            when idle =>
              last_pointer_v   := write2_cnt;
              if px_done = '1' then
                tx_control_mq   <= set;
              end if;

            when set =>
              read2_cnt       <= read2_cnt + 1;
              tdata_o         <= ram2_s(to_integer(read2_cnt));
              if read2_cnt = last_pointer_v-1 then
                tx_control_mq <= exception;
              else
                tx_control_mq <= run;
              end if;

            when run =>
              if tready_i = '1' then
                tdata_o <= ram2_s(to_integer(read2_cnt));
                read2_cnt       <= read2_cnt + 1;
                if read2_cnt = last_pointer_v-1 then
                  tx_control_mq <= exception;
                end if;
              end if;

            when exception =>
              --tdata_o <= ram2_s(to_integer(read2_cnt));
              if tready_i = '1' then
                tx_control_mq <= reload;
              end if;

            when reload =>
              tx_control_mq <= idle;

            when others =>
              tx_control_mq <= idle;

          end case;

      end if;
    end process;


    tlast_o  <= '1' when tx_control_mq = exception else
                '0';

    tvalid_o <= '1' when tx_control_mq = run       else
                '1' when tx_control_mq = exception else
                '0';

    px_ok    <= '1' when tx_control_mq = idle else
                '0';

    tx_done  <= '1' when tx_control_mq = reload else
                '0';


    --fila para TUSER e TDEST
    process(mclk_i)
      variable index   : integer range -1 to pipe_num-1 := 0;
      variable lock    : boolean := true;
      variable tuser_v : std_logic_vector(tuser_i'range);
      variable tdest_v : std_logic_vector(tdest_i'range);
    begin
      if rising_edge(mclk_i) then
        tuser_o <= tuser_s(index);
        tdest_o <= tdest_s(index);
        if aux_valid = '1' then
          tuser_s <= tuser_s(tuser_s'high-1 downto 0) & tuser_i;
          tdest_s <= tdest_s(tdest_s'high-1 downto 0) & tdest_i;
          index   := index + 1;
        end if;
        if tx_done = '1' then
          index := index - 1;
        end if;

        if index < 0 then
          lock  := true;
          index := 0;
        elsif index > 0 and lock = true then
          lock  := false;
          index := 0;
        elsif index > pipe_num-1 then
          index := pipe_num-1;
          report "Error on Idex for TUSER fifo.";
        end if;
        index_t <= index;
      end if;
    end process;

end behavioral;
