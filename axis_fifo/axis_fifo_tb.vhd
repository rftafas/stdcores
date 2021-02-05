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
	use expert.std_string.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.fifo_lib.all;
  use stdblocks.prbs_lib.all;
--stdcores
  use work.axis_fifo_pkg.all;

library vunit_lib;
	context vunit_lib.vunit_context;
  context vunit_lib.vc_context;


entity axis_fifo_tb is
  generic (
    runner_cfg : string
	);
end axis_fifo_tb;

architecture behavioral of axis_fifo_tb is

  constant run_time_c : time    := 1 us;
  constant tdata_byte : integer := 4;
  constant tdest_size : integer := 8;
  constant tuser_size : integer := 8;
  constant fifo_size  : integer := 4;

  signal   rst_i       : std_logic;
  signal   clk_i       : std_logic := '0';

  signal s_tdata_i  : std_logic_vector(8*tdata_byte-1 downto 0);
  signal s_tuser_i  : std_logic_vector(  tuser_size-1 downto 0);
  signal s_tdest_i  : std_logic_vector(  tdest_size-1 downto 0);
  signal s_tstrb_i  : std_logic_vector(  tdata_byte-1 downto 0) := (others=>'1');
  signal s_tready_o : std_logic;
  signal s_tvalid_i : std_logic;
  signal s_tlast_i  : std_logic := '0';

  signal m_tdata_o  : std_logic_vector(8*tdata_byte-1 downto 0);
  signal m_tuser_o  : std_logic_vector(  tuser_size-1 downto 0);
  signal m_tdest_o  : std_logic_vector(  tdest_size-1 downto 0);
  signal m_tstrb_o  : std_logic_vector(  tdata_byte-1 downto 0);
  signal m_tready_i : std_logic;
  signal m_tready_s : std_logic;
  signal m_tvalid_o : std_logic;
  signal m_tvalid_s : std_logic;
  signal m_tlast_o  : std_logic := '0';

  signal fifo_control_s  : std_logic := '1'; 

  signal saved        : boolean := false;
  signal start_check  : boolean := false;
  signal simple_timer : boolean := true;

  constant cnt_top_c : integer := 2**fifo_size;

  constant master_axi_stream : axi_stream_master_t := new_axi_stream_master(
    data_length  => 8*tdata_byte,
    dest_length  => tdest_size,
    user_length  => tuser_size,
    stall_config => new_stall_config(0.00, 1, 10)
  );
  constant slave_axi_stream  : axi_stream_slave_t  := new_axi_stream_slave(
    data_length  => 8*tdata_byte,
    dest_length  => tdest_size,
    user_length  => tuser_size,
    id_length    => 1,
    stall_config => new_stall_config(0.00, 1, 10)
  );

  signal fifo_status_a_o : fifo_status;
  signal fifo_status_b_o : fifo_status;

