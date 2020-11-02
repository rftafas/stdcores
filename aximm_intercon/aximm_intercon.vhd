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
      ADDR_BYTE_NUM  : positive := 8;
      ID_WIDTH       : positive := 8
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

  constant master_num_size     : integer size_of(master_portnum);
  constant slave_num_size      : integer size_of(slave_portnum);

  constant tot_axis_peripheral : positive := 2*master_portnum+3*slave_portnum;
  constant tot_axis_controller : positive := 3*master_portnum+2*slave_portnum;

  constant tdata_size : positive := maximum(ADDR_BYTE_NUM,DATA_BYTE_NUM);
  constant tdest_size : positive := maximum(size_of(slave_portnum),size_of(master_portnum));
  constant tuser_size : positive := size_of(master_portnum)+size_of(slave_portnum)+ID_WIDTH;

  signal m_tdata_s  : std_logic_array (tot_axis_peripheral-1 downto 0,8*tdata_size-1 downto 0);
  signal m_tstrb_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdata_size-1 downto 0);
  signal m_tuser_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tuser_size-1 downto 0);
  signal m_tdest_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdest_size-1 downto 0);
  signal m_tready_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal m_tvalid_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal m_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0);

  signal s_tdata_s  : std_logic_array (tot_axis_peripheral-1 downto 0,8*tdata_size-1 downto 0);
  signal s_tstrb_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdata_size-1 downto 0);
  signal s_tuser_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tuser_size-1 downto 0);
  signal s_tdest_s  : std_logic_array (tot_axis_peripheral-1 downto 0,tdest_size-1 downto 0);
  signal s_tready_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal s_tvalid_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal s_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0)

  signal m_tdata_align_s  : std_logic_array (slave_portnum-1 downto 0,8*tdata_size-1 downto 0);
  signal m_tstrb_align_s  : std_logic_array (slave_portnum-1 downto 0,tdata_size-1 downto 0);
  signal m_tuser_align_s  : std_logic_array (slave_portnum-1 downto 0,tuser_size-1 downto 0);
  signal m_tdest_align_s  : std_logic_array (slave_portnum-1 downto 0,tdest_size-1 downto 0);
  signal m_tready_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal m_tvalid_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal m_tlast_align_s  : std_logic_vector(slave_portnum-1 downto 0);

  signal s_tdata_align_s  : std_logic_array (slave_portnum-1 downto 0,8*tdata_size-1 downto 0);
  signal s_tstrb_align_s  : std_logic_array (slave_portnum-1 downto 0,tdata_size-1 downto 0);
  signal s_tuser_align_s  : std_logic_array (slave_portnum-1 downto 0,tuser_size-1 downto 0);
  signal s_tdest_align_s  : std_logic_array (slave_portnum-1 downto 0,tdest_size-1 downto 0);
  signal s_tready_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal s_tvalid_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal s_tlast_align_s  : std_logic_vector(slave_portnum-1 downto 0)


-------------------------------------------------------------------------------
--AXIS INTERCON SLAVE SIGNALS / ALIAS
--------------------------------------------------------------------------------
  alias s_awaddr_a  : std_logic_array ( slave_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0) is s_tdata_align_s(s_waddr_range.high downto s_waddr_range.low,8*ADDR_BYTE_NUM-1 downto 0);
  alias s_wdata_a   : std_logic_array ( slave_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0) is s_tdata_align_s(s_wdata_range.high downto s_wdata_range.low,8*DATA_BYTE_NUM-1 downto 0);
  alias s_wstrb_a   : std_logic_array (master_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0) is s_tdata_align_s(s_wdata_range.high downto s_wdata_range.low,DATA_BYTE_NUM-1 downto 0);
  alias s_awvalid_a : std_logic_vector( slave_portnum-1 downto 0) is s_tvalid_align_s(s_waddr_range.high downto s_waddr_range.low);
  alias s_wvalid_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tvalid_align_s(s_wdata_range.high downto s_wdata_range.low);
  alias s_awready_a : std_logic_vector( slave_portnum-1 downto 0) is s_tready_s(s_waddr_range.high downto s_waddr_range.low);
  alias s_wready_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tready_s(s_wdata_range.high downto s_wdata_range.low);
  alias s_wlast_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tlast_s(s_wdata_range.high downto s_wdata_range.low);
  alias s_awid_a    : std_logic_array ( slave_portnum-1 downto 0,ID_WIDTH-1 downto 0) is s_tuser_s(s_waddr_range.high downto s_waddr_range.low,ID_WIDTH-1 downto 0);
  alias s_awnus_a   : std_logic_array ( slave_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_waddr_range.high downto s_waddr_range.low,master_nus_size+ID_WIDTH-1 downto ID_WIDTH);
  alias s_awprot_a  : std_logic_array ( slave_portnum-1 downto 0,2 downto 0) is s_tuser_s(s_waddr_range.high downto s_waddr_range.low,master_nus_size+ID_WIDTH+1 downto master_nus_size+ID_WIDTH);
  alias s_awdest_a  : std_logic_array ( slave_portnum-1 downto 0,tdest_size-1 downto 0) is s_tdest_s(s_waddr_range.high downto s_waddr_range.low,tdest_size-1 downto 0);
  alias s_wdest_a   : std_logic_array ( slave_portnum-1 downto 0,tdest_size-1 downto 0) is s_tdest_s(s_wdata_range.high downto s_wdata_range.low,tdest_size-1 downto 0);

