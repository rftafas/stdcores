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
    use stdblocks.timer_lib.all;

entity can_clk is
    generic (
        system_freq   : real := 96.0000e+6 -- the system frequency
    );
    port ( mclk_i      : in  std_logic;
           rst_i       : in  std_logic;
           baud_rate_i : in  std_logic_vector(11 downto 0); -- baudrate in N x kbps, n = 0...2**12
           clk_sync_i  : in  std_logic;
           tx_clken_o  : out std_logic;
           rx_clken_o  : out std_logic;
           fb_clken_o  : out std_logic
    );
end can_clk;

architecture behavioral of can_clk is

    signal   quanta_cnt      : unsigned(3 downto 0) := (others=>'0');
    constant quanta_num      : integer              := 2**quanta_cnt'length;
    constant base_freq       : real                 := real(quanta_num*1000);

    constant NCO_size_c      : integer := 22; --ceil ( log2(1000) + 12 bits )
    constant Resolution_hz_c : real    := system_freq/real(2**NCO_size_c);
    constant baud_calc_c     : integer := increment_value_calc(system_freq,base_freq,NCO_size_c);

    signal   quanta_clk_s    : std_logic;
    signal   quanta_clk_en   : std_logic;
    signal   s_value_s       : std_logic_vector(NCO_size_c-1 downto 0);

begin

    assert system_freq > base_freq
        report "Minimum Frequency is " & to_string(base_freq) & " Hz."
        severity failure;

    nco_u : nco
        generic map (
            Fref_hz         => system_freq,
            Fout_hz         => base_freq,
            Resolution_hz   => Resolution_hz_c,
            use_scaler      => false,
            adjustable_freq => true,
            NCO_size_c      => NCO_size_c
        )
        port map (
            rst_i     => rst_i,
            mclk_i    => mclk_i,
            scaler_i  => '1',
            sync_i    => clk_sync_i,
            n_value_i => s_value_s,
            clkout_o  => quanta_clk_s
        );

    --generate the timebase for
    s_value_s <= baud_rate_i * baud_calc_c;

    quanta_clk_u : det_down
        port map (
            rst_i   => rst_i,
            mclk_i  => mclk_i,
            din     => quanta_clk_s,
            dout    => quanta_clk_en
        );

    quanta_p : process(all)
    begin
        if rst_i = '1' then
            quanta_cnt <= (others=>'0');
        elsif rising_edge(mclk_i) then
            if clk_sync_i = '1' then
                quanta_cnt <= (others=>'0');
            elsif quanta_clk_en = '1' then
                quanta_cnt <= quanta_cnt + 1;
            end if;
        end if;
    end process;

    fb_clken_o <= quanta_clk_en when quanta_cnt =  5 else '0';
    rx_clken_o <= quanta_clk_en when quanta_cnt = 10 else '0';
    tx_clken_o <= quanta_clk_en when quanta_cnt = 15 else '0';


end behavioral;
