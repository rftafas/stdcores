---------------------------------------------------------------------------------
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
--
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-- For more information, please refer to <http://unlicense.org/>
---------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;
library std;
  use std.textio.all;
library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.vc_context;

use work.can_aximm_pkg.all;

entity can_aximm_tb is
  generic (
    runner_cfg : string;
    run_time : integer := 100
  );
  --port (
    --port_declaration_tag
  --);
end can_aximm_tb;

architecture simulation of can_aximm_tb is

  --architecture_declaration_tag


  constant C_S_AXI_ADDR_WIDTH : integer := 7;
  constant C_S_AXI_DATA_WIDTH : integer := 32;
  constant axi_handle : bus_master_t := new_bus(data_length => C_S_AXI_DATA_WIDTH, address_length => C_S_AXI_ADDR_WIDTH);
  constant addr_increment_c : integer := 4;

  signal S_AXI_ACLK : std_logic := '0';
  signal S_AXI_ARESETN : std_logic;
  signal S_AXI_AWADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_AWPROT : std_logic_vector(2 downto 0);
  signal S_AXI_AWVALID : std_logic;
  signal S_AXI_AWREADY : std_logic;
  signal S_AXI_WDATA : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_WSTRB : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  signal S_AXI_WVALID : std_logic;
  signal S_AXI_WREADY : std_logic;
  signal S_AXI_BRESP : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID : std_logic;
  signal S_AXI_BREADY : std_logic;
  signal S_AXI_ARADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_ARPROT : std_logic_vector(2 downto 0);
  signal S_AXI_ARVALID : std_logic;
  signal S_AXI_ARREADY : std_logic;
  signal S_AXI_RDATA : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_RRESP : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID : std_logic;
  signal S_AXI_RREADY : std_logic;
  signal g1_i : std_logic_vector(31 downto 0);
  signal iso_mode_o : std_logic;
  signal fd_enable_o : std_logic;
  signal sample_rate_o : std_logic_vector(15 downto 0);
  signal rx_irq_i : std_logic;
  signal rx_irq_mask_o : std_logic;
  signal tx_irq_i : std_logic;
  signal tx_irq_mask_o : std_logic;
  signal stuff_violation_i : std_logic;
  signal collision_i : std_logic;
  signal channel_ready_i : std_logic;
  signal loop_enable_o : std_logic;
  signal insert_error_o : std_logic;
  signal force_dominant_o : std_logic;
  signal rx_data_valid_i : std_logic;
  signal rx_read_done_o : std_logic;
  signal rx_busy_i : std_logic;
  signal rx_crc_error_i : std_logic;
  signal rx_rtr_i : std_logic;
  signal rx_ide_i : std_logic;
  signal rx_reserved_i : std_logic_vector(1 downto 0);
  signal id1_o : std_logic_vector(28 downto 0);
  signal id1_mask_o : std_logic_vector(28 downto 0);
  signal rx_size_i : std_logic_vector(3 downto 0);
  signal rx_id_i : std_logic_vector(28 downto 0);
  signal rx_data0_i : std_logic_vector(31 downto 0);
  signal rx_data1_i : std_logic_vector(31 downto 0);
  signal tx_ready_i : std_logic;
  signal tx_valid_o : std_logic;
  signal tx_busy_i : std_logic;
  signal tx_arb_lost_i : std_logic;
  signal tx_retry_error_i : std_logic;
  signal tx_rtr_o : std_logic;
  signal tx_eff_o : std_logic;
  signal tx_reserved_o : std_logic_vector(1 downto 0);
  signal tx_dlc_o : std_logic_vector(3 downto 0);
  signal tx_id_o : std_logic_vector(28 downto 0);
  signal tx_data0_o : std_logic_vector(31 downto 0);
  signal tx_data1_o : std_logic_vector(31 downto 0);

begin

  --architecture_body_tag.

  
S_AXI_ACLK <= not S_AXI_ACLK after 10 ns;

