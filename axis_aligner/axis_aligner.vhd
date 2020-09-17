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
library stdblocks;
  use std_blocks.sync_lib.all;

entity axis_aligner is
    generic (
      number_ports   : positive := 2;
      tdata_size     : positive := 8;
      tdest_size     : positive := 8;
      tuser_size     : positive := 8
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
        --AXIS Master Port
      m_tdata_o  : out vector_array(number_ports-1 downto 0)(tdata_size-1 downto 0);
      m_tuser_o  : out vector_array(number_ports-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out vector_array(number_ports-1 downto 0)(tdest_size-1 downto 0);
      m_tready_i : in  std_logic_vector(number_ports-1 downto 0);
      m_tvalid_o : out std_logic_vector(number_ports-1 downto 0);
      m_tlast_o  : out std_logic_vector(number_ports-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  vector_array(number_ports-1 downto 0)(tdata_size-1 downto 0);
      s_tuser_i  : in  vector_array(number_ports-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  vector_array(number_ports-1 downto 0)(tdest_size-1 downto 0);
      s_tready_o : out std_logic_vector(number_ports-1 downto 0);
      s_tvalid_i : in  std_logic_vector(number_ports-1 downto 0);
      s_tlast_i  : in  std_logic_vector(number_ports-1 downto 0)
    );
end axis_aligner;

architecture behavioral of axis_aligner is

  signal en_i_s     : std_logic_vector(number_ports-1 downto 0);
  signal en_o_s     : std_logic_vector(number_ports-1 downto 0);
  signal s_tready_s : std_logic_vector(number_ports-1 downto 0);
  signal m_tready_s : std_logic_vector(number_ports-1 downto 0);
  signal ready_s    : std_logic_vector(number_ports-1 downto 0);

begin

  --Master Connections
  m_tvalid_o <= s_tvalid_i;
  m_tlast_o  <= s_tlast_i;
  m_tdata_o  <= s_tdata_i;
  m_tuser_o  <= s_tuser_i;
  m_tdest_o  <= s_tdest_i;

  m_tready_s <= m_tready_i;
  s_tready_o  <= s_tready_s

  ready_gen : for j in number_ports-1 downto 0 generate

    pulse_align_i : pulse_align
    generic map (
      port_size => number_ports
    )
    port map (
      rst_i  => rst_i,
      mclk_i => clk_i,
      en_i   => en_i_s,
      en_o   => en_o_s
    );

    en_i_s(j)     <= s_tvalid_s(j) and ready_s(j);
    s_tready_s(j) <= en_o_s(j);
    m_tvalid_s(j) <= en_o_s(j);

    det_down_i : det_down
      port map (
        mclk_i => clk_i,
        rst_i  => rst_i,
        din    => m_tready_s,
        dout   => ready_s
      );

  end generate;


end behavioral;
