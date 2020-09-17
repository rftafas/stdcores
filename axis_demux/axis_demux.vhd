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

entity axis_demux is
    generic (
      number_masters : integer := 2;
      tdata_size     : integer := 8;
      tdest_size     : integer := 8;
      tuser_size     : integer := 8;
      select_auto    : boolean := false;
      switch_tlast   : boolean := false;
      max_tx_size    : integer := 10
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --AXIS Master Port
      m_tdata_o  : out vector_array(number_ports-1 downto 0)(tdata_size-1 downto 0);
      m_tuser_o  : out vector_array(number_ports-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out vector_array(number_ports-1 downto 0)(tdest_size-1 downto 0);
      m_tready_i : in  std_logic_vector(number_ports-1 downto 0);
      m_tvalid_o : out std_logic_vector(number_ports-1 downto 0);
      m_tlast_o  : out std_logic_vector(number_ports-1 downto 0);
      --AXIS Slave Port
      s_tdata_i  : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o : out std_logic;
      s_tvalid_i : in  std_logic;
      s_tlast_i  : in  std_logic
    );
end axis_demux;

architecture behavioral of axis_demux is

begin

  --Master Connections
  out_gen : for j in number_masters-1 downto 0 generate
    m_tdata_o(j) <= s_tdata_i;
    m_tuser_o(j) <= s_tuser_i;
    m_tdest_o(j) <= s_tdest_i;
    m_tlast_o(j)  <= s_tlast_i;
    m_tvalid_o(j) <= s_tvalid_i when to_integer(s_tdest_i) = j else '0';
  end generate;

  s_tready_o <= m_tready_i(to_integer(s_tdest_i));

end behavioral;
