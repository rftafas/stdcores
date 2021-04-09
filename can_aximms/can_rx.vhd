----------------------------------------------------------------------------------
--Copyright 2021 Ricardo F Tafas Jr

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

entity can_rx is
    port (
        rst_i          : in  std_logic;
        mclk_i         : in  std_logic;
        rx_clken_i     : in  std_logic;
        fb_clken_i     : in  std_logic;
        --can signals can be bundled in TUSER
        usr_eff_o      : out std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_id_o       : out std_logic_vector(28 downto 0); -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_rtr_o      : out std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_dlc_o      : out std_logic_vector(3 downto 0);
        usr_rsvd_o     : out std_logic_vector(1 downto 0);
        data_o         : out std_logic_vector(63 downto 0);
        data_ready_i   : in  std_logic;
        data_valid_o   : out std_logic;
        data_last_o    : out std_logic;
        --status
        reg_id_i       : in  std_logic_vector(28 downto 0);
        reg_id_mask_i  : in  std_logic_vector(28 downto 0);
        busy_o         : out std_logic;
        rx_crc_error_o : out std_logic;
        --Signals to PHY
        collision_i    : in  std_logic;
        rxdata_i       : out std_logic
    );
end can_rx;

architecture rtl of can_rx is


begin

end rtl;
