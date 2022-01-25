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

entity aximm_ram_iface is
  generic (
    C_S_AXI_ADDR_WIDTH : integer := 7;
    C_S_AXI_DATA_WIDTH : integer := 32
  );
  port (
    AXI_ACLK    : in  std_logic;
    AXI_ARESETN : in  std_logic;
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
    AXI_RREADY  : in  std_logic;
    addr_o : out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    data_i : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    data_o : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    we_i   : in  std_logic
  );
end aximm_ram_iface;

architecture rtl of aximm_ram_iface is

  signal a_rst_s     : std_logic;
  signal a_request_s : std_logic_vector(2 downto 0);
  signal ack_s       : std_logic_vector(2 downto 0);
  signal grant_s     : std_logic_vector(2 downto 0);

begin

  a_rst_s     <= not A_AXI_ARESETN;

  --can only request write if there is no pending BRESP.
  a_request_s(1) <= A_AXI_AWVALID and (AXI_BREADY or not AXI_BVALID);
  --can only request read if there is no pending read.
  a_request_s(0) <= A_AXI_ARVALID and (AXI_RREADY or not AXI_RVALID);

  --RAM Addressing. first, will have to decide between write and read.
  awready_u : fast_queueing
    generic map(
      n_elements => 2
    );
    port map (
      clk_i     => A_AXI_ACLK,
      rst_i     => a_rst_s,
      request_i => a_request_s,
      ack_i     => ack_s,
      grant_o   => grant_s,
      index_o   => open
    );

  --write
  ack_s(1)      <= grant_s(1) and A_AXI_WVALID;
  A_AXI_AWREADY <= grant_s(1) and A_AXI_WVALID;
  A_AXI_WREADY  <= grant_s(1) and A_AXI_WVALID;
  we_o          <= grant_s(1) and A_AXI_WVALID;

  --write BRESP
  process(all)
    variable timeout_v : integer;
  begin
    if a_rst_s = '1' then
      A_AXI_BVALID = '0';
      timeout_v := 0;
    elsif if rising_edge(A_AXI_ACLK) then
      if grant_s(1) then
        timeout_v := 0;
        A_AXI_BVALID  <= '1';
        A_AXI_BRESP   <= "00";
      elsif A_AXI_BREADY = '1' then
        timeout_v := timeout_v + 1;
        A_AXI_RVALID <= '0';
        A_AXI_RRESP   <= "00";
      elsif timeout_v = 16 then
        timeout_v := 0;
        A_AXI_RVALID <= '0';
        A_AXI_RRESP   <= "01";
      end if;
    end if;
  end process;

  --read
  ack_s(0)      <= grant_s(0)
  A_AXI_ARREADY <= grant_s(0);

  process(all)
    variable timeout_v : integer;
  begin
    if a_rst_s = '1' then
      A_AXI_RVALID = '0';
      timeout_v := 0;
    elsif if rising_edge(A_AXI_ACLK) then
      if grant_s(0) then
        timeout_v := 0;
        A_AXI_RVALID  <= '1';
        A_AXI_RRESP   <= "00";
      elsif A_AXI_RREADY = '1' then
        timeout_v := timeout_v + 1;
        A_AXI_RVALID <= '0';
        A_AXI_RRESP   <= "00";
      elsif timeout_v = 16 then
        timeout_v := 0;
        A_AXI_RVALID <= '0';
        A_AXI_RRESP   <= "01";
      end if;
    end if;
  end process;

  --address selection
  addr_o <= A_AXI_AWADDR when grant_s(1) = '1' else A_AXI_ARADDR;

end rtl;

