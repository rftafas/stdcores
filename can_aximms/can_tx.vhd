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

entity can_tx is
    port (
        rst_i      : in std_logic;
        mclk_i     : in std_logic;
        tx_clken_i : in std_logic;
        fb_clken_i : in std_logic;
        --can signals can be bundled in TUSER
        usr_eff_i    : in std_logic;
        usr_id_i     : in std_logic_vector(28 downto 0);
        usr_rtr_i    : in std_logic;
        usr_dlc_i    : in std_logic_vector(3 downto 0);
        usr_rsvd_i   : in std_logic_vector(1 downto 0);
        data_i       : in std_logic_vector(63 downto 0);
        data_ready_o : out std_logic;
        data_valid_i : in std_logic;
        data_last_i  : in std_logic;
        --status
        rtry_error_o : out std_logic;
        ack_error_o  : out std_logic;
        arb_lost_o   : out std_logic;
        busy_o       : out std_logic;
        --Signals to PHY
        ch_ready_i  : in std_logic;
        collision_i : in std_logic;
        rxdata_i    : in std_logic;
        txdata_o    : out std_logic;
        txen_o      : out std_logic
    );
end can_tx;

architecture rtl of can_tx is

    type can_t is (
        idle_st,
        wait_ready_st,
        load_header_st,
        arbitration_st,
        load_data_st,
        data_st,
        load_crc_st,
        crc_st,
        crc_delimiter_st,
        ack_slot_st,
        ack_delimiter_st,
        eof_st,
        clear_fifo_st,
        retry_error_st,
        abort_st
    );

    signal can_mq : can_t := idle_st;

    signal frame_sr : std_logic_vector(0 to 63);
    --signal crc_sr           : std_logic_vector(14 downto 0);
    signal ack_s           : std_logic;
    signal stuff_disable_s : std_logic;
    signal stuff_en        : std_logic;
    signal tx_clken_s      : std_logic;
    signal start_s         : std_logic;
    signal stuff_bit_s     : std_logic;

