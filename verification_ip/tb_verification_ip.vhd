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
use ieee.numeric_std.all;

entity tb_verification_ip is
end tb_verification_ip;

architecture arch_imp of tb_verification_ip is

  constant test_number                      : integer          := 2;
  constant prbs_sel                         : string           := "PRBS23";
  constant packet                           : boolean          := true;
  constant packet_random                    : boolean          := true;
  constant packet_size_max                  : integer          := 32;
  constant packet_size_min                  : integer          := 1;
  constant TUSER_SIZE                       : integer          := 4;
  constant verbose                          : boolean          := false;
  constant C_M00_AXI_ADDR_WIDTH             : integer          := 5;
  constant C_M00_AXI_DATA_WIDTH             : integer          := 32;
  constant C_M00_AXI_TRANSACTIONS_NUM       : integer          := 5;
  constant AXI_TDATA_BYTES_WIDTH            : integer          := 16;

  constant C_M00_AXI_START_DATA_VALUE       : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0) := (others=>'0');
  constant C_M00_AXI_TARGET_SLAVE_BASE_ADDR : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0) := (others=>'0');

  component verification_ip_v1_0 is
    generic (
      test_number                      : integer := 2;
      prbs_sel                         : string;
      packet                           : boolean := true;
      packet_random                    : boolean := true;
      packet_size_max                  : integer := 1023;
      packet_size_min                  : integer := 32;
      TUSER_SIZE                       : integer := 4;
      verbose                          : boolean := false;
      C_M00_AXI_START_DATA_VALUE       : std_logic_vector := C_M00_AXI_START_DATA_VALUE;
      C_M00_AXI_TARGET_SLAVE_BASE_ADDR : std_logic_vector := C_M00_AXI_TARGET_SLAVE_BASE_ADDR;
      C_M00_AXI_ADDR_WIDTH             : integer := 32;
      C_M00_AXI_DATA_WIDTH             : integer := 32;
      C_M00_AXI_TRANSACTIONS_NUM       : integer := 5;
      AXI_TDATA_BYTES_WIDTH            : integer := 16
    );
    port (
      addr_i           : in  std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
      data_i           : in  std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
      data_o           : out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
      command          : in  std_logic_vector(2 downto 0);
      start            : in  std_logic;
      busy             : out std_logic;
      m00_axi_aclk     : in  std_logic;
      m00_axi_aresetn  : in  std_logic;
      m00_axi_awaddr   : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
      m00_axi_awprot   : out std_logic_vector(2 downto 0);
      m00_axi_awvalid  : out std_logic;
      m00_axi_awready  : in  std_logic;
      m00_axi_wdata    : out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
      m00_axi_wstrb    : out std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0);
      m00_axi_wvalid   : out std_logic;
      m00_axi_wready   : in  std_logic;
      m00_axi_bresp    : in  std_logic_vector(1 downto 0);
      m00_axi_bvalid   : in  std_logic;
      m00_axi_bready   : out std_logic;
      m00_axi_araddr   : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
      m00_axi_arprot   : out std_logic_vector(2 downto 0);
      m00_axi_arvalid  : out std_logic;
      m00_axi_arready  : in  std_logic;
      m00_axi_rdata    : in  std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
      m00_axi_rresp    : in  std_logic_vector(1 downto 0);
      m00_axi_rvalid   : in  std_logic;
      m00_axi_rready   : out std_logic;
      s00_axis_aclk    : in  std_logic;
      s00_axis_aresetn : in  std_logic;
      s00_axis_tready  : out std_logic;
      s00_axis_tdata   : in  std_logic_vector(AXI_TDATA_BYTES_WIDTH*8-1 downto 0);
      s00_axis_tstrb   : in  std_logic_vector(AXI_TDATA_BYTES_WIDTH-1 downto 0);
      s00_axis_tuser   : in  std_logic_vector(TUSER_SIZE-1 downto 0);
      s00_axis_tdest   : in  std_logic_vector(1 downto 0);
      s00_axis_tlast   : in  std_logic;
      s00_axis_tvalid  : in  std_logic;
      m00_axis_aclk    : in  std_logic;
      m00_axis_aresetn : in  std_logic;
      m00_axis_tvalid  : out std_logic;
      m00_axis_tdata   : out std_logic_vector(AXI_TDATA_BYTES_WIDTH*8-1 downto 0);
      m00_axis_tuser   : out std_logic_vector(TUSER_SIZE-1 downto 0);
      m00_axis_tdest   : out std_logic_vector(1 downto 0);
      m00_axis_tstrb   : out std_logic_vector(AXI_TDATA_BYTES_WIDTH-1 downto 0);
      m00_axis_tlast   : out std_logic;
      m00_axis_tready  : in  std_logic
    );
  end component;

  signal m00_axi_aclk     : std_logic := '0';
  signal m00_axi_aresetn  : std_logic;
  signal m00_axi_awaddr   : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
  signal m00_axi_awprot   : std_logic_vector(2 downto 0);
  signal m00_axi_awvalid  : std_logic;
  signal m00_axi_awready  : std_logic;
  signal m00_axi_wdata    : std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
  signal m00_axi_wstrb    : std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0);
  signal m00_axi_wvalid   : std_logic;
  signal m00_axi_wready   : std_logic;
  signal m00_axi_bresp    : std_logic_vector(1 downto 0);
  signal m00_axi_bvalid   : std_logic;
  signal m00_axi_bready   : std_logic;
  signal m00_axi_araddr   : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
  signal m00_axi_arprot   : std_logic_vector(2 downto 0);
  signal m00_axi_arvalid  : std_logic;
  signal m00_axi_arready  : std_logic;
  signal m00_axi_rdata    : std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
  signal m00_axi_rresp    : std_logic_vector(1 downto 0);
  signal m00_axi_rvalid   : std_logic;
  signal m00_axi_rready   : std_logic;
  signal s00_axis_aclk    : std_logic := '0';
  signal s00_axis_aresetn : std_logic;
  signal s00_axis_tready  : std_logic;
  signal s00_axis_tdata   : std_logic_vector(AXI_TDATA_BYTES_WIDTH*8-1 downto 0);
  signal s00_axis_tstrb   : std_logic_vector(AXI_TDATA_BYTES_WIDTH-1 downto 0);
  signal s00_axis_tuser   : std_logic_vector(TUSER_SIZE-1 downto 0);
  signal s00_axis_tdest   : std_logic_vector(1 downto 0);
  signal s00_axis_tlast   : std_logic;
  signal s00_axis_tvalid  : std_logic;
  signal m00_axis_aclk    : std_logic := '0';
  signal m00_axis_aresetn : std_logic;
  signal m00_axis_tvalid  : std_logic;
  signal m00_axis_tdata   : std_logic_vector(AXI_TDATA_BYTES_WIDTH*8-1 downto 0);
  signal m00_axis_tuser   : std_logic_vector(TUSER_SIZE-1 downto 0);
  signal m00_axis_tdest   : std_logic_vector(1 downto 0);
  signal m00_axis_tstrb   : std_logic_vector(AXI_TDATA_BYTES_WIDTH-1 downto 0);
  signal m00_axis_tlast   : std_logic;
  signal m00_axis_tready  : std_logic;

  signal addr_i           : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
  signal data_i           : std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
  signal data_o           : std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
  signal command          : std_logic_vector(2 downto 0);
  signal start            : std_logic;
  signal busy             : std_logic;

