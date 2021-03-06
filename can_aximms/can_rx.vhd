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
        usr_eff_o      : out std_logic;
        usr_id_o       : out std_logic_vector(28 downto 0);
        usr_rtr_o      : out std_logic;
        usr_dlc_o      : out std_logic_vector(3 downto 0);
        usr_rsvd_o     : out std_logic_vector(1 downto 0);
        data_o         : out std_logic_vector(63 downto 0);
        data_ready_i   : in  std_logic;
        data_valid_o   : out std_logic;
        data_last_o    : out std_logic;
        --status
        reg_id_i       : in  std_logic_vector(28 downto 0);
        reg_id_mask_i  : in  std_logic_vector(28 downto 0);
        promiscuous_i  : in  std_logic;
        busy_o         : out std_logic;
        rx_crc_error_o : out std_logic;
        send_ack_o     : out std_logic;
        --Signals to PHY
        ch_ready_i     : in std_logic;
        collision_i    : in std_logic;
        rxdata_i       : in std_logic
    );
end can_rx;

architecture rtl of can_rx is

    type can_t is (
        idle_st,
        header_st,
        save_header_st,
        extended_header_st,
        save_extended_header_st,
        get_data_st,
        save_data_st,
        get_crc_st,
        save_crc_st,
        crc_delimiter_st,
        ack_slot_st,
        no_ack_slot_st,
        eof_st,
        save_st,
        abort_st
    );

    signal can_mq : can_t := idle_st;

    signal frame_sr        : std_logic_vector(63 downto 0);
    signal crc_s           : std_logic_vector(14 downto 0);
    signal crc_sr          : std_logic_vector(14 downto 0);
    signal stuff_disable_s : std_logic;
    signal stuff_en        : std_logic;
    signal rx_clken_s      : std_logic;
    signal address_ok_s    : std_logic;
    signal crc_ok_s        : std_logic;

