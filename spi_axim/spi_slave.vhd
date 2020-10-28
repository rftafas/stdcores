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

entity spi_slave is
  generic (
    edge       : std_logic   := '0';
    clock_mode : spi_clock_t := native
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

  signal spck_s         : std_logic;
  signal spck_en        : std_logic;
  signal spcs_s         : std_logic;
  signal mosi_s         : std_logic;

  signal tx_en          : std_logic;
  signal rx_en          : std_logic;
  signal data_en        : std_logic_vector(7 downto 0) := "00000001";
  signal rxdata_en      : std_logic;
  signal busy_s         : std_logic;

  signal output_sr      : std_logic_vector(6 downto 0);
  signal input_sr       : std_logic_vector(6 downto 0);
  signal rxdata_s       : std_logic_vector(7 downto 0);

  signal output_latch_s : std_logic;

  constant edge_c : std_logic := edge_set(edge,clock_mode);

begin

  clk_gen : if clock_mode = native generate
    signal spi_rxdata_s : std_logic_vector(7 downto 0) := "11111111";
    signal rxdata_en_s  : std_logic;
  begin
    spck_en <= '1';
    spck_s  <= spck_i;
    spcs_s  <= spcs_i;
    mosi_s  <= mosi_i;

    sync_busy_u : sync_r
      generic map (2)
      port map ('0',mclk_i,busy_s,spi_busy_o);

    sync_rxen_u : sync_r
      generic map (2)
      port map ('0',mclk_i,rxdata_en,rxdata_en_s);

    det_rxen_u : det_up
      port map ('0',mclk_i,rxdata_en_s,spi_rxen_o);

    sync_txen_u : sync_r
      generic map (2)
      port map ('0',mclk_i,tx_en,spi_txen_o);

    data_gen : for j in 7 downto 0 generate
      sync_j : sync_r
        generic map (2)
        port map ('0',mclk_i,rxdata_s(j),spi_rxdata_o(j));
    end generate;

  else generate
    signal spck_sync_s : std_logic;
  begin
    spck_s        <= mclk_i;
    spi_busy_o    <= busy_s;
    spi_rxdata_o  <= rxdata_s;

    det_rxen_u : det_up
      port map ('0',mclk_i,rxdata_en,spi_rxen_o);

    spi_txen_o <= tx_en;

    sync_mosi_u : sync_r
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
    elsif spck_s = edge_c and spck_s'event then
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
    elsif spck_s = edge_c and spck_s'event then
      if spck_en = '1' then
        if rx_en = '1' then
          input_sr <= "0000000";
          rxdata_s <= input_sr(6 downto 0) & mosi_s;
          rxdata_en <= '1';
        else
          input_sr <= input_sr(5 downto 0) & mosi_s;
          rxdata_en <= '0';
        end if;
      end if;
    end if;
  end process;

  output_sr_p : process(spck_s,spcs_s)
  begin
    if spcs_s = '1' then
      output_sr(6 downto 0) <= "1111111";
    elsif spck_s = edge_c and spck_s'event then
      if spck_en = '1' then
        if tx_en = '1' then
          output_sr <= spi_txdata_i(6 downto 0);
        else
          output_sr <= output_sr(5 downto 0) & '1';
        end if;
      end if;
    end if;
  end process;

  output_latch_s <= spi_txdata_i(7) when tx_en = '1' else output_sr(6);
  output_latch_p: process(all) --(spck_s, spcs_s, output_latch_s )
  begin
    if spcs_i = '1' then
      miso_o  <= '1';
    elsif spck_i = not edge then
      miso_o <= output_latch_s;
    end if;
  end process;

end behavioral;
