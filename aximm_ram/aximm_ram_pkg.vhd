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

package aximm_ram_pkg is

  component aximm_ram is
    generic (
      C_S_AXI_ADDR_WIDTH : integer := 7;
      C_S_AXI_DATA_WIDTH : integer := 32
    );
    port (
      --Port A
      AXI_ACLK    : in std_logic;
      AXI_ARESETN : in std_logic;
      AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      AXI_AWVALID : in  std_logic;
      AXI_AWREADY : out std_logic;
      AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      AXI_WVALID  : in  std_logic;
      AXI_WREADY  : out std_logic;
      AXI_BRESP   : out std_logic_vector(1 downto 0);
      AXI_BVALID  : out std_logic;
      AXI_BREADY  : in  std_logic;
      AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      AXI_ARVALID : in  std_logic;
      AXI_ARREADY : out std_logic;
      AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      AXI_RRESP   : out std_logic_vector(1 downto 0);
      AXI_RVALID  : out std_logic;
      AXI_RREADY  : in  std_logic
    );
  end component;

end aximm_ram_pkg;

package body aximm_ram_pkg is

end package body;
