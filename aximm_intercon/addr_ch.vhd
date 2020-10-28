----------------------------------------------------------------------------------
--Copyright 2020 Ricardo F Tafas Jr

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

entity addr_ch is
    generic (
      master_portnum : positive := 8;
      slave_portnum  : positive := 8;
      DATA_BYTE_NUM  : positive := 8;
      ADDR_BYTE_NUM  : positive := 8
    );
    port (
      --general
      rst_i        : in  std_logic;
      clk_i        : in  std_logic;
      slave_mask_i : in  slave_mask_t;
      --------------------------------------------------------------------------
      --AXIS Master Port
      --------------------------------------------------------------------------
      M_AXI_TUSER  : out std_logic_array (master_portnum-1 downto 0,ID_WIDTH-1 downto 0);
      M_AXI_TVALID : out std_logic_vector(master_portnum-1 downto 0);
      M_AXI_TREADY : in  std_logic_vector(master_portnum-1 downto 0);
      M_AXI_TDATA  : out std_logic_array (master_portnum-1 downto 0,8*ADDR_BYTE_NUM-1 downto 0);
      M_AXI_TDEST  : out std_logic_array (master_portnum-1 downto 0,2 downto 0);
      --------------------------------------------------------------------------
      --AXIS Slave Port
      --------------------------------------------------------------------------
      S_AXI_ID    : in  std_logic_array (ID_WIDTH-1 downto 0);
      S_AXI_VALID : in  std_logic;
      S_AXI_READY : out std_logic;
      S_AXI_ADDR  : in  std_logic_array (8*ADDR_BYTE_NUM-1 downto 0);
      S_AXI_PROT  : in  std_logic_array (2 downto 0)
    );
end addr_ch;

architecture behavioral of addr_ch is


begin

  process(all)
    variable peripheral_num : std_logic_vector();
  begin
    if rst_i = '1' then
    elsif rising_edge(mclk_i) then
      peripheral_num := sel_peripheral(raddr_s,slave_mask_i);
      if S_AXI_VALID = '1' then
        M_AXI_TVALID <= S_AXI_VALID;
        M_AXI_TDATA  <= M_AXI_ARVALID;
        M_AXI_TUSER  <= peripheral_num & controller_num & S_AXI_ID;
        M_AXI_TDEST  <= peripheral_num;
      end if;
    end if;
  end process;

end behavioral;
