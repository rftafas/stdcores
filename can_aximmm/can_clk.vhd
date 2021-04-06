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

entity can_clk is
    generic (
        system_freq   : real := 96.0000e+6 -- the system frequency
    );
    port ( mclk_i      : in  std_logic;
           rst_i       : in  std_logic;
           baud_rate_i : in  std_logic_vector(11 downto 0); -- baudrate in N x kbps, n = 0...2**12
           clk_sync_i  : in  std_logic;
           txen_o      : out std_logic;
           rxen_o      : out std_logic;
           fben_o      : out std_logic
    );
end can_clk;

architecture behavioral of can_clk is

    signal   quanta_cnt      : unsigned(3 downto 0) := (others=>'0');
    constant quanta_num      : integer              := 2**quanta_cnt'length;
    constant base_freq       : real                 := to_real(quanta_num*1000);

    constant NCO_size_c      : integer := 22; --ceil ( log2(1000) + 12 bits )
    constant Resolution_hz_c : real    := system_freq/(2**NCO_size_c);
    constant baud_calc_c     : integer := increment_value_calc(system_freq,base_freq,NCO_size_c);

begin

    assert NCO_size_c > internal_clock_freq
        report "Minimum Frequency is " & to_string(internal_clock_freq) & " Hz."
        severity failure;

    nco_u : nco
        generic map (
          Fref_hz         => system_freq,
          Fout_hz         => max_baud_rate,
          Resolution_hz   => Resolution_hz_c,
          use_scaler      => false,
          adjustable_freq => true,
          NCO_size_c      => NCO_size_c
        )
        port map (
          rst_i     => rst,
          mclk_i    => clk,
          scaler_i  => '1',
          sync_i    => can_rx_clk_sync,
          n_value_i => s_value_s,
          clkout_o  => quanta_clk_s,
        );
    end nco;

    --generate the timebase for
    s_value_s <= baud_rate_i * baud_calc_c;

    quanta_clk_u : det_down
        port map (
            rst_i   => rst,
            mclk_i  => clk,
            din     => quanta_clk_s,
            dout    => quanta_clk_en,
        );

    quanta_p : process(all)
    begin
        if rst_i = '1' then
            quanta_cnt <= (others=>'0');
        elsif rising_edge(mclk_i) then
            if can_rx_clk_sync = '1' then
                quanta_counter <= (others=>'0');
            elsif quanta_clk_en = '1' then
                quanta_counter <= quanta_counter + 1;
            end if;
        end if;
    end process;

    txen_o <= quanta_clk_en when quanta_counter =  5 else '0';
    rxen_o <= quanta_clk_en when quanta_counter = 10 else '0';
    fben_o <= quanta_clk_en when quanta_counter = 15 else '0';


end rtl;
