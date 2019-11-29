----------------------------------------------------------------------------------------------------------
-- SPI-AXI-Controller Machine.
-- Ricardo Tafas
-- This code is provided AS IS. You can do whatever you want with it as long as you say FPGAs are bet than
-- Any kind of solution.
----------------------------------------------------------------------------------------------------------
--The SPI control machine implements an SPI-FRAM interface.
-- BUS OPERATIONS
--WRITE             0000 0010      0x02 Write data to memory array beginning at selected address
--READ              0000 0011      0x03 Read data from memory array beginning at selected address
--FAST_WRITE        0000 0010      0x0A Write data to memory array beginning at selected address
--FAST_READ         0000 0011      0x0B Read data from memory array beginning at selected address
--WRITE_BURST       0100 0010      0x42 Special Write. No increment.
--READ_BURST        0100 1011      0x4B Special Read. No increment.

--CONFIGS

--EDIO              0011 1011      0x3B Enter Dual I/O access (enter SDI bus mode)
--EQIO              0011 1000      0x38 Enter Quad I/O access (enter SQI bus mode)
--RSTIO             1111 1111      0xFF Reset Dual and Quad I/O access (revert to SPI bus mode)
--RDMR              0000 0101      0x05 Read Mode Register
--WRMR              0000 0001      0x01 Write Mode Register
--RDID              1001 1111      0x9F Read Golden Register / Device ID
--RUID              0100 1100      0x4C Read Unique Device ID
--WRSN              1100 0010      0xC2 write serial number / golden register.
--RDSN              1100 0011      0xC3 read serial number / golden register.
--DPD               1011 1010      0xBA deep power down
--HBN               1011 1001      0xB9 hibernate

--INTERNAL BUS Data

--IRQR              1010 0100      0xA4 Interrupt Register. Used to directly decode up to 32 IRQ channels.
--STAT              1010 0101      0xA5 Bus Operation Status.
----------------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.sync_lib.all;

entity spi_control_mq is
    generic (
      spick_freq     : real;
      addr_word_size : integer := 4;
      data_word_size : integer := 4
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
      spi_busy_i   : in  std_logic;
      spi_rxen_i   : in  std_logic;
      spi_txen_o   : out std_logic;
      spi_txdata_o : out std_logic_vector(7 downto 0);
      spi_rxdata_i : in  std_logic_vector(7 downto 0);
      --SPI main registers
      hbn_o        : out std_logic;

      irq_i        : in  std_logic_vector(7 downto 0)
    );
end spi_control_mq;

