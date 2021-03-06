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
  use stdblocks.sync_lib.all;

entity axis_aligner is
    generic (
      number_ports    : positive := 2;
      tdata_byte      : positive := 8;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      switch_on_tlast : boolean  := false
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
end axis_aligner;

architecture behavioral of axis_aligner is

  signal en_i_s     : std_logic_vector(number_ports-1 downto 0);
  signal en_o_s     : std_logic_vector(number_ports-1 downto 0);
  signal s_tready_s : std_logic_vector(number_ports-1 downto 0);
  signal m_tready_s : std_logic_vector(number_ports-1 downto 0);
  signal ready_s    : std_logic_vector(number_ports-1 downto 0);

begin

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

  ready_gen : for j in number_ports-1 downto 0 generate

    trigger_gen : if switch_on_tlast generate
      trigger_p: process(all)
        variable lock : boolean := false;
      begin   
        if rst_i = '1' then
          en_i_s(j) <= '0';
        elsif rising_edge(clk_i) then
          if s_tvalid_i(j) = '1' and s_tready_o(j) = '1' and s_tlast_i(j) = '1' then
            en_i_s(j) <= '0';
          elsif s_tvalid_i(j) = '1' then
            en_i_s(j) <= '1';
          end if;
        end if;
      end process trigger_p;
    else generate
      en_i_s(j) <= s_tvalid_i(j);
    end generate;

    m_tdata_o(j)  <= s_tdata_i(j)  when en_o_s(j) = '1' else (others=>'0');
    m_tuser_o(j)  <= s_tuser_i(j)  when en_o_s(j) = '1' else (others=>'0');
    m_tdest_o(j)  <= s_tdest_i(j)  when en_o_s(j) = '1' else (others=>'0');
    m_tstrb_o(j)  <= s_tstrb_i(j)  when en_o_s(j) = '1' else (others=>'0');
    s_tready_o(j) <= m_tready_i(j) when en_o_s(j) = '1' else '0';
    m_tvalid_o(j) <= s_tvalid_i(j) when en_o_s(j) = '1' else '0';
    m_tlast_o(j)  <= s_tlast_i(j)  when en_o_s(j) = '1' else '0';

  end generate;


end behavioral;
