----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.sync_pkg.all;
    use expert.std_logic_expert.all;


entity spi_mq is
    generic (
      spick_freq     : real;
      word_byte_size : integer := 4
    );
    port (
      --general
      rst_i        : in  std_logic;
      mclk_i       : in  std_logic;
      --spi
      bus_write_o  : out std_logic;
      bus_read_o   : out std_logic;
      bus_done_i   : in  std_logic;
      bus_data_i   : in  std_logic_vector(31 downto 0);
      bus_data_o   : out std_logic_vector(31 downto 0);
      bus_addr_o   : out std_logic_vector(23 downto 0);
      --SPI Interface signals
      spi_busy_i   : in  std_logic;
      spi_rxen_i   : in  std_logic;
      spi_txen_o   : out std_logic;
      spi_txdata_o : out std_logic_vector(7 downto 0);
      spi_rxdata_i : in  std_logic_vector(7 downto 0);
      --SPI main registers
      irq_i        : in  std_logic_vector(31 downto 0);
    );
end spi_mq;

architecture behavioral of spi_mq is

  signal data_en : unsigned(7 downto 0) := "00000001";
  signal input_sr : std_logic_vector(7 downto 0);

  type spi_control_t is array (idle_st, wait_st, read_st, write_st, edio_st, edio_st, edio_st, edio_st, rdmr_st, wrmr_st);
  signal spi_mq : spi_control_t := idle_st;

  signal addr_s : std_logic_vector(23 downto 0);

--  function next_state () return spi_control_t is
  --  begin