begin

    control_p : process (mclk_i)
        variable frame_cnt : integer   := 0;
        variable ide_v     : std_logic := '0';
    begin
        if rst_i = '1' then
            can_mq <= idle_st;
            ide_v     := '0';
            frame_cnt := 0;
        elsif rising_edge(mclk_i) then
            if rx_clken_s = '1' then
                case can_mq is
                    when idle_st =>
                        if rxdata_i = '0' then
                            frame_cnt := 0;
                            ide_v     := '0';
                            can_mq <= header_st;
                        end if;

                    when header_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 18 then
                            if frame_sr(4) = '0' then
                                can_mq <= save_header_st;
                            else
                                can_mq <= extended_header_st;
                            end if;
                        end if;

                    when save_header_st =>
                        frame_cnt := 0;
                        if frame_sr(3 downto 0) = "0000" then
                            can_mq <= get_crc_st;
                        else
                            can_mq <= get_data_st;
                        end if;

                    when extended_header_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 38 then
                            can_mq <= save_extended_header_st;
                        end if;

                    when save_extended_header_st =>
                        frame_cnt := 0;
                        if frame_sr(3 downto 0) = "0000" then
                            can_mq <= get_crc_st;
                        else
                            can_mq <= get_data_st;
                        end if;

                    when get_data_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 63 then
                            can_mq <= save_data_st;
                        elsif frame_cnt = (usr_dlc_o * 8 - 1) then
                            can_mq <= save_data_st;
                        end if;

                    when save_data_st =>
                        frame_cnt := 0;
                        can_mq <= get_crc_st;

                    when get_crc_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 14 then
                            can_mq <= crc_delimiter_st;
                        end if;

                    --when save_crc_st =>
                    --    frame_cnt := 0;
                    --    can_mq <= crc_delimiter_st;

                    when crc_delimiter_st =>
                        frame_cnt := 0;
                        if address_ok_s = '1' and crc_ok_s = '1' and data_ready_i = '1' then
                            can_mq <= ack_slot_st;
                        else
                            can_mq <= no_ack_slot_st;
                        end if;

                    when ack_slot_st =>
                        frame_cnt := 0;
                        can_mq <= eof_st;

                    when no_ack_slot_st =>
                        frame_cnt := 0;
                        can_mq <= eof_st;

                    when eof_st =>
                        frame_cnt := 0;
                        if ch_ready_i = '1' then
                            can_mq <= idle_st;
                        end if;


                    when others        =>
                        frame_cnt := 0;
                        can_mq <= idle_st;

                end case;

            end if;
        end if;
    end process;

    --we disable the stuffing after the CRC (delimiter is not stuffed)
    stuff_disable_s <=  '1' when can_mq = crc_delimiter_st else
                        '1' when can_mq = eof_st           else
                        '1' when can_mq = ack_slot_st      else
                        '1' when can_mq = no_ack_slot_st   else
                        '1' when can_mq = idle_st          else
                        '0';

    send_ack_o      <=  '1' when can_mq = ack_slot_st      else
                        '0';

    busy_o          <=  '0' when can_mq = idle_st          else
                        '1';

    data_valid_o    <=  '1' when can_mq = ack_slot_st      else
                        '0';

    frame_shift_p : process (mclk_i, rst_i)
        variable rx_id_v : std_logic_vector(28 downto 0);
    begin
        if rst_i = '1' then
            frame_sr       <= (others => '0');
            usr_eff_o      <= '0';
            usr_rtr_o      <= '0';
            rx_id_v        := (others => '0');
            usr_rsvd_o     <= (others => '0');
            usr_dlc_o      <= (others => '0');
            usr_id_o       <= (others => '0');
            crc_s          <= (others => '0');
            address_ok_s   <= '0';
            rx_crc_error_o <= '0';
            data_o         <= (others => '0');

        elsif rising_edge(mclk_i) then
            if rx_clken_s = '1' then
                case can_mq is
                    when idle_st =>
                        rx_crc_error_o <= '0';
                        --usr_eff_o    <= '0';
                        --usr_rtr_o    <= '0';
                        --rx_id_v      := (others => '0');
                        --usr_rsvd_o   <= (others => '0');
                        --usr_dlc_o    <= (others => '0');
                        --usr_id_o     <= (others => '0');
                        crc_s          <= (others => '0');
                        address_ok_s   <= '0';
                        frame_sr       <= frame_sr sll 1;
                        frame_sr(0)    <= rxdata_i;

                    when header_st =>
                        frame_sr    <= frame_sr sll 1;
                        frame_sr(0) <= rxdata_i;

                    when save_header_st =>
                        rx_id_v               := (others=>'0');
                        rx_id_v(11 downto 0)  := frame_sr(18 downto 7); --ID_A
                        usr_rtr_o             <= frame_sr(6);           --RTR
                        usr_eff_o             <= '0';                   --IDE
                        usr_rsvd_o(0)         <= frame_sr(4);           --R0
                        usr_dlc_o             <= frame_sr(3 downto 0);  --DLC
                        usr_id_o              <= rx_id_v;
                        if promiscuous_i = '1' then
                            address_ok_s <= '1';
                        elsif ((rx_id_v and reg_id_mask_i) = (reg_id_i and reg_id_mask_i)) then
                            address_ok_s <= '1';
                        else
                            address_ok_s <= '0';
                        end if;
                        frame_sr    <= (others=>'0');
                        frame_sr(0) <= rxdata_i;

                    when extended_header_st =>
                        frame_sr    <= frame_sr sll 1;
                        frame_sr(0) <= rxdata_i;


                    when save_extended_header_st =>
                        rx_id_v               := (others=>'0');
                        rx_id_v(28 downto 18) := frame_sr(37 downto 27); --ID_A
                        --usr_srr_o            <= frame_sr(26);          --SRR
                        usr_eff_o             <= frame_sr(25);           --IDE
                        rx_id_v(17 downto 0)  := frame_sr(24 downto 7);  --ID_B
                        usr_rtr_o             <= frame_sr(6);            --RTR
                        usr_rsvd_o            <= frame_sr(5 downto 4);   --R1 & R0
                        usr_dlc_o             <= frame_sr(3 downto 0);   --DLC
                        usr_id_o              <= rx_id_v;
                        if ((rx_id_v and reg_id_mask_i) = (reg_id_i and reg_id_mask_i)) then
                            address_ok_s <= '1';
                        else
                            address_ok_s <= '0';
                        end if;
                        frame_sr    <= (others=>'0');
                        frame_sr(0) <= rxdata_i;

                    when get_data_st =>
                        frame_sr    <= frame_sr sll 1;
                        frame_sr(0) <= rxdata_i;

                    when save_data_st =>
                        data_o <= frame_sr;
                        frame_sr    <= (others=>'0');
                        frame_sr(0) <= rxdata_i;

                    when get_crc_st =>
                        frame_sr    <= frame_sr sll 1;
                        frame_sr(0) <= rxdata_i;
                        crc_s       <= frame_sr(13 downto 0) & rxdata_i;

                    when crc_delimiter_st =>
                        rx_crc_error_o <= not crc_ok_s;
                        crc_s          <= frame_sr(14 downto 0);
                        frame_sr       <= (others=>'0');
                        frame_sr(0)    <= rxdata_i;

                    when ack_slot_st =>
                        rx_crc_error_o <= '0';
                        frame_sr    <= (others=>'0');

                    when no_ack_slot_st =>
                        frame_sr    <= (others=>'0');

                    when others =>
                        -- usr_eff_o    <= '0';
                        -- usr_rtr_o    <= '0';
                        -- rx_id_v      := (others => '0');
                        -- usr_rsvd_o   <= (others => '0');
                        -- usr_dlc_o    <= (others => '0');
                        -- usr_id_o     <= (others => '0');
                        crc_s        <= (others => '0');
                        address_ok_s <= '0';
                        frame_sr    <= (others=>'0');

                end case;

            end if;
        end if;
    end process frame_shift_p;


    crc_p : process (mclk_i, rst_i)
        variable can_sr_v : std_logic_vector(14 downto 0);
    begin
        if rst_i = '1' then
            can_sr_v := (others => '0');
            crc_sr   <= (others => '0');
        elsif rising_edge(mclk_i) then
            if rx_clken_s = '1' then
                case can_mq is
                    when header_st =>
                        crc_sr <= can_sr_v;
                        crc15(can_sr_v, rxdata_i);

                    when save_header_st =>
                        crc_sr <= can_sr_v;
                        crc15(can_sr_v, rxdata_i);

                    when extended_header_st =>
                        crc_sr <= can_sr_v;
                        crc15(can_sr_v, rxdata_i);

                    when save_extended_header_st =>
                        crc_sr <= can_sr_v;
                        crc15(can_sr_v, rxdata_i);

                    when get_data_st =>
                        crc_sr <= can_sr_v;
                        crc15(can_sr_v, rxdata_i);

                    when save_data_st =>
                        crc_sr <= can_sr_v;
                        crc15(can_sr_v, rxdata_i);

                    when get_crc_st =>
                        null;

                    when save_crc_st =>


                    when crc_delimiter_st =>
                        null;

                    when others =>
                        can_sr_v := (others => '0');

                end case;
            end if;
        end if;
    end process;

    crc_ok_s <= '1' when crc_s = crc_sr else '0';

    stuffing_p : process (mclk_i, rst_i)
        variable stuff_sr : std_logic_vector(4 downto 0);
    begin
        if rst_i = '1' then
            stuff_en <= '0';
            stuff_sr := "11111";
        elsif rising_edge(mclk_i) then
            if rx_clken_i = '1' then
                stuff_sr    := stuff_sr sll 1;
                stuff_sr(0) := rxdata_i;
                if stuff_disable_s = '1' then
                    stuff_en <= '0';
                elsif stuff_en = '1' then
                    stuff_en <= '0';
                elsif stuff_sr = "00000" then
                    stuff_en <= '1';
                elsif stuff_sr = "11111" then
                    stuff_en <= '1';
                end if;
            end if;
        end if;
    end process stuffing_p;

    --the machine stops during stuffing.
    rx_clken_s <=   rx_clken_i when stuff_disable_s = '1'   else
                    rx_clken_i when stuff_en = '0'          else
                    '0';

end rtl;
