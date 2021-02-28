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
  use ieee.math_real.all;
library expert;
	use expert.std_logic_expert.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;

  use work.aximm_intercon_pkg.all;

entity aximm_intercon is
    generic (
      controllers_num : positive := 8;
      peripherals_num : positive := 8;
      DATA_BYTE_NUM   : positive := 8;
      ADDR_SIZE       : positive := 8;
      ID_WIDTH        : positive := 8
    );
    port (
      --general
      rst_i         : in  std_logic;
      clk_i         : in  std_logic;
      addr_map_i    : in  std_logic_array(controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      --------------------------------------------------------------------------
      --AXIS Master Port
      --------------------------------------------------------------------------
      M_AXI_AWID    : out std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_AWVALID : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_AWREADY : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_AWADDR  : out std_logic_array (controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_AWPROT  : out std_logic_array (controllers_num-1 downto 0)(2 downto 0);
      --write data channel
      M_AXI_WVALID  : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_WREADY  : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_WDATA   : out std_logic_array (controllers_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_WSTRB   : out std_logic_array (controllers_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
      M_AXI_WLAST   : out std_logic_vector(controllers_num-1 downto 0);
      --Write Response channel
      M_AXI_BVALID  : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_BREADY  : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_BRESP   : in  std_logic_array (controllers_num-1 downto 0)(1 downto 0);
      M_AXI_BID     : in  std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      -- Read Address channel
      M_AXI_ARVALID : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_ARREADY : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_ARADDR  : out std_logic_array (controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_ARPROT  : out std_logic_array (controllers_num-1 downto 0)(2 downto 0);
      M_AXI_ARID    : out std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      --Read data channel
      M_AXI_RVALID  : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_RREADY  : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_RDATA   : in  std_logic_array (controllers_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_RRESP   : in  std_logic_array (controllers_num-1 downto 0)(1 downto 0);
      M_AXI_RID     : in  std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_RLAST   : in  std_logic_vector(controllers_num-1 downto 0);
      --------------------------------------------------------------------------
      --AXIS Slave Port
      --------------------------------------------------------------------------
      S_AXI_AWID    : in  std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_AWVALID : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_AWREADY : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_AWADDR  : in  std_logic_array (peripherals_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_array (peripherals_num-1 downto 0)(2 downto 0);
      --write data channel
      S_AXI_WVALID  : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_WREADY  : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_WDATA   : in  std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_array (peripherals_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
      S_AXI_WLAST   : in  std_logic_vector(peripherals_num-1 downto 0);
      --Write Response channel
      S_AXI_BVALID  : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_BREADY  : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_BRESP   : out std_logic_array (peripherals_num-1 downto 0)(1 downto 0);
      S_AXI_BID     : out std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      -- Read Address channel
      S_AXI_ARVALID : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_ARREADY : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_ARADDR  : in  std_logic_array (peripherals_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_array (peripherals_num-1 downto 0)(2 downto 0);
      S_AXI_ARID    : in  std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      --Read data channel
      S_AXI_RVALID  : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_RREADY  : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_RDATA   : out std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_RRESP   : out std_logic_array (peripherals_num-1 downto 0)(1 downto 0);
      S_AXI_RID     : out std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_RLAST   : out std_logic_vector(peripherals_num-1 downto 0)
    );
end aximm_intercon;

architecture behavioral of aximm_intercon is

  function ceil_8 ( input : integer) return integer is
  begin
    return integer(ceil(real(input)/8.000));
  end ceil_8;

  constant tdata_size : positive := maximum(ceil_8(ADDR_SIZE),DATA_BYTE_NUM);

  constant tdest_size : positive := maximum(size_of(peripherals_num-1),size_of(controllers_num-1));
  constant tuser_size : positive := tdest_size+ID_WIDTH+5;--must add: prot = 3, rresp = 2

  constant id_r        : range_t := (high => ID_WIDTH-1, low => 0);
  constant prot_r      : range_t := (high => ID_WIDTH+2, low => ID_WIDTH);
  constant master_no_r : range_t := (high => tdest_size+ID_WIDTH+2, low => ID_WIDTH+3);
  constant rresp_r     : range_t := (high => tdest_size+ID_WIDTH+4, low => tdest_size+ID_WIDTH+3);

  signal awaddr_tdest_o_s : std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal awaddr_tuser_o_s : std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));
  signal wdata_tdest_o_s  : std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal wdata_tuser_o_s  : std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));

  signal awaddr_tdest_i_s : std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal awaddr_tuser_i_s : std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));
  signal wdata_tdest_i_s  : std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal wdata_tuser_i_s  : std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));

  signal bresp_tdest_i_s  : std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));

  signal araddr_tdest_o_s : std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal araddr_tuser_o_s : std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));
  signal araddr_tdest_i_s : std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal araddr_tuser_i_s : std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));

  signal rdata_tdest_i_s  : std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal rdata_tuser_i_s  : std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));
  --signal rdata_tdest_o_s  : std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0) := (others=>(others=>'0'));
  signal rdata_tuser_o_s  : std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0) := (others=>(others=>'0'));

  type intercon_vector_matrix is array (natural range <>) of std_logic_array;

  signal s_tdata_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(8*tdata_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal s_tstrb_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(  tdata_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal s_tuser_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(  tuser_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal s_tdest_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(  tdest_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal s_tready_align_s :        std_logic_array(peripherals_num-1 downto 0)(1 downto 0) := (others=>(others=>'0'));
  signal s_tvalid_align_s :        std_logic_array(peripherals_num-1 downto 0)(1 downto 0) := (others=>(others=>'0'));
  signal s_tlast_align_s  :        std_logic_array(peripherals_num-1 downto 0)(1 downto 0) := (others=>(others=>'0'));

  signal m_tdata_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(8*tdata_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal m_tstrb_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(  tdata_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal m_tuser_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(  tuser_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal m_tdest_align_s  : intercon_vector_matrix(peripherals_num-1 downto 0)(1 downto 0)(  tdest_size-1 downto 0) := (others=>(others=>(others=>'0')));
  signal m_tready_align_s :        std_logic_array(peripherals_num-1 downto 0)(1 downto 0) := (others=>(others=>'0'));
  signal m_tvalid_align_s :        std_logic_array(peripherals_num-1 downto 0)(1 downto 0) := (others=>(others=>'0'));
  signal m_tlast_align_s  :        std_logic_array(peripherals_num-1 downto 0)(1 downto 0) := (others=>(others=>'0'));

  signal S_AXI_AWID_s    : std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
  signal S_AXI_AWVALID_s : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_AWREADY_s : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_AWADDR_s  : std_logic_array (peripherals_num-1 downto 0)(8*tdata_size-1 downto 0);
  signal S_AXI_AWPROT_s  : std_logic_array (peripherals_num-1 downto 0)(2 downto 0);

  signal S_AXI_WVALID_s  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_WREADY_s  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_WDATA_s   : std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_WSTRB_s   : std_logic_array (peripherals_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_WLAST_s   : std_logic_vector(peripherals_num-1 downto 0);

  signal S_AXI_BRESP_s   : std_logic_array (peripherals_num-1 downto 0)(7 downto 0);
  signal S_AXI_ARADDR_s  : std_logic_array (peripherals_num-1 downto 0)(8*tdata_size-1 downto 0);

  signal M_AXI_BRESP_s   : std_logic_array (controllers_num-1 downto 0)(7 downto 0);
  signal M_AXI_AWADDR_s  : std_logic_array (controllers_num-1 downto 0)(8*tdata_size-1 downto 0);
  signal M_AXI_ARADDR_s  : std_logic_array (controllers_num-1 downto 0)(8*tdata_size-1 downto 0);

begin

  assert addr_size > size_of(8*DATA_BYTE_NUM)
    report aximm_intercon'INSTANCE_NAME & " ADDR_SIZE must be at least " & to_string(size_of(DATA_BYTE_NUM)) & "."
    severity failure;

--------------------------------------------------------------------------------
--WDATA / AWADDR ALIGNMENT
--------------------------------------------------------------------------------
  slave_gen : for j in peripherals_num-1 downto 0 generate
    --write address channel from master to be aligned
    s_tdata_align_s(j)(0)(S_AXI_AWADDR(j)'range) <= S_AXI_AWADDR(j);
    s_tvalid_align_s(j)(0) <= S_AXI_AWVALID(j);
    s_tstrb_align_s(j)(0)  <= (others=>'1');
    s_tlast_align_s(j)(0)  <= '1';
    s_tuser_align_s(j)(0)(        id_r.high downto         id_r.low) <= S_AXI_AWID(j);
    s_tuser_align_s(j)(0)(      prot_r.high downto      prot_r.low ) <= S_AXI_AWPROT(j);
    s_tuser_align_s(j)(0)( master_no_r.high downto master_no_r.low ) <= to_std_logic_vector(j,tdest_size);
    S_AXI_AWREADY(j) <= s_tready_align_s(j)(0);

    --write data channel from master to be aligned
    s_tdata_align_s(j)(1)(S_AXI_WDATA(j)'range) <= S_AXI_WDATA(j);
    s_tvalid_align_s(j)(1) <= S_AXI_WVALID(j);
    s_tstrb_align_s(j)(1)  <= S_AXI_WSTRB(j);
    s_tdest_align_s(j)(1)  <= to_std_logic_vector(address_decode(S_AXI_AWADDR(j),addr_map_i),tdest_size);
    s_tlast_align_s(j)(1)  <= S_AXI_WLAST(j);
    S_AXI_WREADY(j) <= s_tready_align_s(j)(1);

    align_u : axis_aligner
      generic map(
        number_ports    => 2,
        tdata_byte      => tdata_size,
        tdest_size      => tdest_size,
        tuser_size      => tuser_size,
        switch_on_tlast => true
      )
      port map(
        clk_i      => clk_i,
        rst_i      => rst_i,
        --AXIS Slave Port
        s_tdata_i  => s_tdata_align_s(j),
        s_tuser_i  => s_tuser_align_s(j),
        s_tdest_i  => (others=>(others=>'0')),
        s_tstrb_i  => s_tstrb_align_s(j),
        s_tready_o => s_tready_align_s(j),
        s_tvalid_i => s_tvalid_align_s(j),
        s_tlast_i  => s_tlast_align_s(j),
        --AXIS Master Port
        m_tdata_o  => m_tdata_align_s(j),
        m_tuser_o  => m_tuser_align_s(j),
        m_tdest_o  => open,
        m_tstrb_o  => m_tstrb_align_s(j),
        m_tready_i => m_tready_align_s(j),
        m_tvalid_o => m_tvalid_align_s(j),
        m_tlast_o  => m_tlast_align_s(j)
      );

    S_AXI_AWID_s(j)    <= m_tuser_align_s(j)(0)(  id_r.high downto   id_r.low);
    S_AXI_AWPROT_s(j)  <= m_tuser_align_s(j)(0)(prot_r.high downto prot_r.low);
    S_AXI_AWVALID_s(j) <= m_tvalid_align_s(j)(0);
    m_tready_align_s(j)(0) <= S_AXI_AWREADY_s(j);
    S_AXI_AWADDR_s(j)  <= m_tdata_align_s(j)(0);
  
    S_AXI_WVALID_s(j) <= m_tvalid_align_s(j)(1);
    m_tready_align_s(j)(1) <= S_AXI_WREADY_s(j);
    S_AXI_WDATA_s(j)  <= m_tdata_align_s(j)(1);
    S_AXI_WSTRB_s(j)  <= m_tstrb_align_s(j)(1);
    S_AXI_WLAST_s(j)  <= m_tlast_align_s(j)(1);

    --read address from master to slave
    araddr_tdest_i_s(j) <= to_std_logic_vector(address_decode(S_AXI_ARADDR(j),addr_map_i),tdest_size);
    araddr_tuser_i_s(j)(        id_r.high downto        id_r.low ) <= S_AXI_ARID(j);
    araddr_tuser_i_s(j)(      prot_r.high downto      prot_r.low ) <= S_AXI_ARPROT(j);
    araddr_tuser_i_s(j)( master_no_r.high downto master_no_r.low ) <= to_std_logic_vector(j,tdest_size);
      
    --read data channel from slave to master
    S_AXI_ARADDR_s(j)(S_AXI_ARADDR(j)'range) <= S_AXI_ARADDR(j);
    S_AXI_RRESP(j) <= rdata_tuser_o_s(j)(rresp_r.high downto rresp_r.low);
    S_AXI_RID(j)   <= rdata_tuser_o_s(j)(id_r.high downto id_r.low);
    S_AXI_BRESP(j)(1 downto 0) <= S_AXI_BRESP_s(j)(1 downto 0);

    --READ CHANNEL SLAVE TO MASTER
    rdata_tuser_i_s(j)(   id_r.high downto    id_r.low)  <= S_AXI_RID(j);
    rdata_tuser_i_s(j)(rresp_r.high downto rresp_r.low)  <= S_AXI_RRESP(j);

      
  end generate;

  master_gen : for j in 0 to controllers_num-1 generate

    bresp_u : srfifo1ck
      generic map(
        fifo_size => 16,
        port_size => tdest_size
      )
      port map(
        --general
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => awaddr_tuser_o_s(j)(master_no_r.high downto master_no_r.low),
        ena_i         => M_AXI_AWREADY(j) and M_AXI_AWVALID(j),
        datab_o       => bresp_tdest_i_s(j),
        enb_i         => M_AXI_BREADY(j) and M_AXI_BVALID(j),
        --
        fifo_status_o => open
      );

    --write address channel master to slave
    M_AXI_AWID(j)    <= awaddr_tuser_o_s(j)(id_r.high downto id_r.low);
    M_AXI_AWPROT(j)  <= awaddr_tuser_o_s(j)(prot_r.high downto prot_r.low);

    rdata_u : srfifo1ck
      generic map(
        fifo_size => 16,
        port_size => tdest_size
      )
      port map(
        --general
        clk_i         => clk_i,
        rst_i         => rst_i,
        dataa_i       => (others=>'0'),--araddr_tuser_o_s(j)(master_no_r.high downto master_no_r.low),
        ena_i         => M_AXI_ARREADY(j) and M_AXI_ARVALID(j),
        datab_o       => rdata_tdest_i_s(j),
        enb_i         => M_AXI_RREADY(j)  and M_AXI_RVALID(j) and M_AXI_RLAST(j),
        --
        fifo_status_o => open
      );

    M_AXI_BRESP_s(j)(1 downto 0) <= M_AXI_BRESP(j);
    M_AXI_AWADDR(j) <= M_AXI_AWADDR_s(j)(ADDR_SIZE-1 downto 0);

    --READ ADDRESS MMASTER TO SLAVE
    M_AXI_ARID(j)    <= araddr_tuser_o_s(j)(id_r.high downto id_r.low);
    M_AXI_ARPROT(j)  <= araddr_tuser_o_s(j)(prot_r.high downto prot_r.low);
    M_AXI_ARADDR(j)  <= M_AXI_ARADDR_s(j)(M_AXI_ARADDR(j)'range);


  end generate;

--------------------------------------------------------------------------------
--STREAMING INTERCON
--------------------------------------------------------------------------------
  awaddr_intercon_u : axis_intercon
    generic map (
      controllers_num => controllers_num,
      peripherals_num => peripherals_num,
      tdata_byte      => ceil_8(ADDR_SIZE),
      tdest_size      => tdest_size,
      tuser_size      => tuser_size,
      select_auto     => true,
      switch_tlast    => true,
      interleaving    => false,
      max_tx_size     => 4096/DATA_BYTE_NUM
    )
    port map (
      rst_i      => rst_i,
      clk_i      => clk_i,
      --controller
      m_tdata_o  => M_AXI_AWADDR_s,
      m_tstrb_o  => open,
      m_tuser_o  => awaddr_tuser_o_s,
      m_tdest_o  => open,
      m_tready_i => M_AXI_AWREADY,
      m_tvalid_o => M_AXI_AWVALID,
      m_tlast_o  => open,
      --peripheral
      s_tdata_i  => S_AXI_AWADDR_s,
      s_tstrb_i  => (others=>(others=>'1')),
      s_tuser_i  => awaddr_tuser_i_s,
      s_tdest_i  => awaddr_tdest_i_s,
      s_tready_o => S_AXI_AWREADY_s,
      s_tvalid_i => S_AXI_AWVALID_s,
      s_tlast_i  => (others=>'1')
    );

  wdata_intercon_u : axis_intercon
    generic map (
      controllers_num => controllers_num,
      peripherals_num => peripherals_num,
      tdata_byte      => DATA_BYTE_NUM,
      tdest_size      => tdest_size,
      tuser_size      => tuser_size,
      select_auto     => true,
      switch_tlast    => true,
      interleaving    => false,
      max_tx_size     => 4096/DATA_BYTE_NUM
    )
    port map (
      rst_i      => rst_i,
      clk_i      => clk_i,
      m_tdata_o  => M_AXI_WDATA,
      m_tstrb_o  => M_AXI_WSTRB,
      m_tuser_o  => wdata_tuser_o_s,
      m_tdest_o  => open,
      m_tready_i => M_AXI_WREADY,
      m_tvalid_o => M_AXI_WVALID,
      m_tlast_o  => M_AXI_WLAST,

      s_tdata_i  => S_AXI_WDATA_s,
      s_tstrb_i  => S_AXI_WSTRB_s,
      s_tuser_i  => wdata_tuser_i_s,
      s_tdest_i  => (others=>(others=>'0')),
      s_tready_o => S_AXI_WREADY_s,
      s_tvalid_i => S_AXI_WVALID_s,
      s_tlast_i  => S_AXI_WLAST_s
    );

  bresp_intercon_u : axis_intercon
    generic map (
      controllers_num => peripherals_num,
      peripherals_num => controllers_num,
      tdata_byte      => 1,
      tdest_size      => tdest_size,
      tuser_size      => ID_WIDTH,
      select_auto     => true,
      switch_tlast    => true,
      interleaving    => false,
      max_tx_size     => 4096/DATA_BYTE_NUM
    )
    port map (
      rst_i      => rst_i,
      clk_i      => clk_i,
      m_tdata_o  => S_AXI_BRESP_s,
      m_tstrb_o  => open,
      m_tuser_o  => S_AXI_BID,
      m_tdest_o  => open,
      m_tready_i => S_AXI_BREADY,
      m_tvalid_o => S_AXI_BVALID,
      m_tlast_o  => open,

      s_tdata_i  => M_AXI_BRESP_s,
      s_tstrb_i  => (others=>(others=>'1')),
      s_tuser_i  => M_AXI_BID,
      s_tdest_i  => bresp_tdest_i_s,
      s_tready_o => M_AXI_BREADY,
      s_tvalid_i => M_AXI_BVALID,
      s_tlast_i  => (others=>'1')
    );

  araddr_intercon_u : axis_intercon
    generic map (
      controllers_num => controllers_num,
      peripherals_num => peripherals_num,
      tdata_byte      => ceil_8(ADDR_SIZE),
      tdest_size      => tdest_size,
      tuser_size      => tuser_size,
      select_auto     => true,
      switch_tlast    => true,
      interleaving    => false,
      max_tx_size     => 4096/DATA_BYTE_NUM
    )
    port map (
      rst_i      => rst_i,
      clk_i      => clk_i,
      m_tdata_o  => M_AXI_ARADDR_s,
      m_tstrb_o  => open,
      m_tuser_o  => araddr_tuser_o_s,
      m_tdest_o  => araddr_tdest_o_s,
      m_tready_i => M_AXI_ARREADY,
      m_tvalid_o => M_AXI_ARVALID,
      m_tlast_o  => open,

      s_tdata_i  => S_AXI_ARADDR_s,
      s_tstrb_i  => (others=>(others=>'1')),
      s_tuser_i  => araddr_tuser_i_s,
      s_tdest_i  => araddr_tdest_i_s,
      s_tready_o => S_AXI_ARREADY,
      s_tvalid_i => S_AXI_ARVALID,
      s_tlast_i  => (others=>'1')
    );

  rdata_intercon_u : axis_intercon
    generic map (
      controllers_num => peripherals_num,
      peripherals_num => controllers_num,
      tdata_byte      => DATA_BYTE_NUM,
      tdest_size      => tdest_size,
      tuser_size      => tuser_size,
      select_auto     => true,
      switch_tlast    => true,
      interleaving    => false,
      max_tx_size     => 4096/DATA_BYTE_NUM
    )
    port map (
      rst_i      => rst_i,
      clk_i      => clk_i,
      m_tdata_o  => S_AXI_RDATA,
      m_tstrb_o  => open,
      m_tuser_o  => rdata_tuser_o_s,
      m_tdest_o  => open,
      m_tready_i => S_AXI_RREADY,
      m_tvalid_o => S_AXI_RVALID,
      m_tlast_o  => S_AXI_RLAST,

      s_tdata_i  => M_AXI_RDATA,
      s_tstrb_i  => (others=>(others=>'1')),
      s_tuser_i  => rdata_tuser_i_s,
      s_tdest_i  => rdata_tdest_i_s,
      s_tready_o => M_AXI_RREADY,
      s_tvalid_i => M_AXI_RVALID,
      s_tlast_i  => M_AXI_RLAST
    );

end behavioral;


