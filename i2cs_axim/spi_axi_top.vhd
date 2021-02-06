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
--The SPI control machine implements an SPI-FRAM interface.
-- Check for Microchip 23LCV1024
--
--BUS OPERATIONS
--
--WRITE             0000 0010      0x02 Write data to memory array beginning at selected address
--READ              0000 0011      0x03 Read data from memory array beginning at selected address
--FAST_WRITE        0000 0010      0x0A Write data to memory array beginning at selected address
--FAST_READ         0000 0011      0x0B Read data from memory array beginning at selected address
--WRITE_BURST       0100 0010      0x42 Special Write. No increment.
--READ_BURST        0100 1011      0x4B Special Read. No increment.

--Note for READ and WRITE
--For oversampled clock, SPICK < MCLK/8 and all operations work well.
--To use regular READ and WRITE, SPICK < MCLK/4
--If SPICK > MCLK/4, FAST_READ and FAST_WRITE will work.
--upper limit: SPICK = MCLK

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

--IRQR              1010 0100      0xA4 Interrupt Register. Used to directly decode up to 32 irqs
--STAT              1010 0101      0xA5 Bus Operation Status.
---------------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library stdblocks;
    use stdblocks.sync_lib.all;
  library stdcores;
      use stdcores.spi_axim_pkg.all;

