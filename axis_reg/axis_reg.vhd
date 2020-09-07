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

entity axis_reg is
    generic (
      tdata_size      : integer := 8;
      tdest_size      : integer := 8;
      tuser_size      : integer := 8
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;

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
      m_tlast_o    : out std_logic
    );
end axis_reg;

architecture behavioral of axis_reg is

  type negotiation_control_t is (idle, protection, active);
  signal control_mq : negotiation_control_t;

begin

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      case control_mq is
        when idle =>
          if s_tvalid_i = '1' then
            if m_tready_i = '1' then
              control_mq <= active;
            else
              control_mq <= protection;
            end if;
          end if;

        when protection =>
          if m_tready_i = '1' then
            control_mq <= idle;
          end if;

        when active =>
          if s_tvalid_i = '0' then
            if m_tready_i = '1' then
              control_mq <= active;
            else
              control_mq <= protection;
            end if;
          end if;

        when others =>
          control_mq <= idle;

      end case;
    end if;
  end process;

  s_tready_o <= m_tready_i;

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if control_mq = active then

        m_tvalid_o <= s_tvalid_i;
        m_tdata_o  <= s_tdata_i;
        m_tuser_o  <= s_tuser_i;
        m_tdest_o  <= s_tdest_i;
        m_tlast_o  <= s_tlast_i;
      end if;
    end if;
  end process;

end behavioral;
