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

entity can_tx is
    port (
        rst_i        : in  std_logic;
        mclk_i       : in  std_logic;
        tx_en_i      : in  std_logic;
        fb_en_i      : in  std_logic;
        --can signals can be bundled in TUSER
        usr_eff_i    : in  std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_id_i     : in  std_logic_vector(29 downto 0); -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_rtr_i    : in  std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_dlc_i    : in  std_logic_vector(3 downto 0);
        usr_rsvd_i   : in  std_logic_vector(1 downto 0);
        data_i       : in  std_logic_vector(63 downto 0);
        data_ready_o : out std_logic;
        data_valid_i : in  std_logic;
        data_last_i  : in  std_logic;
        --status
        rtry_error_o : out std_logic;
        ack_error_o  : out std_logic;
        arb_lost_o   : out std_logic;
        busy_o       : out std_logic;
        --Signals to PHY
        collision_i  : in  std_logic;
        txdata_o     : out std_logic;
        txen_o       : out std_logic
    );
end can_tx;

architecture rtl of can_tx is

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

    signal frame_sr         : std_logic_vector(63 downto 0);
    signal crc_s            : std_logic_vector(14 downto 0);
    signal ack_s            : std_logic;
    signal stuff_disable_s  : std_logic;
    signal stuff_en         : std_logic;
    signal tx_clken_s       : std_logic;

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
            if tx_clken_s = '1' then
                case can_mq is
                    when idle_st =>
                        frame_cnt := 0;
                        if data_valid = '1' then
                            can_mq <= load_header_st;
                        end if;

                    when load_header_st =>
                        if channel_ready_i = '1' then
                            frame_cnt := 0;
                            can_mq <= arbitration_st;
                        end if;

                    when arbitration_st =>
                        if collision = '1' then
                            frame_cnt := 0;
                            can_mq <= abort_st;
                        else
                            frame_cnt := frame_cnt + 1;
                            if usr_eff = '1' and frame_cnt = 19 then
                                if usr_dlc = "0000" then
                                    can_mq <= load_crc_st;
                                else
                                    can_mq <= load_data_st;
                                end if;
                            elsif usr_eff = '0' and frame_cnt = 38 then
                                if usr_dlc = "0000" then
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
                        if frame_cnt = usr_dlc*8 then
                            can_mq <= load_crc_st;
                        end if;

                    when load_crc_st =>
                        frame_cnt := 0;
                        can_mq <= crc_st;

                    when crc_st =>
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 16 then
                            can_mq <= ack_slot_st;
                        end if;

                    when crc_delimiter_st =>
                        frame_cnt := 0;
                        can_mq <= ack_slot_st;

                    when ack_slot_st =>
                        frame_cnt := 0;
                        can_mq <= eof_st;

                    when eof_st =>
                        --this states covers: ACK delimiter (1b), EOF (7b) and IFS (3b)
                        frame_cnt := frame_cnt + 1;
                        if frame_cnt = 11 then
                            if ack = '1' then
                                can_mq <= clear_fifo_st;
                            elsif retry_cnt_v = 7 then
                                can_mq <= clear_fifo_st;
                            else
                                can_mq <= idle_st;
                                retry_cnt_v <= retry_cnt_v + 1;
                            end if;
                        end if;

                    when clear_fifo_st =>
                        retry_cnt_v := 0;
                        frame_cnt   := 0;
                        can_mq      <= idle_st;

                    when abort =>
                        frame_cnt   := 0;
                        retry_cnt_v := retry_cnt_v + 1;
                        if retry_cnt_v = 7 then
                            can_mq <= clear_fifo_st;
                        else
                            can_mq <= load_header_st;
                        end if;

                    when others =>
                        can_mq <= idle_st;

                end case;

            end if;
        end if;
    end process frame_p;

    --we disable the stuffing after the CRC (delimiter is not stuffed)
    stuff_disable_s <=  '1' when can_mq = crc_delimiter_st else
                        '1' when can_mq = ack_slot_st      else
                        '1' when can_mq = eof_st           else
                        '0';

    txen_o  <=  '0' when can_mq = idle_st           else
                '0' when can_mq = clear_fifo_st     else
                '0' when can_mq = abort_st          else
                '0' when can_mq = load_header_st    else
                '1';

    busy_o  <=  '0' when can_mq = idle_st           else
                '1';


    --if we detect a colision during the ACK, it means that someone has
    --acknoledged our frame. We won't retransmitt it.
    ack_p : process(all)
    begin
        if rst = '1' then
            ack_s       <= '0';
            ack_error_o <= '0';
        elsif rising_edge(mclk_i) then
            if tx_clken_s = '1' then
                if can_mq = ack_slot_st then
                    if collision_i = '1' then
                        ack_s <= '1';
                    else
                        ack_error_o <= '1';
                    end if;
                elsif can_mq = idle_st then
                    ack_s       <= '0';
                    ack_error_o <= '0';
                end if;
            end if;
        end if;
    end process;


    frame_shift_p: process(mclk_i, rst_i)
    begin
        if rst_i = '1' then
        elsif rising_edge(mclk_i) then
            if tx_en_s = '1' then
                case can_mq is
                    when load_header_st =>
                        frame_sr    <= (others=>'1');
                        frame_sr(0) <= '0';                                            --SOF
                        if usr_eff_i = '1' then                                        --29 bit ID
                            frame_sr(1 to 12)  <= usr_id_i(28 downto 18);              --ID_A
                            frame_sr(13)       <= '0';                                 --SRR
                            frame_sr(14)       <= '1';                                 --IDE
                            frame_sr(15 to 32) <= usr_id_i(17 downto 0);               --ID_B
                            frame_sr(33 to 34) <= reserved_i;                          --R1 & R0
                            frame_sr(35 to 38) <= usr_dlc_i;                           --DLC
                        else                                                            --11 bit ID
                            frame_sr(1 to 12)  <= usr_id_i(11 downto 0);               --ID_A
                            frame_sr(13)       <= usr_rtr_i;                           --RTR
                            frame_sr(14)       <= '0';                                 --IDE
                            frame_sr(15)       <= reserved_i(0);                       --R0
                            frame_sr(16 to 19) <= usr_dlc_i;                           --DLC
                        end if;

                    when load_data_st =>
                        frame_sr                     <= (others=>'1');
                        frame_sr(0 to 8*usr_dlc_i-1) <= data_i(8*usr_dlc_i-1 downto 0);

                    when load_crc_st =>
                        frame_sr          <= (others=>'1');
                        frame_sr(0 to 14) <= crc_s;

                    when others =>
                        frame_sr     <= frame_sr sll 1;
                        frame_sr(63) <= '1';

                end case;
            end if;
        end if;
    end process frame_shift_p;

    crc_p: process(mclk_i, rst_i)
    begin
        if rst_i = '1' then
            crc_s <= (others=>'0');
        elsif rising_edge(mclk_i) then
            if tx_en_s = '1' then
                case can_mq is
                    when idle_st =>
                        crc_s <= (others=>'0');
                    when load_header_st =>
                        crc_s <= (others=>'0');
                    when abort_st =>
                        crc_s <= (others=>'0');
                    when clear_fifo_st =>
                        crc_s <= (others=>'0');
                    when others =>
                        crc15(crc_s,frame_sr(63));
                end case;
            end if;
        end if;
    end process;

    stuffing_p: process(mclk_i, rst_i)
        variable stuff_sr : std_logic_vector(4 downto 0)
    begin
        if rst_i = '1' then
            txdata_o <= '0';
            stuff_en <= '0';
            stuff_sr <= "11111"
        elsif rising_edge(mclk_i) then
            if tx_clken_i = '1' then
                stuff_sr    := stuff_sr sll 1;
                stuff_sr(0) := txdata_o;
                if stuff_disable_s = '1' then
                    txdata_o <= frame_sr(63);
                    stuff_en <= '0';
                elsif stuff_en = '1' then
                    txdata_o <= stuff_bit;
                    stuff_en <= '0';
                else
                    txdata_o      <= frame_sr(63);
                    if stuff_sr = "00000" then
                        stuff_en  <= '1'
                        stuff_bit := '1';
                    elsif stuff_sr = "11111" then
                        stuff_en  <= '1'
                        stuff_bit := '0';
                    end if;
                end if;
            end if;
        end if;
    end process stuffing_p;

    --the machine stops during stuffing.
    tx_clken_s <=  tx_clken_i when stuff_disable_s = '1'  else
                   tx_clken_i when stuff_en = '0'         else
                   '0';

end rtl;
