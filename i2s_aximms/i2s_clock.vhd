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
--Frame size:
--000 - 64 (32 bit per channel)
--001 -  8 (16 bit per channel)
--010 - 16 (32 bit per channel)
--011 - 32 (64 bit per channel)
--100 - 48 (24 bit per channel)
--
--Clock Source:
--00 - Internal clock
--01 - Integer Divider of Reference Clock
--10 - Fractionary Ratio of Reference Clock
--11 - no use here.
--
--Sample Rate - Internal Generation (kHz)
--000 - 48
--001 -  8
--010 - 16
--011 - 24
--100 - 32
--101 - 64
--110 - 96
--111 - 44.1
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.timer_lib.all;
library stdcores;
  use stdcores.i2s_aximms_pkg.all;

entity i2s_clock is
  generic (
    Fmclk_hz            : real    := 100.0000e+6;
    Fref_hz             : real    :=  24.5760e+6;
    use_clock_generator : boolean := true;
    use_adpll           : boolean := true;
    use_int_divider     : boolean := true
  );
  port (
    --general
    rst_i           : in  std_logic;
    mclk_i          : in  std_logic;
    --configs
    multiplier_i    : in  std_logic_vector(15 downto 0);
    divider_i       : in  std_logic_vector(15 downto 0);
    sample_size_i   : in  std_logic_vector(2 downto 0);
    sample_freq_i   : in  std_logic_vector(2 downto 0);
    sel_clk_src     : in  std_logic_vector(1 downto 0);
    --clock reference
    clkref_i        : in  std_logic;
    clksample_i     : in  std_logic;
    --to I2S cores
    bclk_o          : out std_logic;
    lrclk_o         : out std_logic
  );
end i2s_clock;

architecture behavioral of i2s_clock is

  constant resolution_c       : real    := 100.000;
  constant NCO_size_c         : integer := nco_size_calc(Fmclk_hz,resolution_c);

  signal n_value_s : std_logic_vector(NCO_size_c-1 downto 0);


  constant NCO_frec_vec       : integer_vector(2 downto 0) := (
    1      => increment_value_calc(Fmclk_hz, 8.000e3,NCO_size_c),
    2      => increment_value_calc(Fmclk_hz,16.000e3,NCO_size_c),
    3      => increment_value_calc(Fmclk_hz,24.000e3,NCO_size_c),
    4      => increment_value_calc(Fmclk_hz,32.000e3,NCO_size_c),
    5      => increment_value_calc(Fmclk_hz,64.000e3,NCO_size_c),
    6      => increment_value_calc(Fmclk_hz,96.000e3,NCO_size_c),
    7      => increment_value_calc(Fmclk_hz,44.100e3,NCO_size_c),
    others => increment_value_calc(Fmclk_hz,48.000e3,NCO_size_c)
  );

  constant sample_size_vec : integer_vector(2 downto 0) := (
    1 =>  8,
    2 => 12,
    3 => 16,
    4 => 24,
    others => 32
  );

  signal i2s_cnt        : integer;

  signal bclk_s         : std_logic;
  signal lrclk_s        : std_logic;

  signal div_bclk_s     : std_logic;
  signal adpll_bclk_s   : std_logic;
  signal int_bclk_s     : std_logic;

begin

  --asserts to be included:
  -- message in case of internal clock generation, that it won't consider multiplier/divider

  adpll_gen : if use_adpll generate
    adpll_u : adpll_fractional
      generic map(
        Fref_hz       => Fmclk_hz,
        Fout_hz       => 96.000e3,
        Bandwidth_hz  => 1000.000,
        Resolution_hz =>  100.000
      );
      port map(
        rst_i        => rst_i,
        mclk_i       => mclk_i,
        divider_i    => to_integer(divider_i)
        multiplier_i => to_integer(multiplier_i),
        clkin_i      => clkref_i,
        clkout_o     => adpll_bclk_s
      );

  else generate
    adpll_bclk_s  <= '0';

  end generate;

  divider_gen : if enable_int_divider generate
    clkin_div_u : det_updn port map (rst_i,mclk_i, clkref_i, clkref_en);

    ckdiv_p : process(rst_i, mclk_i)
      variable divider_cnt : integer := 0;
    begin
      if rst_i = '1' then
        divider_cnt := 0;
        div_bclk_s <= '0';

      elsif mclk_i'event and mclk_i = '1' then
        if clkref_en = '1' then
          divider_cnt := divider_cnt + 1;
          if divider_cnt = divider_i then
            div_bclk_s  <= '1';
          elsif divider_cnt = 2*divider_i then
            div_bclk_s  <= '0';
            divider_cnt := 0;
          end if;
        end if;
      end if;

  else generate
    div_bclk_s  <= '0';

  end generate;

  int_clk_gen : if use_clock_generator or fixed_internal_fsample generate

    n_value_s <= to_std_logic_vector(
      2 * sample_size_vec(to_integer(sample_size_i)) * NCO_frec_vec(to_integer(sample_freq_i)),
      NCO_size_c
    );

    nco_u : nco
      generic map(
        Fref_hz         => Fmclk_hz,
        Fout_hz         => 96.000e3,
        Resolution_hz   => resolution_c,
        use_scaler      => false,
        adjustable_freq => true,
        NCO_size_c      => NCO_size_c,
      );
      port map(
        rst_i     => rst_i,
        mclk_i    => mclk_i,
        scaler_i  => '1',
        sync_i    => '0',
        n_value_i => n_value_s,
        clkout_o  => int_bclk_s,
      );

  else generate;
    int_bclk_s <= '0';

  end generate;

  bclk_s <= int_bclk_s   when sel_clk_src_i = "00" else
            div_bclk_s   when sel_clk_src_i = "01" else
            adpll_bclk_s when sel_clk_src_i = "10" else
            '0';

  clkin_div_u : det_down port map (rst_i,mclk_i, bclk_s, bclk_dn_en_s);

  lrclk_p : process(all)
    begin
      if mclk_i'event and mclk_i = '1' then
        if bclk_dn_en_s = '1' then
          i2s_cnt <= i2s_cnt + 1;
          if i2s_cnt = sample_size_vec(to_integer(sample_size_i))-1 then
            sample_size_int <= '0';
            lrclk_s <= '0';
          elsif i2s_cnt = 2*sample_size_vec(to_integer(sample_size_i))-1 then
            lrclk_s <= '1';
          end if;
        end if;
      end if;
  end process;


  bclk_o  <= bclk_s;
  lrclk_o <= lrclk_s;

end behavioral;