begin

    pulse_error_u : stretch_sync
    port map(
        rst_i  => rst_i,
        mclk_i => mclk_i,
        da_i   => tx_clken_s,
        db_i   => data_valid_i,
        dout_o => start_s
    );

    control_p : process (rst_i, mclk_i)
        variable retry_cnt : integer := 0;
        variable frame_cnt : integer := 0;
    begin
        if rst_i = '1' then
            can_mq <= idle_st;
            retry_cnt := 0;
            frame_cnt := 0;
        elsif rising_edge(mclk_i) then
            if tx_clken_s = '1' then
                case can_mq is
                    when idle_st =>
                        frame_cnt := 0;
                        if start_s = '1' then
                            can_mq <= wait_ready_st;
                        end if;

                    when wait_ready_st =>
                        frame_cnt := 0;
                        if ch_ready_i = '1' then
                            can_mq <= load_header_st;
                        end if;

                    when load_header_st =>
                        frame_cnt := 0;
                        can_mq <= arbitration_st;

                    when arbitration_st =>
                        if collision_i = '1' then
                            frame_cnt := 0;
                            can_mq <= abort_st;
                        else
                            frame_cnt := frame_cnt + 1;
                            if usr_eff_i = '0' and frame_cnt = 18 then
                                if usr_dlc_i = "0000" then
                                    can_mq <= load_crc_st;
                                else
                                    can_mq <= load_data_st;
                                end if;
                            elsif usr_eff_i = '1' and frame_cnt = 39 then
                                if usr_dlc_i = "0000" then
                                    can_mq <= load_crc_st;
                                else
                                    can_mq <= load_data_st;
                                end if;
                            end if;
                        end if;

                    when load_data_st =>
                        frame_cnt := 0;
                        can_mq <= data_st;

                    when data_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 63 then
                            can_mq <= load_crc_st;
                        elsif frame_cnt = usr_dlc_i * 8 - 1 then
                            can_mq <= load_crc_st;
                        end if;

                    when load_crc_st =>
                        frame_cnt := 0;
                        can_mq <= crc_st;

                    when crc_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 15 then
                            can_mq <= crc_delimiter_st;
                        end if;

                    when crc_delimiter_st =>
                        frame_cnt := 0;
                        can_mq <= ack_slot_st;

                    when ack_slot_st =>
                        frame_cnt := 0;
                        can_mq <= ack_delimiter_st;

                    when ack_delimiter_st =>
                        frame_cnt := 0;
                        can_mq <= eof_st;

                    when eof_st =>
                        --this states covers: EOF (7b) and IFS (3b)
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 10 then
                            if ack_s = '1' then
                                can_mq <= clear_fifo_st;
                            elsif retry_cnt = 7 then
                                can_mq <= retry_error_st;
                            else
                                can_mq <= abort_st;
                            end if;
                        end if;

                    when retry_error_st =>
                        retry_cnt := 0;
                        frame_cnt := 0;
                        can_mq <= idle_st;

                    when clear_fifo_st =>
                        retry_cnt := 0;
                        frame_cnt := 0;
                        can_mq <= idle_st;

                    when abort_st =>
                        frame_cnt := 0;
                        retry_cnt := retry_cnt + 1;
                        if retry_cnt = 7 then
                            can_mq <= clear_fifo_st;
                        else
                            can_mq <= wait_ready_st;
                        end if;

                    when others =>
                        can_mq <= idle_st;

                end case;

            end if;
        end if;
    end process;

    frame_shift_p : process (mclk_i, rst_i)
        variable crc_sr : std_logic_vector(14 downto 0);
    begin
        if rst_i = '1' then
            ack_s           <= '0';
            ack_error_o     <= '0';
            stuff_disable_s <= '1';
            arb_lost_o      <= '0';
            txen_o          <= '0';
            busy_o          <= '0';
            rtry_error_o    <= '0';
            crc_sr   := (others => '0');
            frame_sr <= (others => '1');
        elsif rising_edge(mclk_i) then
            if tx_clken_s = '1' then
                case can_mq is
                    when wait_ready_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '1';
                        arb_lost_o      <= '0';
                        txen_o          <= '0';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr   := (others => '0');
                        frame_sr <= (others => '1');

                    when load_header_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr      := (others => '0');
                        frame_sr    <= (others => '1');
                        frame_sr(0) <= '0';                               --SOF

                        if usr_eff_i = '1' then                           --29 bit ID
                            frame_sr(1 to 11)  <= usr_id_i(28 downto 18); --ID_A
                            frame_sr(12)       <= '0';                    --SRR
                            frame_sr(13)       <= '1';                    --IDE
                            frame_sr(14 to 31) <= usr_id_i(17 downto 0);  --ID_B
                            frame_sr(32)       <= usr_rtr_i;              --RTR
                            frame_sr(33 to 34) <= usr_rsvd_i;             --R1 & R0
                            frame_sr(35 to 38) <= usr_dlc_i;              --DLC

                        else                                              --11 bit ID
                            frame_sr(1 to 11)  <= usr_id_i(10 downto 0);  --ID_A
                            frame_sr(12)       <= usr_rtr_i;              --RTR
                            frame_sr(13)       <= '0';                    --IDE
                            frame_sr(14)       <= usr_rsvd_i(0);          --R0
                            frame_sr(15 to 18) <= usr_dlc_i;              --DLC
                        end if;

                    when arbitration_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc15(crc_sr, frame_sr(0));
                        frame_sr     <= frame_sr sll 1;
                        frame_sr(63) <= '1';

                    when load_data_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc15(crc_sr, frame_sr(0));
                        frame_sr                         <= (others => '1');
                        frame_sr(0 to 8 * usr_dlc_i - 1) <= data_i(8 * usr_dlc_i - 1 downto 0);

                    when data_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc15(crc_sr, frame_sr(0));
                        frame_sr     <= frame_sr sll 1;
                        frame_sr(63) <= '1';

                    when load_crc_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc15(crc_sr, frame_sr(0));
                        frame_sr          <= (others => '1');
                        frame_sr(0 to 14) <= crc_sr;

                    when crc_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr := crc_sr;
                        frame_sr     <= frame_sr sll 1;
                        frame_sr(63) <= '1';

                    when crc_delimiter_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '1';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr       := (others => '0');
                        frame_sr     <= (others => '1');

                    when ack_slot_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '1';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr       := (others => '0');
                        frame_sr     <= (others => '1');

                    when ack_delimiter_st =>
                        ack_s           <= not rxdata_i;
                        ack_error_o     <= rxdata_i;
                        stuff_disable_s <= '1';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr       := (others => '0');
                        frame_sr     <= (others => '1');

                    when eof_st =>
                        --ack_s           <= '1';
                        --ack_error_o     <= '0';
                        stuff_disable_s <= '1';
                        arb_lost_o      <= '0';
                        txen_o          <= '1';
                        busy_o          <= '1';
                        rtry_error_o    <= '0';
                        crc_sr   := (others => '0');
                        frame_sr <= (others => '1');

                    when retry_error_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '0';
                        busy_o          <= '0';
                        rtry_error_o    <= '1';
                        crc_sr   := (others => '0');
                        frame_sr <= (others => '1');

                    when clear_fifo_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '0';
                        txen_o          <= '0';
                        busy_o          <= '0';
                        rtry_error_o    <= '0';
                        crc_sr   := (others => '0');
                        frame_sr <= (others => '1');

                    when abort_st =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '0';
                        arb_lost_o      <= '1';
                        txen_o          <= '0';
                        busy_o          <= '0';
                        rtry_error_o    <= '0';
                        crc_sr   := (others => '0');
                        frame_sr <= (others => '1');

                    when others =>
                        ack_s           <= '0';
                        ack_error_o     <= '0';
                        stuff_disable_s <= '1';
                        arb_lost_o      <= '0';
                        txen_o          <= '0';
                        busy_o          <= '0';
                        rtry_error_o    <= '0';
                        crc_sr   := (others => '0');
                        frame_sr <= (others => '1');

                end case;
            end if;
        end if;
    end process frame_shift_p;

    stuffing_p : process (mclk_i, rst_i)
        variable stuff_sr : std_logic_vector(4 downto 0);
    begin
        if rst_i = '1' then
            stuff_en    <= '0';
            stuff_bit_s <= '0';
            stuff_sr := "00001";
        elsif rising_edge(mclk_i) then
            if tx_clken_i = '1' then
                if stuff_disable_s = '1' then
                    stuff_sr    := (others => '0');
                    stuff_sr(0) := '1';
                    stuff_en <= '0';
                elsif stuff_en = '1' then
                    stuff_sr(0) := stuff_bit_s;
                    stuff_en <= '0';
                else
                    stuff_sr    := stuff_sr sll 1;
                    stuff_sr(0) := txdata_o;
                    if stuff_sr = "00000" then
                        stuff_en    <= '1';
                        stuff_bit_s <= '1';
                    elsif stuff_sr = "11111" then
                        stuff_en    <= '1';
                        stuff_bit_s <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process stuffing_p;

    txdata_o <= stuff_bit_s when stuff_en = '1' else
                frame_sr(0);

    --the machine stops during stuffing.
    tx_clken_s <= tx_clken_i when stuff_disable_s = '1' else
                  tx_clken_i when stuff_en = '0' else
                  '0';

end rtl;