begin

  m00_axis_aclk <= not m00_axis_aclk after 10 ns;
  s00_axis_aclk <= not s00_axis_aclk after 10 ns;
  m00_axi_aclk  <= not m00_axi_aclk  after 10 ns;
  m00_axi_aresetn  <= '0', '1' after 40 ns;
  m00_axis_aresetn <= '0', '1' after 40 ns;
  s00_axis_aresetn <= '0', '1' after 40 ns;

-- I/O Connections assignments
  dut_u : verification_ip_v1_0
    generic map(
      test_number                      => test_number,
      prbs_sel                         => prbs_sel,
      packet                           => packet,
      packet_random                    => packet_random,
      packet_size_max                  => packet_size_max,
      packet_size_min                  => packet_size_min,
      TUSER_SIZE                       => TUSER_SIZE,
      verbose                          => verbose,
      C_M00_AXI_START_DATA_VALUE       => C_M00_AXI_START_DATA_VALUE,
      C_M00_AXI_TARGET_SLAVE_BASE_ADDR => C_M00_AXI_TARGET_SLAVE_BASE_ADDR,
      C_M00_AXI_ADDR_WIDTH             => C_M00_AXI_ADDR_WIDTH,
      C_M00_AXI_DATA_WIDTH             => C_M00_AXI_DATA_WIDTH,
      C_M00_AXI_TRANSACTIONS_NUM       => C_M00_AXI_TRANSACTIONS_NUM,
      AXI_TDATA_BYTES_WIDTH            => AXI_TDATA_BYTES_WIDTH
    )
    port map(
      addr_i           => addr_i,
      data_i           => data_i,
      data_o           => data_o,
      command          => command,
      start            => start,
      busy             => busy,
      m00_axi_aclk     => m00_axi_aclk,
      m00_axi_aresetn  => m00_axi_aresetn,
      m00_axi_awaddr   => m00_axi_awaddr,
      m00_axi_awprot   => m00_axi_awprot,
      m00_axi_awvalid  => m00_axi_awvalid,
      m00_axi_awready  => m00_axi_awready,
      m00_axi_wdata    => m00_axi_wdata,
      m00_axi_wstrb    => m00_axi_wstrb,
      m00_axi_wvalid   => m00_axi_wvalid,
      m00_axi_wready   => m00_axi_wready,
      m00_axi_bresp    => m00_axi_bresp,
      m00_axi_bvalid   => m00_axi_bvalid,
      m00_axi_bready   => m00_axi_bready,
      m00_axi_araddr   => m00_axi_araddr,
      m00_axi_arprot   => m00_axi_arprot,
      m00_axi_arvalid  => m00_axi_arvalid,
      m00_axi_arready  => m00_axi_arready,
      m00_axi_rdata    => m00_axi_rdata,
      m00_axi_rresp    => m00_axi_rresp,
      m00_axi_rvalid   => m00_axi_rvalid,
      m00_axi_rready   => m00_axi_rready,
      s00_axis_aclk    => s00_axis_aclk,
      s00_axis_aresetn => s00_axis_aresetn,
      s00_axis_tready  => s00_axis_tready,
      s00_axis_tdata   => s00_axis_tdata,
      s00_axis_tstrb   => s00_axis_tstrb,
      s00_axis_tuser   => s00_axis_tuser,
      s00_axis_tdest   => s00_axis_tdest,
      s00_axis_tlast   => s00_axis_tlast,
      s00_axis_tvalid  => s00_axis_tvalid,
      m00_axis_aclk    => m00_axis_aclk,
      m00_axis_aresetn => m00_axis_aresetn,
      m00_axis_tvalid  => m00_axis_tvalid,
      m00_axis_tdata   => m00_axis_tdata,
      m00_axis_tuser   => m00_axis_tuser,
      m00_axis_tdest   => m00_axis_tdest,
      m00_axis_tstrb   => m00_axis_tstrb,
      m00_axis_tlast   => m00_axis_tlast,
      m00_axis_tready  => m00_axis_tready
    );

    m00_axis_tready  <= s00_axis_tready;

    s00_axis_tvalid  <= m00_axis_tvalid;
    s00_axis_tdata   <= m00_axis_tdata;
    s00_axis_tuser   <= m00_axis_tuser;
    s00_axis_tdest   <= m00_axis_tdest;
    s00_axis_tstrb   <= m00_axis_tstrb;
    s00_axis_tlast   <= m00_axis_tlast;


    process
    begin
        start <= '0';
        wait until m00_axi_aresetn = '1';
        -- read golden register.
        wait until rising_edge(m00_axi_aclk);
        start <= '1';
        command  <= "000";
        addr_i   <= (others=>'0');
        wait until busy = '1';
        wait until busy = '0';
        start <= '0';
        --escrever no registro de chave
        wait;
        for j in 0 to 2**C_M00_AXI_ADDR_WIDTH-1 loop
            wait until rising_edge(m00_axi_aclk);
            start <= '1';
            command  <= "001";
            data_i <= std_logic_vector(to_unsigned(2**C_M00_AXI_ADDR_WIDTH-1-j,data_i'length));
            addr_i <= std_logic_vector(to_unsigned(j,addr_i'length));
            wait until busy = '1';
            wait until busy = '0';
            start <= '0';
        end loop;
        wait;
    end process;

end arch_imp;
