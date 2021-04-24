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

    use work.can_aximm_pkg.all;

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

  type can_t is (
    idle_st,
    load_header_st,
    arbitration_st,
    load_data_st,
    data_st,
    load_crc_st,
    crc_st,
    crc_delimiter_st,
    ack_slot_st,
    eof_st,
    clear_fifo_st,
    abort_st
  );

  signal can_mq : can_t := idle_st;

  signal frame_sr         : std_logic_vector(0 to 63);
  signal crc_s            : std_logic_vector(14 downto 0);
  signal ack_s            : std_logic;
  signal stuff_disable_s  : std_logic;
  signal stuff_en         : std_logic;
  signal rx_clken_s       : std_logic;

begin

  control_p: process(mclk_i)
    variable retry_cnt : integer := 0;
    variable frame_cnt : integer := 0;
  begin
    if rst_i = '1' then
        can_mq    <= idle_st;
        retry_cnt := 0;
        frame_cnt := 0;
    elsif rising_edge(mclk_i) then
        if rx_clken_s = '1' then
            case can_mq is
                when idle_st =>
                when load_header_st =>
                when arbitration_st =>
                when load_data_st =>
                when data_st =>
                when load_crc_st =>
                when crc_st =>
                when crc_delimiter_st =>
                when ack_slot_st =>
                when eof_st =>
                when clear_fifo_st =>
                when abort_st =>
                when others =>
                    can_mq <= idle_st;

            end case;

        end if;
    end if;
  end process;

  busy_o  <=  '0' when can_mq = idle_st           else
              '1';



  crc_p: process(mclk_i, rst_i)
    variable crc_sr : std_logic_vector(15 downto 1);
  begin
      if rst_i = '1' then
          crc_s  <= (others=>'0');
          crc_sr := (others=>'0');
      elsif rising_edge(mclk_i) then
          rx_crc_error_o <= '0';
          if rx_clken_s = '1' then
              case can_mq is
                  when idle_st =>
                      crc_s <= (others=>'0');
                  when load_header_st =>
                      crc_s <= (others=>'0');
                  when abort_st =>
                      crc_s <= (others=>'0');
                  when clear_fifo_st =>
                      crc_s <= (others=>'0');
                  when crc_delimiter_st =>
                    if crc_s /= crc_sr then
                      rx_crc_error_o <= '1';
                    end if;
                  when crc_st =>
                    crc_sr    := crc_sr sll 1;
                    crc_sr(0) := rxdata_i;
                  when others =>
                    crc15(crc_s,rxdata_i);
              end case;
          end if;
      end if;
  end process;

  stuffing_p: process(mclk_i, rst_i)
      variable stuff_sr  : std_logic_vector(4 downto 0);
  begin
      if rst_i = '1' then
          stuff_en  <= '0';
          stuff_sr  := "11111";
      elsif rising_edge(mclk_i) then
          if rx_clken_i = '1' then
              stuff_sr    := stuff_sr sll 1;
              stuff_sr(0) := rxdata_i;
              if stuff_disable_s = '1' then
                stuff_en <= '0';
              elsif stuff_en = '1' then
                stuff_en <= '0';
              elsif stuff_sr = "00000" then
                stuff_en  <= '1';
              elsif stuff_sr = "11111" then
                stuff_en  <= '1';
              end if;
          end if;
      end if;
  end process stuffing_p;

  --the machine stops during stuffing.
  rx_clken_s <= rx_clken_i when stuff_disable_s = '1'  else
                rx_clken_i when stuff_en = '0'         else
                '0';

end rtl;
