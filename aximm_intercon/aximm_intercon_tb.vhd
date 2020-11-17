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

entity aximm_intercon_tb is
end aximm_intercon_tb;

architecture behavioral of aximm_intercon_tb is

  constant master_portnum : positive := 5;
  constant slave_portnum  : positive := 8;
  constant DATA_BYTE_NUM  : positive := 8;
  constant ID_WIDTH       : positive := 8;
  constant ADDR_SIZE      : positive := 8;

  --general
  signal rst_i         : std_logic := '0';
  signal clk_i         : std_logic := '0';
  --------------------------------------------------------------------------
  --AXIS Master Port
  --------------------------------------------------------------------------
  signal M_AXI_AWID    : std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  signal M_AXI_AWVALID : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_AWREADY : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_AWADDR  : std_logic_array (master_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal M_AXI_AWPROT  : std_logic_array (master_portnum-1 downto 0)(2 downto 0);
  --write data channel
  signal M_AXI_WVALID  : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_WREADY  : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_WDATA   : std_logic_array (master_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal M_AXI_WSTRB   : std_logic_array (master_portnum-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
  signal M_AXI_WLAST   : std_logic_vector(master_portnum-1 downto 0);
  --Write Response channel
  signal M_AXI_BVALID  : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_BREADY  : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_BRESP   : std_logic_array (master_portnum-1 downto 0)(1 downto 0);
  signal M_AXI_BID     : std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  -- Read Address channel
  signal M_AXI_ARVALID : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_ARREADY : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_ARADDR  : std_logic_array (master_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal M_AXI_ARPROT  : std_logic_array (master_portnum-1 downto 0)(2 downto 0);
  signal M_AXI_ARID    : std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  --Read data channel
  signal M_AXI_RVALID  : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_RREADY  : std_logic_vector(master_portnum-1 downto 0);
  signal M_AXI_RDATA   : std_logic_array (master_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal M_AXI_RRESP   : std_logic_array (master_portnum-1 downto 0)(1 downto 0);
  signal M_AXI_RID     : std_logic_array (master_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  signal M_AXI_RLAST   : std_logic_vector(master_portnum-1 downto 0);
  --------------------------------------------------------------------------
  --AXIS Slave Port
  --------------------------------------------------------------------------
  signal S_AXI_AWID    : std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  signal S_AXI_AWVALID : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_AWREADY : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_AWADDR  : std_logic_array (slave_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal S_AXI_AWPROT  : std_logic_array (slave_portnum-1 downto 0)(2 downto 0);
  --write data channel
  signal S_AXI_WVALID  : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_WREADY  : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_WDATA   : std_logic_array (slave_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_WSTRB   : std_logic_array (slave_portnum-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_WLAST   : std_logic_vector(slave_portnum-1 downto 0);
  --Write Response channel
  signal S_AXI_BVALID  : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_BREADY  : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_BRESP   : std_logic_array (slave_portnum-1 downto 0)(1 downto 0);
  signal S_AXI_BID     : std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  -- Read Address channel
  signal S_AXI_ARVALID : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_ARREADY : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_ARADDR  : std_logic_array (slave_portnum-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal S_AXI_ARPROT  : std_logic_array (slave_portnum-1 downto 0)(2 downto 0);
  signal S_AXI_ARID    : std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  --Read data channel
  signal S_AXI_RVALID  : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_RREADY  : std_logic_vector(slave_portnum-1 downto 0);
  signal S_AXI_RDATA   : std_logic_array (slave_portnum-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_RRESP   : std_logic_array (slave_portnum-1 downto 0)(1 downto 0);
  signal S_AXI_RID     : std_logic_array (slave_portnum-1 downto 0)(ID_WIDTH-1 downto 0);
  signal S_AXI_RLAST   : std_logic_vector(slave_portnum-1 downto 0);

  signal addr_map_s : std_logic_array(master_portnum-1 downto 0)(ADDR_SIZE-1 downto 0) := (others=>(others=>'X'));
  signal addr_map_c : std_logic_array(master_portnum-1 downto 0)(ADDR_SIZE-1 downto 0) := (
    ("0000----"),
    ("0001----"),
    ("0010----"),
    ("01------"),
    ("1-------")
  );

begin

clk_i <= not clk_i after 10 ns;
rst_i <= '1',  '0' after 10 ns;


--There are several ways to configure the peripheral address map. It can be made
-- on signal declaration (see addr_map_c above) or using the set_peripheral_api.
config_process : process(all)
begin
  set_peripheral_address(0,"0000----",addr_map_s);
  set_peripheral_address(1,"0001----",addr_map_s);
  set_peripheral_address(2,"0010----",addr_map_s);
  set_peripheral_address(3,"01------",addr_map_s);
  set_peripheral_address(4,"1-------",addr_map_s);
end process;

aximm_intercon_i : aximm_intercon
  generic map (
    master_portnum => master_portnum,
    slave_portnum  => slave_portnum,
    DATA_BYTE_NUM  => DATA_BYTE_NUM,
    ADDR_SIZE      => ADDR_SIZE,
    ID_WIDTH       => ID_WIDTH
  )
  port map (
    rst_i         => rst_i,
    clk_i         => clk_i,
    addr_map_i    => addr_map_s,

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
    M_AXI_RLAST   => M_AXI_RLAST,
    S_AXI_AWID    => S_AXI_AWID,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_AWADDR  => S_AXI_AWADDR,
    S_AXI_AWPROT  => S_AXI_AWPROT,
    S_AXI_WVALID  => S_AXI_WVALID,
    S_AXI_WREADY  => S_AXI_WREADY,
    S_AXI_WDATA   => S_AXI_WDATA,
    S_AXI_WSTRB   => S_AXI_WSTRB,
    S_AXI_WLAST   => S_AXI_WLAST,
    S_AXI_BVALID  => S_AXI_BVALID,
    S_AXI_BREADY  => S_AXI_BREADY,
    S_AXI_BRESP   => S_AXI_BRESP,
    S_AXI_BID     => S_AXI_BID,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_ARADDR  => S_AXI_ARADDR,
    S_AXI_ARPROT  => S_AXI_ARPROT,
    S_AXI_ARID    => S_AXI_ARID,
    S_AXI_RVALID  => S_AXI_RVALID,
    S_AXI_RREADY  => S_AXI_RREADY,
    S_AXI_RDATA   => S_AXI_RDATA,
    S_AXI_RRESP   => S_AXI_RRESP,
    S_AXI_RID     => S_AXI_RID,
    S_AXI_RLAST   => S_AXI_RLAST
  );

end behavioral;