main : process
    variable rdata_v : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others=>'0');
    variable wdata_v : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others=>'0');
begin
    test_runner_setup(runner, runner_cfg);
    S_AXI_ARESETN     <= '0';
    wait until rising_edge(S_AXI_ACLK);
    wait until rising_edge(S_AXI_ACLK);
    S_AXI_ARESETN     <= '1';
    wait until rising_edge(S_AXI_ACLK);
    wait until rising_edge(S_AXI_ACLK);

    while test_suite loop
        if run("Sanity check for system.") then
            report "System Sane. Begin tests.";
            check_passed(result("Sanity check for system."));

        elsif run("Simple Run Test") then
            wait for 100 us;
            check_passed(result("Simple Run Test Pass."));

        elsif run("Read Only Test") then
          --Testing g1_i
          read_bus(net,axi_handle,0,rdata_v);
          check_equal(rdata_v(31 downto 0),g1_i,result("Test Read: g1_i."));
          --Testing channel_ready_i
          read_bus(net,axi_handle,16,rdata_v);
          check_equal(rdata_v(8),channel_ready_i,result("Test Read: channel_ready_i."));
          --Testing rx_busy_i
          read_bus(net,axi_handle,32,rdata_v);
          check_equal(rdata_v(8),rx_busy_i,result("Test Read: rx_busy_i."));
          --Testing rx_crc_error_i
          read_bus(net,axi_handle,32,rdata_v);
          check_equal(rdata_v(9),rx_crc_error_i,result("Test Read: rx_crc_error_i."));
          --Testing rx_rtr_i
          read_bus(net,axi_handle,32,rdata_v);
          check_equal(rdata_v(16),rx_rtr_i,result("Test Read: rx_rtr_i."));
          --Testing rx_ide_i
          read_bus(net,axi_handle,32,rdata_v);
          check_equal(rdata_v(24),rx_ide_i,result("Test Read: rx_ide_i."));
          --Testing rx_reserved_i
          read_bus(net,axi_handle,32,rdata_v);
          check_equal(rdata_v(26 downto 25),rx_reserved_i,result("Test Read: rx_reserved_i."));
          --Testing rx_size_i
          read_bus(net,axi_handle,44,rdata_v);
          check_equal(rdata_v(3 downto 0),rx_size_i,result("Test Read: rx_size_i."));
          --Testing rx_id_i
          read_bus(net,axi_handle,48,rdata_v);
          check_equal(rdata_v(28 downto 0),rx_id_i,result("Test Read: rx_id_i."));
          --Testing rx_data0_i
          read_bus(net,axi_handle,52,rdata_v);
          check_equal(rdata_v(31 downto 0),rx_data0_i,result("Test Read: rx_data0_i."));
          --Testing rx_data1_i
          read_bus(net,axi_handle,56,rdata_v);
          check_equal(rdata_v(31 downto 0),rx_data1_i,result("Test Read: rx_data1_i."));
          --Testing tx_ready_i
          read_bus(net,axi_handle,64,rdata_v);
          check_equal(rdata_v(0),tx_ready_i,result("Test Read: tx_ready_i."));
          --Testing tx_busy_i
          read_bus(net,axi_handle,64,rdata_v);
          check_equal(rdata_v(8),tx_busy_i,result("Test Read: tx_busy_i."));
          check_passed(result("Read Out Test Pass."));

        elsif run("Read and Write Test") then
          --Testing iso_mode_o
          wdata_v := "11000101011010101001011110111110";
          write_bus(net,axi_handle,4,wdata_v,"0001");
          read_bus(net,axi_handle,4,rdata_v);
          check_equal(rdata_v(0),wdata_v(0),result("Test Readback and Port value: iso_mode_o."));
          check_equal(iso_mode_o,wdata_v(0),result("Test Readback and Port value: iso_mode_o."));
          --Testing fd_enable_o
          wdata_v := "10110101100101011000011010101110";
          write_bus(net,axi_handle,4,wdata_v,"0001");
          read_bus(net,axi_handle,4,rdata_v);
          check_equal(rdata_v(1),wdata_v(1),result("Test Readback and Port value: fd_enable_o."));
          check_equal(fd_enable_o,wdata_v(1),result("Test Readback and Port value: fd_enable_o."));
          --Testing sample_rate_o
          wdata_v := "10101100110000100010011010010111";
          write_bus(net,axi_handle,8,wdata_v,"0011");
          read_bus(net,axi_handle,8,rdata_v);
          check_equal(rdata_v(15 downto 0),wdata_v(15 downto 0),result("Test Readback and Port value: sample_rate_o."));
          check_equal(sample_rate_o,wdata_v(15 downto 0),result("Test Readback and Port value: sample_rate_o."));
          --Testing rx_irq_mask_o
          wdata_v := "10100001010011111010001010000111";
          write_bus(net,axi_handle,12,wdata_v,"0001");
          read_bus(net,axi_handle,12,rdata_v);
          check_equal(rdata_v(1),wdata_v(1),result("Test Readback and Port value: rx_irq_mask_o."));
          check_equal(rx_irq_mask_o,wdata_v(1),result("Test Readback and Port value: rx_irq_mask_o."));
          --Testing tx_irq_mask_o
          wdata_v := "01111111001110010111111110111110";
          write_bus(net,axi_handle,12,wdata_v,"0010");
          read_bus(net,axi_handle,12,rdata_v);
          check_equal(rdata_v(9),wdata_v(9),result("Test Readback and Port value: tx_irq_mask_o."));
          check_equal(tx_irq_mask_o,wdata_v(9),result("Test Readback and Port value: tx_irq_mask_o."));
          --Testing loop_enable_o
          wdata_v := "11110101000111000111100111111100";
          write_bus(net,axi_handle,28,wdata_v,"0001");
          read_bus(net,axi_handle,28,rdata_v);
          check_equal(rdata_v(0),wdata_v(0),result("Test Readback and Port value: loop_enable_o."));
          check_equal(loop_enable_o,wdata_v(0),result("Test Readback and Port value: loop_enable_o."));
          --Testing force_dominant_o
          wdata_v := "10010110111011111110110001110000";
          write_bus(net,axi_handle,28,wdata_v,"0100");
          read_bus(net,axi_handle,28,rdata_v);
          check_equal(rdata_v(16),wdata_v(16),result("Test Readback and Port value: force_dominant_o."));
          check_equal(force_dominant_o,wdata_v(16),result("Test Readback and Port value: force_dominant_o."));
          --Testing id1_o
          wdata_v := "01101101000100010111000001101001";
          write_bus(net,axi_handle,36,wdata_v,"1111");
          read_bus(net,axi_handle,36,rdata_v);
          check_equal(rdata_v(28 downto 0),wdata_v(28 downto 0),result("Test Readback and Port value: id1_o."));
          check_equal(id1_o,wdata_v(28 downto 0),result("Test Readback and Port value: id1_o."));
          --Testing id1_mask_o
          wdata_v := "11011110100010110000101011111111";
          write_bus(net,axi_handle,40,wdata_v,"1111");
          read_bus(net,axi_handle,40,rdata_v);
          check_equal(rdata_v(28 downto 0),wdata_v(28 downto 0),result("Test Readback and Port value: id1_mask_o."));
          check_equal(id1_mask_o,wdata_v(28 downto 0),result("Test Readback and Port value: id1_mask_o."));
          --Testing tx_rtr_o
          wdata_v := "10010011101110001110110100001011";
          write_bus(net,axi_handle,64,wdata_v,"0100");
          read_bus(net,axi_handle,64,rdata_v);
          check_equal(rdata_v(16),wdata_v(16),result("Test Readback and Port value: tx_rtr_o."));
          check_equal(tx_rtr_o,wdata_v(16),result("Test Readback and Port value: tx_rtr_o."));
          --Testing tx_eff_o
          wdata_v := "01010001101101000001100110100110";
          write_bus(net,axi_handle,64,wdata_v,"1000");
          read_bus(net,axi_handle,64,rdata_v);
          check_equal(rdata_v(24),wdata_v(24),result("Test Readback and Port value: tx_eff_o."));
          check_equal(tx_eff_o,wdata_v(24),result("Test Readback and Port value: tx_eff_o."));
          --Testing tx_reserved_o
          wdata_v := "00010010010100011101000101010011";
          write_bus(net,axi_handle,64,wdata_v,"1000");
          read_bus(net,axi_handle,64,rdata_v);
          check_equal(rdata_v(26 downto 25),wdata_v(26 downto 25),result("Test Readback and Port value: tx_reserved_o."));
          check_equal(tx_reserved_o,wdata_v(26 downto 25),result("Test Readback and Port value: tx_reserved_o."));
          --Testing tx_dlc_o
          wdata_v := "00011011010001000101111011001000";
          write_bus(net,axi_handle,68,wdata_v,"0001");
          read_bus(net,axi_handle,68,rdata_v);
          check_equal(rdata_v(3 downto 0),wdata_v(3 downto 0),result("Test Readback and Port value: tx_dlc_o."));
          check_equal(tx_dlc_o,wdata_v(3 downto 0),result("Test Readback and Port value: tx_dlc_o."));
          --Testing tx_id_o
          wdata_v := "10111010101000110100000100111100";
          write_bus(net,axi_handle,72,wdata_v,"1111");
          read_bus(net,axi_handle,72,rdata_v);
          check_equal(rdata_v(28 downto 0),wdata_v(28 downto 0),result("Test Readback and Port value: tx_id_o."));
          check_equal(tx_id_o,wdata_v(28 downto 0),result("Test Readback and Port value: tx_id_o."));
          --Testing tx_data0_o
          wdata_v := "11101101010010100011110011000011";
          write_bus(net,axi_handle,76,wdata_v,"1111");
          read_bus(net,axi_handle,76,rdata_v);
          check_equal(rdata_v(31 downto 0),wdata_v(31 downto 0),result("Test Readback and Port value: tx_data0_o."));
          check_equal(tx_data0_o,wdata_v(31 downto 0),result("Test Readback and Port value: tx_data0_o."));
          --Testing tx_data1_o
          wdata_v := "10011001111101111101010110100110";
          write_bus(net,axi_handle,80,wdata_v,"1111");
          read_bus(net,axi_handle,80,rdata_v);
          check_equal(rdata_v(31 downto 0),wdata_v(31 downto 0),result("Test Readback and Port value: tx_data1_o."));
          check_equal(tx_data1_o,wdata_v(31 downto 0),result("Test Readback and Port value: tx_data1_o."));
          check_passed(result("Read and Write Test Pass."));

        elsif run("Split Read Write Test") then
          check_passed(result("Split Read Write Test Pass."));

        elsif run("Write to Clear Test") then
          --Testing rx_irq_i: Set to '1'
          rx_irq_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          rx_irq_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,12,rdata_v);
          check(rdata_v(0) = '1',result("Test Read Ones: rx_irq_i."));
          wdata_v(0) := '1';
          write_bus(net,axi_handle,12,wdata_v,"0001");
          read_bus(net,axi_handle,12,rdata_v);
          check(rdata_v(0) = '0',result("Test Read Zeroes: rx_irq_i."));
          --Testing tx_irq_i: Set to '1'
          tx_irq_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          tx_irq_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,12,rdata_v);
          check(rdata_v(8) = '1',result("Test Read Ones: tx_irq_i."));
          wdata_v(8) := '1';
          write_bus(net,axi_handle,12,wdata_v,"0010");
          read_bus(net,axi_handle,12,rdata_v);
          check(rdata_v(8) = '0',result("Test Read Zeroes: tx_irq_i."));
          --Testing stuff_violation_i: Set to '1'
          stuff_violation_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          stuff_violation_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,16,rdata_v);
          check(rdata_v(0) = '1',result("Test Read Ones: stuff_violation_i."));
          wdata_v(0) := '1';
          write_bus(net,axi_handle,16,wdata_v,"0001");
          read_bus(net,axi_handle,16,rdata_v);
          check(rdata_v(0) = '0',result("Test Read Zeroes: stuff_violation_i."));
          --Testing collision_i: Set to '1'
          collision_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          collision_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,16,rdata_v);
          check(rdata_v(1) = '1',result("Test Read Ones: collision_i."));
          wdata_v(1) := '1';
          write_bus(net,axi_handle,16,wdata_v,"0001");
          read_bus(net,axi_handle,16,rdata_v);
          check(rdata_v(1) = '0',result("Test Read Zeroes: collision_i."));
          --Testing rx_data_valid_i: Set to '1'
          rx_data_valid_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          rx_data_valid_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,32,rdata_v);
          check(rdata_v(0) = '1',result("Test Read Ones: rx_data_valid_i."));
          wdata_v(0) := '1';
          write_bus(net,axi_handle,32,wdata_v,"0001");
          read_bus(net,axi_handle,32,rdata_v);
          check(rdata_v(0) = '0',result("Test Read Zeroes: rx_data_valid_i."));
          --Testing tx_arb_lost_i: Set to '1'
          tx_arb_lost_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          tx_arb_lost_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,64,rdata_v);
          check(rdata_v(9) = '1',result("Test Read Ones: tx_arb_lost_i."));
          wdata_v(9) := '1';
          write_bus(net,axi_handle,64,wdata_v,"0010");
          read_bus(net,axi_handle,64,rdata_v);
          check(rdata_v(9) = '0',result("Test Read Zeroes: tx_arb_lost_i."));
          --Testing tx_retry_error_i: Set to '1'
          tx_retry_error_i <= '1';
          wait until rising_edge(S_AXI_ACLK);
          tx_retry_error_i <= '0';
          wait until rising_edge(S_AXI_ACLK);
          read_bus(net,axi_handle,64,rdata_v);
          check(rdata_v(10) = '1',result("Test Read Ones: tx_retry_error_i."));
          wdata_v(10) := '1';
          write_bus(net,axi_handle,64,wdata_v,"0010");
          read_bus(net,axi_handle,64,rdata_v);
          check(rdata_v(10) = '0',result("Test Read Zeroes: tx_retry_error_i."));
          check_passed(result("Write to Clear Test Pass."));

        elsif run("Write to Pulse Test") then
          --Testing insert_error_o
          wdata_v(8) := '1';
          write_bus(net,axi_handle,28,wdata_v,"0010");
          wait until insert_error_o = '1';
          --Testing rx_read_done_o
          wdata_v(1) := '1';
          write_bus(net,axi_handle,32,wdata_v,"0001");
          wait until rx_read_done_o = '1';
          --Testing tx_valid_o
          wdata_v(1) := '1';
          write_bus(net,axi_handle,64,wdata_v,"0001");
          wait until tx_valid_o = '1';
          check_passed(result("Write to Pulse Test Pass."));

        elsif run("External Clear Test") then
          check_passed(result("External Clear Test Pass."));

        end if;
    end loop;
    test_runner_cleanup(runner); -- Simulation ends here
