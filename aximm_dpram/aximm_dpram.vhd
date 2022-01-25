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
library expert;
  use expert.std_logic_expert.all;

entity aximm_ram is
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
end can_aximm;

architecture rtl of aximm_ram is

  signal a_addr_s   : std_logic_veector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal a_data_i_s : std_logic_veector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal a_data_o_s : std_logic_veector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal a_we_s     : std_logic;

  signal b_addr_s   : std_logic_veector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal b_data_i_s : std_logic_veector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal b_data_o_s : std_logic_veector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal b_we_s     : std_logic;

begin

  a_rst_s <= not A_AXI_ARESETN;

  --write
  AWREADY <= AXI_AWVALID and AXI_WVALID and (AXI_BREADY or not AXI_BVALID);
  WREADY  <= AXI_AWVALID and AXI_WVALID and (AXI_BREADY or not AXI_BVALID);
  we_s    <= AXI_AWVALID and AXI_WVALID and (AXI_BREADY or not AXI_BVALID);
  process(all)
    variable timer_v : integer := 0;
  begin
    if a_rst_s = '1' then
      AXI_BVALID = '0';
      timer_v := 0;
    elsif if rising_edge(A_AXI_ACLK) then
      if AXI_WREADY = '1' then
        AXI_BVALID <= '1';
        AXI_BRESP  <= "00";
        timer_v := 0;
      elsif AXI_BREADY = '1' then
        AXI_BVALID <= '0';
        AXI_BRESP  <= "00";
        timer_v := 0;
      elsif timer_v = 16 then
        AXI_BVALID = '0';
        AXI_BRESP  <= "01";
        timer_v := 0;
      else
        timer_v := timer_v + 1;
      end if;
    end if;
  end process;

  --read
  AXI_ARREADY <= AXI_ARVALID and (AXI_RREADY or not AXI_RVALID);

  process(all)
    variable timer_v : integer := 0;
  begin
    if a_rst_s = '1' then
      AXI_RREADY = '0';
      timer_v := 0;
    elsif if rising_edge(A_AXI_ACLK) then
      if AXI_ARREADY = '1' then
        AXI_RVALID <= '1';
        AXI_RRESP <= "00";
        timer_v := 0;
      elsif AXI_RREADY = '1' then
        AXI_RVALID = '0';
        AXI_RRESP <= "00";
        timer_v := 0;
      elsif timer_v = 16 then
        AXI_RVALID <= '0';
        AXI_RRESP <= "01";
        timer_v := 0;
      else
        timer_v := timer_v + 1;
      end if;
    end if;
  end process;

  ram_u : tdp_ram
    generic map(
        mem_size  => C_S_AXI_ADDR_WIDTH,
        port_size => C_S_AXI_DATA_WIDTH,
        ram_type  => blockram,
    );
    port map(
        --general
        clka_i  => AXI_ACLK,
        rsta_i  => a_rst_s,
        clkb_i  => AXI_ACLK,
        rstb_i  => a_rst_s,
        addra_i => AXI_AWADDR,
        addrb_i => AXI_ARADDR,
        dataa_i => AXI_WDATA,
        dataa_o => open,
        datab_o => AXI_RDATA,
        ena_i   => '1',
        enb_i   => '1',
        wea_i   => we_s
    );

end rtl;

