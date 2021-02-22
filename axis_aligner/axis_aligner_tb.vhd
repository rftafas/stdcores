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
  use stdblocks.prbs_lib.all;

library vunit_lib;
	context vunit_lib.vunit_context;
  context vunit_lib.vc_context;

entity axis_aligner_tb is
  generic (
    runner_cfg      : string
	);
end axis_aligner_tb;

architecture behavioral of axis_aligner_tb is

  constant peripherals_num : positive := 2;
  constant packet_size_c   : integer := 8;
  constant packet_number_c : integer := 8;

  component axis_aligner is
    generic (
      number_ports    : positive := 2;
      tdata_byte      : positive := 8;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      switch_on_tlast : boolean  := true
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
        --AXIS Master Port
      m_tdata_o  : out std_logic_array (number_ports-1 downto 0)(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_array (number_ports-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array (number_ports-1 downto 0)(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_array (number_ports-1 downto 0)(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic_vector(number_ports-1 downto 0);
      m_tvalid_o : out std_logic_vector(number_ports-1 downto 0);
      m_tlast_o  : out std_logic_vector(number_ports-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  std_logic_array (number_ports-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array (number_ports-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array (number_ports-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array (number_ports-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(number_ports-1 downto 0);
      s_tvalid_i : in  std_logic_vector(number_ports-1 downto 0);
      s_tlast_i  : in  std_logic_vector(number_ports-1 downto 0)
    );
  end component axis_aligner;

  constant run_time_c : time    := 100 us;
  constant tdata_byte : integer := 4;
  constant tdest_size : integer := 8;
  constant tuser_size : integer := 8;

  signal   rst_i       : std_logic;
  signal   clk_i       : std_logic := '0';

  signal s_tdata_i  : std_logic_array(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
  signal s_tuser_i  : std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
  signal s_tdest_i  : std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
  signal s_tstrb_i  : std_logic_array(peripherals_num-1 downto 0)(tdata_byte-1 downto 0) := (others=>(others=>'1'));
  signal s_tready_o : std_logic_vector(peripherals_num-1 downto 0);
  signal s_tvalid_i : std_logic_vector(peripherals_num-1 downto 0);
  signal s_tlast_i  : std_logic_vector(peripherals_num-1 downto 0) := (others=>'0');

  signal m_tdata_o  : std_logic_array(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
  signal m_tuser_o  : std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
  signal m_tdest_o  : std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
  signal m_tstrb_o  : std_logic_array(peripherals_num-1 downto 0)(tdata_byte-1 downto 0);
  signal m_tready_i : std_logic_vector(peripherals_num-1 downto 0);
  signal m_tvalid_o : std_logic_vector(peripherals_num-1 downto 0);
  signal m_tlast_o  : std_logic_vector(peripherals_num-1 downto 0);

  signal start : boolean := false;
  signal done  : boolean_vector(peripherals_num-1 downto 0) := (others=>false);
  signal saved : boolean_vector(peripherals_num-1 downto 0) := (others=>false);

  type axi_slave_array_t is array (peripherals_num-1 downto 0) of axi_stream_slave_t;

  impure function new_slave_array return axi_slave_array_t is
    variable tmp : axi_slave_array_t;
  begin
    for j in peripherals_num-1 downto 0 loop
      tmp(j) := new_axi_stream_slave(
        data_length  => 8*tdata_byte,
        dest_length  => tdest_size,
        user_length  => tuser_size,
        id_length    => 1,
        stall_config => new_stall_config(0.00, 1, 10)
      );
    end loop;
    return tmp;
  end new_slave_array;

  constant slave_axi_stream  : axi_slave_array_t := new_slave_array;

  type axi_master_array_t is array (peripherals_num-1 downto 0) of axi_stream_master_t;

  impure function new_master_array return axi_master_array_t is
    variable tmp : axi_master_array_t;
  begin
    for j in peripherals_num-1 downto 0 loop
      tmp(j) := new_axi_stream_master(
        data_length  => 8*tdata_byte,
        dest_length  => tdest_size,
        user_length  => tuser_size,
        stall_config => new_stall_config(0.00, 1, 10)
      );
    end loop;
    return tmp;
  end new_master_array;

  constant master_axi_stream : axi_master_array_t := new_master_array;

begin

  clk_i   <= not   clk_i after 5 ns;
  test_runner_watchdog(runner, 200 us);

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    rst_i     <= '1';
    wait until rising_edge(clk_i);
    wait until rising_edge(clk_i);
    rst_i     <= '0';

    while test_suite loop
      if run("Free running simulation") then
        report "Will run for " & to_string(run_time_c);
        wait for run_time_c;
        check_passed(result("Free running finished."));

      elsif run("PRBS simulation") then
        info("Init test");
        wait until rising_edge(clk_i);
        start <= true;
        wait until rising_edge(clk_i);
        start <= false;
        wait until ( (and done) and (and saved) and rising_edge(clk_i));
        info("Test done");

      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  stream_chec_gen : for k in 0 to peripherals_num-1 generate

    stimuli: process
      variable last       : std_logic := '0';
      variable prbs       : prbs_t;
    begin

      done(k) <= false;
      last := '0';
      wait until start and rising_edge(clk_i);
      wait for (k * 100 ns);
      info("VCI_" & to_string(k) & ": Writing data.");

      for i in 1 to packet_number_c loop
        for j in packet_size_c-1 downto 0 loop
          wait until rising_edge(clk_i);
          if j = 0 then
            last := '1';
          end if;
          push_axi_stream(net, master_axi_stream(k),
            tdata => prbs.get_data(8*tdata_byte),
            tlast => last,
            tdest => std_logic_vector(to_signed(j, tdest_size)),
            tuser => std_logic_vector(to_signed(j, tuser_size))
          );
        end loop;
        last := '0';
        wait for (k * 250 ns);
      end loop;

      info("VCI_" & to_string(k) & ": Sendind data.");
      done(k) <= true;
      wait until rising_edge(clk_i) and s_tvalid_i(k) = '1';
      wait until rising_edge(clk_i) and s_tvalid_i(k) = '0';
      info("VCI_" & to_string(k) & ": Data sent.");
      wait;

    end process;

    save: process
      variable tdata_v : std_logic_vector(8*tdata_byte-1 downto 0);
      variable tdest_v : std_logic_vector(tdest_size-1 downto 0);
      variable tuser_v : std_logic_vector(tuser_size-1 downto 0);
      variable last    : std_logic;
      variable tkeep_v : std_logic_vector(tdata_byte-1 downto 0);
      variable tstrb_v : std_logic_vector(tdata_byte-1 downto 0);
      variable tid_v   : std_logic_vector(0 downto 0);
      variable prbs    : prbs_t;
    begin
      if rst_i = '1' then
        saved(k) <= false;
      end if;
      wait until start and rising_edge(clk_i);

      info("Reading data from VCI_" & to_string(k) & ".");

      for j in 1 to packet_number_c loop
        for j in packet_size_c-1 downto 0 loop
          pop_axi_stream(net, slave_axi_stream(k),
            tdata => tdata_v,
            tlast => last,
            tkeep => tkeep_v,
            tstrb => tstrb_v,
            tid   => tid_v,
            tdest => tdest_v,
            tuser => tuser_v
          );
          if (j = 0) and (last='0') then
            --error("Something went wrong. Last misaligned!");
          end if;
          check_equal(prbs.get_data(tdata_v'length),tdata_v,result("Checking data error") );
          check_equal(to_integer(tdest_v),j,result("Checking counter value, error at " & to_string(j) ) );
          check_equal(to_integer(tuser_v),j,result("Checking counter value, error at " & to_string(j) ) );
        end loop;
      end loop;

      info("VCI_" & to_string(k) & " Readout Complete!");
      saved(k) <= true;
      wait;
    end process;

    vunit_axiss: entity vunit_lib.axi_stream_slave
      generic map (
        slave => slave_axi_stream(k)
      )
      port map (
        aclk   => clk_i,
        tvalid => m_tvalid_o(k),
        tready => m_tready_i(k),
        tdata  => m_tdata_o(k),
        tlast  => m_tlast_o(k),
        tstrb  => m_tstrb_o(k),
        tdest  => m_tdest_o(k),
        tuser  => m_tuser_o(k)
      );

    vunit_axism: entity vunit_lib.axi_stream_master
      generic map (
        master => master_axi_stream(k)
      )
      port map (
        aclk   => clk_i,
        tvalid => s_tvalid_i(k),
        tready => s_tready_o(k),
        tdata  => s_tdata_i(k),
        tlast  => s_tlast_i(k),
        tstrb  => s_tstrb_i(k),
        tdest  => s_tdest_i(k),
        tuser  => s_tuser_i(k)
      );

  end generate;


  dut : axis_aligner
  generic map (
    number_ports    => peripherals_num,
    tdata_byte      => tdata_byte,
    tdest_size      => tdest_size,
    tuser_size      => tuser_size,
    switch_on_tlast => true
  )
  port map (
    clk_i      => clk_i,
    rst_i      => rst_i,
    s_tdata_i  => s_tdata_i,
    s_tuser_i  => s_tuser_i,
    s_tdest_i  => s_tdest_i,
    s_tstrb_i  => s_tstrb_i,
    s_tready_o => s_tready_o,
    s_tvalid_i => s_tvalid_i,
    s_tlast_i  => s_tlast_i,

    m_tdata_o  => m_tdata_o,
    m_tuser_o  => m_tuser_o,
    m_tdest_o  => m_tdest_o,
    m_tstrb_o  => m_tstrb_o,
    m_tready_i => m_tready_i,
    m_tvalid_o => m_tvalid_o,
    m_tlast_o  => m_tlast_o
  );

end behavioral;


