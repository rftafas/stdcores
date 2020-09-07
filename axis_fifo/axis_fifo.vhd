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
-- Simple AXI fifo.
-- It supports:
-- 1) Continuous streaming.
-- 2) Cut through packet mode.
-- 3) Full packet mode.
-- Sync or Async.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_gray.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;
  use stdblocks.axis_lib.all;

entity axis_fifo is
    generic (
      ram_type     :  fifo_t := blockram;
      fifo_size    : integer := 8;
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      packet_mode  : boolean := false;
      tuser_enable : boolean := false;
      tlast_enable : boolean := false;
      tdest_enable : boolean := false;
      sync_mode    : boolean := false;
      cut_through  : boolean := false
    );
    port (
      --general
      clka_i       : in  std_logic;
      rsta_i       : in  std_logic;
      clkb_i       : in  std_logic;
      rstb_i       : in  std_logic;

      s_tdata_i    : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i    : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i    : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o   : out std_logic;
      s_tvalid_i   : in  std_logic;
      s_tlast_i    : in  std_logic;

      m_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i   : in  std_logic;
      m_tvalid_o   : out std_logic;
      m_tlast_o    : out std_logic;

      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
end axis_fifo;

architecture behavioral of axis_fifo is

  constant fifo_param_c : fifo_config_rec := (
    ram_type     => ram_type,
    fifo_size    => fifo_size,
    tdata_size   => tdata_size,
    tdest_size   => tdest_size,
    tuser_size   => tuser_size,
    packet_mode  => packet_mode,
    tuser_enable => tuser_enable,
    tdest_enable => tdest_enable,
    tlast_enable => tlast_enable,
    cut_through  => cut_through,
    sync_mode    => sync_mode
  );

  constant internal_size_c : integer := fifo_size_f(fifo_param_c);

  signal fifo_data_i_s   : std_logic_vector(internal_size_c-1 downto 0);
  signal fifo_data_o_s   : std_logic_vector(internal_size_c-1 downto 0);

  signal enb_i_s         : std_logic;
  signal ena_i_s         : std_logic;
  signal clk_s           : std_logic;
  signal m_tlast_o_s     : std_logic;

  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;

  signal counter_s       : integer := 0;
  signal has_packet_s    : std_logic;
  signal count_up_s      : std_logic;
  signal count_dn_s      : std_logic;

begin

  --input, data to fifo
  fifo_data_i_s     <= fifo_in_f(fifo_param_c,s_tdata_i,s_tuser_i,s_tdest_i,s_tlast_i);

  --output, data FROM fifo.
  m_tdata_o   <= tdata_out_f(fifo_param_c,fifo_data_o_s);
  m_tuser_o   <= tuser_out_f(fifo_param_c,fifo_data_o_s);
  m_tdest_o   <= tdest_out_f(fifo_param_c,fifo_data_o_s);
  m_tlast_o   <= tlast_out_f(fifo_param_c,fifo_data_o_s);

  s_tready_o      <= not fifo_status_a_s.full;
  ena_i_s         <= not fifo_status_a_s.full and s_tvalid_i;

  m_tvalid_o      <= not fifo_status_b_s.empty;
  enb_i_s         <= not fifo_status_b_s.empty and m_tready_i;

  fifo_status_a_o <= fifo_status_a_s;
  fifo_status_b_o <= fifo_status_b_s;

  sync_fifo_gen : if sync_mode generate

    fifo_u : stdfifo1ck
      generic map(
        ram_type  => ram_type,
        fifo_size => fifo_size,
        port_size => internal_size_c
      )
      port map(
        clk_i   => clka_i,
        rst_i   => rsta_i,
        dataa_i  => fifo_data_i_s,
        datab_o  => fifo_data_o_s,
        ena_i    => ena_i_s,
        enb_i    => enb_i_s,

        fifo_status_o => fifo_status_a_s
      );

    clk_s           <= clka_i;
    fifo_status_b_s <= fifo_status_a_s;
    count_up_s      <= s_tlast_i and ena_i_s;

  else generate
    signal count_sync_s : std_logic_vector(1 downto 0);
  begin
    clk_s <= clkb_i;
    fifo_u : stdfifo2ck
      generic map(
        ram_type  => ram_type,
        fifo_size => fifo_size,
        port_size => internal_size_c
      )
      port map(
        --general
        clka_i   => clka_i,
        rsta_i   => rsta_i,
        clkb_i   => clkb_i,
        rstb_i   => rstb_i,
        dataa_i  => fifo_data_i_s,
        datab_o  => fifo_data_o_s,
        ena_i    => ena_i_s,
        enb_i    => enb_i_s,

        fifo_status_a_o => fifo_status_a_s,
        fifo_status_b_o => fifo_status_b_s
      );

    count_sync_s(0) <= s_tlast_i and ena_i_s;

    async_stretch_i : stretch_async
    port map (
      clkin_i  => clka_i,
      clkout_i => clkb_i,
      din      => count_sync_s(0),
      dout     => count_sync_s(1)
    );

    det_up_i : det_up
      port map (
        rst_i  => rstb_i,
        mclk_i => clkb_i,
        din    => count_sync_s(1),
        dout   => count_up_s
      );

  end generate;

  count_dn_s  <= tlast_out_f(fifo_param_c,fifo_data_o_s) and enb_i_s;

  packet_proc : process(clk_s)
  begin
    if rising_edge(clk_s) then
        if count_dn_s = '1' and count_up_s = '0' then
          counter_s <= counter_s - 1;
        elsif count_dn_s = '0' and count_up_s = '1' then
          counter_s <= counter_s + 1;
        end if;
        if counter_s /= 0 then
          has_packet_s <= '1';
        else
          has_packet_s <= '0';
        end if;
    end if;
  end process;


end behavioral;
