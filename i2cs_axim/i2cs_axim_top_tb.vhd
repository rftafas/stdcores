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
library ieee;
    use ieee.std_logic_1164.all;
library stdblocks;
    use stdblocks.sync_lib.all;
library stdcores;
    use stdcores.spi_axim_pkg.all;

entity spi_axi_top_tb is
end spi_axi_top_tb;

architecture simulation of spi_axi_top_tb is

  constant  spi_cpol      : std_logic := '0';
  constant  spi_cpha      : std_logic := '0';

  constant  ID_WIDTH      : integer := 1;
  constant  ID_VALUE      : integer := 0;
  constant  ADDR_BYTE_NUM : integer := 4;
  constant  DATA_BYTE_NUM : integer := 4;
  constant  serial_num_rw : boolean := false;

  signal    rst_i         : std_logic;
  signal    mclk_i        : std_logic := '0';
  signal    mosi_i        : std_logic;
  signal    miso_o        : std_logic;
  signal    spck_i        : std_logic;
  signal    spcs_i        : std_logic;
  signal    RSTIO_o       : std_logic;

  constant  DID_i         : std_logic_vector(DATA_BYTE_NUM*8-1 downto 0) := x"76543210";
  constant  UID_i         : std_logic_vector(DATA_BYTE_NUM*8-1 downto 0) := x"AAAAAAAA";
  constant  serial_num_i  : std_logic_vector(DATA_BYTE_NUM*8-1 downto 0) := x"A4A4A4A4";
  signal    irq_i         : std_logic_vector(7 downto 0)                 := x"86";
  signal    irq_o         : std_logic;

  signal    M_AXI_AWID    : std_logic_vector(ID_WIDTH-1 downto 0);
  signal    M_AXI_AWVALID : std_logic;
  signal    M_AXI_AWREADY : std_logic;
  signal    M_AXI_AWADDR  : std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
  signal    M_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal    M_AXI_WVALID  : std_logic;
  signal    M_AXI_WREADY  : std_logic;
  signal    M_AXI_WDATA   : std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
  signal    M_AXI_WSTRB   : std_logic_vector(DATA_BYTE_NUM-1 downto 0);
  signal    M_AXI_WLAST   : std_logic;
  signal    M_AXI_BVALID  : std_logic;
  signal    M_AXI_BREADY  : std_logic;
  signal    M_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal    M_AXI_BID     : std_logic_vector(ID_WIDTH-1 downto 0);
  signal    M_AXI_ARVALID : std_logic;
  signal    M_AXI_ARREADY : std_logic;
  signal    M_AXI_ARADDR  : std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
  signal    M_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal    M_AXI_ARID    : std_logic_vector(ID_WIDTH-1 downto 0);
  signal    M_AXI_RVALID  : std_logic;
  signal    M_AXI_RREADY  : std_logic;
  signal    M_AXI_RDATA   : std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
  signal    M_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal    M_AXI_RID     : std_logic_vector(ID_WIDTH-1 downto 0);
  signal    M_AXI_RLAST   : std_logic;

  constant frequency_mhz   : real := 10.0000;
  constant spi_period      : time := ( 1.000 / frequency_mhz) * 1 us;
  constant spi_half_period : time := spi_period;

  type spi_buffer_t is array (NATURAL RANGE <>) of std_logic_vector(7 downto 0);
  signal RDSN_c        : spi_buffer_t(4 downto 0) := (x"C3", others => x"00");
  signal WRSN_c        : spi_buffer_t(4 downto 0) := (x"C2", x"89", x"AB", x"CD", x"EF" );
  signal RDID_c        : spi_buffer_t(4 downto 0) := (x"9F", others => x"00");
  signal RUID_c        : spi_buffer_t(4 downto 0) := (x"4C", others => x"00");

  signal IRQRD_c       : spi_buffer_t(1 downto 0) := (x"A2", x"00");
  signal IRQWR_c       : spi_buffer_t(1 downto 0) := (x"A3", x"0F");
  signal IRQMRD_c      : spi_buffer_t(1 downto 0) := (x"D2", x"00");
  signal IRQMWR_c      : spi_buffer_t(1 downto 0) := (x"D3", x"F0");

  --read/write
  signal SIMPLE_READ_c   : spi_buffer_t(8 downto 0) := (READ_c, others => x"00");
  signal SIMPLE_WRITE_c  : spi_buffer_t(8 downto 0) := (
    WRITE_c,
    x"00",
    x"00",
    x"00",
    x"00",
    x"AB",
    x"CD",
    x"12",
    x"34"
  );

  signal SIMPLE_READ_2_c   : spi_buffer_t(12 downto 0) := (READ_c, others => x"00");
  signal SIMPLE_WRITE_2_c  : spi_buffer_t(12 downto 0) := (
    WRITE_c,
    x"00",
    x"00",
    x"00",
    x"00",
    x"AB",
    x"CD",
    x"12",
    x"34",
    x"56",
    x"78",
    x"9A",
    x"BC"
  );

  --read/write
  signal FAST_READ_WORD_c     : spi_buffer_t(13 downto 0) := (FAST_READ_c, others => x"00");
  signal FAST_WRITE_WORD_c    : spi_buffer_t(13 downto 0) := (
    FAST_WRITE_c,
    x"00",
    x"00",
    x"00",
    x"00",
    X"UU",--intentional trash
    x"AB",
    x"CD",
    x"12",
    x"34",
    x"56",
    x"78",
    x"9A",
    x"BC"
  );

  signal spi_rxdata_s    : spi_buffer_t(15 downto 0);
  signal spi_rxdata_en   : std_logic;

  procedure spi_bus (
    signal data_i  : in  spi_buffer_t;
    signal data_o  : out spi_buffer_t;
    signal spcs    : out std_logic;
    signal spck    : out std_logic;
    signal miso    : in  std_logic;
    signal mosi    : out std_logic
  ) is
  begin
    for k in data_i'range loop
      for j in 7 downto 0 loop
        spcs <= '0';
        spck <= '0';
        mosi <= data_i(k)(j);
        wait for spi_half_period;
        spck      <= '1';
        data_o(k)(j) <= miso;
        wait for spi_half_period;
      end loop;
    end loop;
    spcs <= '1';
    spck <= '0';
    mosi <= 'H';
  end procedure;

