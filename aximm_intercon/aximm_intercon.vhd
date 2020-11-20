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
  use work.aximm_intercon_pkg.all;

entity aximm_intercon is
    generic (
      master_portnum : positive := 8;
      slave_portnum  : positive := 8;
      DATA_BYTE_NUM  : positive := 8;
      ADDR_SIZE      : positive := 8;
      ID_WIDTH       : positive := 8
    );
    port (
      --general
      rst_i         : in  std_logic;
      clk_i         : in  std_logic;
      addr_map_i    : in  std_logic_array(slave_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
      --------------------------------------------------------------------------

      --AXIS Master Port
      --------------------------------------------------------------------------
      M_AXI_AWID    : out std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_AWVALID : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_AWREADY : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_AWADDR  : out std_logic_array (master_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_AWPROT  : out std_logic_array (master_portnum-1 downto 0)(2 downto 0);
      --write data channel
      M_AXI_WVALID  : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_WREADY  : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_WDATA   : out std_logic_array (master_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_WSTRB   : out std_logic_array (master_portnum-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
      M_AXI_WLAST   : out std_logic_vector(master_portnum-1 downto 0);
      --Write Response channel
      M_AXI_BVALID  : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_BREADY  : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_BRESP   : in  std_logic_array (master_portnum-1 downto 0)(1 downto 0);
      M_AXI_BID     : in  std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      -- Read Address channel
      M_AXI_ARVALID : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_ARREADY : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_ARADDR  : out std_logic_array (master_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_ARPROT  : out std_logic_array (master_portnum-1 downto 0)(2 downto 0);
      M_AXI_ARID    : out std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      --Read data channel
      M_AXI_RVALID  : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_RREADY  : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_RDATA   : in  std_logic_array (master_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_RRESP   : in  std_logic_array (master_portnum-1 downto 0)(1 downto 0);
      M_AXI_RID     : in  std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_RLAST   : in  std_logic_vector(master_portnum-1 downto 0);
      --------------------------------------------------------------------------
      --AXIS Slave Port
      --------------------------------------------------------------------------
      S_AXI_AWID    : in  std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_AWVALID : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_AWREADY : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_AWADDR  : in  std_logic_array (slave_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_array (slave_portnum-1 downto 0)(2 downto 0);
      --write data channel
      S_AXI_WVALID  : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_WREADY  : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_WDATA   : in  std_logic_array (slave_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_array (slave_portnum-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
      S_AXI_WLAST   : in  std_logic_vector(slave_portnum-1 downto 0);
      --Write Response channel
      S_AXI_BVALID  : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_BREADY  : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_BRESP   : out std_logic_array (slave_portnum-1 downto 0)(1 downto 0);
      S_AXI_BID     : out std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      -- Read Address channel
      S_AXI_ARVALID : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_ARREADY : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_ARADDR  : in  std_logic_array (slave_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_array (slave_portnum-1 downto 0)(2 downto 0);
      S_AXI_ARID    : in  std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      --Read data channel
      S_AXI_RVALID  : out std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_RREADY  : in  std_logic_vector(slave_portnum-1 downto 0);
      S_AXI_RDATA   : out std_logic_array (slave_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_RRESP   : out std_logic_array (slave_portnum-1 downto 0)(1 downto 0);
      S_AXI_RID     : out std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_RLAST   : out std_logic_vector(slave_portnum-1 downto 0)
    );
end aximm_intercon;

architecture behavioral of aximm_intercon is

  constant tot_axis_peripheral : positive := 2*master_portnum+3*slave_portnum;
  constant tot_axis_controller : positive := 3*master_portnum+2*slave_portnum;

  constant tdata_size : positive := maximum(ADDR_SIZE,8*DATA_BYTE_NUM);
  constant tstrb_size : positive := ( tdata_size/8 + (tdata_size mod 8) );
  constant tdest_size : positive := maximum(size_of(slave_portnum),size_of(master_portnum));
  constant tuser_size : positive := size_of(master_portnum)+size_of(slave_portnum)+ID_WIDTH;

  signal m_tdata_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tdata_size-1 downto 0);
  signal m_tstrb_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tstrb_size-1 downto 0);
  signal m_tuser_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tuser_size-1 downto 0);
  signal m_tdest_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tdest_size-1 downto 0);
  signal m_tready_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal m_tvalid_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal m_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0);

  signal s_tdata_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tdata_size-1 downto 0);
  signal s_tstrb_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tstrb_size-1 downto 0);
  signal s_tuser_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tuser_size-1 downto 0);
  signal s_tdest_s  : std_logic_array (tot_axis_peripheral-1 downto 0)(tdest_size-1 downto 0);
  signal s_tready_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal s_tvalid_s : std_logic_vector(tot_axis_peripheral-1 downto 0);
  signal s_tlast_s  : std_logic_vector(tot_axis_peripheral-1 downto 0);

  signal s_tdata_align_s  : std_logic_array (slave_portnum-1 downto 0)(tdata_size-1 downto 0);
  signal s_tstrb_align_s  : std_logic_array (slave_portnum-1 downto 0)(tstrb_size-1 downto 0);
  signal s_tuser_align_s  : std_logic_array (slave_portnum-1 downto 0)(tuser_size-1 downto 0);
  signal s_tdest_align_s  : std_logic_array (slave_portnum-1 downto 0)(tdest_size-1 downto 0);
  signal s_tready_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal s_tvalid_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal s_tlast_align_s  : std_logic_vector(slave_portnum-1 downto 0);

  signal m_tdata_align_s  : std_logic_array (slave_portnum-1 downto 0)(tdata_size-1 downto 0);
  signal m_tstrb_align_s  : std_logic_array (slave_portnum-1 downto 0)(tstrb_size-1 downto 0);
  signal m_tuser_align_s  : std_logic_array (slave_portnum-1 downto 0)(tuser_size-1 downto 0);
  signal m_tdest_align_s  : std_logic_array (slave_portnum-1 downto 0)(tdest_size-1 downto 0);
  signal m_tready_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal m_tvalid_align_s : std_logic_vector(slave_portnum-1 downto 0);
  signal m_tlast_align_s  : std_logic_vector(slave_portnum-1 downto 0);

  constant s_awaddr_base  : integer := 0*slave_portnum;
  constant s_wdata_base   : integer := 1*slave_portnum;
  constant s_araddr_base  : integer := 2*slave_portnum;
  constant s_rdata_base   : integer := 0*slave_portnum;
  constant s_bresp_base   : integer := 1*slave_portnum;

  constant m_awaddr_base  : integer := 2*slave_portnum;
  constant m_wdata_base   : integer := 2*slave_portnum + 1*master_portnum;
  constant m_araddr_base  : integer := 2*slave_portnum + 2*master_portnum;
  constant m_rdata_base   : integer := 3*slave_portnum;
  constant m_bresp_base   : integer := 3*slave_portnum + 1*master_portnum;

  constant s_wrange_r : range_t := (
    high => 2*slave_portnum-1,
    low  => slave_portnum
  );

  constant id_r        : range_t := (high => ID_WIDTH-1, low => 0);
  constant prot_r      : range_t := (high => ID_WIDTH+2, low => ID_WIDTH);
  constant master_no_r : range_t := (high => tdest_size+ID_WIDTH+2, low => ID_WIDTH+3);
  constant rresp_r     : range_t := (high => tdest_size+ID_WIDTH+4, low => tdest_size+ID_WIDTH+3);

begin
--------------------------------------------------------------------------------
--WDATA / AWADDR ALIGNMENT
--------------------------------------------------------------------------------
  slave_gen : for j in slave_portnum-1 downto 0 generate

    --write address channel from master to be aligned
    s_tdata_align_s(j)(S_AXI_AWADDR(j)'range) <= S_AXI_AWADDR(j);
    s_tvalid_align_s(j) <= S_AXI_AWVALID(j);
    s_tstrb_align_s(j)  <= (others=>'1');
    s_tdest_align_s(j)  <= to_std_logic_vector(address_decode(S_AXI_AWADDR(j),addr_map_i),tdest_size);
    s_tuser_align_s(j)(       id_r.high downto        id_r.low) <= S_AXI_AWID(j);
    s_tuser_align_s(j)(     prot_r.high downto      prot_r.low) <= S_AXI_AWPROT(j);
    s_tuser_align_s(j)(master_no_r.high downto master_no_r.low) <= to_std_logic_vector(j,tdest_size);
    s_tlast_align_s(j)  <= '1';
    S_AXI_AWREADY(j)    <= s_tready_align_s(j);

    --write data channel from master to be aligned
    s_tdata_align_s(j+s_wdata_base)(S_AXI_WDATA(j)'range) <= S_AXI_WDATA(j);
    s_tvalid_align_s(j+s_wdata_base) <= S_AXI_WVALID(j);
    s_tstrb_align_s(j+s_wdata_base)  <= S_AXI_WSTRB(j);
    s_tdest_align_s(j+s_wdata_base)  <= to_std_logic_vector(address_decode(S_AXI_AWADDR(j),addr_map_i),tdest_size);
    s_tuser_align_s(j+s_wdata_base)  <= (others=>'1');
    s_tlast_align_s(j+s_wdata_base)  <= S_AXI_WLAST(j);
    S_AXI_AWREADY(j) <= s_tready_align_s(j+s_wdata_base);

    align_u : axis_aligner
      generic map(
        number_ports => 2*slave_portnum,
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

      --write address from master aligned with data
      s_tdata_s(j)  <= m_tdata_align_s(j);
      s_tstrb_s(j)  <= m_tstrb_align_s(j);
      s_tvalid_s(j) <= m_tvalid_align_s(j);
      s_tdest_s(j)  <= m_tdest_align_s(j);
      s_tuser_s(j)  <= m_tuser_align_s(j);
      s_tlast_s(j)  <= m_tlast_align_s(j);
      m_tready_align_s(j) <= s_tready_s(j);

      --write data from master aligned with address
      s_tdata_s(j+s_wdata_base)  <= m_tdata_align_s (j+s_wdata_base);
      s_tstrb_s(j+s_wdata_base)  <= m_tstrb_align_s (j+s_wdata_base);
      s_tvalid_s(j+s_wdata_base) <= m_tvalid_align_s(j+s_wdata_base);
      s_tdest_s(j+s_wdata_base)  <= m_tdest_align_s (j+s_wdata_base);
      s_tuser_s(j+s_wdata_base)  <= m_tuser_align_s (j+s_wdata_base);
      s_tlast_s(j+s_wdata_base)  <= m_tlast_align_s (j+s_wdata_base);
      m_tready_align_s(j+s_wdata_base) <= s_tready_s(j+s_wdata_base);

      --rrite Response channel from slave to master
      S_AXI_BRESP(j)  <= m_tdata_s(j+s_bresp_base);
      S_AXI_BVALID(j) <= m_tvalid_s(j+s_bresp_base);
      S_AXI_BID(j)    <= m_tuser_s(j+s_bresp_base)(id_r.high downto id_r.low);
      m_tready_s((j+s_bresp_base)) <= S_AXI_BREADY(j) ;

      --read address from master to slave
      s_tdata_s(j+s_araddr_base)(S_AXI_ARADDR(j)'range) <= S_AXI_ARADDR(j);
      s_tvalid_s(j+s_araddr_base) <= S_AXI_ARVALID(j);
      s_tstrb_s(j+s_araddr_base)  <= (others=>'1');
      s_tdest_s(j+s_araddr_base)  <= to_std_logic_vector(address_decode(S_AXI_ARADDR(j),addr_map_i),tdest_size);
      s_tuser_s(j+s_araddr_base)(       id_r.high downto        id_r.low) <= S_AXI_ARID(j);
      s_tuser_s(j+s_araddr_base)(     prot_r.high downto      prot_r.low) <= S_AXI_ARPROT(j);
      s_tuser_s(j+s_araddr_base)(master_no_r.high downto master_no_r.low) <= to_std_logic_vector(j,tdest_size);

      s_tlast_s(j+s_araddr_base)  <= '1';
      S_AXI_ARREADY(j) <= s_tready_s(j+s_araddr_base);

      --read data channel from slave to master
      S_AXI_RDATA(j)  <= m_tdata_s(j+s_bresp_base);
      S_AXI_RVALID(j) <= m_tvalid_s(j+s_bresp_base);
      S_AXI_RRESP(j)  <= m_tuser_s(j+s_bresp_base)(rresp_r.high downto rresp_r.low);
      S_AXI_RID(j)    <= m_tuser_s(j+s_bresp_base)(id_r.high downto id_r.low);
      S_AXI_RLAST(j)  <= m_tlast_s(j+s_bresp_base);
      m_tready_s(j+s_bresp_base) <= S_AXI_RREADY(j);

  end generate;

  master_gen : for j in 0 to master_portnum-1 generate

    bresp_u : srfifo1ck
      generic map(
        fifo_size => 16,
        port_size => tdest_size
      )
      port map(
        --general
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => m_tuser_s(j+m_awaddr_base)(master_no_r.high downto master_no_r.low),
        ena_i         => m_tvalid_s(j+m_awaddr_base) and m_tready_s(j+m_awaddr_base),
        datab_o       => s_tdest_s(j+m_bresp_base),
        enb_i         => s_tvalid_s(j+m_bresp_base)  and s_tready_s(j+m_bresp_base),
        --
        fifo_status_o => open
      );


      --write address channel master to slave
      M_AXI_AWADDR(j)  <= m_tdata_s(j+m_awaddr_base)(M_AXI_AWADDR(j)'range);
      M_AXI_AWVALID(j) <= m_tvalid_s(j+m_awaddr_base);
      M_AXI_AWID(j)    <= m_tuser_s(j+m_awaddr_base)(id_r.high downto id_r.low);
      M_AXI_AWPROT(j)  <= m_tuser_s(j+m_awaddr_base)(prot_r.high downto prot_r.low);
      m_tready_s(j+m_awaddr_base) <= M_AXI_AWREADY(j);

      --write data channel master to slave
      M_AXI_WDATA(j)  <= m_tdata_s(j+m_wdata_base);
      M_AXI_WVALID(j) <= m_tvalid_s(j+m_wdata_base);
      M_AXI_WSTRB(j)  <= m_tstrb_s(j+m_wdata_base);
      M_AXI_WLAST(j)  <= m_tlast_s(j+m_wdata_base);
      m_tready_s(j+m_wdata_base) <= M_AXI_WREADY(j);

      --WRITE RESPONSE SLAVE TO MASTER
      s_tdata_s(j+m_bresp_base)(M_AXI_BRESP(j)'range) <= M_AXI_BRESP(j);
      s_tvalid_s(j+m_bresp_base) <= M_AXI_BVALID(j);
      s_tstrb_s(j+m_bresp_base)  <= (others=>'1');
      --s_tdest_s(j+m_bresp_base)  <= --from fifo
      s_tuser_s(j+m_bresp_base)(id_r.high downto id_r.low) <= M_AXI_BID(j);
      s_tlast_s(j+m_bresp_base)  <= '1';
      M_AXI_BREADY(j) <= s_tready_s(j+m_bresp_base);

      --READ ADDRESS MMASTER TO SLAVE
      M_AXI_ARADDR(j) <= m_tdata_s(j+m_araddr_base)(M_AXI_ARADDR(j)'range);
      M_AXI_ARVALID(j)  <= m_tvalid_s(j+m_araddr_base);
      M_AXI_ARPROT(j)  <= m_tuser_s(j+m_araddr_base)(prot_r.high downto prot_r.low);
      M_AXI_ARID(j)    <= m_tuser_s(j+m_araddr_base)(id_r.high downto id_r.low);
      m_tready_s(j+m_araddr_base) <= M_AXI_ARREADY(j);

      --READ CHANNEL SLAVE TO MASTER
      s_tdata_s(j+m_rdata_base)(M_AXI_RDATA(j)'range) <= M_AXI_RDATA(j);
      s_tvalid_s(j+m_rdata_base) <= M_AXI_RVALID(j);
      s_tstrb_s(j+m_rdata_base)  <= (others=>'1');
      --s_tdest_s(j+m_rdata_base)  <= from fifo;
      s_tuser_s(j+m_rdata_base)(   id_r.high downto    id_r.low)  <= M_AXI_RID(j);
      s_tuser_s(j+m_rdata_base)(rresp_r.high downto rresp_r.low)  <= M_AXI_RRESP(j);
      s_tlast_s(j+m_rdata_base)  <= M_AXI_RLAST(j);
      M_AXI_RREADY(j) <= s_tready_s(j+m_rdata_base);

      rdata_u : srfifo1ck
        generic map(
          fifo_size => 16,
          port_size => tdest_size
        )
        port map(
          --general
          clk_i         => clk_i,
          rst_i         => rst_i,
          dataa_i       => m_tuser_s(j+m_araddr_base)(master_no_r.high downto master_no_r.low),
          ena_i         => m_tvalid_s(j+m_araddr_base) and m_tready_s(j+m_araddr_base),
          datab_o       => s_tdest_s(j+m_rdata_base),
          enb_i         => s_tvalid_s(j+m_rdata_base)  and s_tready_s(j+m_rdata_base) and s_tlast_s(j+m_rdata_base),
          --
          fifo_status_o => open
        );

  end generate;

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
