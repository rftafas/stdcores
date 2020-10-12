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
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

package spi_axim_pkg is

	constant WRITE_c       : std_logic_vector(7 downto 0) := x"02";
  constant READ_c        : std_logic_vector(7 downto 0) := x"03";
  constant FAST_WRITE_c  : std_logic_vector(7 downto 0) := x"0A";
  constant FAST_READ_c   : std_logic_vector(7 downto 0) := x"0B";
  constant WRITE_BURST_c : std_logic_vector(7 downto 0) := x"42";
  constant READ_BURST_c  : std_logic_vector(7 downto 0) := x"4B";
  constant EDIO_c        : std_logic_vector(7 downto 0) := x"3B";
  constant EQIO_c        : std_logic_vector(7 downto 0) := x"38";
  constant RSTIO_c       : std_logic_vector(7 downto 0) := x"FF";
  constant RDMR_c        : std_logic_vector(7 downto 0) := x"05";
  constant WRMR_c        : std_logic_vector(7 downto 0) := x"01";
  constant RDID_c        : std_logic_vector(7 downto 0) := x"9F";
  constant RUID_c        : std_logic_vector(7 downto 0) := x"4C";
  constant WRSN_c        : std_logic_vector(7 downto 0) := x"C2";
  constant RDSN_c        : std_logic_vector(7 downto 0) := x"C3";
  constant DPD_c         : std_logic_vector(7 downto 0) := x"BA";
  constant HBN_c         : std_logic_vector(7 downto 0) := x"B9";
  constant IRQRD_c       : std_logic_vector(7 downto 0) := x"A2";
  constant IRQWR_c       : std_logic_vector(7 downto 0) := x"A3";
  constant IRQMRD_c      : std_logic_vector(7 downto 0) := x"D2";
  constant IRQMWR_c      : std_logic_vector(7 downto 0) := x"D3";
  constant STAT_c        : std_logic_vector(7 downto 0) := x"A5";

	type spi_clock_t is (native, oversampled);

    component spi_axi_top
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
  end component spi_axi_top;

	component spi_control_mq
    generic (
      addr_word_size : integer := 4;
      data_word_size : integer := 4;
      serial_num_rw  : boolean := true
      );
    port (
      rst_i        : in  std_logic;
      mclk_i       : in  std_logic;
      bus_write_o  : out std_logic;
      bus_read_o   : out std_logic;
      bus_done_i   : in  std_logic;
      bus_data_i   : in  std_logic_vector(data_word_size*8-1 downto 0);
      bus_data_o   : out std_logic_vector(data_word_size*8-1 downto 0);
      bus_addr_o   : out std_logic_vector(addr_word_size*8-1 downto 0);
      spi_busy_i   : in  std_logic;
      spi_rxen_i   : in  std_logic;
      spi_txen_i   : in  std_logic;
      spi_txdata_o : out std_logic_vector(7 downto 0);
      spi_rxdata_i : in  std_logic_vector(7 downto 0);
      RSTIO_o      : out std_logic;
      DID_i        : in  std_logic_vector(data_word_size*8-1 downto 0);
      UID_i        : in  std_logic_vector(data_word_size*8-1 downto 0);
      serial_num_i : in  std_logic_vector(data_word_size*8-1 downto 0);
      irq_i        : in  std_logic_vector(7 downto 0);
      irq_mask_o   : out std_logic_vector(7 downto 0);
      irq_clear_o  : out std_logic_vector(7 downto 0)
      );
    end component spi_control_mq;

    component spi_axi_master
      generic (
        ID_WIDTH      : integer := 1;
        ID_VALUE      : integer := 1;
        ADDR_BYTE_NUM : integer := 4;
        DATA_BYTE_NUM : integer := 4
      );
      port (
        M_AXI_RESET   : in  std_logic;
        M_AXI_ACLK    : in  std_logic;
        bus_addr_i    : in  std_logic_vector(ADDR_BYTE_NUM*8-1 downto 0);
        bus_data_i    : in  std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
        bus_data_o    : out std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
        bus_write_i   : in  std_logic;
        bus_read_i    : in  std_logic;
        bus_done_o    : out std_logic;
        bus_error_o   : out std_logic;
        M_AXI_AWID    : out std_logic_vector(ID_WIDTH-1 downto 0);
        M_AXI_AWVALID : out std_logic;
        M_AXI_AWREADY : in  std_logic;
        M_AXI_AWADDR  : out std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
        M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
        M_AXI_WVALID  : out std_logic;
        M_AXI_WREADY  : in  std_logic;
        M_AXI_WDATA   : out std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
        M_AXI_WSTRB   : out std_logic_vector(DATA_BYTE_NUM-1 downto 0);
        M_AXI_WLAST   : out std_logic;
        M_AXI_BVALID  : in  std_logic;
        M_AXI_BREADY  : out std_logic;
        M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
        M_AXI_BID     : in  std_logic_vector(ID_WIDTH-1 downto 0);
        M_AXI_ARVALID : out std_logic;
        M_AXI_ARREADY : in  std_logic;
        M_AXI_ARADDR  : out std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
        M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
        M_AXI_ARID    : out std_logic_vector(ID_WIDTH-1 downto 0);
        M_AXI_RVALID  : in  std_logic;
        M_AXI_RREADY  : out std_logic;
        M_AXI_RDATA   : in  std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
        M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
        M_AXI_RID     : in  std_logic_vector(ID_WIDTH-1 downto 0);
        M_AXI_RLAST   : in  std_logic
      );
    end component spi_axi_master;

    component spi_slave
			generic (
      	edge       : std_logic    := '0';
      	clock_mode : spi_clock_t := native
      );
      port (
        rst_i        : in  std_logic;
        mclk_i       : in  std_logic;
        spck_i       : in  std_logic;
        mosi_i       : in  std_logic;
        miso_o       : out std_logic;
        spcs_i       : in  std_logic;
        spi_busy_o   : out std_logic;
        spi_rxen_o   : out std_logic;
        spi_txen_o   : out std_logic;
        spi_rxdata_o : out std_logic_vector(7 downto 0);
        spi_txdata_i : in  std_logic_vector(7 downto 0)
      );
    end component spi_slave;

    component spi_irq_ctrl
      port (
        rst_i        : in  std_logic;
        mclk_i       : in  std_logic;
        master_irq_o : out std_logic;
        vector_irq_o : out std_logic_vector(7 downto 0);
        vector_irq_i : in  std_logic_vector(7 downto 0);
        vector_clr_i : in  std_logic_vector(7 downto 0);
        vector_msk_i : in  std_logic_vector(7 downto 0)
      );
    end component spi_irq_ctrl;

		function edge_config (CPOL : std_logic; CPHA: std_logic) return std_logic;

end spi_axim_pkg;

--a arquitetura
package body spi_axim_pkg is

	function edge_config (CPOL : std_logic; CPHA: std_logic) return std_logic is
	begin
		return CPOL xnor CPHA;
	end edge_config;

end spi_axim_pkg;
