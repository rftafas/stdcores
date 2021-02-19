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

entity axis_intercon_tb is
  generic (
    runner_cfg      : string
	);
end axis_intercon_tb;

architecture behavioral of axis_intercon_tb is

  constant run_time_c      : time     := 100 us;
  constant tdata_byte      : integer  := 4;
  constant tdest_size      : integer  := 8;
  constant tuser_size      : integer  := 8;
  constant peripherals_num : positive := 2;
  constant controllers_num : positive := 8;
  constant packet_size_c   : integer  := 8;
  constant packet_number_c : integer  := 8;

  component axis_intercon is
    generic (
      controllers_num : positive := 8;
      peripherals_num : positive := 8;
      tdata_byte : positive := 8;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      select_auto     : boolean  := false;
      switch_tlast    : boolean  := false;
      interleaving    : boolean  := false;
      max_tx_size     : positive := 10
    );
    port (
      --general
      rst_i       : in  std_logic;
      clk_i       : in  std_logic;
      --AXIS Master Port
      m_tdata_o  : out std_logic_array(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_array(peripherals_num-1 downto 0)(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic_vector(peripherals_num-1 downto 0);
      m_tvalid_o : out std_logic_vector(peripherals_num-1 downto 0);
      m_tlast_o  : out std_logic_vector(peripherals_num-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  std_logic_array(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(controllers_num-1 downto 0);
      s_tvalid_i : in  std_logic_vector(controllers_num-1 downto 0);
      s_tlast_i  : in  std_logic_vector(controllers_num-1 downto 0)
    );
  end component axis_intercon;

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

  type axi_master_array_t is array (controllers_num-1 downto 0) of axi_stream_master_t;

  impure function new_master_array return axi_master_array_t is
    variable tmp : axi_master_array_t;
  begin
    for j in controllers_num-1 downto 0 loop
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

  shared variable prbs : prbs_t;

 
begin

  clk_i   <= not   clk_i after 5 ns;
  test_runner_watchdog(runner, 200 us);

  main : process
    variable tdata_v : std_logic_vector(8*tdata_byte-1 downto 0);
    variable tdest_v : std_logic_vector(tdest_size-1 downto 0);
    variable tuser_v : std_logic_vector(tuser_size-1 downto 0);
    variable last    : std_logic := '0';
    variable tkeep_v : std_logic_vector(tdata_byte-1 downto 0);
    variable tstrb_v : std_logic_vector(tdata_byte-1 downto 0);
    variable tid_v   : std_logic_vector(0 downto 0);
    variable master_index : integer := 0;
    variable slave_index  : integer := 0;
  begin
    test_runner_setup(runner, runner_cfg);

    rst_i     <= '1';
    wait until rising_edge(clk_i);
    wait until rising_edge(clk_i);
    rst_i     <= '0';

    while test_suite loop
      if run("Free running simulation") then
        info("Will run for " & to_string(run_time_c));
        wait for run_time_c;
        check_passed(result("Free running finished."));

      elsif run("1:1 Master-Slave") then
        info("VCI: Writing data.");
        for i in 0 to packet_number_c*controllers_num-1 loop
          master_index := i mod controllers_num;
          slave_index  := i mod peripherals_num;
          for j in packet_size_c-1 downto 0 loop
            if j = 0 then
              last := '1';
            end if;
            push_axi_stream(net, master_axi_stream(master_index),
              tdata => prbs.get_data(8*tdata_byte),
              tlast => last,
              tdest => std_logic_vector(to_signed(slave_index, tdest_size)),
              tuser => std_logic_vector(to_signed(i, tuser_size))
            );
          end loop;
          last := '0';
        end loop;

        info("VCI: Saving data.");
        for i in 0 to packet_number_c*peripherals_num-1 loop
          master_index := i mod controllers_num;
          slave_index  := i mod peripherals_num;
          for j in packet_size_c-1 downto 0 loop
            pop_axi_stream(net, slave_axi_stream(slave_index),
              tdata => tdata_v,
              tlast => last,
              tkeep => tkeep_v,
              tstrb => tstrb_v,
              tid   => tid_v,
              tdest => tdest_v,
              tuser => tuser_v
            );
            if (j = 0) and (last='0') then
              error("Something went wrong. Last misaligned!");
            end if;
            check_equal(prbs.get_data(tdata_v'length),tdata_v,result("Checking data error") );
            check_equal(to_integer(tdest_v),slave_index,result("Checking counter value, error at " & to_string(j) ) );
            check_equal(to_integer(tuser_v),i,result("Checking counter value, error at " & to_string(j) ) );
          end loop;
        end loop;
        info("VCI: Readout Complete!");

      elsif run("Each Master to All slaves") then

      elsif run("All slaves to one Slave") then

      elsif run("1:1 Master Slave with intermitent read") then

      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;

  stream_slave_gen : for k in 0 to peripherals_num-1 generate

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

  end generate;

  stream_master_gen : for k in 0 to controllers_num-1 generate

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


  dut : axis_intercon
  generic map (
    controllers_num => controllers_num,
    peripherals_num => peripherals_num,
    tdata_byte      => tdata_byte,
    tdest_size      => tdest_size,
    tuser_size      => tuser_size,
    switch_tlast    => true,
    select_auto     => false,
    interleaving    => false,
    max_tx_size     => 10
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


