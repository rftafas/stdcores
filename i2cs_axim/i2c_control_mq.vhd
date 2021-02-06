----------------------------------------------------------------------------------
--Copyright 2020 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.sync_lib.all;
library stdcores;
    use stdcores.spi_axim_pkg.all;
library stdblocks;
    use stdblocks.sync_lib.all;

entity spi_control_mq is
    generic (
      addr_word_size : integer := 2;
      data_word_size : integer := 4;
      opcode_c       : std_logic_vector(3 downto 0) := "1010"
    );
    port (
      --general
      rst_i        : in  std_logic;
      mclk_i       : in  std_logic;
      --spi
      bus_write_o  : out std_logic;
      bus_read_o   : out std_logic;
      bus_done_i   : in  std_logic;
      bus_data_i   : in  std_logic_vector(data_word_size*8-1 downto 0);
      bus_data_o   : out std_logic_vector(data_word_size*8-1 downto 0);
      bus_addr_o   : out std_logic_vector(addr_word_size*8-1 downto 0);
      --SPI Interface signals
      i2c_busy_i   : in  std_logic;
      i2c_rxen_i   : in  std_logic;
      i2c_rxdata_i : in  std_logic_vector(7 downto 0);
      spi_txen_o   : out std_logic;
      i2c_txdata_o : out std_logic_vector(7 downto 0);
      --I2C SLAVE DDR
      slave_addr_i : out std_logic_vector(2 downto 0)
    );
end spi_control_mq;

architecture behavioral of spi_control_mq is

  signal modereg_s   : std_logic_vector(7 downto 0) := (others=>'0');
  signal irq_mask_s  : std_logic_vector(7 downto 0) := (others=>'0');

  signal serialnum_s : std_logic_vector(8*data_word_size-1 downto 0) := (others=>'0');
  signal did_s       : std_logic_vector(8*data_word_size-1 downto 0) := (others=>'0');
  signal uid_c       : std_logic_vector(8*data_word_size-1 downto 0) := (others=>'0');

  constant buffer_size   : integer := data_word_size;--maximum(addr_word_size, data_word_size);

  signal data_en : unsigned(7 downto 0) := "00000001";
  signal input_sr : std_logic_vector(7 downto 0);

  type command_t is (
    WRITE_cmd,
    READ_cmd,
    WRITE_BURST_cmd,
    READ_BURST_cmd
  );

  type i2c_control_t is (
    --command states
    addr_st,
    act_st,
    inc_addr_st,
    idle_st,
    wait4i2c_st,
    wait_command_st,
    wait_forever_st
  );

  record i2c_param_t is
    command : std_logic;
    opcode  : std_logic_vector(3 downto 0);
    my_addr : std_logic_vector(2 downto 0)
  end record i2c_handler_r;


  signal i2c_mq      : i2c_control_t := idle_st;
  signal i2c_param_s : i2c_param_t := (
    command => '0';
    opcode  => "0000";
    my_addr => "000"
  );

  signal addr_s : std_logic_vector(23 downto 0);

  procedure next_state (
    variable i2c_data : in    i2c_param_t;
    signal   my_addr  : in    std_logic_vector(2 downto 0);
    signal   aux_cnt  : in    integer;
    signal   busy     : in    std_logic;
    signal   state    : inout spi_control_t
  )
  return spi_control_t is
    variable tmp        : spi_control_t;
    variable slave_addr : std_logic_vector(3 downto 0);
    variable opcode     : std_logic_vector(2 downto 0);
    variable command    : std_logic;
  begin

    tmp        := state;
    slave_addr := i2c_data.slave_addr;
    opcode     := i2c_data.opcode;
    command    := i2c_data.command;

    if busy = '0' then
      tmp := idle_st;
    else
      case state is
        when idle_st =>
          tmp := wait_command_st;

        when wait_command_st =>
          if opcode = opcode_c and slave_addr = my_addr then
            if command = WRITE_c then
                tmp := addr_st;
            elsif command = READ_c then
                tmp := act_st;
            end if;
          else
            tmp := wait_forever_st;
          end if;

        when addr_st =>
          if aux_cnt = addr_word_size then
            if command = WRITE_c then
              tmp := wait4i2c_st;
            else
              tmp := idle_st;
            end if;
          end if;

        when inc_addr_st =>
          tmp := wait4i2c_st;

        when wait4i2c_st =>
          if command = WRITE_c then
              if aux_cnt = data_word_size then
                tmp := act_st;
              end if;
          else
            if aux_cnt = data_word_size then
              tmp := act_st;
            end if;
          end if;

        when act_st =>
          tmp := inc_addr_st;

        when others =>
          tmp := wait_forever_st;

      end case;

    end if;

    state := tmp;

  end procedure;

  signal get_addr_s : boolean;
  signal buffer_s   : std_logic_vector(8*buffer_size-1 downto 0);
  signal aux_cnt_s  : integer;
  signal command_s  : std_logic_vector(7 downto 0);