--------------------------------------------------------------------------------
--AXIS INTERCON SLAVE SIGNALS / ALIAS
--------------------------------------------------------------------------------
  constant s_waddr_range : range_t := (
    high => slave_portnum-1,
    low  => 0
  );
  constant s_wdata_range : range_t := (
    high => 2*slave_portnum-1,
    low  =>   slave_portnum
  );
  constant s_raddr_range : range_t := (
    high => 3*slave_portnum-1,
    low  => 2*slave_portnum
  );
  constant s_rdata_range : range_t := (
    high =>   master_portnum+3*slave_portnum-1,
    low  => 3*slave_portnum
  );
  constant s_bresp_range : range_t := (
    high => 2*master_portnum+3*slave_portnum-1,
    low  => master_portnum+3*slave_portnum
  );

  alias s_awaddr_a  : std_logic_array ( slave_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0) is s_tdata_s(s_waddr_range.high downto s_waddr_range.low,8*ADDR_BYTE_NUM-1 downto 0);
  alias s_wdata_a   : std_logic_array ( slave_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0) is s_tdata_s(s_wdata_range.high downto s_wdata_range.low,8*DATA_BYTE_NUM-1 downto 0);
  alias s_araddr_a  : std_logic_array ( slave_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0) is s_tdata_s(s_raddr_range.high downto s_raddr_range.low,8*ADDR_BYTE_NUM-1 downto 0);
  alias s_rdata_a   : std_logic_array (master_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0) is s_tdata_s(s_rdata_range.high downto s_rdata_range.low,8*DATA_BYTE_NUM-1 downto 0);
  alias s_bresp_a   : std_logic_array (master_portnum-1 downto 0,                1 downto 0) is s_tdata_s(s_bresp_range.high downto s_bresp_range.low,                1 downto 0);

  --alias s_wastrb_a  : std_logic_array (master_portnum-1 downto 0,ADDR_BYTE_NUM-1 downto 0) is s_tdata_s(s_waddr_range.high downto s_waddr_range.low,ADDR_BYTE_NUM-1 downto 0);
  alias s_wstrb_a   : std_logic_array (master_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0) is s_tdata_s(s_wdata_range.high downto s_wdata_range.low,DATA_BYTE_NUM-1 downto 0);
  --alias s_rastrb_a  : std_logic_array (master_portnum-1 downto 0,ADDR_BYTE_NUM-1 downto 0) is s_tdata_s(s_raddr_range.high downto s_raddr_range.low,ADDR_BYTE_NUM-1 downto 0);
  --alias s_rstrb_a   : std_logic_array ( slave_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0) is s_tdata_s(s_rdata_range.high downto s_rdata_range.low,DATA_BYTE_NUM-1 downto 0);
  --alias s_bstrb_a   : std_logic_array ( slave_portnum-1 downto 0,              0 downto 0) is s_tdata_s(s_bresp_range.high downto s_bresp_range.low,              0 downto 0);

  alias s_awvalid_a : std_logic_vector( slave_portnum-1 downto 0) is s_tvalid_s(s_waddr_range.high downto s_waddr_range.low);
  alias s_wvalid_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tvalid_s(s_wdata_range.high downto s_wdata_range.low);
  alias s_arvalid_a : std_logic_vector( slave_portnum-1 downto 0) is s_tvalid_s(s_raddr_range.high downto s_raddr_range.low);
  alias s_rvalid_a  : std_logic_vector(master_portnum-1 downto 0) is s_tvalid_s(s_rdata_range.high downto s_rdata_range.low);
  alias s_bvalid_a  : std_logic_vector(master_portnum-1 downto 0) is s_tvalid_s(s_bresp_range.high downto s_bresp_range.low);

  alias s_awready_a : std_logic_vector( slave_portnum-1 downto 0) is s_tready_s(s_waddr_range.high downto s_waddr_range.low);
  alias s_wready_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tready_s(s_wdata_range.high downto s_wdata_range.low);
  alias s_arready_a : std_logic_vector( slave_portnum-1 downto 0) is s_tready_s(s_raddr_range.high downto s_raddr_range.low);
  alias s_rready_a  : std_logic_vector(master_portnum-1 downto 0) is s_tready_s(s_rdata_range.high downto s_rdata_range.low);
  alias s_bready_a  : std_logic_vector(master_portnum-1 downto 0) is s_tready_s(s_bresp_range.high downto s_bresp_range.low);

  --alias s_awlast_a : std_logic_vector(master_portnum-1 downto 0) is s_tlast_s(s_waddr_range.high downto s_waddr_range.low);
  alias s_wlast_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tlast_s(s_wdata_range.high downto s_wdata_range.low);
  --alias s_arlast_a : std_logic_vector(master_portnum-1 downto 0) is s_tlast_s(s_raddr_range.high downto s_raddr_range.low);
  alias s_rlast_a  : std_logic_vector(master_portnum-1 downto 0) is s_tlast_s(s_rdata_range.high downto s_rdata_range.low);
  --alias s_blast_a  : std_logic_vector( slave_portnum-1 downto 0) is s_tlast_s(s_bresp_range.high downto s_bresp_range.low);

  --TUSER should transport:
  --Master of current transaction
  --ID of current transaction.
  alias s_awid_a    : std_logic_array ( slave_portnum-1 downto 0,ID_WIDTH-1 downto 0) is s_tuser_s(s_waddr_range.high downto s_waddr_range.low,ID_WIDTH-1 downto 0);
  --alias s_wid_a     : std_logic_array (slave_portnum-1 downto 0,ID_WIDTH-1 downto 0) is s_tuser_s(s_wdata_range.high downto s_wdata_range.low,ID_WIDTH-1 downto 0);
  alias s_arid_a    : std_logic_array ( slave_portnum-1 downto 0,ID_WIDTH-1 downto 0) is s_tuser_s(s_raddr_range.high downto s_raddr_range.low,ID_WIDTH-1 downto 0);
  alias s_rid_a     : std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0) is s_tuser_s(s_rdata_range.high downto s_rdata_range.low,ID_WIDTH-1 downto 0);
  alias s_bid_a     : std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0) is s_tuser_s(s_bresp_range.high downto s_bresp_range.low,ID_WIDTH-1 downto 0);

  alias s_awnus_a   : std_logic_array ( slave_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_waddr_range.high downto s_waddr_range.low,master_nus_size+ID_WIDTH-1 downto ID_WIDTH);
  alias s_wnus_a    : std_logic_array ( slave_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_wdata_range.high downto s_wdata_range.low,master_nus_size+ID_WIDTH-1 downto ID_WIDTH);
  alias s_arnus_a   : std_logic_array ( slave_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_raddr_range.high downto s_raddr_range.low,master_nus_size+ID_WIDTH-1 downto ID_WIDTH);
  alias s_rnus_a    : std_logic_array (master_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_rdata_range.high downto s_rdata_range.low,master_nus_size+ID_WIDTH-1 downto ID_WIDTH);
  alias s_bnus_a    : std_logic_array (master_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_bresp_range.high downto s_bresp_range.low,master_nus_size+ID_WIDTH-1 downto ID_WIDTH);

  alias s_awprot_a  : std_logic_array ( slave_portnum-1 downto 0,2 downto 0) is s_tuser_s(s_waddr_range.high downto s_waddr_range.low,master_nus_size+ID_WIDTH+1 downto master_nus_size+ID_WIDTH);
  alias s_arprot_a  : std_logic_array ( slave_portnum-1 downto 0,2 downto 0) is s_tuser_s(s_raddr_range.high downto s_raddr_range.low,master_nus_size+ID_WIDTH+1 downto master_nus_size+ID_WIDTH);

  alias s_rresp_a   : std_logic_array (master_portnum-1 downto 0,master_nus_size-1 downto 0) is s_tuser_s(s_rdata_range.high downto s_rdata_range.low,ID_WIDTH+1 downto ID_WIDTH);

  alias s_awdest_a  : std_logic_array ( slave_portnum-1 downto 0,tdest_size-1 downto 0) is s_tdest_s(s_waddr_range.high downto s_waddr_range.low,tdest_size-1 downto 0);
  alias s_wdest_a   : std_logic_array ( slave_portnum-1 downto 0,tdest_size-1 downto 0) is s_tdest_s(s_wdata_range.high downto s_wdata_range.low,tdest_size-1 downto 0);
  alias s_ardest_a  : std_logic_array ( slave_portnum-1 downto 0,tdest_size-1 downto 0) is s_tdest_s(s_raddr_range.high downto s_raddr_range.low,tdest_size-1 downto 0);
  alias s_rdest_a   : std_logic_array (master_portnum-1 downto 0,tdest_size-1 downto 0) is s_tdest_s(s_rdata_range.high downto s_rdata_range.low,tdest_size-1 downto 0);
  alias s_bdest_a   : std_logic_array (master_portnum-1 downto 0,tdest_size 1 downto 0) is s_tdest_s(s_bresp_range.high downto s_bresp_range.low,tdest_size 1 downto 0);

  --------------------------------------------------------------------------------
  --AXIS INTERCON MASTER SIGNALS / ALIAS
  --------------------------------------------------------------------------------
  constant m_waddr_range : range_t := (
    high => master_portnum-1,
    low  => 0
  );
  constant m_wdata_range : range_t := (
    high => 2*master_portnum-1,
    low  =>   master_portnum
  );
  constant m_raddr_range : range_t := (
    high => 3*master_portnum-1,
    low  => 2*master_portnum
  );
  constant m_rdata_range : range_t := (
    high =>   slave_portnum+3*master_portnum-1,
    low  => 3*master_portnum
  );
  constant m_bresp_range : range_t := (
    high => 2*slave_portnum+3*master_portnum-1,
    low  => slave_portnum+3*master_portnum
  );

  alias m_awaddr_a  : std_logic_array (master_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0) is m_tdata_s(m_waddr_range.high downto m_waddr_range.low,8*ADDR_BYTE_NUM-1 downto 0);
  alias m_wdata_a   : std_logic_array (master_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0) is m_tdata_s(m_wdata_range.high downto m_wdata_range.low,8*DATA_BYTE_NUM-1 downto 0);
  alias m_araddr_a  : std_logic_array (master_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0) is m_tdata_s(m_raddr_range.high downto m_raddr_range.low,8*ADDR_BYTE_NUM-1 downto 0);
  alias m_rdata_a   : std_logic_array ( slave_portnum-1 downto 0,8*DATA_BYTE_NUM-1 downto 0) is m_tdata_s(m_rdata_range.high downto m_rdata_range.low,8*DATA_BYTE_NUM-1 downto 0);
  alias m_bresp_a   : std_logic_array ( slave_portnum-1 downto 0,                1 downto 0) is m_tdata_s(m_bresp_range.high downto m_bresp_range.low,                1 downto 0);

  --alias m_wastrb_a  : std_logic_array (master_portnum-1 downto 0,ADDR_BYTE_NUM-1 downto 0) is m_tdata_s(m_waddr_range.high downto m_waddr_range.low,ADDR_BYTE_NUM-1 downto 0);
  alias m_wstrb_a   : std_logic_array (master_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0) is m_tdata_s(m_wdata_range.high downto m_wdata_range.low,DATA_BYTE_NUM-1 downto 0);
  --alias m_rastrb_a  : std_logic_array (master_portnum-1 downto 0,ADDR_BYTE_NUM-1 downto 0) is m_tdata_s(m_raddr_range.high downto m_raddr_range.low,ADDR_BYTE_NUM-1 downto 0);
  --alias m_rstrb_a   : std_logic_array ( slave_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0) is m_tdata_s(m_rdata_range.high downto m_rdata_range.low,DATA_BYTE_NUM-1 downto 0);
  --alias m_bstrb_a   : std_logic_array ( slave_portnum-1 downto 0,              0 downto 0) is m_tdata_s(m_bresp_range.high downto m_bresp_range.low,              0 downto 0);

  alias m_awvalid_a : std_logic_vector(master_portnum-1 downto 0) is m_tvalid_s(m_waddr_range.high downto m_waddr_range.low);
  alias m_wvalid_a  : std_logic_vector(master_portnum-1 downto 0) is m_tvalid_s(m_wdata_range.high downto m_wdata_range.low);
  alias m_arvalid_a : std_logic_vector(master_portnum-1 downto 0) is m_tvalid_s(m_raddr_range.high downto m_raddr_range.low);
  alias m_rvalid_a  : std_logic_vector( slave_portnum-1 downto 0) is m_tvalid_s(m_rdata_range.high downto m_rdata_range.low);
  alias m_bvalid_a  : std_logic_vector( slave_portnum-1 downto 0) is m_tvalid_s(m_bresp_range.high downto m_bresp_range.low);

  alias m_awready_a : std_logic_vector(master_portnum-1 downto 0) is m_tready_s(m_waddr_range.high downto m_waddr_range.low);
  alias m_wready_a  : std_logic_vector(master_portnum-1 downto 0) is m_tready_s(m_wdata_range.high downto m_wdata_range.low);
  alias m_arready_a : std_logic_vector(master_portnum-1 downto 0) is m_tready_s(m_raddr_range.high downto m_raddr_range.low);
  alias m_rready_a  : std_logic_vector( slave_portnum-1 downto 0) is m_tready_s(m_rdata_range.high downto m_rdata_range.low);
  alias m_bready_a  : std_logic_vector( slave_portnum-1 downto 0) is m_tready_s(m_bresp_range.high downto m_bresp_range.low);

  --alias m_awlast_a : std_logic_vector(master_portnum-1 downto 0) is m_tlast_s(m_waddr_range.high downto m_waddr_range.low);
  alias m_wlast_a  : std_logic_vector(master_portnum-1 downto 0) is m_tlast_s(m_wdata_range.high downto m_wdata_range.low);
  --alias m_arlast_a : std_logic_vector(master_portnum-1 downto 0) is m_tlast_s(m_raddr_range.high downto m_raddr_range.low);
  alias m_rlast_a  : std_logic_vector( slave_portnum-1 downto 0) is m_tlast_s(m_rdata_range.high downto m_rdata_range.low);
  --alias m_blast_a  : std_logic_vector( slave_portnum-1 downto 0) is m_tlast_s(m_bresp_range.high downto m_bresp_range.low);

  --TUSER should transport:
  --Master of current transaction
  --ID of current transaction.
  alias m_awid_a    : std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0) is m_tuser_s(m_waddr_range.high downto m_waddr_range.low,ID_WIDTH-1 downto 0);
  --alias m_wid_a     : std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0) is m_tuser_s(m_wdata_range.high downto m_wdata_range.low,ID_WIDTH-1 downto 0);
  alias m_arid_a    : std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0) is m_tuser_s(m_raddr_range.high downto m_raddr_range.low,ID_WIDTH-1 downto 0);
  alias m_rid_a     : std_logic_array ( slave_portnum-1 downto 0,ID_WIDTH-1 downto 0) is m_tuser_s(m_rdata_range.high downto m_rdata_range.low,ID_WIDTH-1 downto 0);
  alias m_bid_a     : std_logic_array ( slave_portnum-1 downto 0,ID_WIDTH-1 downto 0) is m_tuser_s(m_bresp_range.high downto m_bresp_range.low,ID_WIDTH-1 downto 0);

  alias m_awnum_a   : std_logic_array (master_portnum-1 downto 0,master_num_size-1 downto 0) is m_tuser_s(m_waddr_range.high downto m_waddr_range.low,master_num_size+ID_WIDTH-1 downto ID_WIDTH);
  alias m_wnum_a    : std_logic_array (master_portnum-1 downto 0,master_num_size-1 downto 0) is m_tuser_s(m_wdata_range.high downto m_wdata_range.low,master_num_size+ID_WIDTH-1 downto ID_WIDTH);
  alias m_arnum_a   : std_logic_array (master_portnum-1 downto 0,master_num_size-1 downto 0) is m_tuser_s(m_raddr_range.high downto m_raddr_range.low,master_num_size+ID_WIDTH-1 downto ID_WIDTH);
  alias m_rnum_a    : std_logic_array ( slave_portnum-1 downto 0,master_num_size-1 downto 0) is m_tuser_s(m_rdata_range.high downto m_rdata_range.low,master_num_size+ID_WIDTH-1 downto ID_WIDTH);
  alias m_bnum_a    : std_logic_array ( slave_portnum-1 downto 0,master_num_size-1 downto 0) is m_tuser_s(m_bresp_range.high downto m_bresp_range.low,master_num_size+ID_WIDTH-1 downto ID_WIDTH);

  alias m_awprot_a  : std_logic_array (master_portnum-1 downto 0,2 downto 0) is m_tuser_s(m_waddr_range.high downto m_waddr_range.low,master_num_size+ID_WIDTH+1 downto master_num_size+ID_WIDTH);
  alias m_arprot_a  : std_logic_array (master_portnum-1 downto 0,2 downto 0) is m_tuser_s(m_raddr_range.high downto m_raddr_range.low,master_num_size+ID_WIDTH+1 downto master_num_size+ID_WIDTH);

  alias m_rresp_a   : std_logic_array ( slave_portnum-1 downto 0,master_num_size-1 downto 0) is m_tuser_s(m_rdata_range.high downto m_rdata_range.low,ID_WIDTH+1 downto ID_WIDTH);