architecture behavioral of spi_control_mq is

  constant buffer_size   : integer := maximum(addr_word_size, data_word_size);
  constant WRITE_c       : std_logic_vector(7 downto 0) := x"02";
  constant READ_c        : std_logic_vector(7 downto 0) := x"03";
  constant FAST_WRITE_c  : std_logic_vector(7 downto 0) := x"0A";
  constant FAST_READ_c   : std_logic_vector(7 downto 0) := x"0B";
  constant WRITE_BURST_c : std_logic_vector(7 downto 0) := x"42";
  constant READ_BURST_c  : std_logic_vector(7 downto 0) := x"4B";
  constant EDIO_c        : std_logic_vector(7 downto 0) := x"3B";
  constant EQIO_c        : std_logic_vector(7 downto 0) := x"38";
  constant RSTIO_c       : std_logic_vector(7 downto 0) := x"FF";
  constant RDMR_c        : std_logic_vector(7 downto 0) := x"05";
  constant WRMR_c        : std_logic_vector(7 downto 0) := x"01";
  constant RDID_c        : std_logic_vector(7 downto 0) := x"9F";
  constant RUID_c        : std_logic_vector(7 downto 0) := x"4C";
  constant WRSN_c        : std_logic_vector(7 downto 0) := x"C2";
  constant RDSN_c        : std_logic_vector(7 downto 0) := x"C3";
  constant DPD_c         : std_logic_vector(7 downto 0) := x"BA";
  constant HBN_c         : std_logic_vector(7 downto 0) := x"B9";
  constant IRQR_c        : std_logic_vector(7 downto 0) := x"A4";
  constant STAT_c        : std_logic_vector(7 downto 0) := x"A5";


  signal data_en : unsigned(7 downto 0) := "00000001";
  signal input_sr : std_logic_vector(7 downto 0);

  type spi_control_t is (
    --command states
    addr_st,
    read_st,
    write_st,
    act_st,
    inc_addr_st,
    -- edio_st,
    -- eqio_st,
    -- rstio_st,
    -- rdmr_st,
    -- wrmr_st,
    -- rdid_st,
    -- ruid_st,
    -- wrsn_st,
    -- rdsn_st,
    -- dpd_st,
    -- hbn_st,
    -- irqr_st,
    -- stat_st,
    --mgmt states
    idle_st,
    ack_st,
    wait4spi_st,
    wait_command_st,
    wait_forever_st
  );
  signal spi_mq : spi_control_t := idle_st;

  signal addr_s : std_logic_vector(23 downto 0);

  function next_state (command : std_logic_vector(7 downto 0); state : spi_control_t ) return spi_control_t is
    variable tmp : spi_control_t;
  begin
    tmp := idle_st;
    case state is
      when idle_st =>
        tmp := wait_command_st;
      when wait_command_st =>
        case command is
          when WRITE_c       =>
            tmp := addr_st;
          when READ_c        =>
            tmp := addr_st;
          when FAST_WRITE_c  =>
            tmp := addr_st;
          when FAST_READ_c   =>
            tmp := addr_st;
          when WRITE_BURST_c =>
            tmp := addr_st;
          when READ_BURST_c  =>
            tmp := addr_st;
          when EDIO_c        =>
            tmp := act_st;
          when EQIO_c        =>
            tmp := act_st;
          when RSTIO_c       =>
            tmp := act_st;
          when RDMR_c        =>
            tmp := act_st;
          when WRMR_c        =>
            tmp := wait4spi_st;
          when RDID_c        =>
            tmp := act_st;
          when RUID_c        =>
            tmp := act_st;
          when WRSN_c        =>
            tmp := wait4spi_st;
          when RDSN_c        =>
            tmp := act_st;
          when DPD_c         =>
            tmp := act_st;
          when HBN_c         =>
            tmp := act_st;
          when IRQR_c =>
            tmp := act_st;
          when others        =>
            tmp := wait_forever_st;
        end case;

      when addr_st =>
        case command is
          when WRITE_c       =>
            tmp := wait4spi_st;
          when FAST_WRITE_c  =>
            tmp := ack_st;
          when WRITE_BURST_c =>
            tmp := ack_st;
          when READ_c        =>
            tmp := act_st;
          when FAST_READ_c   =>
            tmp := ack_st;
          when READ_BURST_c  =>
            tmp := ack_st;
          when others        =>
            tmp := wait_forever_st;
        end case;

      when ack_st =>
        case command is
          when FAST_WRITE_c  =>
            tmp := wait4spi_st;
          when WRITE_BURST_c =>
            tmp := wait4spi_st;
          when FAST_READ_c   =>
            tmp := read_st;
          when READ_BURST_c  =>
            tmp := read_st;
          when others        =>
            tmp := wait_forever_st;
        end case;

      when inc_addr_st =>
        case command is
          when WRITE_c       =>
            tmp := wait4spi_st;
          when FAST_WRITE_c  =>
            tmp := wait4spi_st;
          when READ_c        =>
            tmp := read_st;
          when FAST_READ_c   =>
            tmp := read_st;
          when others        =>
            tmp := wait_forever_st;
        end case;

      when wait4spi_st =>
        case command is
          when WRITE_c =>
            tmp := write_st;
          when FAST_WRITE_c =>
            tmp := write_st;
          when WRITE_BURST_c =>
            tmp := write_st;
          when READ_c =>
            tmp := inc_addr_st;
          when FAST_READ_c =>
            tmp := inc_addr_st;
          when READ_BURST_c =>
            tmp := read_st;
          when WRMR_c =>
            tmp := wait_forever_st;
          when WRSN_c =>
            tmp := wait_forever_st;
          when others =>
            tmp := wait_forever_st;
        end case;

      when write_st =>
        case command is
          when WRITE_c       =>
            tmp := inc_addr_st;
          when FAST_WRITE_c  =>
            tmp := inc_addr_st;
          when WRITE_BURST_c =>
            tmp := wait4spi_st;
          when others        =>
            tmp := wait_forever_st;
        end case;

      when read_st =>
        case command is
          when READ_c        =>
            tmp := wait4spi_st;
          when FAST_READ_c   =>
            tmp := wait4spi_st;
          when READ_BURST_c  =>
            tmp := wait4spi_st;
          when others        =>
            tmp := wait_forever_st;
        end case;

      when others =>
        tmp := wait_forever_st;

    end case;
    return tmp;
  end function;

  signal get_addr_s : boolean;

