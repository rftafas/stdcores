----------------------------------------------------------------------------------
-- SPI-AXI-Master  by Ricardo F Tafas Jr
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library sync_lib;
    use sync_lib.sync_pkg.all;


entity spi_axi_top is
    generic (
      spick_oversample : boolean   := true;
      spi_cpol         : std_logic := '0';
      spi_chpa         : std_logic := '0';
      clock_mode       : string    := "fast";

    );
    port (
      --general
      mclk_i  : in  std_logic;
      rst_i   : in  std_logic;
      --spi
      mosi    : in  std_logic;
      miso    : out std_logic;
      spck    : in  std_logic;
      spcs    : in  std_logic
      --AXI-MM
      axim_awaddr   : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
      axim_awprot   : out std_logic_vector(2 downto 0);
      axim_awvalid  : out std_logic;
      axim_awready  : in  std_logic;
      axim_wdata    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
      axim_wstrb    : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
      axim_wvalid   : out std_logic;
      axim_wready   : in  std_logic;
      axim_bresp    : in  std_logic_vector(1 downto 0);
      axim_bvalid   : in  std_logic;
      axim_bready   : out std_logic;
      axim_araddr   : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
      axim_arprot   : out std_logic_vector(2 downto 0);
      axim_arvalid  : out std_logic;
      axim_arready  : in  std_logic;
      axim_rdata    : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
      axim_rresp    : in  std_logic_vector(1 downto 0);
      axim_rvalid   : in  std_logic;
      axim_rready   : out std_logic
    );
end spi_axi_top;

architecture behavioral of spi_axi_top is

  signal spick_en : std_logic;


begin

  --SPI CLOCK MODE
  ckmode_gen : if clock_mode = "fast" generate

  else generate

  end generate;


  spi_mq_i : spi_mq
    generic map (
      spick_freq => spick_freq
    )
    port map (
      rst_i     => rst_i,
      spick_i   => spick_i,
      mosi_i    => mosi_i,
      miso_o    => miso_o,
      spcs_i    => spcs_i,
      reg_eno_o => reg_eno_o,
      reg_o     => reg_o_s,
      en_o      => en_s,
      reg_i     => reg_i_s
    );

 process()
 if 



end behavioral;