begin

  mealy2moore_p : process()
  begin
    if clkA = '1' Then
    if moore_mq = idle_st then
      if com_start_i = '1' then
      elsif spi_byte_en_i = '1' then

      elsif  then

    else
    end if;
  end process;


  --The SPI control machine implements an SPI-SRAM interface:
  --READ              0000 0011      0x03 Read data from memory array beginning at selected address
  --WRITE             0000 0010      0x02 Write data to memory array beginning at selected address
  --EDIO              0011 1011      0x3B Enter Dual I/O access (enter SDI bus mode)
  --EQIO              0011 1000      0x38 Enter Quad I/O access (enter SQI bus mode)
  --RSTIO             1111 1111      0xFF Reset Dual and Quad I/O access (revert to SPI bus mode)
  --RDMR              0000 0101      0x05 Read Mode Register
  --WRMR              0000 0001      0x01 Write Mode Register
  --Extension
  --RDGR              1010 0100      0xA0 Read Golden Register
  --WRGR              1010 0101      0xA1 Read/Write Golden Register
  --WRITE_BURST       1010 0010      0xA2 Write data to memory array beginning at selected address. No increment.
  --READ_BUSRT        1010 0011      0xA3 Read data from memory array beginning at selected address. No increment.
  --IRQR              1010 0100      0xA4 Interrupt Register. Used to directly decode up to 32 IRQ channels.
  --STAT              1010 0101      0xA5 Bus Operation Status.

  spi_mq_p : process(spick_i)
    variable aux_cnt : integer := 0;
  begin
    if spick_i = '1' then
        case master_spi_mq is
          when idle_st  =>
            if spi_busy_i = '1' then
              master_spi_mq <= wait_command_st;
            end if;

          when wait_command_st  =>
            if spi_rxen_i = '1' then
              command_v := spi_rxdata_i
              case command_v is
                when edio_c  =>
                  master_spi_mq <= edio_st;
                when eqio_c  =>
                  master_spi_mq <= eqio_st;
                when rstio_c =>
                  master_spi_mq <= rstio_st;
                when rdmr_c  =>
                  master_spi_mq <= rdmr_st;
                when wrmr_c  =>
                  master_spi_mq <= wrmr_st;
                when others  =>
                  master_spi_mq <= get_addr_st;
              end case;
            end if;
            aux_cnt := 0;

          when addr_st =>
            case addr_mq is
              when wait_spi_st  =>
                if spi_rxen_i = '1' then
                  addr_mq <= save_addr_st;
                end if;

              when save_addr_st =>
                aux_cnt := aux_cnt + 1;
                if aux_cnt = 4 then
                  case command_v is
                    when read_st =>
                    when write_st =>
                    when read_burst_st =>
                    when write_burst_st =>
                    when others =>
                  end case;
                  aux_cnt := 0;
                else
                  addr_mq <= wait_spi_st;
                end if;

              when others =>
            end case;

          when read_st =>
            case read_mq is
              when read_axi_st =>
                if bus_done_i = '1' then
                  read_mq <= save_spi_st;
                end if;

              when save_spi_st =>
                read_mq <= send_spi_st;

              when send_spi_st =>
                aux_cnt := aux_cnt + 1;
                if aux_cnt = 4 then
                  read_mq <= inc_addr_st;
                  aux_cnt := 0;
                elsif spi_rxen_i = '1' then
                  read_mq <= save_spi_st;
                end if;

              when inc_addr_st =>
                read_mq <= read_axi_st;

              when others =>
            end case;

          when write_st =>
            case write_mq is
              when write_axi_st =>
                if bus_done_i = '1' then
                  write_mq <= inc_addr_st;
                end if;

              when wait_spi_st =>
                aux_cnt := aux_cnt + 1;
                if aux_cnt = 4 then
                  write_mq <= inc_addr_st;
                  aux_cnt := 0;
                elsif spi_rxen_i = '1' then
                  write_mq <= save_spi_st;
                end if;

              when inc_addr_st =>
                write_mq <= write_axi_st;

              when others =>
            end case;

          when edio_st =>
          when eqio_st =>
          when rstio_st =>
          when rdmr_st =>
          when wrmr_st =>

          when rdgr_st =>
            if word_en = '1' then
              master_spi_mq <= wait_st;
            end if;

          when wrgr_st =>
            if word_en = '1' then
              master_spi_mq <= wait_st;
            end if;

          --when write_burst_st =>

          --when read_burst_st  =>

          when irqr_st =>
            if word_en = '1' then
              master_spi_mq <= wait_st;
            end if;

          when wait_spi_st  =>
            if spi_busy_i = '0' then
              master_spi_mq <= idle_st;
            elsif addr_en = '1' then
                aux_cnt := aux_cnt + 1;
                if aux_cnt = 3 then
                  case command_v is
                    when read_st =>
                    when write_st =>
                    when read_burst_st =>
                    when write_burst_st =>
                    when others =>
                  end case;
                  aux_cnt := 0;
                end if;
              end if;


            end if;

          when others   =>
            if spi_busy_i = '0' then
              master_spi_mq <= idle_st;
            else
              master_spi_mq <= wait_st;
            end if;

        end case;
      end if;
    end if;
  end process;

  addr_p : process(spick_i)
    variable addr_v : std_logic_vector(23 downto 0);
  begin
    if spick_i = '1' then
      if spi_mq = addr_st then
        --addr_v(31 downto 24) := addr_v(23 downto 16);
        addr_v(23 downto 16) := addr_v(15 downto  8);
        addr_v(15 downto  8) := addr_v( 7 downto  0);
        addr_v( 7 downto  0) := reg_i;
      elsif spi_mq = next_read_st then
        addr_v <= addr_v + 1;
      end if;
      addr_o <= addr_v;
    end if;
  end process;

  addr_p : process(spick_i)
    variable addr_v : std_logic_vector(23 downto 0);
  begin
    if spick_i = '1' then
      if spi_mq = addr_st then
        if spi_rxen_i = '1' then
          --addr_v(31 downto 24) := addr_v(23 downto 16);
          addr_v(23 downto 16) := addr_v(15 downto  8);
          addr_v(15 downto  8) := addr_v( 7 downto  0);
          addr_v( 7 downto  0) := reg_i;
        end if;
      elsif spi_mq = next_read_st then
        addr_v <= addr_v + 1;
      end if;
      addr_o <= addr_v;
    end if;
  end process;

  read_o  <= '1' when spi_mq = read_st  else '0';
  write_o <= '1' when spi_mq = write_st else '0';


end behavioral;
