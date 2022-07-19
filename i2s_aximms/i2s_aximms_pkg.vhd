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

  constant package_version_c : String := "20220622_1606";

  component i2s_regbank is
    generic (
      C_S_AXI_ADDR_WIDTH : integer := 7;
      C_S_AXI_DATA_WIDTH : integer := 32
    );
    port (
      S_AXI_ACLK    : in std_logic;
      S_AXI_ARESETN : in std_logic;
      S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in std_logic;
      S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in std_logic;
      g1_i                  : in std_logic_vector(31 downto 0);
      bclk_edge_o           : out std_logic;
      lrclk_polarity_o      : out std_logic;
      lrclk_justified_o     : out std_logic;
      frame_size_o          : out std_logic_vector(2 downto 0);
      clock_source_o        : out std_logic_vector(1 downto 0);
      sample_rate_o         : out std_logic_vector(2 downto 0);
      ref_div_o             : out std_logic_vector(15 downto 0);
      ref_mult_o            : out std_logic_vector(15 downto 0);
      rxfull_irq_i          : in std_logic;
      txempty_irq_i         : in std_logic;
      bclk_err_irq_i        : in std_logic;
      lrclk_err_irq_i       : in std_logic;
      rxfull_irq_mask_o     : out std_logic;
      txempty_irq_mask_o    : out std_logic;
      bclk_err_irq_mask_o   : out std_logic;
      lrclk_err_irq_mask_o  : out std_logic;
      rx_fifo_status_i      : in std_logic_vector(1 downto 0);
      tx_fifo_status_i      : in std_logic_vector(1 downto 0);
      i2s_mm_left_i         : in std_logic_vector(31 downto 0);
      i2s_mm_left_o         : out std_logic_vector(31 downto 0);
      i2s_mm_right_i        : in std_logic_vector(31 downto 0);
      i2s_mm_right_o        : out std_logic_vector(31 downto 0)
    );
  end component;

  component i2s_clock is
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
  end component i2s_clock;

end i2s_aximms_pkg;

--a arquitetura
package body i2s_aximms_pkg is

end i2s_aximms_pkg;