begin

  i2c_mq_p : process(all)
    variable aux_cnt           : integer range -1 to buffer_size := 0;
    variable command_v         : std_logic_vector(7 downto 0);
    variable decoded_command_v : std_logic_vector(7 downto 0);
    variable temp_v            : std_logic_vector(7 downto 0);
    variable buffer_v          : std_logic_vector(8*buffer_size-1 downto 0);
    variable addr_v            : std_logic_vector(8*addr_word_size-1 downto 0);
  begin
    if rst_i = '1' then
      i2c_mq       <= idle_st;
      addr_v       := (others=>'0');
      aux_cnt      := 0;
      i2c_txdata_o <= (others=>'1');
      buffer_v     := (others=>'0');
      bus_read_o   <= '0';
      bus_write_o  <= '0';
      bus_addr_o   <= (others=>'0');
    elsif mclk_i = '1' and mclk_i'event then
      case i2c_mq is
          when idle_st  =>
            bus_read_o   <= '0';
            bus_write_o  <= '0';
            command_v    := (others=>'0');
            addr_v       := (others=>'0');
            aux_cnt      := 0;
            i2c_txdata_o <= (others=>'1');
            buffer_v     := (others=>'0');
            next_state(i2c_data, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);

          when wait_command_st  =>
            i2c_txdata_o <= (others=>'1');
            if i2c_rxen_i = '1' then
              i2c_param_s.command    := i2c_rxdata_i(0);
              i2c_param_s.opcode     := i2c_rxdata_i(0);
              i2c_param_s.slave_addr := i2c_rxdata_i(0);
              
              i2c_mq    <= next_state(i2c_param_s, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
            end if;

          when addr_st =>
            if i2c_rxen_i = '1' then
              aux_cnt  := aux_cnt + 1;
              buffer_v := buffer_v sll 8;
              buffer_v := set_slice(buffer_v, i2c_rxdata_i, 0);
              next_state(i2c_rxdata_i, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
              addr_v     := buffer_v(addr_v'range);
              if aux_cnt = addr_word_size then
                aux_cnt    := 0;
                bus_addr_o <= addr_v;
              end if;
            end if;

          when ack_st =>
            i2c_txdata_o <= x"AC";
            aux_cnt      := -1;
            if spi_txen_i = '0' then
              --i.e. we won't get out of here while it still has something to do.
              i2c_mq <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
            end if;

          when wait4i2c_st =>
            if i2c_busy_i = '0' then -- If SPI bus is deactivated
              i2c_mq   <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
            else
              case command_v is

                when FAST_READ_c =>
                  if i2c_rxen_i = '1' then
                    i2c_txdata_o <= get_slice(buffer_v,8,buffer_size-1);
                    --if aux_cnt > -1 then
                      buffer_v     := buffer_v sll 8;
                      buffer_v     := set_slice(buffer_v, i2c_rxdata_i, 0);
                    --end if;
                    aux_cnt      := aux_cnt + 1;
                    i2c_mq <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
                  end if;

                when others =>
                  if i2c_rxen_i = '1' then
                    aux_cnt      := aux_cnt + 1;
                    i2c_mq <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
                    buffer_v     := buffer_v sll 8;
                    buffer_v     := set_slice(buffer_v, i2c_rxdata_i, 0);
                  elsif spi_txen_i = '0' then
                  elsif spi_txen_i = '1' then
                    i2c_txdata_o <= get_slice(buffer_v,8,buffer_size-1);
                  end if;

              end case;
            end if;
            if (aux_cnt = data_word_size) then
              aux_cnt := 0;
            end if;

          when act_st =>
            temp_v  := action_decode(command_v);

            case temp_v is

              when READ_c        =>
                bus_read_o <= '1';
                if bus_done_i = '1' then
                  bus_read_o <= '0';
                  i2c_mq     <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
                  buffer_v   := set_slice(buffer_v, bus_data_i, 0);
                end if;

              when WRITE_c        =>
                bus_data_o   <= buffer_v(bus_data_o'range);
                buffer_v     := (others=>'0');
                i2c_txdata_o <= (others=>'0');
                bus_write_o  <= '1';
                if bus_done_i = '1' then
                  i2c_mq      <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
                  bus_write_o <= '0';
                end if;

              when others        =>
                buffer_v := (others=>'1');
                i2c_mq   <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
                report "Invalid Command detected." severity warning;

            end case;

          when inc_addr_st   =>
            i2c_mq     <= next_state(command_v, slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);
            addr_v     := addr_v + data_word_size;
            bus_addr_o <= addr_v;

          when others   =>
            --i2c_txdata_o <= x"FF";
            i2c_mq  <= next_state(command_v,slave_addr_i, aux_cnt, i2c_busy_i, i2c_mq);

        end case;
      end if;
    --debugg signals: variables are not tracked on Xilinx VivadoSIM.
    buffer_s  <= buffer_v;
    aux_cnt_s <= aux_cnt;
    command_s <= command_v;
  end process;

  --Algumas saídas.
  irq_mask_o <= irq_mask_s;

end behavioral;
