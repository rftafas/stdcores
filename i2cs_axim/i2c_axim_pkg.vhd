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

package i2c_axim_pkg is

  constant WRITE_c : std_logic := '1';
  constant READ_c  : std_logic := '0';

  type i2c_master_t is protected
    procedure i2c_start (
      signal sda : inout std_logic;
      signal scl : out std_logic;
    );
    procedure i2c_send (
      signal sda    : inout std_logic;
      signal scl    : out std_logic;
      signal data_i : in std_logic_vector(7 downto 0)
    );
    procedure i2c_get (
      signal data_o : out std_logic_vector(7 downto 0);
      signal ack    : in boolean;
      signal sda    : inout std_logic;
      signal scl    : out std_logic;
    );
    procedure i2c_stop (
      signal sda : inout std_logic;
      signal scl : out std_logic;
    );
    procedure i2c_send_buffer (
      signal sda         : inout std_logic;
      signal scl         : out std_logic;
      signal data_buffer : in std_logic_array
    );
    procedure i2c_get_buffer (
      signal sda         : inout std_logic;
      signal scl         : out std_logic;
      signal address     : in std_logic_vector(15 downto 0);
      signal data_buffer : in std_logic_array
    );

    procedure i2c_run (
      signal sda         : inout std_logic;
      signal scl         : out std_logic;
    );
    
  end protected i2c_master_t;

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
      rst_i  : in std_logic;
      mclk_i : in std_logic;
      --spi
      mosi_i : in std_logic;
      miso_o : out std_logic;
      spck_i : in std_logic;
      spcs_i : in std_logic;
      --
      RSTIO_o      : out std_logic;
      DID_i        : in std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
      UID_i        : in std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
      serial_num_i : in std_logic_vector(DATA_BYTE_NUM * 8 - 1 downto 0);
      irq_i        : in std_logic_vector(7 downto 0);
      irq_o        : out std_logic;
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
  end component spi_axi_top;

  component spi_control_mq
    generic (
      addr_word_size : integer := 4;
      data_word_size : integer := 4;
      serial_num_rw  : boolean := true
    );
    port (
      rst_i        : in std_logic;
      mclk_i       : in std_logic;
      bus_write_o  : out std_logic;
      bus_read_o   : out std_logic;
      bus_done_i   : in std_logic;
      bus_data_i   : in std_logic_vector(data_word_size * 8 - 1 downto 0);
      bus_data_o   : out std_logic_vector(data_word_size * 8 - 1 downto 0);
      bus_addr_o   : out std_logic_vector(addr_word_size * 8 - 1 downto 0);
      spi_busy_i   : in std_logic;
      spi_rxen_i   : in std_logic;
      spi_txen_i   : in std_logic;
      spi_txdata_o : out std_logic_vector(7 downto 0);
      spi_rxdata_i : in std_logic_vector(7 downto 0);
      RSTIO_o      : out std_logic;
      DID_i        : in std_logic_vector(data_word_size * 8 - 1 downto 0);
      UID_i        : in std_logic_vector(data_word_size * 8 - 1 downto 0);
      serial_num_i : in std_logic_vector(data_word_size * 8 - 1 downto 0);
      irq_i        : in std_logic_vector(7 downto 0);
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
  end component spi_axi_master;

  component i2c_slave
    generic (
      stop_hold : positive := 4; --number of mck after scl edge up for SDA edge up.
    );
    port (
      --general
      rst_i  : in std_logic;
      mclk_i : in std_logic;
      --I2C
      scl_i : in std_logic;
      sda_i : in std_logic;
      sda_o : out std_logic;
      --Internal
      i2c_busy_o   : out std_logic;
      i2c_rxen_o   : out std_logic;
      i2c_rxdata_o : out std_logic_vector(7 downto 0);
      i2c_txen_i   : in std_logic;
      i2c_txdata_i : in std_logic_vector(7 downto 0)
    );
  end component i2c_slave;

  procedure tri_state (
    signal from_pin : out std_logic;
    signal to_pin   : in std_logic;
    signal pin      : inout std_logic
  );

end i2c_axim_pkg;

--a arquitetura
package body i2c_axim_pkg is

  procedure tri_state (
    signal from_pin : out std_logic;
    signal to_pin   : in std_logic;
    signal pin      : inout std_logic
  ) is
  begin

    from_pin <= pin;
    if to_pin = '0' then
      pin <= '0';
    else
      pin <= 'Z';
    end if;

  end procedure;

  type i2c_master_t is protected body

    procedure i2c_start (
      signal sda : inout std_logic;
      signal scl : out std_logic;
    ) is
    begin
      --start
      scl <= '1';
      sda <= 'H';
      wait for 50 ns;
      sda <= '0';
      wait for 50 ns;
    end procedure;

    procedure i2c_send (
      signal sda    : inout std_logic;
      signal scl    : out std_logic;
      signal data_i : in std_logic_vector(7 downto 0)
    ) is
    begin
      scl <= '0';
      for j in 7 downto 0 loop
        sda <= to_H(data_i(j));
        wait for 50 ns;
        scl <= '1';
        wait for 50 ns;
        scl <= '0';
      end loop;
      wait for 50 ns;
      wait until sda = '0';
      scl <= '1';
      wait for 50 ns;
    end i2c_send;

    procedure i2c_get (
      signal data_o : out std_logic_vector(7 downto 0);
      signal ack    : in boolean;
      signal sda    : inout std_logic;
      signal scl    : out std_logic;
    ) is
    begin
      scl <= '0';
      for j in 7 downto 0 loop
        wait for 50 ns
        scl <= '1';
        wait for 50 ns;
        data_o(j) <= to_X01(sda);
        scl       <= '0';
      end loop;

      if ack then
        sda <= '0';
      else
        sda <= '1';
      end if;

      wait for 50 ns;
      scl <= '1';
      wait for 50 ns;
    end i2c_send;

    procedure i2c_stop (
      signal sda : inout std_logic;
      signal scl : out std_logic;
    ) is
    begin
      sda <= '1';
      wait for 50 ns;
    end i2c_send;

    procedure i2c_send_buffer (
      signal sda         : inout std_logic;
      signal scl         : out std_logic;
      signal data_buffer : in std_logic_array
    ) is
    begin
      i2c_start(sda, scl);
      i2c_send(sda, scl, opcode & my_addr & write_c);
      for j in data_buffer'range loop
        i2c_send(sda, scl, data_buffer(j));
      end loop;
      i2c_stop(sda, scl);
    end send_buffer;

    procedure i2c_get_buffer (
      signal sda         : inout std_logic;
      signal scl         : out std_logic;
      signal address     : in std_logic_vector(15 downto 0);
      signal data_buffer : in std_logic_array
    ) is
    begin
      i2c_start(sda, scl);
      i2c_send(sda, scl, opcode & my_addr & write_c);
      for j in data_buffer'range loop
        if j = data_buffer'right then
          i2c_get(sda, scl, data_buffer(j));
        else

        end loop;
        i2c_stop(sda, scl);
      end read_buffer;

    end protected body i2c_master_t;
  end i2c_axim_pkg;
