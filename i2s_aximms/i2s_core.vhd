----------------------------------------------------------------------------------
--Copyright 2022 Ricardo F Tafas Jr

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

entity i2s_core is
    port (
        --general
        rst_i           : in std_logic;
        mclk_i          : in std_logic;
        --I2S channel
        bclk_i          : in  std_logic;
        lrclk_i         : in  std_logic;
        i2s_i           : in  std_logic;
        i2s_o           : out std_logic;
        --Internal AXIS BUS
        audio_enable_o  : out std_logic;
        audio_data_o    : out std_logic_vector(63 downto 0);
        audio_data_i    : out std_logic_vector(63 downto 0)
    );
end i2s_core;

architecture behavioral of i2s_core is

    signal sample_en    : std_logic;
    signal send_sr      : std_logic_vector(63 downto 0);
    signal receive_sr   : std_logic_vector(63 downto 0);

    type i2s_t is (sample_st, left_data_st, right_data_st);
    signal i2s_mq : i2s_t;

    signal bclk_up_en_s : std_logic;
    signal bclk_dn_en_s : std_logic;

begin

    det_up_bclk_u : det_up
        port map('0', mclk_i, bclk_i, bclk_up_en_s);

    det_dn_bclk_u : det_down
        port map('0', mclk_i, bclk_i, bclk_dn_en_s);

    fsm_p : process(all)
    begin
        if rising_edge(mclk_i) then
            if bclk_up_en_s = '1' then
                case i2s_mq is
                    when right_data_st =>
                        if lrclk_i = '0' then
                            i2s_mq <= sample_st;
                        end if;

                    when sample_st =>
                        i2s_mq <= left_data_st;

                    when left_data_st =>
                        if lrclk_i = '1' then
                            i2s_mq <= right_data_st;
                        end if;

                    when others =>
                        i2s_mq <= right_data_st;

                end case;
            end if;
        end if;
    end process;

    sample_en <= bclk_dn_en_s when i2s_mq = sample_st else '0';
    audio_enable_o <= sample_en;

    shiftin_p : process(all)
    begin
        if rising_edge(mclk_i) then
            if bclk_up_en_s = '1' then
                send_sr    <= send_sr sll 1;
                send_sr(0) <= i2s_i;
            end if;
        end if;
    end process;
    audio_data_o <= send_sr;

    shiftout_p : process(all)
    begin
        if rising_edge(mclk_i) then
            if sample_en = '1' then
                receive_sr <= audio_data_i;
            elsif bclk_dn_en_s = '1' then
                receive_sr    <= receive_sr sll 1;
                receive_sr(0) <= '0';
            end if;
        end if;
    end process;
    i2s_o <= receive_sr(63);


end behavioral;