begin

  --clock e reset
  mclk_i <= not mclk_i after 10 ns;
  rst_i  <= '1', '0' after 30 ns;

  process
  begin
    spck_i <= '0';
    spcs_i <= '1';
    mosi_i <= 'H';
    wait until rst_i = '0';
    wait until mclk_i'event and mclk_i = '1';
    --ID TESTING
    --spi_bus(RUID_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(RDID_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --SERIAL NUMBER TESTING
    --spi_bus(WRSN_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(RDSN_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --IRQ TESTING
    --irq_i <= x"00";
    --spi_bus(IRQRD_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(IRQWR_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(IRQRD_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(IRQMWR_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(IRQMRD_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --READ/WRITE TEST - 1 beat
    --spi_bus(SIMPLE_READ_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --READ/WRITE TEST - 2 beat
    --spi_bus(SIMPLE_READ_2_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(SIMPLE_WRITE_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --FAST_READ/WRITE
    spi_bus(FAST_READ_WORD_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    --wait for 35 ns;
    --spi_bus(FAST_WRITE_WORD_c,spi_rxdata_s,spcs_i,spck_i,miso_o,mosi_i);
    wait;
  end process;


  spi_axi_top_i : spi_axi_top
  generic map (
    cpol          => spi_cpol,
    cpha          => spi_cpha,
    ID_WIDTH      => ID_WIDTH,
    ID_VALUE      => ID_VALUE,
    ADDR_BYTE_NUM => ADDR_BYTE_NUM,
    DATA_BYTE_NUM => DATA_BYTE_NUM,
    serial_num_rw => serial_num_rw
  )
  port map (
    rst_i         => rst_i,
    mclk_i        => mclk_i,
    mosi_i        => mosi_i,
    miso_o        => miso_o,
    spck_i        => spck_i,
    spcs_i        => spcs_i,
    RSTIO_o       => RSTIO_o,
    DID_i         => DID_i,
    UID_i         => UID_i,
    serial_num_i  => serial_num_i,
    irq_i         => irq_i,
    irq_o         => irq_o,
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

  M_AXI_AWREADY <= '1';
  M_AXI_WREADY  <= '1';
  M_AXI_BVALID  <= '1';
  M_AXI_BRESP   <= "00";
  M_AXI_BID     <= (others=>'0');
  M_AXI_ARREADY <= '1';
  M_AXI_RVALID  <= '1';
  M_AXI_RDATA   <= x"4321ABCD"  when M_AXI_ARADDR(2) = '0' else x"56789ABC";
  M_AXI_RRESP   <= "00";
  M_AXI_RID     <= (others=>'0');
  M_AXI_RLAST   <= '0';

end simulation;
