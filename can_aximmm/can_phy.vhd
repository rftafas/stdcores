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

entity can_phy is
    generic (
        internal_phy : boolean := false
    )
    port (
        mclk_i            : in  std_logic;
        --configs
        force_error_i     : in  std_logic;
        internal_loop_i   : in  std_logic;
        lock_dominant_i   : in  std_logic;
        loopback_i        : in  std_logic;
        --stats
        stuff_violation_o : out std_logic;
        collision_o       : out std_logic;
        channel_ready_o   : out std_logic;
        --commands
        send_ack_i        : in  std_logic;
        -- data channel;
        tx_clken_i        : in  std_logic;
        tx_clken_i        : in  std_logic;
        rx_clken_i        : in  std_logic;
        fb_clken_i        : in  std_logic;
        tx_i              : in  std_logic;
        tx_en_i           : in  std_logic;
        rx_o              : out std_logic;
        rx_sync_o         : out std_logic;
        --external PHY
        txo_o : out   std_logic;
        txo_t : out   std_logic;
        rxi   : in    std_logic;
        --internal phy
        can_l : inout std_logic;
        can_h : inout std_logic
    );
end can_phy;

architecture rtl of can_phy is

    signal rx_int_s : std_logic; --create rx_out as buffer
    signal rx_int_s : std_logic; --create rx_out as buffer

begin

    --error injection. we have to guarantee that the command from registerbank is captured by the phy.
    pulse_error_u : stretch_sync
        port map (
          rst_i  => '0',
          mclk_i => mclk_i,
          da_i   => tx_clken_i,
          db_i   => force_error_i,
          dout_o => force_error_s
        );

    --we sample TX_I so it should place an FFD the closest to the IO.
    tx_p: process(clk, rst)
    begin
        if rst = rst_val then
            tx_s    <= '1';
            tx_en_s <= '0';
        elsif rising_edge(clk) then
            if tx_clken_i = '1' then
                tx_en_s <= tx_en_i;
                if lock_dominant_i = '1' then
                    tx_s <= '0';
                elsif send_ack_i = '1' then
                    tx_s <= '0';
                elsif force_error_s = '1' then
                    tx_s <= not tx_i;
                else
                    tx_s <= tx_i;
                end if;
            end if;

        end if;
    end process tx_p;

    --no internal phy:
    txo_o <= tx_s;
    txo_t <= tx_en_s;

    --internal phy:
    can_l <= '0' when (tx_en_s and not tx_s) = '1' else 'Z';
    can_h <= '0' when (tx_en_s and     tx_s) = '1' else 'Z';

    --internal PHY: ex from RXI, external PHY: RX from CANH/L
    rx_s <= rxi when not internal_phy           else
            '1' when can_h = '1' and can_l ='0' else
            '0';

    --we always sync it.
    rx_sync_u : sync_r
        port map (
          rst_i  => '0',
          mclk_i => mclk_i,
          din    => rx_s,
          dout   => rx_int_s
        );

    --detect the edge to sync the internal clock
    rx_det_u : det_down
        port map (
          rst_i  => '0',
          mclk_i => mclk_i,
          din    => rx_int_s,
          dout   => rx_sync_o
        );

    --send the data.
    rx_o <= rx_int_s;

    --we can only detect when we send a 1 but the bus remains low.
    col_det_p : process(clk, rst)
    begin
        if rst = rst_val then
            collision_o <= '0';
        elsif rising_edge(clk) then
            if fb_clken_i = '1' then
                collision_o <= (not rx_int_s) and tx_s and tx_en_s;
            elsif tx_clken_i = '1' then
                collision_o <= '0';
            end if;
        end if;
    end process;

    line_status_p : process(clk, rst)
        variable stuff_sr : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if rst = rst_val then
            channel_ready_o   <= '0';
            stuff_violation_o <= '0';
            stuff_sr          := (others => '0');
        elsif rising_edge(clk) then
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
