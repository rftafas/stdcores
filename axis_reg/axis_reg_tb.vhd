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
library vunit_lib;
	context vunit_lib.vunit_context;
  context vunit_lib.vc_context;

entity axis_reg_tb is
  generic (
    runner_cfg : string;
    tb_path    : string;
    csv_o      : string := "data/out.csv"

	);
end axis_reg_tb;

architecture behavioral of axis_reg_tb is

  component axis_reg
    generic (
      tdata_byte : integer := 8;
      tdest_size : integer := 8;
      tuser_size : integer := 8
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      s_tdata_i  : in  std_logic_vector(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_vector(tdata_byte-1 downto 0);
      s_tready_o : out std_logic;
      s_tvalid_i : in  std_logic;
      s_tlast_i  : in  std_logic;
      m_tdata_o  : out std_logic_vector(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_vector(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic;
      m_tvalid_o : out std_logic;
      m_tlast_o  : out std_logic
    );
  end component axis_reg;

  constant run_time_c : time    := 100 us;
  constant tdata_byte : integer := 8;
  constant tdest_size : integer := 8;
  constant tuser_size : integer := 8;

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
  signal m_tvalid_o : std_logic;
  signal m_tlast_o  : std_logic := '0';

  signal start : boolean := false;
  signal done  : boolean := false;
  signal saved : boolean := false;
  constant cnt_top_c : integer := 8;
  constant m_O : integer_array_t := new_2d(cnt_top_c, 1, 8*tdata_byte, true);
  constant master_axi_stream : axi_stream_master_t := new_axi_stream_master(
    data_length => 8*tdata_byte,
    stall_config => new_stall_config(0.00, 1, 10)
  );
  constant slave_axi_stream  : axi_stream_slave_t  := new_axi_stream_slave(
    data_length => 8*tdata_byte,
    stall_config => new_stall_config(0.00, 1, 10)
  );

begin

  clk_i   <= not   clk_i after 5 ns;

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
        check_true(true, result("Free running finished."));

      elsif run("Counter simulation") then
        info("Init test");
        wait until rising_edge(clk_i);
        start <= true;
        wait until rising_edge(clk_i);
        start <= false;
        wait until (done and saved and rising_edge(clk_i));
        info("Test done");

      end if;
    end loop;

    test_runner_cleanup(runner); -- Simulation ends here
  end process;


  stimuli: process
    variable last : std_logic;
  begin
    wait until start and rising_edge(clk_i);
    done <= false;
    wait until rising_edge(clk_i);
    info("Sending data.");
    for j in cnt_top_c-1 downto 0 loop
      wait until rising_edge(clk_i);
      if j = 0 then
        last := '1';
      end if;
      push_axi_stream(net, master_axi_stream, std_logic_vector(to_signed(j, 8*tdata_byte)) , tlast => last);
    end loop;

    info("Data sent!");
    wait until rising_edge(clk_i);
    done <= true;
  end process;

  save: process
    variable o : std_logic_vector(8*tdata_byte-1 downto 0);
    variable last : std_logic:='0';
  begin
    if rst_i = '1' then
      saved <= false;
    end if;
    wait until start and rising_edge(clk_i);
    wait for 100 ns;

    info("Receiving m_O from UUT...");

    for j in cnt_top_c-1 downto 0 loop
      pop_axi_stream(net, slave_axi_stream, tdata => o, tlast => last);
      if (j = 0) and (last='0') then
        error("Something went wrong. Last misaligned!");
      end if;
    end loop;

    wait until rising_edge(clk_i);

    info("Test Complete!");
    wait until rising_edge(clk_i);
    saved <= true;
  end process;

  vunit_axism: entity vunit_lib.axi_stream_master
    generic map (
      master => master_axi_stream
    )
    port map (
      aclk   => clk_i,
      tvalid => s_tvalid_i,
      tready => s_tready_o,
      tdata  => s_tdata_i,
      tlast  => s_tlast_i
    );

  vunit_axiss: entity vunit_lib.axi_stream_slave
    generic map (
      slave => slave_axi_stream
    )
    port map (
      aclk   => clk_i,
      tvalid => m_tvalid_o,
      tready => m_tready_i,
      tdata  => m_tdata_o,
      tlast  => m_tlast_o
    );


  axis_reg_i : axis_reg
  generic map (
    tdata_byte => tdata_byte,
    tdest_size => tdest_size,
    tuser_size => tuser_size
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
