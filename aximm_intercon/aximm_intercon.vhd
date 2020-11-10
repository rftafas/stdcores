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
      M_AXI_WSTRB   : out std_logic_array (master_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0);
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
      S_AXI_WSTRB   : in  std_logic_array (slave_portnum-1 downto 0,DATA_BYTE_NUM-1 downto 0);
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

  constant master_num_size     : integer := size_of(master_portnum);
  constant slave_num_size      : integer := size_of(slave_portnum);

  constant tot_axis_peripheral : positive := 2*master_portnum+3*slave_portnum;
  constant tot_axis_controller : positive := 3*master_portnum+2*slave_portnum;

  constant tdata_size : positive := maximum(ADDR_BYTE_NUM,DATA_BYTE_NUM);
  constant tdest_size : positive := maximum(size_of(slave_portnum),size_of(master_portnum));
  constant tuser_size : positive := size_of(master_portnum)+size_of(slave_portnum)+ID_WIDTH;

  type axi_signal_t is record
    tdata  : std_logic_vector(tdata_size-1 downto 0);
    tready : std_logic;
    tvalid : std_logic;
    tlast  : std_logic;
    tuser  : std_logic_vector(8*tdata_size-1 downto 0);
    tdest  : std_logic_vector(tdest_size-1 downto 0);
    tstrb  : std_logic_vector(tdata_size-1 downto 0);
  end record axi_signal_t;

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
  signal s_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0);

