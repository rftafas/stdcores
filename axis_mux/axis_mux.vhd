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
    use stdblocks.scheduler_lib.all;

entity axis_mux is
    generic (
      number_ports : positive := 2;
      tdata_size   : positive := 8;
      tdest_size   : positive := 8;
      tuser_size   : positive := 8;
      select_auto  : boolean  := false;
      switch_tlast : boolean  := false;
      interleaving : boolean  := false;
      max_tx_size  : positive := 10;
      mode         : integer  := 10
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --AXIS Slave Port
      s_tdata_i  : in  vector_array(number_ports-1 downto 0)(tdata_size-1 downto 0);
      s_tuser_i  : in  vector_array(number_ports-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  vector_array(number_ports-1 downto 0)(tdest_size-1 downto 0);
      s_tready_o : out std_logic_vector(number_ports-1 downto 0);
      s_tvalid_i : in  std_logic_vector(number_ports-1 downto 0);
      s_tlast_i  : in  std_logic_vector(number_ports-1 downto 0)
      --AXIS Master port
      m_tdata_o  : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i : in  std_logic;
      m_tvalid_o : out std_logic;
      m_tlast_o  : out std_logic
    );
end axis_mux;

architecture behavioral of axis_mux is

  signal tx_count_s : integer;
  signal index_s    : natural range 0 to number_ports-1;
  signal ack_s      : std_logic_vector(number_ports-1 downto 0);

  type axi_tdata_array is array (number_ports-1 downto 0) of std_logic_vector(tdata_size-1 downto 0);
  type axi_tuser_array is array (number_ports-1 downto 0) of std_logic_vector(tuser_size-1 downto 0);
  type axi_tdest_array is array (number_ports-1 downto 0) of std_logic_vector(tdest_size-1 downto 0);

  signal axi_tdata_s : axi_tdata_array;
  signal axi_tuser_s : axi_tuser_array;
  signal axi_tdest_s : axi_tdest_array;

  signal s_tvalid_s : std_logic_vector(number_ports-1 downto 0);
  signal  s_tlast_s : std_logic_vector(number_ports-1 downto 0);
  signal s_tready_s : std_logic_vector(number_ports-1 downto 0);

begin

  --output selection
  m_tdata_o  <= s_tdata_i(index_s);
  m_tdest_o  <= s_tdest_i(index_s);
  m_tuser_o  <= s_tuser_i(index_s);
  m_tvalid_o <= s_tvalid_i(index_s);
  m_tlast_o  <= s_tlast_i(index_s);

  process(all)
  begin
    if rst_i = '1' then
      tx_count_s <= 0;
    elsif rising_edge(clk_i) then
      --max size count
      if max_tx_size = 0 then
        tx_count_s <= 1;
      elsif (s_tready_s(index_s) and s_tvalid_i(index_s)) = '1' then
        if ack_s(index_s) = '1' then
          tx_count_s <= 0;
        elsif tx_count_s = max_tx_size-1 then
          tx_count_s <= 0;
        else
          tx_count_s <= tx_count_s + 1;
        end if;
      end if;
    end if;
  end process;

  s0_tready_o   <= s_tready_s(0) and m_tready_i;
  s1_tready_o   <= s_tready_s(1) and m_tready_i;

  priority_engine_i : queueing
    generic map (
      n_elements => number_ports,
      mode       => mode
    )
    port map (
      clk_i     => clk_i,
      rst_i     => rst_i,
      request_i => s_tvalid_s,
      ack_i     => ack_s,
      grant_o   => s_tready_s,
      index_o   => index_s
    );

    ack_gen : for j in number_ports-1 downto 0 generate
      ack_s(j) <= s_tlast_i(j) when switch_tlast               else
                  '1'          when tx_count_s = max_tx_size-1 else
                  '1'          when interleaving               else
                  '0';
    end generate;

end behavioral;
