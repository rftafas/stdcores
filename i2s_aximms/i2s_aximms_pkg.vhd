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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package i2s_aximms_pkg is

  component i2s_clock is
    generic (
      Fmclk_hz            : real    := 100.0000e+6;
      Fref_hz             : real    :=  24.5760e+6;
      use_clock_generator : boolean := true;
      use_adpll           : boolean := true;
      use_int_divider     : boolean := true;
    )
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
  end component i2s_clock;

end i2s_aximms_pkg;

--a arquitetura
package body i2s_aximms_pkg is

end i2s_aximms_pkg;
