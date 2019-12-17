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

  signal tx_en         : std_logic;
  signal rx_en         : std_logic;
  signal spi_rxen_s    : std_logic;
  signal data_en       : std_logic_vector(7 downto 0) := "00000001";
  signal output_sr     : std_logic_vector(7 downto 0);
  signal spi_rxdata_s  : std_logic_vector(7 downto 0) := "11111111";
  signal spi_rxdata_en : std_logic;
  signal spi_rxen_sync : std_logic;
  signal busy_s        : std_logic;
  signal spi_txen_s     : std_logic := '0';
  signal spi_txen_clear : std_logic := '0';

  signal spi_txdata_s  : std_logic_vector(7 downto 0);

  signal input_sr : std_logic_vector(7 downto 0);

begin

  data_cnt_p : process(spcs_i, spck_i)
    variable zero_flag : boolean;
  begin
    if spcs_i = '1' then
      data_en   <= "00000000";
      busy_s    <= '0';
      zero_flag := false;
    elsif spck_i = not CPOL and spck_i'event then
      if zero_flag then
        data_en <= data_en(6 downto 0) & '0';
        if data_en(6) = '1' then
          zero_flag := false;
        end if;
      else
        zero_flag := true;
        data_en <= data_en(6 downto 0) & '1';
      end if;
      busy_s  <= '1';
    end if;
  end process;
  tx_en <= data_en(7);
  rx_en <= data_en(7);

  input_sr_p : process(spck_i,spcs_i)
  begin
    if spcs_i = '1' then
      input_sr <= "00000000";
    elsif spck_i = not CPOL and spck_i'event then
      input_sr <= input_sr(6 downto 0) & mosi_i;
    end if;
  end process;

  -- output_latch_p: process(tx_en, spck_i, spcs_i, spi_txdata_i(7) )
  -- begin
  --   if spcs_i = '1' then
  --     output_sr(7) <= '1';
  --   elsif tx_en = '1' then
  --     output_sr(7) <= spi_txdata_i(7);
  --   elsif spck_i = CPOL then
  --     output_sr(7) <= output_sr(6);
  --   end if;
  -- end process;

  output_sr_p : process(spck_i,spcs_i)
  begin
    if spcs_i = '1' then
      output_sr(6 downto 0) <= "1111111";
    elsif spck_i = not CPOL and spck_i'event then
      if tx_en = '1' then
        output_sr(6 downto 0) <= spi_txdata_i(6 downto 0);
      else
        output_sr(6 downto 0) <= output_sr(5 downto 0) & '1';
      end if;
    end if;
  end process;

  output_sr(7) <= spi_txdata_i(7) when tx_en = '1' else output_sr(6);

  output_latch_p: process(spck_i, spcs_i, output_sr(7) )
  begin
    if spcs_i = '1' then
      miso_o  <= '1';
    elsif spck_i = CPOL then
      miso_o <= output_sr(7);
    end if;
  end process;

  --OUTPUTS
  sync_busy_u : sync_r
    generic map (2)
    port map ('0',mclk_i,busy_s,spi_busy_o);

  sync_exen_u : sync_r
    generic map (2)
    port map ('0',mclk_i,rx_en,spi_rxen_sync);

  det_rxen_u : det_up
    port map ('0',mclk_i,spi_rxen_sync,spi_rxen_s);

  data_gen : for j in 7 downto 0 generate
    sync_j : sync_r
      generic map (2)
      port map ('0',mclk_i,input_sr(j),spi_rxdata_s(j));
  end generate;

  spi_rxen_o <= spi_rxen_s;
  spi_rxdata_o <= spi_rxdata_s;

end behavioral;