end process;

test_runner_watchdog(runner, 101 us);



  axi_master_u : entity vunit_lib.axi_lite_master
    generic map (
      bus_handle => axi_handle
    )
    port map (
      aclk => S_AXI_ACLK,
      --areset_n => S_AXI_ARESETN,
      awaddr => S_AXI_AWADDR,
      --awprot => S_AXI_AWPROT,
      awvalid => S_AXI_AWVALID,
      awready => S_AXI_AWREADY,
      wdata => S_AXI_WDATA,
      wstrb => S_AXI_WSTRB,
      wvalid => S_AXI_WVALID,
      wready => S_AXI_WREADY,
      bresp => S_AXI_BRESP,
      bvalid => S_AXI_BVALID,
      bready => S_AXI_BREADY,
      araddr => S_AXI_ARADDR,
      --arprot => S_AXI_ARPROT,
      arvalid => S_AXI_ARVALID,
      arready => S_AXI_ARREADY,
      rdata => S_AXI_RDATA,
      rresp => S_AXI_RRESP,
      rvalid => S_AXI_RVALID,
      rready => S_AXI_RREADY
    );

  dut_u : can_aximm
    generic map (
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
    )
    port map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR => S_AXI_AWADDR,
      S_AXI_AWPROT => S_AXI_AWPROT,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTRB => S_AXI_WSTRB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARPROT => S_AXI_ARPROT,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => S_AXI_RVALID,
      S_AXI_RREADY => S_AXI_RREADY,
      g1_i => g1_i,
      iso_mode_o => iso_mode_o,
      fd_enable_o => fd_enable_o,
      sample_rate_o => sample_rate_o,
      rx_irq_i => rx_irq_i,
      rx_irq_mask_o => rx_irq_mask_o,
      tx_irq_i => tx_irq_i,
      tx_irq_mask_o => tx_irq_mask_o,
      stuff_violation_i => stuff_violation_i,
      collision_i => collision_i,
      channel_ready_i => channel_ready_i,
      loop_enable_o => loop_enable_o,
      insert_error_o => insert_error_o,
      force_dominant_o => force_dominant_o,
      rx_data_valid_i => rx_data_valid_i,
      rx_read_done_o => rx_read_done_o,
      rx_busy_i => rx_busy_i,
      rx_crc_error_i => rx_crc_error_i,
      rx_rtr_i => rx_rtr_i,
      rx_ide_i => rx_ide_i,
      rx_reserved_i => rx_reserved_i,
      id1_o => id1_o,
      id1_mask_o => id1_mask_o,
      rx_size_i => rx_size_i,
      rx_id_i => rx_id_i,
      rx_data0_i => rx_data0_i,
      rx_data1_i => rx_data1_i,
      tx_ready_i => tx_ready_i,
      tx_valid_o => tx_valid_o,
      tx_busy_i => tx_busy_i,
      tx_arb_lost_i => tx_arb_lost_i,
      tx_retry_error_i => tx_retry_error_i,
      tx_rtr_o => tx_rtr_o,
      tx_eff_o => tx_eff_o,
      tx_reserved_o => tx_reserved_o,
      tx_dlc_o => tx_dlc_o,
      tx_id_o => tx_id_o,
      tx_data0_o => tx_data0_o,
      tx_data1_o => tx_data1_o
    );


    --Read Only: g1_i;
    g1_i <= "01010000011001001100010110100101";
    --Read Only: channel_ready_i;
    channel_ready_i <= '0';
    --Read Only: rx_busy_i;
    rx_busy_i <= '0';
    --Read Only: rx_crc_error_i;
    rx_crc_error_i <= '1';
    --Read Only: rx_rtr_i;
    rx_rtr_i <= '0';
    --Read Only: rx_ide_i;
    rx_ide_i <= '0';
    --Read Only: rx_reserved_i;
    rx_reserved_i <= "11";
    --Read Only: rx_size_i;
    rx_size_i <= "1101";
    --Read Only: rx_id_i;
    rx_id_i <= "01100001110011101111111110001";
    --Read Only: rx_data0_i;
    rx_data0_i <= "00010001111010001110100000001011";
    --Read Only: rx_data1_i;
    rx_data1_i <= "01100001100011111111111011000101";
    --Read Only: tx_ready_i;
    tx_ready_i <= '1';
    --Read Only: tx_busy_i;
    tx_busy_i <= '0';

end simulation;

