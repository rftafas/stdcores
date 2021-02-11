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

package i2cs_axim_pkg is

  constant WRITE_c : std_logic := '1';
  constant READ_c  : std_logic := '0';

  component i2cs_axim_top
    generic (
      ID_WIDTH      : integer     := 1;
      ID_VALUE      : integer     := 0;
      ADDR_BYTE_NUM : integer     := 4;
      DATA_BYTE_NUM : integer     := 4
    );
    port (
      --general
      rst_i  : in std_logic;
      mclk_i : in std_logic;
      --i2c
      sda_i     : in std_logic;
      sda_o     : out std_logic;
      scl_i     : in std_logic;
      sda_oen_o : out std_logic;
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
  end component i2cs_axim_top;

  component i2cs_control_mq
    generic (
      addr_word_size : integer := 4;
      data_word_size : integer := 4;
      opcode_c       : std_logic_vector(3 downto 0) := "1010"
    );
    port (
      rst_i        : in  std_logic;
      mclk_i       : in  std_logic;
      bus_write_o  : out std_logic;
      bus_read_o   : out std_logic;
      bus_done_i   : in  std_logic;
      bus_data_i   : in  std_logic_vector(data_word_size * 8 - 1 downto 0);
      bus_data_o   : out std_logic_vector(data_word_size * 8 - 1 downto 0);
      bus_addr_o   : out std_logic_vector(addr_word_size * 8 - 1 downto 0);
      i2c_busy_i   : in  std_logic;
      i2c_rxen_i   : in  std_logic;
      i2c_txen_o   : out std_logic;
      i2c_txdata_o : out std_logic_vector(7 downto 0);
      i2c_rxdata_i : in  std_logic_vector(7 downto 0);
      my_addr_i    : in  std_logic_vector(2 downto 0)
    );
  end component i2cs_control_mq;

  component i2cs_axi_master
    generic (
      ID_WIDTH      : integer := 1;
      ID_VALUE      : integer := 0;
      ADDR_BYTE_NUM : integer := 4;
      DATA_BYTE_NUM : integer := 4
    );
    port (
      M_AXI_RESET   : in std_logic;
      M_AXI_ACLK    : in std_logic;
      bus_addr_i    : in std_logic_vector(ADDR_BYTE_NUM * 8 - 1 downto 0);
      bus_data_i    : in std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
      bus_data_o    : out std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
      bus_write_i   : in std_logic;
      bus_read_i    : in std_logic;
      bus_done_o    : out std_logic;
      bus_error_o   : out std_logic;
      M_AXI_AWID    : out std_logic_vector(ID_WIDTH - 1 downto 0);
      M_AXI_AWVALID : out std_logic;
      M_AXI_AWREADY : in std_logic;
      M_AXI_AWADDR  : out std_logic_vector(8 * ADDR_BYTE_NUM - 1 downto 0);
      M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
      M_AXI_WVALID  : out std_logic;
      M_AXI_WREADY  : in std_logic;
      M_AXI_WDATA   : out std_logic_vector(8 * DATA_BYTE_NUM - 1 downto 0);
      M_AXI_WSTRB   : out std_logic_vector(DATA_BYTE_NUM - 1 downto 0);
      M_AXI_WLAST   : out std_logic;
      M_AXI_BVALID  : in std_logic;
      M_AXI_BREADY  : out std_logic;
      M_AXI_BRESP   : in std_logic_vector(1 downto 0);
      M_AXI_BID     : in std_logic_vector(ID_WIDTH - 1 downto 0);
      M_AXI_ARVALID : out std_logic;
      M_AXI_ARREADY : in std_logic;
      M_AXI_ARADDR  : out std_logic_vector(8 * ADDR_BYTE_NUM - 1 downto 0);
      M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
      M_AXI_ARID    : out std_logic_vector(ID_WIDTH - 1 downto 0);
      M_AXI_RVALID  : in std_logic;
      M_AXI_RREADY  : out std_logic;
      M_AXI_RDATA   : in std_logic_vector(8 * DATA_BYTE_NUM - 1 downto 0);
      M_AXI_RRESP   : in std_logic_vector(1 downto 0);
      M_AXI_RID     : in std_logic_vector(ID_WIDTH - 1 downto 0);
      M_AXI_RLAST   : in std_logic
    );
  end component i2cs_axi_master;

  component i2c_slave
    generic (
      stop_hold : positive := 4 --number of mck after scl edge up for SDA edge up.
    );
    port (
      --general
      rst_i  : in std_logic;
      mclk_i : in std_logic;
      --I2C
      scl_i   : in std_logic;
      sda_i   : in std_logic;
      sda_o   : out std_logic;
      sda_t_o : out std_logic;
      --Internal
      i2c_busy_o   : out std_logic;
      i2c_rxen_o   : out std_logic;
      i2c_rxdata_o : out std_logic_vector(7 downto 0);
      i2c_txen_i   : in std_logic;
      i2c_txdata_i : in std_logic_vector(7 downto 0)
    );
  end component i2c_slave;

  procedure tri_state (
    signal from_pin : out   std_logic;
    signal to_pin   : in    std_logic;
    signal pin      : inout std_logic;
    signal oe       : in    std_logic
  );

end i2cs_axim_pkg;

--a arquitetura
package body i2cs_axim_pkg is

  procedure tri_state (
    signal from_pin : out   std_logic;
    signal to_pin   : in    std_logic;
    signal pin      : inout std_logic;
    signal oe       : in    std_logic
  ) is
  begin

    from_pin <= pin;
    if oe = '1' then
      if to_pin = '0' then
        pin <= '0';
      else
        pin <= 'Z';
      end if;
    else
      pin <= 'Z';
    end if;

  end procedure;

end i2cs_axim_pkg;
