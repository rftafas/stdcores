----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
-- For this IP, CPOL = 0 and CPHA = 0. SPI Master must be configured accordingly.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library expert;
    use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.sync_lib.all;


entity spi_slave is
    generic (
      CPOL : std_logic := '0'
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
      spi_txen_i   : in  std_logic;
      spi_rxdata_o : out std_logic_vector(7 downto 0);
      spi_txdata_i : in  std_logic_vector(7 downto 0)
    );
end spi_slave;

architecture behavioral of spi_slave is

  signal tx_en        : std_logic;
  signal rx_en        : std_logic;
  signal spi_rxen_s   : std_logic;
  signal data_en      : std_logic_vector(7 downto 0) := "00000001";
  signal output_sr    : std_logic_vector(7 downto 0);
  signal spi_rxdata_s : std_logic_vector(7 downto 0);
  signal spi_txdata_s : std_logic_vector(7 downto 0);

  signal input_sr : std_logic_vector(7 downto 0);

begin

  data_cnt_p : process(spcs_i, spck_i)
  begin
    if spcs_i = '1' then
      data_en <= "00000001";
    elsif spck_i = CPOL and spck_i'event then
      data_en <= data_en(6 downto 0) & data_en(7);
    end if;
  end process;
  tx_en <= data_en(0);
  rx_en <= data_en(7);

  input_latch_p : process(spcs_i, spck_i, mosi_i)
  begin
    if spck_i = CPOL then
      if spcs_i = '0' then
        input_sr(0) <= mosi_i;
      end if;
    end if;
  end process;

  input_sr_p : process(spck_i)
  begin
    if spck_i = CPOL and spck_i'event then
      if spcs_i = '0' then
        input_sr(7 downto 1) <= input_sr(6 downto 0);
        if rx_en = '1' then
          spi_rxdata_s <= input_sr;
        end if;
      end if;
    end if;
  end process;

  txdata_latch_p : process(spi_txen_i, spi_txdata_i)
  begin
    if spi_txen_i = '1' then
      spi_txdata_s <= spi_txdata_i;
    end if;
  end process;

  output_sr_p : process(tx_en,spck_i)
  begin
    if spck_i = CPOL and spck_i'event then
      if tx_en = '1' then
        output_sr(6 downto 0) <= spi_txdata_s(6 downto 0);
      else
        output_sr(6 downto 0) <= output_sr(5 downto 0) & '1';
      end if;
    end if;
  end process;

  output_latch_p : process(tx_en, spck_i)
  begin
    if tx_en = '1' then
      output_sr(7) <= spi_txdata_s(7);
    elsif spck_i = CPOL then
      output_sr(7) <= output_sr(6);
    end if;
  end process;
  miso_o <= output_sr(7);


  --OUTPUTS
  sync_busy_u : sync_r
    generic map (2)
    port map ('0',mclk_i,spcs_i,spi_busy_o);

  sync_exen_u : sync_r
    generic map (2)
    port map ('0',mclk_i,data_en(7),spi_rxen_s);

  det_rxen_u : det_up
    port map ('0',mclk_i,spi_rxen_s,spi_rxen_o);

  data_gen : for j in 7 downto 0 generate
    sync_j : sync_r
      generic map (2)
      port map ('0',mclk_i,spi_rxdata_s(j),spi_rxdata_o(j));
  end generate;


end behavioral;
