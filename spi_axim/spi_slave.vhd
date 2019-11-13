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
      spick_freq : real
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
      --AXI-MM
      spi_rxen_o   : out std_logic;
      spi_txen_i   : in  std_logic;
      spi_rxdata_o : out std_logic_vector(7 downto 0);
      spi_txdata_i : in  std_logic_vector(7 downto 0)
    );
end spi_mq;

architecture behavioral of spi_mq is

  signal data_en : unsigned(7 downto 0) := "00000001";
  signal input_sr : std_logic_vector(7 downto 0);

begin


  data_cnt_p : process(spick_i)
  begin
    if spick_i = '1' then
      if spcs_i = '1' then
        data_en <= "00000001";;
      else
        data_en <= data_en(6 downto 0) & data_en(7);
      end if;
    end if;
  end process;
  en_o <= data_en(7);

  input_p : process(spick_i)
  begin
    if spick_i = '1' then
      if spcs_i = '0' then
        input_sr <= input_sr(6 downto 0) & mosi_i;
      end if;
    end if;
  end process;

  output_p : process(spick_i)
  begin
    if mclk_i = '1' then
      if reg_en_i = '1' then
        output_sr <= reg_i;
        busy_v := true;
      else
        output_sr <= output_sr(6 downto 0) & 0;
      end if;
    end if;
  end process;
  miso_o <= output_sr(7);

end behavioral;
