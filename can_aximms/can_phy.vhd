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
use ieee.math_real.all;
library expert;
use expert.std_logic_expert.all;
library stdblocks;
use stdblocks.sync_lib.all;

entity can_phy is
    generic (
        internal_phy : boolean := false
    );
    port (
        rst_i  : in std_logic;
        mclk_i : in std_logic;
        --configs
        force_error_i   : in std_logic;
        lock_dominant_i : in std_logic;
        loopback_i      : in std_logic;
        --stats
        stuff_violation_o : out std_logic;
        collision_o       : out std_logic;
        channel_ready_o   : out std_logic;
        --commands
        send_ack_i : in  std_logic;
        read_ack_o : out std_logic;
        -- data channel;
        tx_clken_i : in  std_logic;
        rx_clken_i : in  std_logic;
        fb_clken_i : in  std_logic;
        tx_i       : in  std_logic;
        tx_en_i    : in  std_logic;
        rx_o       : out std_logic;
        rx_sync_o  : out std_logic;
        --external PHY
        txo_o : out std_logic;
        txo_t : out std_logic;
        rxi   : in  std_logic;
        --internal phy
        can_l : inout std_logic;
        can_h : inout std_logic
    );
end can_phy;

architecture rtl of can_phy is

    signal rx_s        : std_logic;
    signal rx_int_s    : std_logic;
    signal rx_sync_o_s : std_logic;
    signal tx_s        : std_logic;
    signal tx_en_s     : std_logic;

    signal force_error_s : std_logic;
    signal lock_end_en   : std_logic;
    signal lock_start_en : std_logic;

begin

    --error injection. we have to guarantee that the command from registerbank is captured by the phy.
    pulse_error_u : stretch_sync
    port map(
        rst_i  => '0',
        mclk_i => mclk_i,
        da_i   => tx_clken_i,
        db_i   => force_error_i,
        dout_o => force_error_s
    );

    lock_start_u : det_up
    port map(
        rst_i  => rst_i,
        mclk_i => mclk_i,
        din    => lock_dominant_i,
        dout   => lock_start_en
    );

    lock_end_u : det_down
    port map(
        rst_i  => rst_i,
        mclk_i => mclk_i,
        din    => lock_dominant_i,
        dout   => lock_end_en
    );


    --we sample TX_I so it should place an FFD the closest to the IO.
    tx_p : process (mclk_i, rst_i)
        variable dominant_lock : boolean := false;
        variable ack_lock      : boolean := false;
    begin
        if rst_i = '1' then
            tx_s    <= '1';
            tx_en_s <= '0';
        elsif rising_edge(mclk_i) then

            if lock_start_en = '1' then
                dominant_lock := true;
            elsif lock_end_en = '1' then
                dominant_lock := false;
            end if;

            if send_ack_i = '1' and tx_clken_i = '1' then
                ack_lock := true;
            elsif tx_clken_i = '1' then
                ack_lock := false;
            end if;

            if dominant_lock then
                tx_s    <= '0';
                tx_en_s <= '1';
            elsif ack_lock then
                tx_s    <= '0';
                tx_en_s <= '1';
            else
                tx_s    <= tx_i;
                tx_en_s <= tx_en_i;
            end if;

        end if;
    end process tx_p;

    --no internal phy:
    txo_o <= tx_s;
    txo_t <= tx_en_s;

    --internal phy:
    can_l <= '0' when (tx_en_s and not tx_s) = '1' else
        'Z';
    can_h <= '0' when (tx_en_s and tx_s) = '1' else
        'Z';

    --internal PHY: ex from RXI, external PHY: RX from CANH/L
    rx_s <= rxi when not internal_phy else
            '1' when can_h = '1' and can_l = '0' else
            '0';

    --we always sync it.
    rx_sync_u : sync_r
    port map(
        rst_i  => '0',
        mclk_i => mclk_i,
        din    => rx_s,
        dout   => rx_int_s
    );

    --detect the edge to sync the internal clock
    rx_det_u : det_down
    port map(
        rst_i  => '0',
        mclk_i => mclk_i,
        din    => rx_int_s,
        dout   => rx_sync_o_s
    );
    rx_sync_o <= rx_sync_o_s and not send_ack_i;

    --send the data.
    rx_o <= rx_int_s;


    --we can only detect when we send a 1 but the bus remains low.
    read_ack_p : process (mclk_i, rst_i)
    begin
        if rst_i = '1' then
            read_ack_o <= '0';
        elsif rising_edge(mclk_i) then
            if rx_clken_i = '1' then
                read_ack_o <= not rx_int_s;
            end if;
        end if;
    end process;

    --we can only detect when we send a 1 but the bus remains low.
    col_det_p : process (mclk_i, rst_i)
    begin
        if rst_i = '1' then
            collision_o <= '0';
        elsif rising_edge(mclk_i) then
            if fb_clken_i = '1' then
                collision_o <= (not rx_int_s) and tx_s and tx_en_s;
            elsif tx_clken_i = '1' then
                collision_o <= '0';
            end if;
        end if;
    end process;

    line_status_p : process (mclk_i, rst_i)
        variable stuff_sr : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if rst_i = '1' then
            channel_ready_o   <= '0';
            stuff_violation_o <= '0';
            stuff_sr := (others => '0');
        elsif rising_edge(mclk_i) then
            if rx_clken_i = '1' then
                stuff_sr    := stuff_sr sll 1;
                stuff_sr(0) := rx_int_s;
            end if;
            if channel_ready_o = '1' then
                if stuff_sr = "11111110" then
                    channel_ready_o   <= '0';
                    stuff_violation_o <= '0';
                end if;
            elsif stuff_sr = "11111111" then
                channel_ready_o   <= '1';
                stuff_violation_o <= '0';
            elsif stuff_sr(5 downto 0) = "000000" then
                channel_ready_o   <= '0';
                stuff_violation_o <= '1';
            elsif stuff_sr(5 downto 0) = "111111" then
                channel_ready_o   <= '0';
                stuff_violation_o <= '1';
            else
                channel_ready_o   <= '0';
                stuff_violation_o <= '0';
            end if;
        end if;
    end process;
end rtl;