begin
--------------------------------------------------------------------------------
--AXIS INTERCON SLAVE
--------------------------------------------------------------------------------
s_awid_a      <= S_AXI_AWID;
s_awvalid_a   <= S_AXI_AWVALID;
S_AXI_AWREADY <= s_awready_a;
s_awaddr_a    <= S_AXI_AWADDR;
s_awprot_a    <= S_AXI_AWPROT;

s_wvalid_a    <= S_AXI_WVALID;
S_AXI_WREADY  <= s_wready_a;
s_wdata_a     <= S_AXI_WDATA;
s_wstrb_a     <= S_AXI_WSTRB;
s_wlast_a     <= S_AXI_WLAST;

s_bvalid_a    <= M_AXI_BVALID;
M_AXI_BREADY  <= s_bready_a;
s_bresp_a     <= M_AXI_BRESP;
s_bid_a       <= M_AXI_BID;

s_arvalid_a   <= S_AXI_ARVALID;
S_AXI_ARREADY <= s_arready_a;
s_araddr_a    <= S_AXI_ARADDR;
s_arprot_a    <= S_AXI_ARPROT;
s_arid_a      <= S_AXI_ARID;

s_rvalid_a    <= M_AXI_RVALID;
M_AXI_RREADY  <= s_rready_a;
s_rdata_a     <= M_AXI_RDATA;
s_rresp_a     <= M_AXI_RRESP;
s_rid_a       <= M_AXI_RID;
s_rlast_a     <= M_AXI_RLAST;

