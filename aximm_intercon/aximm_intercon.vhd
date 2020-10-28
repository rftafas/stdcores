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
library expert;
	use expert.std_logic_expert.all;

entity aximm_intercon is
    generic (
      master_portnum : positive := 8;
      slave_portnum  : positive := 8;
      DATA_BYTE_NUM  : positive := 8;
      ADDR_BYTE_NUM  : positive := 8
    );
    port (
      --general
      rst_i       : in  std_logic;
      clk_i       : in  std_logic;
      --------------------------------------------------------------------------
      --AXIS Master Port
      --------------------------------------------------------------------------
      M_AXI_AWID    : out std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      M_AXI_AWVALID : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_AWREADY : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_AWADDR  : out std_logic_array (master_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
      M_AXI_AWPROT  : out std_logic_array (master_portnum-1 downto 0,2 downto 0);
      --write data channel
      M_AXI_WVALID  : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_WREADY  : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_WDATA   : out std_logic_array (master_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_WSTRB   : out std_logic_vector(master_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0);
      M_AXI_WLAST   : out std_logic_vector(master_portnum-1 downto 0);
      --Write Response channel
      M_AXI_BVALID  : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_BREADY  : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_BRESP   : in  std_logic_array (master_portnum-1 downto 0,1 downto 0);
      M_AXI_BID     : in  std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      -- Read Address channel
      M_AXI_ARVALID : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_ARREADY : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_ARADDR  : out std_logic_array (master_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
      M_AXI_ARPROT  : out std_logic_array (master_portnum-1 downto 0,2 downto 0);
      M_AXI_ARID    : out std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      --Read data channel
      M_AXI_RVALID  : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_RREADY  : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_RDATA   : in  std_logic_array (master_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_RRESP   : in  std_logic_array (master_portnum-1 downto 0,1 downto 0);
      M_AXI_RID     : in  std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      M_AXI_RLAST   : in  std_logic_vector(master_portnum-1 downto 0);
      --------------------------------------------------------------------------
      --AXIS Slave Port
      --------------------------------------------------------------------------
      S_AXI_AWID    : in  std_logic_array (slave_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      S_AXI_AWVALID : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_AWREADY : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_AWADDR  : in  std_logic_array (slave_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_array (slave_portnum-1 downto 0,2 downto 0);
      --write data channel
      S_AXI_WVALID  : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_WREADY  : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_WDATA   : in  std_logic_array (slave_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector(slave_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0);
      S_AXI_WLAST   : in  std_logic_vector(slave_portnum-1 downto 0);
      --Write Response channel
      S_AXI_BVALID  : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_BREADY  : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_BRESP   : out std_logic_array (slave_portnum-1 downto 0,1 downto 0);
      S_AXI_BID     : out std_logic_array (slave_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      -- Read Address channel
      S_AXI_ARVALID : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_ARREADY : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_ARADDR  : in  std_logic_array (slave_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_array (slave_portnum-1 downto 0,2 downto 0);
      S_AXI_ARID    : in  std_logic_array (slave_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      --Read data channel
      S_AXI_RVALID  : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_RREADY  : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_RDATA   : out std_logic_array (slave_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_RRESP   : out std_logic_array (slave_portnum-1 downto 0,1 downto 0);
      S_AXI_RID     : out std_logic_array (slave_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      S_AXI_RLAST   : out std_logic_vector(slave_portnum-1 downto 0)
    );
end aximm_intercon;

architecture behavioral of aximm_intercon is

  constant tot_axis_peripheral : positive := 2*master_portnum+3*slave_portnum;
  constant tot_axis_controller : positive := 3*master_portnum+2*slave_portnum;
  constant tdest_size          : positive := size_of(slave_portnum);

  signal m_tdata_s  : std_logic_array (tot_axis_peripheral-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
  signal m_tuser_s  : std_logic_array (tot_axis_peripheral-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
  signal m_tdest_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdest_size-1 downto 0);
  signal m_tready_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal m_tvalid_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal m_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0);

  signal s_tdata_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdata_size-1 downto 0);
  signal s_tuser_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tuser_size-1 downto 0);
  signal s_tdest_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdest_size-1 downto 0);
  signal s_tready_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal s_tvalid_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal s_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0)

begin

  --AXI CONTROLLERS READ CHANNEL LOGIC
  addr_gen : for j in 0 to tot_axis_controller-1 generate

    ar_gen : if j < master_portnum generate
      M_AXI_ARADDR(j)  <= m_tdata_s(j);
      M_AXI_ARID(j)    <= m_tuser_s(j,());
      M_AXI_ARPROT(j)  <= m_tuser_s(j,());
      --<= m_tdest_s(j);
      m_tready_s(j)    <= M_AXI_ARREADY(j);
      M_AXI_ARVALID(j) <= m_tvalid_s(j);
      --<= m_tlast_s(j);
    elsif j < 2*master_portnum generate
      M_AXI_AWADDR(j)  <= m_tdata_s(j);
      M_AXI_AWID(j)    <= m_tuser_s(j,());
      M_AXI_AWPROT(j)  <= m_tuser_s(j,());
      --<= m_tdest_s(j);
      m_tready_s(j)    <= M_AXI_AWREADY(j);
      M_AXI_AWVALID(j) <= m_tvalid_s(j);
      --<= m_tlast_s(j);
    elsif j < 3*master_portnum generate
      M_AXI_WDATA(j)   <= m_tdata_s(j);
      --<= m_tuser_s(j,());
      M_AXI_WSTRB(j)   <= m_tuser_s(j,());
      --<= m_tdest_s(j);
      m_tready_s(j)    <= M_AXI_WREADY(j);
      M_AXI_WVALID(j)  <= m_tvalid_s(j);
      --<= m_tlast_s(j);
    elsif j < 3*master_portnum + slave_portnum generate
      M_AXI_AWADDR(j)  <= m_tdata_s(j);
      M_AXI_AWID(j)    <= m_tuser_s(j,());
      M_AXI_AWPROT(j)  <= m_tuser_s(j,());
      --<= m_tdest_s(j);
      m_tready_s(j)    <= M_AXI_AWREADY(j);
      M_AXI_AWVALID(j) <= m_tvalid_s(j);
      --<= m_tlast_s(j);
    else generate
      M_AXI_AWADDR(j)  <= m_tdata_s(j);
      M_AXI_AWID(j)    <= m_tuser_s(j,());
      M_AXI_AWPROT(j)  <= m_tuser_s(j,());
      --<= m_tdest_s(j);
      m_tready_s(j)    <= M_AXI_AWREADY(j);
      M_AXI_AWVALID(j) <= m_tvalid_s(j);
      --<= m_tlast_s(j);
    end generate;

  end generate;

  axis_intercon_i : axis_intercon
  generic map (
    master_portnum => 5*master_portnum,
    slave_portnum  => 5*slave_portnum,
    tdata_size     => tdata_size,
    tdest_size     => tdest_size,
    tuser_size     => tuser_size,
    select_auto    => select_auto,
    switch_tlast   => switch_tlast,
    interleaving   => interleaving,
    max_tx_size    => max_tx_size,
    mode           => mode
  )
  port map (
    rst_i      => rst_i,
    clk_i      => clk_i,
    m_tdata_o  => m_tdata_o,
    m_tuser_o  => m_tuser_o,
    m_tdest_o  => m_tdest_o,
    m_tready_i => m_tready_i,
    m_tvalid_o => m_tvalid_o,
    m_tlast_o  => m_tlast_o,
    s_tdata_i  => s_tdata_i,
    s_tuser_i  => s_tuser_i,
    s_tdest_i  => s_tdest_i,
    s_tready_o => s_tready_o,
    s_tvalid_i => s_tvalid_i,
    s_tlast_i  => s_tlast_i
  );


end behavioral;