entity spi_axi_top is
  generic (
    CPOL          : std_logic   := '0';
    CPHA          : std_logic   := '0';
    ID_WIDTH      : integer     := 1;
    ID_VALUE      : integer     := 0;
    ADDR_BYTE_NUM : integer     := 4;
    DATA_BYTE_NUM : integer     := 4;
    serial_num_rw : boolean     := true;
    clock_mode    : spi_clock_t := native
    );
  port (
    --general
    rst_i         : in  std_logic;
    mclk_i        : in  std_logic;
    --spi
    mosi_i        : in  std_logic;
    miso_o        : out std_logic;
    spck_i        : in  std_logic;
    spcs_i        : in  std_logic;
    --
    RSTIO_o       : out std_logic;
    DID_i         : in  std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
    UID_i         : in  std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
    serial_num_i  : in  std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
    irq_i         : in  std_logic_vector(7 downto 0);
    irq_o         : out std_logic;
    --AXI-MM
    M_AXI_AWID    : out std_logic_vector(ID_WIDTH-1 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;
    M_AXI_AWADDR  : out std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    --write data channel
    M_AXI_WVALID  : out std_logic;
    M_AXI_WREADY  : in  std_logic;
    M_AXI_WDATA   : out std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
    M_AXI_WSTRB   : out std_logic_vector(DATA_BYTE_NUM-1 downto 0);
    M_AXI_WLAST   : out std_logic;
    --Write Response channel
    M_AXI_BVALID  : in  std_logic;
    M_AXI_BREADY  : out std_logic;
    M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_BID     : in  std_logic_vector(ID_WIDTH-1 downto 0);
    -- Read Address channel
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;
    M_AXI_ARADDR  : out std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARID    : out std_logic_vector(ID_WIDTH-1 downto 0);
    --Read data channel
    M_AXI_RVALID  : in  std_logic;
    M_AXI_RREADY  : out std_logic;
    M_AXI_RDATA   : in  std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
    M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_RID     : in  std_logic_vector(ID_WIDTH-1 downto 0);
    M_AXI_RLAST   : in  std_logic
  );
end spi_axi_top;

architecture behavioral of spi_axi_top is

  signal irq_s       : std_logic_vector(7 downto 0);
  signal irq_clear_s : std_logic_vector(7 downto 0);
  signal irq_mask_s  : std_logic_vector(7 downto 0);

  signal spick_en : std_logic;
  signal spick_s : std_logic;

  signal bus_write_s  : std_logic;
  signal bus_read_s   : std_logic;
  signal bus_done_s   : std_logic;
  signal bus_data_i_S : std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
  signal bus_data_o_s : std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
  signal bus_addr_s   : std_logic_vector(ADDR_BYTE_NUM*8-1 downto 0);

  signal spi_busy_s   : std_logic;
  signal spi_rxen_s   : std_logic;
  signal spi_txen_s   : std_logic;
  signal spi_rxdata_s : std_logic_vector(7 downto 0);
  signal spi_txdata_s : std_logic_vector(7 downto 0);

  constant edge       : std_logic := edge_config(CPOL, CPHA);

begin

  spi_slave_u : spi_slave
    generic map (
      edge       => edge,
      clock_mode => clock_mode
    )
    port map (
      rst_i        => rst_i,
      mclk_i       => mclk_i,
      spck_i       => spck_i,
      mosi_i       => mosi_i,
      miso_o       => miso_o,
      spcs_i       => spcs_i,
      spi_busy_o   => spi_busy_s,
      spi_rxen_o   => spi_rxen_s,
      spi_txen_o   => spi_txen_s,
      spi_rxdata_o => spi_rxdata_s,
      spi_txdata_i => spi_txdata_s
    );

  spi_mq_u : spi_control_mq
      generic map (
        addr_word_size => ADDR_BYTE_NUM,
        data_word_size => DATA_BYTE_NUM,
        serial_num_rw  => serial_num_rw
      )
      port map (
        rst_i        => rst_i,
        mclk_i       => mclk_i,
        bus_write_o  => bus_write_s,
        bus_read_o   => bus_read_s,
        bus_done_i   => bus_done_s,
        bus_data_i   => bus_data_o_s,
        bus_data_o   => bus_data_i_s,
        bus_addr_o   => bus_addr_s,
        spi_busy_i   => spi_busy_s,
        spi_rxen_i   => spi_rxen_s,
        spi_txen_i   => spi_txen_s,
        spi_txdata_o => spi_txdata_s,
        spi_rxdata_i => spi_rxdata_s,
        RSTIO_o      => RSTIO_o,
        DID_i        => DID_i,
        UID_i        => UID_i,
        serial_num_i => serial_num_i,
        irq_i        => irq_s,
        irq_mask_o   => irq_mask_s,
        irq_clear_o  => irq_clear_s
      );

  axi_master_u : spi_axi_master
    generic map (
      ID_WIDTH      => ID_WIDTH,
      ID_VALUE      => ID_VALUE,
      ADDR_BYTE_NUM => ADDR_BYTE_NUM,
      DATA_BYTE_NUM => DATA_BYTE_NUM
    )
    port map (
      M_AXI_RESET   => rst_i,
      M_AXI_ACLK    => mclk_i,
      bus_addr_i    => bus_addr_s,
      bus_data_i    => bus_data_i_s,
      bus_data_o    => bus_data_o_s,
      bus_write_i   => bus_write_s,
      bus_read_i    => bus_read_s,
      bus_done_o    => bus_done_s,
      bus_error_o   => open,
      M_AXI_AWID    => M_AXI_AWID,
      M_AXI_AWVALID => M_AXI_AWVALID,
      M_AXI_AWREADY => M_AXI_AWREADY,
      M_AXI_AWADDR  => M_AXI_AWADDR,
      M_AXI_AWPROT  => M_AXI_AWPROT,
      M_AXI_WVALID  => M_AXI_WVALID,
      M_AXI_WREADY  => M_AXI_WREADY,
      M_AXI_WDATA   => M_AXI_WDATA,
      M_AXI_WSTRB   => M_AXI_WSTRB,
      M_AXI_WLAST   => M_AXI_WLAST,
      M_AXI_BVALID  => M_AXI_BVALID,
      M_AXI_BREADY  => M_AXI_BREADY,
      M_AXI_BRESP   => M_AXI_BRESP,
      M_AXI_BID     => M_AXI_BID,
      M_AXI_ARVALID => M_AXI_ARVALID,
      M_AXI_ARREADY => M_AXI_ARREADY,
      M_AXI_ARADDR  => M_AXI_ARADDR,
      M_AXI_ARPROT  => M_AXI_ARPROT,
      M_AXI_ARID    => M_AXI_ARID,
      M_AXI_RVALID  => M_AXI_RVALID,
      M_AXI_RREADY  => M_AXI_RREADY,
      M_AXI_RDATA   => M_AXI_RDATA,
      M_AXI_RRESP   => M_AXI_RRESP,
      M_AXI_RID     => M_AXI_RID,
      M_AXI_RLAST   => M_AXI_RLAST
    );

  spi_irq_ctrl_u : spi_irq_ctrl
    port map (
      rst_i        => rst_i,
      mclk_i       => mclk_i,
      master_irq_o => irq_o,
      vector_irq_o => irq_s,
      vector_irq_i => irq_i,
      vector_clr_i => irq_clear_s,
      vector_msk_i => irq_mask_s
    );

end behavioral;