--we must align write address and data channels as per spec.
align_gen : for j in 0 to master_portnum-1 generate
begin
  s_awvalid_align_s(j)  <= S_AXI_AWVALID(j);
  s_AXI_AWREADY(j)      <= s_awready_align_s(j);
  s_tdata_align_s(j)(S_AXI_AWADDR'range)   <= S_AXI_AWADDR(j);
  s_tuser_s(j)(ID_WIDTH+1 downto ID_WIDTH) <= S_AXI_AWPROT(j);
  s_tuser_s(j)(ID_WIDTH-1 downto        0) <= S_AXI_AWID(j);

  s_wvalid_align_s(j+1) <= S_AXI_WVALID;
  s_AXI_WREADY          <= s_wready_align_s(j+1);
  s_wdata_align_s(j+1)  <= S_AXI_WDATA;
  s_wstrb_align_s(j+1)  <= S_AXI_WSTRB;
  s_wlast_align_s(j+1)  <= S_AXI_WLAST;

  align_u : axis_aligner
    generic map(
      number_ports => 2,
      tdata_size   => ,
      tdest_size   => ,
      tuser_size   =>
    )
    port map(
      clk_i      => clk_i,
      rst_i      => rst_i,
        --AXIS Master Port
      m_tdata_o  => m_tdata_align_s(j),
      m_tuser_o  => m_tuser_align_s(j),
      m_tdest_o  => m_tdest_align_s(j),
      m_tready_i => m_tready_align_s(j),
      m_tvalid_o => m_tvalid_align_s(j),
      m_tlast_o  => m_tlast_align_s(j),
        --AXIS Slave Port
      s_tdata_i  => s_tdata_align_s(j),
      s_tuser_i  => s_tuser_align_s(j),
      s_tdest_i  => s_tdest_align_s(j),
      s_tready_o => s_tready_align_s(j),
      s_tvalid_i => s_tvalid_align_s(j),
      s_tlast_i  => s_tlast_align_s(j)
    );

    m_awid_a         <= m_tuser_align_s;
    m_awvalid_a      <= m_tvalid_align_s;
    m_tready_align_s <= m_awready_a;
    m_awaddr_a       <= m_tdata_align_s;
    m_awprot_a       <= m_tuser_align_s;

    m_wvalid_a        <= m_tvalid_align_s;
    m_tready_align_s  <= m_wready_a;
    m_wdata_a         <= m_tdata_align_s;
    m_wstrb_a         <= m_tstrb_align_s;
    m_wlast_a         <= m_tlast_align_s;

end generate;

--Save pending operations on write channel, because one slave can accept several
write_gen : for j in slave_portnum-1 downto 0 generate
  signal saveadd_en : std_logic;
begin
  s_awdest_a(j) <= slave_decode(s_awaddr_a(j));
  saveadd_en    <= s_awvalid_a(j) and s_awready_a(j);
  wdata_u : srfifo1ck
      generic map(
        fifo_size => 16,
        port_size => s_wdest_a(j)
      );
      port map(
        --general
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => s_awdest_a(j),
        datab_o       => s_wdest_a(j),
        ena_i         => saveadd_en,
        enb_i         => s_wlast_a(j),
        --
        fifo_status_o => open
      );

  s_ardest_a(j) <= slave_decode(s_araddr_a(j));

end generate;

--------------------------------------------------------------------------------
--AXIS INTERCON MASTER
--------------------------------------------------------------------------------
  --WADDR
  M_AXI_AWID    <= m_awid_a;
  M_AXI_AWVALID <= m_awvalid_a;
  m_awready_a   <= M_AXI_AWREADY;
  M_AXI_AWADDR  <= m_awaddr_a;
  M_AXI_AWPROT  <= m_awprot_a;

  --WDATA
  M_AXI_WVALID <= m_wvalid_a;
  m_wready_a   <= M_AXI_WREADY;
  M_AXI_WDATA  <= m_wdata_a;
  M_AXI_WSTRB  <= m_wstrb_a;
  M_AXI_WLAST  <= m_wlast_a;

  --BRESP
  S_AXI_BVALID <= m_bvalid_a;
  m_bready_a   <= S_AXI_BREADY;
  S_AXI_BRESP  <= m_bresp_a;
  S_AXI_BID    <= m_bid_a;

  --RADDR
  M_AXI_ARVALID <= m_arvalid_a;
  m_arready_a   <= M_AXI_ARREADY;
  M_AXI_ARADDR  <= m_araddr_a;
  M_AXI_ARPROT  <= m_arprot_a;
  M_AXI_ARID    <= m_arid_a;

  --RDATA
  S_AXI_RVALID <= m_rvalid_a;
  m_rready_a   <= S_AXI_RREADY;
  S_AXI_RDATA  <= m_rdata_a;
  S_AXI_RRESP  <= m_rresp_a;
  S_AXI_RID    <= m_rid_a;
  S_AXI_RLAST  <= m_rlast_a;







--------------------------------------------------------------------------------
--STREAMING INTERCON
--------------------------------------------------------------------------------
  axis_intercon_i : axis_intercon
  generic map (
    master_portnum => tot_axis_controller,
    slave_portnum  => tot_axis_peripheral,
    tdata_size     => tdata_size,
    tdest_size     => tdest_size,
    tuser_size     => tuser_size,
    select_auto    => true,
    switch_tlast   => true,
    interleaving   => false,
    max_tx_size    => 16
  )
  port map (
    rst_i      => rst_i,
    clk_i      => clk_i,
    m_tdata_o  => m_tdata_s,
    m_tstrb_o  => m_tstrb_s,
    m_tuser_o  => m_tuser_s,
    m_tdest_o  => m_tdest_s,
    m_tready_i => m_tready_s,
    m_tvalid_o => m_tvalid_s,
    m_tlast_o  => m_tlast_s,
    s_tdata_i  => s_tdata_s,
    s_tstrb_i  => s_tstrb_s,
    s_tuser_i  => s_tuser_s,
    s_tdest_i  => s_tdest_s,
    s_tready_o => s_tready_s,
    s_tvalid_i => s_tvalid_s,
    s_tlast_i  => s_tlast_s
  );




end behavioral;
