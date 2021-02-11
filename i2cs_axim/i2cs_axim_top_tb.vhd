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
  use stdcores.i2cs_axim_pkg.all;
library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.vc_context;
  context vunit_lib.com_context;

  use stdcores.i2cm_vci_pkg.all;


entity i2cs_axim_top_tb is
  generic (
    runner_cfg : string
  );
end i2cs_axim_top_tb;

architecture simulation of i2cs_axim_top_tb is

  constant slave_addr : std_logic_vector(2 downto 0) := "011";
  constant opcode     : std_logic_vector(3 downto 0) := "1010";

  constant  ID_WIDTH      : integer := 1;
  constant  ID_VALUE      : integer := 0;
  constant ADDR_BYTE_NUM : integer := 2;
  constant DATA_BYTE_NUM : integer := 4;

  signal rst_i  : std_logic;
  signal mclk_i : std_logic := '0';

  signal sda : std_logic;
  signal scl : std_logic;

  signal sda_i_s   : std_logic;
  signal sda_o_s   : std_logic;
  signal sda_oen_s : std_logic;
  signal scl_s     : std_logic;

  signal M_AXI_AWID    : std_logic_vector(ID_WIDTH - 1 downto 0);
  signal M_AXI_AWVALID : std_logic;
  signal M_AXI_AWREADY : std_logic;
  signal M_AXI_AWADDR  : std_logic_vector(8 * ADDR_BYTE_NUM - 1 downto 0);
  signal M_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal M_AXI_WVALID  : std_logic;
  signal M_AXI_WREADY  : std_logic;
  signal M_AXI_WDATA   : std_logic_vector(8 * DATA_BYTE_NUM - 1 downto 0);
  signal M_AXI_WSTRB   : std_logic_vector(DATA_BYTE_NUM - 1 downto 0);
  signal M_AXI_WLAST   : std_logic;
  signal M_AXI_BVALID  : std_logic;
  signal M_AXI_BREADY  : std_logic;
  signal M_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal M_AXI_BID     : std_logic_vector(ID_WIDTH - 1 downto 0);
  signal M_AXI_ARVALID : std_logic;
  signal M_AXI_ARREADY : std_logic;
  signal M_AXI_ARADDR  : std_logic_vector(8 * ADDR_BYTE_NUM - 1 downto 0);
  signal M_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal M_AXI_ARID    : std_logic_vector(ID_WIDTH - 1 downto 0);
  signal M_AXI_RVALID  : std_logic;
  signal M_AXI_RREADY  : std_logic;
  signal M_AXI_RDATA   : std_logic_vector(8 * DATA_BYTE_NUM - 1 downto 0);
  signal M_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal M_AXI_RID     : std_logic_vector(ID_WIDTH - 1 downto 0);
  signal M_AXI_RLAST   : std_logic;

  constant frequency_mhz   : real := 10.0000;
  constant i2c_period      : time := (1.000 / frequency_mhz) * 1 us;

  shared variable i2c_controller : i2c_master_t;

  constant i2c_message_write_c : i2c_message_vector(3 downto 0) := (
    x"AA",
    x"12",
    x"AA",
    x"23"
  );

  constant memory : memory_t := new_memory;

  constant axi_rd_slave : axi_slave_t := new_axi_slave(memory => memory,
  logger => get_logger("axi_rd_slave"));

  constant axi_wr_slave : axi_slave_t := new_axi_slave(memory => memory,
    logger => get_logger("axi_wr_slave"));

begin

  --clock e reset
  mclk_i <= not mclk_i after 10 ns;

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    rst_i     <= '1';
    wait until rising_edge(mclk_i);
    wait until rising_edge(mclk_i);
    rst_i <= '0';

    while test_suite loop
      if run("Sanity check for system.") then
        report "System Sane. Begin tests.";
        check_passed("Sanity check for system.");
      
      elsif run("Basic Write Test") then
        i2c_controller.set_opcode(opcode);
        i2c_controller.set_slave_address(slave_addr);  
        i2c_controller.ram_write(net,x"0000",i2c_message_write_c);
        wait_i2c : loop
          exit when i2c_controller.status = ready;
          wait for 10 ns;
        end loop;
        wait for 1 us;
        check_passed("Basic Write Ok.");
          
      end if;
    end loop;
    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  test_runner_watchdog(runner, 100 us);

  --VCI
  i2c_master_p: process
  begin
    i2c_controller.run(net,sda,scl);   
  end process i2c_master_p;

  aximm_slave_u: entity vunit_lib.axi_write_slave
    generic map (
      axi_slave => axi_wr_slave
    )
    port map (
      aclk    => mclk_i,
      awvalid => M_AXI_AWVALID,
      awready => M_AXI_AWREADY,
      awid    => M_AXI_AWID,
      awaddr  => M_AXI_AWADDR,
      awlen   => "00000000",
      awsize  => "000",
      awburst => "00",

      wvalid  => M_AXI_WVALID,
      wready  => M_AXI_WREADY,
      wdata   => M_AXI_WDATA,
      wstrb   => M_AXI_WSTRB,
      wlast   => M_AXI_WLAST,

      bvalid  => M_AXI_BVALID,
      bready  => M_AXI_BREADY,
      bid     => M_AXI_BID,
      bresp   => M_AXI_BRESP
    );

  --Connection between VCI and DUT.
  --Note that tristate function can be used for device connection to external IO.
  tri_state(sda_i_s,sda_o_s,sda,sda_oen_s);
  sda   <= 'H';
  scl   <= 'H';

  --DUT
  i2cs_axim_top_u : i2cs_axim_top
    generic map(
      ID_WIDTH      => ID_WIDTH,
      ID_VALUE      => ID_VALUE,
      ADDR_BYTE_NUM => ADDR_BYTE_NUM,
      DATA_BYTE_NUM => DATA_BYTE_NUM
    )
    port map(
      rst_i         => rst_i,
      mclk_i        => mclk_i,
      sda_i         => sda_i_s,
      sda_o         => sda_o_s,
      sda_oen_o     => sda_oen_s,
      scl_i         => scl,
      my_addr_i     => slave_addr,
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
  M_AXI_BID     <= (others => '0');
  M_AXI_ARREADY <= '1';
  M_AXI_RVALID  <= '1';
  M_AXI_RDATA   <= x"4321ABCD" when M_AXI_ARADDR(2) = '0' else
    x"56789ABC";
  M_AXI_RRESP <= "00";
  M_AXI_RID   <= (others => '0');
  M_AXI_RLAST <= '0';

end simulation;