begin
--------------------------------------------------------------------------------
--WDATA / AWADDR ALIGNMENT
--------------------------------------------------------------------------------
  align_gen : for j in 0 to slave_portnum-1 generate

    align_namespace : block
      signal  s_tdata_align_s : std_logic_array (1 downto 0,8*tdata_size-1 downto 0);
      signal  s_tstrb_align_s : std_logic_array (1 downto 0,tdata_size-1 downto 0);
      signal  s_tuser_align_s : std_logic_array (1 downto 0,tuser_size-1 downto 0);
      signal  s_tdest_align_s : std_logic_array (1 downto 0,tdest_size-1 downto 0);
      signal s_tready_align_s : std_logic_vector(1 downto 0);
      signal s_tvalid_align_s : std_logic_vector(1 downto 0);
      signal  s_tlast_align_s : std_logic_vector(1 downto 0);
      signal  m_tdata_align_s : std_logic_array (1 downto 0,8*tdata_size-1 downto 0);
      signal  m_tstrb_align_s : std_logic_array (1 downto 0,tdata_size-1 downto 0);
      signal  m_tuser_align_s : std_logic_array (1 downto 0,tuser_size-1 downto 0);
      signal  m_tdest_align_s : std_logic_array (1 downto 0,tdest_size-1 downto 0);
      signal m_tready_align_s : std_logic_vector(1 downto 0);
      signal m_tvalid_align_s : std_logic_vector(1 downto 0);
      signal  m_tlast_align_s : std_logic_vector(1 downto 0);
      alias awid_a       : std_logic_vector() is s_tuser_align_s(0,);
      alias awprot_a     : std_logic_vector(2 downto 0) is s_tuser_align_s(0,2 downto 0);
      alias awmasterid_a : std_logic_vector() is s_tuser_align_s(0,);
    begin

      test_gen : for k in S_AXI_AWADDR'range(1) generate
        s_tdata_align_s(0,k)  <= S_AXI_AWADDR(j,k);
      end generate;
      s_tvalid_align_s(0) <= S_AXI_AWVALID(j);
      s_tstrb_align_s(0)  <= (others=>'1');
      s_tdest_align_s(0)  <= slave_decode(S_AXI_AWADDR(j));
      awid_a              <= S_AXI_AWID(j);
      awprot_a            <= S_AXI_AWPROT(j);
      awmasterid_a        <= so_std_logic_vector(j,); --master_id
      s_tlast_align_s(0)  <= '1';
      S_AXI_AWREADY(j)    <= s_tready_align_s(0);

      s_tdata_align_s(1,S_AXI_WDATA(j)'range(1))  <= S_AXI_WDATA(j);
      s_tvalid_align_s(1) <= S_AXI_WVALID(j);
      s_tstrb_align_s(1)  <= S_AXI_WSTRB(j)
      s_tdest_align_s(1)  <= slave_decode(S_AXI_AWADDR(j));
      s_tlast_align_s(1)  <= S_AXI_WLAST(j);
      S_AXI_AWREADY(j)    <= s_tready_align_s(1);


      align_u : axis_aligner
        generic map(
          number_ports => 2,
          tdata_size   => tdata_size,
          tdest_size   => tdest_size,
          tuser_size   => tuser_size
        )
        port map(
          clk_i      => clk_i,
          rst_i      => rst_i,
          --AXIS Slave Port
          s_tdata_i  => s_tdata_align_s,
          s_tuser_i  => s_tuser_align_s,
          s_tdest_i  => s_tdest_align_s,
          s_tstrb_i  => s_tstrb_align_s,
          s_tready_o => s_tready_align_s,
          s_tvalid_i => s_tvalid_align_s,
          s_tlast_i  => s_tlast_align_s,
          --AXIS Master Port
          m_tdata_o  => m_tdata_align_s,
          m_tuser_o  => m_tuser_align_s,
          m_tdest_o  => m_tdest_align_s,
          m_tstrb_o  => m_tstrb_align_s,
          m_tready_i => m_tready_align_s,
          m_tvalid_o => m_tvalid_align_s,
          m_tlast_o  => m_tlast_align_s
        );

      s_tdata_s(j,s_tdata_s'range(1))  <= m_tdata_align_s(0,m_tdata_align_s'range(1));
      s_tstrb_s(j)  <= m_tstrb_align_s(0);
      s_tvalid_s(j) <= m_tvalid_align_s(0);
      s_tdest_s(j)  <= m_tdest_align_s(0);
      s_tuser_s(j)  <= m_tuser_align_s(0);
      s_tlast_s(j) <= m_tlast_align_s(0);
      m_tready_align_s(0) <= s_tready_s(j);

      s_tdata_s(slave_portnum+j)  <= m_tdata_align_s(1);
      s_tstrb_s(slave_portnum+j)  <= m_tstrb_align_s(1);
      s_tvalid_s(slave_portnum+j) <= m_tvalid_align_s(1);
      s_tdest_s(slave_portnum+j)  <= m_tdest_align_s(1);
      s_tuser_s(slave_portnum+j)  <= m_tuser_align_s(1);
      s_tlast_s(slave_portnum+j)  <= m_tlast_align_s(1);
      m_tready_align_s(1) <= s_tready_s(slave_portnum+j);

    end block align_namespace;
  end generate;

  for j in 2*slave_portnum to 3*slave_portnum-1 generate
    s_tdata_s(j,S_AXI_ARADDR'range(1))  <= S_AXI_ARADDR(j);
    s_tvalid_s(j)    <= S_AXI_ARVALID(j);
    s_tstrb_s(j)     <= (others=>'1')
    s_tdest_s(j)     <= slave_decode(S_AXI_ARADDR(j));
    s_tuser_s(j)     <= S_AXI_ARID(j,) & S_AXI_ARPROT(j) & to_std_logic_vector(j,); --master_id
    s_tlast_s(j)     <= '1';
    S_AXI_ARREADY(j) <= s_tready_s(j);
  end generate;

  for j in 3*slave_portnum to 3*slave_portnum+master_portnum-1 generate
    s_tdata_s(j,M_AXI_BRESP'range(1))  <= M_AXI_BRESP(j);
    s_tvalid_s(j)   <= M_AXI_BVALID(j);
    s_tstrb_s(j)    <= (others=>'1')
    s_tdest_s(j)    <= master_decode();
    s_tuser_s(j)    <= M_AXI_BID; --master_id
    s_tlast_s(j)    <= '1';
    M_AXI_BREADY(j) <= s_tready_s(j);
  end generate;

  for j in 3*slave_portnum+master_portnum to 3*slave_portnum+2*master_portnum-1 generate
    s_tdata_s(j,M_AXI_RDATA'range(1))  <= M_AXI_RDATA(j);
    s_tvalid_s(j)   <= M_AXI_RVALID(j);
    s_tstrb_s(j)    <= (others=>'1')
    s_tdest_s(j)    <= master_decode();
    s_tuser_s(j)    <= M_AXI_RID & M_AXI_RRESP(j);
    s_tlast_s(j)    <= M_AXI_RLAST(j);
    M_AXI_RREADY(j) <= s_tready_s(j);
  end generate;

--------------------------------------------------------------------------------
--AXIS INTERCON SLAVE
--------------------------------------------------------------------------------
--Save pending operations on write channel, because one slave can accept several
  bresp_fifo_gen : for j in master_portnum-1 downto 0 generate
  begin
    bresp_u : srfifo1ck
      generic map(
        fifo_size => 16,
        port_size => s_wdest_a(j)'length
      );
      port map(
        --general
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => s_awnus_a(j),
        datab_o       => s_bdest_a(j),
        ena_i         => m_awvalid_a(j) and m_awready_a(j),
        enb_i         => m_bready_a(j)  and m_bvalid_a(j),
        --
        fifo_status_o => open
      );
  end generate;

  rdata_fifo_gen : for j in master_portnum-1 downto 0 generate
  begin
    s_ardest_a(j) <= slave_decode(s_araddr_a(j));

    rdata_u : srfifo1ck
      generic map(
        fifo_size => 16,
        port_size => s_wdest_a(j)
      );
      port map(
        --general
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => s_arnus_a(j),
        datab_o       => s_rdest_a(j),
        ena_i         => s_awready_a(j) and s_arready_a(j),
        enb_i         => s_rready_a(j)  and  s_rready_a(j) and s_rlast_a(j)
        --
        fifo_status_o => open
      );
    end generate;

--------------------------------------------------------------------------------
--AXIS INTERCON MASTER
--------------------------------------------------------------------------------
maddr_gen : for j in 0 to master_portnum-1 generate
  M_AXI_AWID(j)    <= get_id(m_tuser_s(j));
  M_AXI_AWVALID(j) <= m_tvalid_s(j);
  m_tready_s(j)    <= M_AXI_AWREADY(j);
  M_AXI_AWADDR(j)  <= m_tdata_s(j,M_AXI_AWADDR'range(1));
  M_AXI_AWPROT(j)  <= get_prot(m_tuser_s(j));
end generate;

mdat_gen : for j in master_portnum to 2*master_portnum-1 generate
  M_AXI_WVALID <= M_AXI_WVALID(j);
  m_wready_a   <= M_AXI_WREADY;
  M_AXI_WDATA  <= m_wdata_a;
  M_AXI_WSTRB  <= m_wstrb_a;
  M_AXI_WLAST  <= m_wlast_a;
end generate;

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
    max_tx_size    => 4096/DATA_BYTE_NUM
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
