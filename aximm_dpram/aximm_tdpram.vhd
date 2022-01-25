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
    A_AXI_ACLK    : in std_logic;
    A_AXI_ARESETN : in std_logic;
    A_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    A_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    A_AXI_AWVALID : in  std_logic;
    A_AXI_AWREADY : out std_logic;
    A_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    A_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    A_AXI_WVALID  : in  std_logic;
    A_AXI_WREADY  : out std_logic;
    A_AXI_BRESP   : out std_logic_vector(1 downto 0);
    A_AXI_BVALID  : out std_logic;
    A_AXI_BREADY  : in  std_logic;
    A_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    A_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    A_AXI_ARVALID : in  std_logic;
    A_AXI_ARREADY : out std_logic;
    A_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    A_AXI_RRESP   : out std_logic_vector(1 downto 0);
    A_AXI_RVALID  : out std_logic;
    A_AXI_RREADY  : in  std_logic;
    --Port B
    B_AXI_ACLK    : in std_logic;
    B_AXI_ARESETN : in std_logic;
    B_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    B_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    B_AXI_AWVALID : in  std_logic;
    B_AXI_AWREADY : out std_logic;
    B_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    B_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    B_AXI_WVALID  : in  std_logic;
    B_AXI_WREADY  : out std_logic;
    B_AXI_BRESP   : out std_logic_vector(1 downto 0);
    B_AXI_BVALID  : out std_logic;
    B_AXI_BREADY  : in  std_logic;
    B_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    B_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    B_AXI_ARVALID : in  std_logic;
    B_AXI_ARREADY : out std_logic;
    B_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    B_AXI_RRESP   : out std_logic_vector(1 downto 0);
    B_AXI_RVALID  : out std_logic;
    B_AXI_RREADY  : in  std_logic
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

  a_rst_s     <= not A_AXI_ARESETN;
  b_rst_s     <= not B_AXI_ARESETN;

  porta_u : single_ram_iface
    generic (
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
    );
    port (
      AXI_ACLK    => A_AXI_ACLK,
      AXI_ARESETN => A_AXI_ARESETN,
      AXI_AWADDR  => A_AXI_AWADDR,
      AXI_AWPROT  => A_AXI_AWPROT,
      AXI_AWVALID => A_AXI_AWVALID,
      AXI_AWREADY => A_AXI_AWREADY,
      AXI_WDATA   => A_AXI_WDATA,
      AXI_WSTRB   => A_AXI_WSTRB,
      AXI_WVALID  => A_AXI_WVALID,
      AXI_WREADY  => A_AXI_WREADY,
      AXI_BRESP   => A_AXI_BRESP,
      AXI_BVALID  => A_AXI_BVALID,
      AXI_BREADY  => A_AXI_BREADY,
      AXI_ARADDR  => A_AXI_ARADDR,
      AXI_ARPROT  => A_AXI_ARPROT,
      AXI_ARVALID => A_AXI_ARVALID,
      AXI_ARREADY => A_AXI_ARREADY,
      AXI_RDATA   => A_AXI_RDATA,
      AXI_RRESP   => A_AXI_RRESP,
      AXI_RVALID  => A_AXI_RVALID,
      AXI_RREADY  => A_AXI_RREADY,
      addr_o => a_addr_s,
      data_i => a_data_i_s,
      data_o => a_data_o_s,
      we_i   => a_we_s,
    );

  portb_u : single_ram_iface
    generic (
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
    );
    port (
      AXI_ACLK    => B_AXI_ACLK,
      AXI_ARESETN => B_AXI_ARESETN,
      AXI_AWADDR  => B_AXI_AWADDR,
      AXI_AWPROT  => B_AXI_AWPROT,
      AXI_AWVALID => B_AXI_AWVALID,
      AXI_AWREADY => B_AXI_AWREADY,
      AXI_WDATA   => B_AXI_WDATA,
      AXI_WSTRB   => B_AXI_WSTRB,
      AXI_WVALID  => B_AXI_WVALID,
      AXI_WREADY  => B_AXI_WREADY,
      AXI_BRESP   => B_AXI_BRESP,
      AXI_BVALID  => B_AXI_BVALID,
      AXI_BREADY  => B_AXI_BREADY,
      AXI_ARADDR  => B_AXI_ARADDR,
      AXI_ARPROT  => B_AXI_ARPROT,
      AXI_ARVALID => B_AXI_ARVALID,
      AXI_ARREADY => B_AXI_ARREADY,
      AXI_RDATA   => B_AXI_RDATA,
      AXI_RRESP   => B_AXI_RRESP,
      AXI_RVALID  => B_AXI_RVALID,
      AXI_RREADY  => B_AXI_RREADY,
      addr_o => b_addr_s,
      data_i => b_data_i_s,
      data_o => b_data_o_s,
      we_i   => b_we_s,
    );

  ram_u : tdp_ram
    generic map(
        mem_size  => C_S_AXI_ADDR_WIDTH,
        port_size => C_S_AXI_DATA_WIDTH,
        ram_type  => blockram,
    );
    port map(
        --general
        clka_i  => A_AXI_ACLK,
        rsta_i  => a_rst_s,
        clkb_i  => B_AXI_ACLK,
        rstb_i  => b_rst_s,
        addra_i => a_addr_s,
        addrb_i => b_addr_s,
        dataa_i => a_data_i_s,
        datab_i => b_data_i_s,
        dataa_o => a_data_o_s,
        datab_o => b_data_o_s,
        ena_i   => '1',
        enb_i   => '1',
        wea_i   => a_we_s,
        web_i   => b_we_s
    );

end rtl;

