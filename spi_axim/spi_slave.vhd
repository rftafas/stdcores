----------------------------------------------------------------------------------------------------------
-- SPI-AXI-Controller Machine.
-- Ricardo Tafas
-- This is open source code licensed under LGPL.
-- By using it on your system you agree with all LGPL conditions.
-- This code is provided AS IS, without any sort of warranty.
-- Author: Ricardo F Tafas Jr
-- 2019
---------------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.sync_lib.all;


entity spi_slave is
  generic (
    edge       : std_logic    := '0';
    clock_mode : clock_mode_t := native
  );
  port (
    --general
    rst_i    : in  std_logic;
    mclk_i   : in  std_logic;
    --spi
    spck_i   : in  std_logic;
    mosi_i   : in  std_logic;
    miso_o   : out std_logic;
    spcs_i   : in  std_logic;
    --Internal
    spi_busy_o   : out std_logic;
    spi_rxen_o   : out std_logic;
    spi_txen_o   : out std_logic;
    spi_rxdata_o : out std_logic_vector(7 downto 0);
    spi_txdata_i : in  std_logic_vector(7 downto 0)
  );
end spi_slave;

architecture behavioral of spi_slave is

  signal edge_s        : std_logic;
  signal spck_s        : std_logic;
  signal spcs_s        : std_logic;
  signal mosi_s        : std_logic;

  signal tx_en         : std_logic;
  signal rx_en         : std_logic;
  signal data_en       : std_logic_vector(7 downto 0) := "00000001";
  signal busy_s        : std_logic;
  signal receive_flag  : boolean := false;

  signal output_sr     : std_logic_vector(6 downto 0);
  signal input_sr      : std_logic_vector(6 downto 0);

begin

  clk_gen : if spi_clock_mode = native generate
    signal spi_rxdata_s : std_logic_vector(7 downto 0) := "11111111";
    signal rxdata_en_s  : std_logic;
  begin
    edge_s  <= edge;
    spck_en <= '1';
    spck_s  <= spck_i;
    spcs_s  <= spcs_i;
    mosi_s  <= mosi_i;

    sync_busy_u : sync_r
      generic map (2)
      port map ('0',mclk_i,busy_s,spi_busy_o);

    sync_exen_u : sync_r
      generic map (2)
      port map ('0',mclk_i,rxdata_en,rxdata_en_s);

    det_rxen_u : det_up
      port map ('0',mclk_i,rxdata_en_s,spi_rxen_o);

    data_gen : for j in 7 downto 0 generate
      sync_j : sync_r
        generic map (2)
        port map ('0',mclk_i,rxdata_s(j),spi_rxdata_o(j));
    end generate;

  else generate
    signal spck_sync_s : std_logic;
  begin
    edge_s        <= '1';
    spck_s        <= mclk_i;
    spi_busy_o    <= busy_s;
    spi_rxdata_o  <= rxdata_s;
    spi_rxen_o    <= rx_en;

    sync_spck_u : sync_r
      generic map (2)
      port map ('0',mclk_i,mosi_i,mosi_s);

    --clock will be oversampled.
    sync_spck_u : sync_r
      generic map (2)
      port map ('0',mclk_i,spck_i,spck_sync_s);

    --depending on the edge, we use detup or down
    edge_gen : if edge = '1' generate
      det_spck_u : det_up
        port map ('0',mclk_i,spck_sync_s,spck_en);

    else generate
      det_spck_u : det_down
        port map ('0',mclk_i,spck_sync_s,spck_en);

    end generate;

    sync_spcs_u : sync_r
      generic map (2)
      port map ('0',mclk_i,spcs_i,spcs_s);

end generate;

  data_cnt_p : process(spcs_s, spck_s)
  begin
    if spcs_s = '1' then
      data_en <= "00000001";
      rx_en   <= '0';
    elsif spck_s = edge_s and spck_s'event then
      if spck_en = '1' then
        data_en <= data_en(6 downto 0) & data_en(7);
      end if;
    end if;
  end process;
  busy_s  <= not spcs_s;
  rx_en   <= data_en(7);
  tx_en   <= data_en(0) and not spcs_s;

  input_sr_p : process(spck_s,spcs_s)
  begin
    if spcs_s = '1' then
      input_sr  <= (others=>'0');
      rxdata_en <= '0';
      rxdata_s  <= (others=>'0');
    elsif spck_s = edge_s and spck_s'event then
      if spck_en = '1' then
        if rx_en = '1' then
          input_sr <= "0000000";
          rxdata_s <= input_sr(6 downto 0) & mosi_i;
          rxdata_en <= '1';
        else
          input_sr <= input_sr(5 downto 0) & mosi_i;
          rxdata_en <= '0';
        end if;
      end if;
    end if;
  end process;

  output_sr_p : process(spck_s,spcs_s)
  begin
    if spcs_s = '1' then
      output_sr(6 downto 0) <= "1111111";
    elsif spck_s = edge_s and spck_s'event then
      if spck_en = '1' then
        if tx_en = '1' then
          output_sr <= spi_txdata_i(6 downto 0);
        else
          output_sr <= output_sr(6 downto 0) & '1';
        end if;
      end if;
    end if;
  end process;

  output_latch_s <= spi_txdata_i(7) when tx_en = '1' else output_sr(6);
  output_latch_p: process(all) --(spck_s, spcs_s, output_latch_s )
  begin
    if spcs_i = '1' then
      miso_o  <= '1';
    elsif spck_i = not edge_s then
      miso_o <= output_latch_s;
    end if;
  end process;

end behavioral;