begin

  clk_i   <= not   clk_i after 5 ns;
  simple_timer <= true, false after run_time_c;

  main : process
    variable prbs     : prbs_t;
    variable last     : std_logic := '0';
    variable pckt_num : integer := 0;
  begin
    test_runner_setup(runner, runner_cfg);

    rst_i     <= '1';
    wait until rising_edge(clk_i);
    wait until rising_edge(clk_i);
    rst_i     <= '0';

    while test_suite loop
      if run("Sanity Test") then
        check_passed(result("Sanity check."));

      elsif run("Data Packet simulation") then
        info("Single data Packet with " & to_string(cnt_top_c) & " words.");
        start_check <= true;
        wait until rising_edge(clk_i);
        for j in 0 to cnt_top_c-1 loop
          if j = cnt_top_c-1 then
            last := '1';
          end if;
          push_axi_stream(net, master_axi_stream,
            tdata => prbs.get_data(8*tdata_byte),
            tlast => last,
            tdest => std_logic_vector(to_signed(j, tdest_size)),
            tuser => std_logic_vector(to_signed(j, tuser_size))
          );
        end loop;
        wait until rising_edge(clk_i);
        start_check <= false;
        wait until saved and rising_edge(clk_i);
        check_passed(result("Data Packet Test."));

      elsif run("Free running simulation") then
        info("Will run for " & to_string(run_time_c));
        start_check <= true;
        while simple_timer loop
          if (pckt_num > 0) and (pckt_num mod (cnt_top_c-1) = 0) then
            last := '1';
          else
            last := '0';
          end if;
          push_axi_stream(net, master_axi_stream,
            tdata => prbs.get_data(8*tdata_byte),
            tlast => last,
            tdest => std_logic_vector(to_signed(pckt_num, tdest_size)),
            tuser => std_logic_vector(to_signed(pckt_num, tuser_size))
          );
          pckt_num := pckt_num + 1;
          wait until rising_edge(clk_i);
        end loop;
        check_passed(result("Free running finished."));
      
      elsif run("Overflow Simulation") then
        info("Sending data until fifo is full.");
        fifo_control_s <= '0';
        start_check      <= true;

        while true loop
          if (pckt_num > 0) and (pckt_num mod (cnt_top_c-1) = 0) then
            last := '1';
          else
            last := '0';
          end if;
          push_axi_stream(net, master_axi_stream,
            tdata => prbs.get_data(8*tdata_byte),
            tlast => last,
            tdest => std_logic_vector(to_signed(pckt_num, tdest_size)),
            tuser => std_logic_vector(to_signed(pckt_num, tuser_size))
          );
          pckt_num := pckt_num + 1;
          wait until rising_edge(clk_i);
          if last = '1' and fifo_status_a_o.full = '1' then
            exit;
          end if;
        end loop;
        for j in 0 to 3 loop
          wait until rising_edge(clk_i);
        end loop;
        fifo_control_s <= '1';
        wait until m_tvalid_o = '0';
        start_check      <= false;
        check_passed(result("Overflow test."));
      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  test_runner_watchdog(runner, 2*run_time_c);

  save: process
    variable tdata_v  : std_logic_vector(8*tdata_byte-1 downto 0);
    variable tdest_v  : std_logic_vector(tdest_size-1 downto 0);
    variable tuser_v  : std_logic_vector(tuser_size-1 downto 0);
    variable last     : std_logic;
    variable tkeep_v  : std_logic_vector(tdata_byte-1 downto 0);
    variable tstrb_v  : std_logic_vector(tdata_byte-1 downto 0);
    variable tid_v    : std_logic_vector(0 downto 0);
    variable prbs     : prbs_t;
    variable pckt_num : integer := 0;
  begin
    if rst_i = '1' then
      saved <= false;
      if not prbs.set_order(23) then
        wait;
      end if;
      if not prbs.reset then
        wait;
      end if;
    end if;
    wait until start_check and rising_edge(clk_i);
    
    while start_check loop
      pop_axi_stream(net, slave_axi_stream,
        tdata => tdata_v,
        tlast => last,
        tkeep => tkeep_v,
        tstrb => tstrb_v,
        tid   => tid_v,
        tdest => tdest_v,
        tuser => tuser_v
      );
      check_equal(prbs.get_data(tdata_v'length),tdata_v,result("Checking data error.") );
      check_equal(to_integer(tdest_v),pckt_num,result("TDEST out of order, error at " & to_string(pckt_num) ) );
      check_equal(to_integer(tuser_v),pckt_num,result("TUSER out of order, error at " & to_string(pckt_num) ) );
      if (pckt_num > 0) and (pckt_num mod (cnt_top_c-1) = 0) then
        check_equal(last,std_logic'('1'),result("TLAST Missing.") );
      end if;
      pckt_num := pckt_num + 1;
    end loop;
    info("Test Complete!");
    wait until rising_edge(clk_i);
    saved <= true;
  end process;

  m_tready_i <= fifo_control_s and m_tready_s;
  m_tvalid_s <= fifo_control_s and m_tvalid_o;

  vunit_axism: entity vunit_lib.axi_stream_master
    generic map (
      master => master_axi_stream
    )
    port map (
      aclk   => clk_i,
      tvalid => s_tvalid_i,
      tready => s_tready_o,
      tdata  => s_tdata_i,
      tlast  => s_tlast_i,
      tstrb  => s_tstrb_i,
      tdest  => s_tdest_i,
      tuser  => s_tuser_i
    );

  vunit_axiss: entity vunit_lib.axi_stream_slave
    generic map (
      slave => slave_axi_stream
    )
    port map (
      aclk   => clk_i,
      tvalid => m_tvalid_s,
      tready => m_tready_s,
      tdata  => m_tdata_o,
      tlast  => m_tlast_o,
      tstrb  => m_tstrb_o,
      tdest  => m_tdest_o,
      tuser  => m_tuser_o
    );

    dut_u : axis_fifo
      generic map (
        ram_type     => blockram,
        fifo_size    => fifo_size,
        tdata_size   => 8*tdata_byte,
        tdest_size   => tdest_size,
        tuser_size   => tuser_size,
        packet_mode  => false,
        tuser_enable => true,
        tlast_enable => true,
        tdest_enable => true,
        sync_mode    => false,
        cut_through  => false
      )
      port map (
        clka_i       => clk_i,
        rsta_i       => rst_i,
        clkb_i       => clk_i,
        rstb_i       => rst_i,
  
        s_tdata_i    => s_tdata_i,
        s_tuser_i    => s_tuser_i,
        s_tdest_i    => s_tdest_i,
        s_tready_o   => s_tready_o,
        s_tvalid_i   => s_tvalid_i,
        s_tlast_i    => s_tlast_i,
  
        m_tdata_o    => m_tdata_o,
        m_tuser_o    => m_tuser_o,
        m_tdest_o    => m_tdest_o,
        m_tready_i   => m_tready_i,
        m_tvalid_o   => m_tvalid_o,
        m_tlast_o    => m_tlast_o,
  
        fifo_status_a_o => fifo_status_a_o,
        fifo_status_b_o => fifo_status_b_o
      );


end behavioral;
