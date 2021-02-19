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
      controllers_num : positive := 2;
      tdata_byte      : positive := 1;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      select_auto     : boolean  := false;
      switch_tlast    : boolean  := false;
      interleaving    : boolean  := false;
      max_tx_size     : positive := 10;
      mode            : integer  := 10
    );
    port (
      --general
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      --AXIS Slave Port
      s_tdata_i  : in  std_logic_array(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(controllers_num-1 downto 0);
      s_tvalid_i : in  std_logic_vector(controllers_num-1 downto 0);
      s_tlast_i  : in  std_logic_vector(controllers_num-1 downto 0);
      --AXIS Master port
      m_tdata_o  : out std_logic_vector(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_vector(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic;
      m_tvalid_o : out std_logic;
      m_tlast_o  : out std_logic
    );
end axis_mux;

architecture behavioral of axis_mux is

  signal tx_count_s : integer;
  signal index_s    : natural range 0 to controllers_num-1;
  signal ack_s      : std_logic_vector(controllers_num-1 downto 0);

  signal axi_tdata_s : std_logic_array(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
  signal axi_tuser_s : std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0);
  signal axi_tdest_s : std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0);
  signal axi_tstrb_s : std_logic_array(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
  signal s_tvalid_s  : std_logic_vector(controllers_num-1 downto 0);

  signal en_i_s       : std_logic_vector(controllers_num-1 downto 0);
  signal en_o_s       : std_logic_vector(controllers_num-1 downto 0);
  signal last_data_en : std_logic_vector(controllers_num-1 downto 0);
  signal timeout_s    : std_logic_vector(15 downto 0) := (others=>'0');

begin

  m_tdata_o  <= s_tdata_i(index_s)  when en_o_s(index_s) = '1' else (others=>'0');
  m_tuser_o  <= s_tuser_i(index_s)  when en_o_s(index_s) = '1' else (others=>'0');
  m_tdest_o  <= s_tdest_i(index_s)  when en_o_s(index_s) = '1' else (others=>'0');
  m_tstrb_o  <= s_tstrb_i(index_s)  when en_o_s(index_s) = '1' else (others=>'0');
  m_tvalid_o <= s_tvalid_i(index_s) when en_o_s(index_s) = '1' else '0';
  m_tlast_o  <= s_tlast_i(index_s)  when en_o_s(index_s) = '1' else '0';

  process(all)
  begin
    if rst_i = '1' then
      tx_count_s <= 0;
      timeout_s  <= (others=>'0');
    elsif rising_edge(clk_i) then
      if ( en_o_s(index_s) and s_tvalid_i(index_s) ) = '1' then
        timeout_s <= x"0001";
      else
        timeout_s <= timeout_s sll 1;
      end if;
    end if;
  end process;

  ready_gen : for j in 0 to controllers_num-1 generate
    s_tready_o(j) <= m_tready_i when en_o_s(j) = '1' else '0';
    en_i_s(j)     <= s_tvalid_i(j);
  end generate;

  schedulling_engine_u : queueing
    generic map (
      n_elements => controllers_num
    )
    port map (
      clk_i     => clk_i,
      rst_i     => rst_i,
      request_i => en_i_s,
      ack_i     => ack_s,
      grant_o   => en_o_s,
      index_o   => index_s
    );

    ack_gen : for j in controllers_num-1 downto 0 generate
      last_data_en(j) <= m_tready_i and s_tready_o(j) and s_tlast_i(j);
      ack_s(j) <= last_data_en(j) when switch_tlast               else
                  '1'             when timeout_s(15) = '1'        else
                  '1'             when tx_count_s = max_tx_size-1 else
                  '1'             when interleaving               else
                  '0';
    end generate;

end behavioral;
