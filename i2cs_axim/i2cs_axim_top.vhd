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
--The I2C control machine implements an I2C-RAM interface, extended to full 16-bit address.
-- Check for Microchip 47L64
---------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library stdblocks;
use stdblocks.sync_lib.all;
library stdcores;
use stdcores.spi_axim_pkg.all;

entity i2cs_axim_top is
  generic (
    ADDR_BYTE_NUM : integer := 4;
    DATA_BYTE_NUM : integer := 4
  );
  port (
    --general
    rst_i  : in std_logic;
    mclk_i : in std_logic;
    --i2c
    sda_i     : in std_logic;
    sda_o     : out std_logic;
    scl_i     : in std_logic;
    my_addr_i : in std_logic_vector(2 downto 0);
    --AXI-MM
    M_AXI_AWID    : out std_logic_vector(ID_WIDTH - 1 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in std_logic;
    M_AXI_AWADDR  : out std_logic_vector(8 * ADDR_BYTE_NUM - 1 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    --write data channel
    M_AXI_WVALID : out std_logic;
    M_AXI_WREADY : in std_logic;
    M_AXI_WDATA  : out std_logic_vector(8 * DATA_BYTE_NUM - 1 downto 0);
    M_AXI_WSTRB  : out std_logic_vector(DATA_BYTE_NUM - 1 downto 0);
    M_AXI_WLAST  : out std_logic;
    --Write Response channel
    M_AXI_BVALID : in std_logic;
    M_AXI_BREADY : out std_logic;
    M_AXI_BRESP  : in std_logic_vector(1 downto 0);
    M_AXI_BID    : in std_logic_vector(ID_WIDTH - 1 downto 0);
    -- Read Address channel
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in std_logic;
    M_AXI_ARADDR  : out std_logic_vector(8 * ADDR_BYTE_NUM - 1 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARID    : out std_logic_vector(ID_WIDTH - 1 downto 0);
    --Read data channel
    M_AXI_RVALID : in std_logic;
    M_AXI_RREADY : out std_logic;
    M_AXI_RDATA  : in std_logic_vector(8 * DATA_BYTE_NUM - 1 downto 0);
    M_AXI_RRESP  : in std_logic_vector(1 downto 0);
    M_AXI_RID    : in std_logic_vector(ID_WIDTH - 1 downto 0);
    M_AXI_RLAST  : in std_logic
  );
end i2cs_axim_top;

architecture behavioral of i2cs_axim_top is

  signal irq_s       : std_logic_vector(7 downto 0);
  signal irq_clear_s : std_logic_vector(7 downto 0);
  signal irq_mask_s  : std_logic_vector(7 downto 0);

  signal spick_en : std_logic;
  signal spick_s  : std_logic;

  signal bus_write_s  : std_logic;
  signal bus_read_s   : std_logic;
  signal bus_done_s   : std_logic;
  signal bus_data_i_S : std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
  signal bus_data_o_s : std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
  signal bus_addr_s   : std_logic_vector(ADDR_BYTE_NUM * 8 - 1 downto 0);

  signal spi_busy_s   : std_logic;
  signal spi_rxen_s   : std_logic;
  signal spi_txen_s   : std_logic;
  signal spi_rxdata_s : std_logic_vector(7 downto 0);
  signal spi_txdata_s : std_logic_vector(7 downto 0);

  constant edge : std_logic := edge_config(CPOL, CPHA);

begin

  spi_slave_u : spi_slave
  generic map(
    edge       => edge,
    clock_mode => clock_mode
  )
  port map(
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

  spi_mq_u : i2c_control_mq
  generic map(
    addr_word_size => ADDR_BYTE_NUM,
    data_word_size => DATA_BYTE_NUM,
    serial_num_rw  => serial_num_rw
  )
  port map(
    rst_i        => rst_i,
    mclk_i       => mclk_i,
    bus_write_o  => bus_write_s,
    bus_read_o   => bus_read_s,
    bus_done_i   => bus_done_s,
    bus_data_i   => bus_data_o_s,
    bus_data_o   => bus_data_i_s,
    bus_addr_o   => bus_addr_s,
    i2c_busy_i   => spi_busy_s,
    i2c_rxen_i   => spi_rxen_s,
    i2c_txen_o   => spi_txen_s,
    i2c_txdata_o => spi_txdata_s,
    i2c_rxdata_i => spi_rxdata_s,
    my_addr_i    => my_addr_i
  );

  axi_master_u : i2c_axi_master
  generic map(
    ID_WIDTH      => ID_WIDTH,
    ID_VALUE      => ID_VALUE,
    ADDR_BYTE_NUM => ADDR_BYTE_NUM,
    DATA_BYTE_NUM => DATA_BYTE_NUM
  )
  port map(
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
end behavioral;