begin

  spi_mq_p : process(mclk_i)
    variable aux_cnt   : integer range 0 to 4 := 0;
    variable command_v : std_logic_vector(7 downto 0);
    variable buffer_v  : std_logic_vector(spi_txdata_o'range);
    variable addr_v    : std_logic_vector(spi_rxdata_i'range);
  begin
    if rst_i = '1' then
      spi_mq       <= idle_st;
      command_v    := (others=>'0');
      addr_v       := (others=>'0');
      aux_cnt      := 0;
      spi_txen_o   <= '0';
      spi_txdata_o <= (others=>'0');
      buffer_v     := (others=>'0');
    elsif mclk_i = '1' and mclk_i'event then
      if spi_busy_i = '0' then
        spi_mq       <= idle_st;
        command_v    := (others=>'0');
        addr_v       := (others=>'0');
        aux_cnt      := 0;
        spi_txen_o   <= '0';
        spi_txdata_o <= (others=>'0');
        buffer_v     := (others=>'0');
      else
        case spi_mq is
          when idle_st  =>
            command_v := (others=>'0');
            spi_mq    <= next_state(command_v, spi_mq);
            command_v    := (others=>'0');
            addr_v       := (others=>'0');
            aux_cnt      := 0;
            spi_txen_o   <= '0';
            spi_txdata_o <= (others=>'0');
            buffer_v     := (others=>'0');
          when wait_command_st  =>
            spi_mq  <= next_state(command_v, spi_mq);
            if spi_rxen_i = '1' then
              command_v := spi_rxdata_i;
            end if;

          when addr_st =>
            if spi_rxen_i = '1' then
              aux_cnt := aux_cnt + 1;
              for j in 1 to 8 loop
                buffer_v := buffer_v(buffer_size-2 downto 0) & '1';
              end loop;
              buffer_v(7 downto 0) := spi_rxdata_i;

              if aux_cnt = addr_word_size then
                spi_mq     <= next_state(command_v, spi_mq);
                addr_v     := buffer_v(addr_v'range);
                bus_addr_o <= addr_v;
                aux_cnt    := 0;
              end if;

            end if;

          when ack_st =>
            spi_mq    <= next_state(command_v, spi_mq);
            spi_txen_o   <= '1';
            spi_txdata_o <= x"AC";

          when write_st =>
            bus_data_o  <= buffer_v(bus_data_o'range);
            bus_write_o <= '1';
            if bus_done_i = '1' then
              bus_write_o <= '0';
              spi_mq      <= next_state(command_v, spi_mq);
            end if;

          when read_st =>
            bus_read_o <= '1';
            if bus_done_i = '1' then
              bus_read_o <= '0';
              spi_mq    <= next_state(command_v, spi_mq);
              buffer__v(bus_data_i'range) := bus_data_i;
              spi_txen_o   <= '1';
              spi_txdata_o <= buffer_v(buffer_v'high downto buffer_v'high-7);
            end if;

          when inc_addr_st =>
            spi_mq     <= next_state(command_v, spi_mq);
            addr_v     := addr_v + 1;
            bus_addr_o <= addr_v;

          when wait4spi_st =>

            if spi_rxen_i = '1' then
              aux_cnt  := aux_cnt + 1;
              for j in 1 to 8 loop
                buffer_v := buffer_v(buffer_size-2 downto 0) & '1';
              end loop;
              buffer_v(7 downto 0) := spi_rxdata_i;
              spi_txen_o   <= '1';
              spi_txdata_o <= buffer_v(buffer_v'high downto buffer_v'high-7);
              --decide next state
              if next_state(command_v, spi_mq) = write_st then
                if aux_cnt = data_word_size then
                  spi_mq   <= next_state(command_v, spi_mq);
                end if;
              elsif next_state(command_v, spi_mq) = read_st then
                if aux_cnt = data_word_size-1 then
                  spi_mq   <= next_state(command_v, spi_mq);
                end if;
              end if;
            else
              spi_txen_o <= '0';
            end if;

          when act_st =>
            case command is
              when EDIO_c        =>
                spi_txen_o   <= '1';
                spi_txdata_o <= x"AC";

              when EQIO_c        =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when RSTIO_c       =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when RDMR_c        =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when WRMR_c        =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when RDID_c        =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when RUID_c        =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when WRSN_c        =>

              when RDSN_c        =>
                spi_txen_o   <= '1';
                spi_txdata_o <= x"AC";

              when DPD_c         =>
              spi_txen_o   <= '1';
              spi_txdata_o <= x"AC";

              when HBN_c         =>
                hbn_o  <= '1';

              when IRQR_c =>
                spi_txen_o   <=   '1';
                spi_txdata_o <= irq_i;

              when others        =>
                spi_txen_o   <=   '1';
                spi_txdata_o <= x"FF";
            end case;

          when wait_forever_st =>
            --wait for SPI deassert its BUSY as we do not accept anything from here.

          when others   =>
            spi_mq  <= next_state(command_v, spi_mq);


        end case;
      end if;
      --saídas
    end if;
  end process;


end behavioral;
