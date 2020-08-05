----------------------------------------------------------------------------------------------------------
-- Simple Serial Controllers - SPI MASTER
-- Ricardo Tafas
-- This is open source code licensed under LGPL.
-- By using it on your system you agree with all LGPL conditions.
-- This code is provided AS IS, without any sort of warranty.
-- Author: Ricardo F Tafas Jr
-- 2020
---------------------------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
  use stdblocks.sync_lib.all;
library stdcores;
	use stdcores.axis_s_spim_pkg.all;


entity spi_master is
  generic (
    edge       : std_logic   := '0';
    clock_mode : spi_clock_t := oversampled
  );
  port (
    --general
    rst_i          : in  std_logic;
    mclk_i         : in  std_logic;
    refclk_i       : in  std_logic;
    --spi
    spck_o         : out std_logic;
    miso_i         : in  std_logic;
    mosi_o         : out std_logic;
    spcs_o         : out std_logic;
    --Internal
    spi_tx_valid_i : in  std_logic;
    spi_rxen_o     : out std_logic;
    spi_txen_o     : out std_logic;
    spi_rxdata_o   : out std_logic_vector(7 downto 0);
    spi_txdata_i   : in  std_logic_vector(7 downto 0)
  );
end spi_master;

architecture behavioral of spi_master is

  signal edge_s        : std_logic;
  signal spck_s        : std_logic;
  signal spck_en       : std_logic;
  signal spcs_s        : std_logic;
  signal miso_s        : std_logic;

  signal refclk_up_s   : std_logic;
  signal refclk_dn_s   : std_logic;

  signal tx_en         : std_logic;
  signal rx_en         : std_logic;
  signal data_en       : std_logic_vector(7 downto 0) := "00000001";
  signal busy_s        : std_logic;
  signal receive_flag  : boolean := false;

  signal output_sr     : std_logic_vector(6 downto 0);
  signal input_sr      : std_logic_vector(6 downto 0);

  signal rxdata_en     : std_logic;
  signal rxdata_s      : std_logic_vector(7 downto 0) := "00000001";


begin

  clk_gen : if clock_mode = native generate
    spck_en <= '1';

    spck_s  <= mclk_i and busy_s;
    miso_s <= miso_i when mclk_i = edge and mclk_i'event;

    -- miso_edge_p : process(mclk_i)
    -- begin
    --   if mclk_i = edge and mclk_i'event then
    --     miso_s <= miso_i when mclk_i = edge and mclk_i'event;
    --   end if;
    -- end process;

  else generate
    spck_en <= '1';
    miso_s  <= miso_i;
    spck_s  <= refclk_i and busy_s;

    sync_miso_u : sync_r
      generic map (2)
      port map ('0',mclk_i,miso_i,miso_s);

    edge_ref_up_u : det_up
        port map ('0',mclk_i,refclk_i,refclk_up_s);

    edge_ref_dn_u : det_down
        port map ('0',mclk_i,refclk_i,refclk_dn_s);

    spck_en <= refclk_up_s when edge = '1' else refclk_dn_s;

  end generate;

  spck_o  <= spck_s when edge = '1' else not spck_s;

  data_cnt_p : process(rst_i, mclk_i)
    variable busy_v : std_logic := '0';
  begin
    if rst_i = '1' then
      data_en <= "00000001";
      rx_en   <= '0';
      busy_v  := '0';
    elsif mclk_i = '1' and mclk_i'event then
      if spck_en = '1' then
        if busy_s = '1' then
          data_en <= data_en(6 downto 0) & data_en(7);
          if data_en(7) = '1' and spi_tx_valid_i = '0' then
            busy_s <= '0';
          end if;
        elsif spi_tx_valid_i = '1' then
          busy_s <= '1';
        end if;
      end if;
    end if;
  end process;
  spcs_s  <= not busy_s;
  rx_en   <= data_en(7) and busy_s;
  tx_en   <= data_en(7) and spi_tx_valid_i;
  spi_rxen_o <= rx_en;
  spi_txen_o <= tx_en;
  spcs_o <= spcs_s;

  output_sr_p : process(rst_i,mclk_i)
  begin
    if rst_i = '1' then
      output_sr(6 downto 0) <= "1111111";
    elsif mclk_i = '1' and mclk_i'event then
      if busy_s = '0' then
        output_sr(6 downto 0) <= "1111111";
      elsif spck_en = '1' then
        if tx_en = '1' then
          output_sr <= spi_txdata_i(7 downto 0);
        else
          output_sr <= output_sr(6 downto 0) & '1';
        end if;
      end if;
    end if;
  end process;

  mosi_o <= output_sr(7);

  input_sr_p : process(rst_i,mclk_i)
  begin
    if rst_i = '1' then
      input_sr  <= (others=>'0');
      rxdata_en <= '0';
      rxdata_s  <= (others=>'0');
    elsif mclk_i = '1' and mclk_i'event then
      if spck_en = '1' then
        if busy_s = '0' then
          rxdata_en <= '0';
          input_sr <= "0000000";
        elsif rx_en = '1' then
          input_sr <= "0000000";
          rxdata_s <= input_sr(7 downto 0);
          rxdata_en <= '1';
        else
          input_sr(7 downto 0) <= input_sr(6 downto 0) & miso_s;
          rxdata_en <= '0';
        end if;
      end if;
    end if;
  end process;

end behavioral;
