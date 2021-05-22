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
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.sync_lib.all;

    use work.can_aximm_pkg.all;

entity can_aximm_top is
  generic (
    system_freq  : real    := 96.0000e+6;
    internal_phy : boolean := false
  );
  port (
    mclk_i        : in  std_logic;
    rst_i         : in  std_logic;
    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    --Simple IRQs
    tx_irq_o      : out std_logic;
    rx_irq_o      : out std_logic;
    --external PHY signals
    txo_o         : out std_logic;
    txo_t         : out std_logic;
    rxi           : in  std_logic;
    --internal phy
    can_l         : inout std_logic;
    can_h         : inout std_logic
  );
end can_aximm_top;

architecture behavior of can_aximm_top is

  --clock control
  signal baud_rate_s       : std_logic_vector(15 downto 0);
  signal rx_clken_s        : std_logic;
  signal fb_clken_s        : std_logic;
  signal tx_clken_s        : std_logic;

  -- CAN TX
  signal tx_eff_s          : std_logic;
  signal tx_id_s           : std_logic_vector(28 downto 0);
  signal tx_rtr_s          : std_logic;
  signal tx_dlc_s          : std_logic_vector( 3 downto 0);
  signal tx_rsvd_s         : std_logic_vector( 1 downto 0);
  signal tx_data_s         : std_logic_vector(63 downto 0);
  signal tx_valid_s        : std_logic;
  signal tx_ready_s        : std_logic;
  signal ack_error_s       : std_logic;
  signal arb_lost_s        : std_logic;
  signal rtry_error_s      : std_logic;
  signal tx_busy_s         : std_logic;
  signal tx_serial_data_s  : std_logic;
  signal tx_serial_data_en : std_logic;
  signal tx_irq_s          : std_logic;
  signal tx_irq_mask_s     : std_logic;
  signal tx_busy_down_s    : std_logic;

  --CAN RX
  signal rx_eff_s          : std_logic;
  signal rx_id_s           : std_logic_vector(28 downto 0);
  signal reg_id_s          : std_logic_vector(28 downto 0);
  signal reg_id_mask_s     : std_logic_vector(28 downto 0);
  signal rx_rtr_s          : std_logic;
  signal rx_dlc_s          : std_logic_vector( 3 downto 0);
  signal rx_rsvd_s         : std_logic_vector( 1 downto 0);
  signal rx_data_valid_s   : std_logic;
  signal rx_data_s         : std_logic_vector(63 downto 0);
  signal rx_busy_s         : std_logic;
  signal rx_serial_data_s  : std_logic;
  signal rx_irq_s          : std_logic;
  signal rx_irq_mask_s     : std_logic;
  signal rx_busy_down_s    : std_logic;
  signal rx_crc_error_s    : std_logic;
  signal promiscuous_s     : std_logic;

  --PHY
  signal collision_s       : std_logic;
  signal rx_sync_s         : std_logic;
  signal insert_error_s    : std_logic;
  signal force_dominant_s  : std_logic;
  signal loopback_s        : std_logic;
  signal stuff_violation_s : std_logic;
  signal channel_ready_s   : std_logic;
  signal send_ack_s        : std_logic;

begin

  ----------------------------------------------------------------------------------
  --AXI REGBANK
  ----------------------------------------------------------------------------------
  can_reg_u : can_aximm
    generic map(
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
    )
    port map(
      S_AXI_ACLK        => mclk_i,
      S_AXI_ARESETN     => not rst_i,
      S_AXI_AWADDR      => S_AXI_AWADDR,
      S_AXI_AWPROT      => S_AXI_AWPROT,
      S_AXI_AWVALID     => S_AXI_AWVALID,
      S_AXI_AWREADY     => S_AXI_AWREADY,
      S_AXI_WDATA       => S_AXI_WDATA,
      S_AXI_WSTRB       => S_AXI_WSTRB,
      S_AXI_WVALID      => S_AXI_WVALID,
      S_AXI_WREADY      => S_AXI_WREADY,
      S_AXI_BRESP       => S_AXI_BRESP,
      S_AXI_BVALID      => S_AXI_BVALID,
      S_AXI_BREADY      => S_AXI_BREADY,
      S_AXI_ARADDR      => S_AXI_ARADDR,
      S_AXI_ARPROT      => S_AXI_ARPROT,
      S_AXI_ARVALID     => S_AXI_ARVALID,
      S_AXI_ARREADY     => S_AXI_ARREADY,
      S_AXI_RDATA       => S_AXI_RDATA,
      S_AXI_RRESP       => S_AXI_RRESP,
      S_AXI_RVALID      => S_AXI_RVALID,
      S_AXI_RREADY      => S_AXI_RREADY,
      ---
      g1_i              => golden_c,
      iso_mode_o        => open,
      fd_enable_o       => open,
      sample_rate_o     => baud_rate_s,
      rx_irq_i          => rx_irq_s,
      rx_irq_mask_o     => rx_irq_mask_s,
      tx_irq_i          => tx_irq_s,
      tx_irq_mask_o     => tx_irq_mask_s,
      stuff_violation_i => stuff_violation_s,
      collision_i       => collision_s,
      channel_ready_i   => channel_ready_s,
      loop_enable_o     => loopback_s,
      insert_error_o    => insert_error_s,
      force_dominant_o  => force_dominant_s,
      rx_data_valid_i   => rx_data_valid_s,
      rx_read_done_o    => open,
      rx_busy_i         => rx_busy_s,
      rx_crc_error_i    => rx_crc_error_s,
      rx_rtr_i          => rx_rtr_s,
      rx_ide_i          => rx_eff_s,
      rx_reserved_i     => rx_rsvd_s,
      id1_o             => reg_id_s,
      id1_mask_o        => reg_id_mask_s,
      rx_size_i         => rx_dlc_s,
      rx_id_i           => rx_id_s,
      rx_data0_i        => rx_data_s(31 downto  0),
      rx_data1_i        => rx_data_s(63 downto 32),
      tx_ready_i        => tx_ready_s,
      tx_valid_o        => tx_valid_s,
      tx_busy_i         => tx_busy_s,
      tx_arb_lost_i     => arb_lost_s,
      tx_retry_error_i  => rtry_error_s,
      tx_rtr_o          => tx_rtr_s,
      tx_eff_o          => tx_eff_s,
      tx_reserved_o     => tx_rsvd_s,
      tx_dlc_o          => tx_dlc_s,
      tx_id_o           => tx_id_s,
      tx_data0_o        => tx_data_s(31 downto  0),
      tx_data1_o        => tx_data_s(63 downto 32)
    );

  tx_ready_s <= not tx_busy_s;

  ----------------------------------------------------------------------------------
  --IRQ
  ----------------------------------------------------------------------------------
  tx_irq_u : det_down
    port map (
      rst_i  => '0',
      mclk_i => mclk_i,
      din    => tx_busy_s,
      dout   => tx_busy_down_s
    );


  rx_irq_u : det_down
    port map (
      rst_i  => '0',
      mclk_i => mclk_i,
      din    => rx_busy_s,
      dout   => rx_busy_down_s
    );

    tx_irq_s <= tx_irq_mask_s and tx_busy_down_s;
    rx_irq_s <= rx_irq_mask_s and rx_busy_down_s;
    tx_irq_o <= tx_irq_s;
    rx_irq_o <= rx_irq_s;


  ----------------------------------------------------------------------------------
  --CLOCK AND QUANTA
  ----------------------------------------------------------------------------------
  can_clk : entity work.can_clk
    generic map(
      system_freq   => system_freq
    )
    port map(
      mclk_i      => mclk_i,
      rst_i       => rst_i,
      baud_rate_i => baud_rate_s(11 downto 0),
      clk_sync_i  => rx_sync_s,
      rx_clken_o  => rx_clken_s,
      fb_clken_o  => fb_clken_s,
      tx_clken_o  => tx_clken_s
    );

  ----------------------------------------------------------------------------------
  --TX
  ----------------------------------------------------------------------------------
  can_tx_u : can_tx
    port map(
      rst_i        => rst_i,
      mclk_i       => mclk_i,
      tx_clken_i   => tx_clken_s,
      fb_clken_i   => fb_clken_s,
      usr_eff_i    => tx_eff_s,
      usr_id_i     => tx_id_s,
      usr_rtr_i    => tx_rtr_s,
      usr_dlc_i    => tx_dlc_s,
      usr_rsvd_i   => tx_rsvd_s,
      data_i       => tx_data_s,
      data_ready_o => open,
      data_valid_i => tx_valid_s,
      data_last_i  => '0',
      rtry_error_o => rtry_error_s,
      ack_error_o  => ack_error_s,
      arb_lost_o   => arb_lost_s,
      busy_o       => tx_busy_s,
      ch_ready_i   => channel_ready_s,
      collision_i  => collision_s,
      rxdata_i     => rx_serial_data_s,
      txdata_o     => tx_serial_data_s,
      txen_o       => tx_serial_data_en
    );

  ----------------------------------------------------------------------------------
  --RX
  ----------------------------------------------------------------------------------
  can_rx_u : can_rx
    port map (
      rst_i          => rst_i,
      mclk_i         => mclk_i,
      rx_clken_i     => rx_clken_s,
      fb_clken_i     => fb_clken_s,
      usr_eff_o      => rx_eff_s,
      usr_id_o       => rx_id_s,
      usr_rtr_o      => rx_rtr_s,
      usr_dlc_o      => rx_dlc_s,
      usr_rsvd_o     => rx_rsvd_s,
      data_ready_i   => '1',
      data_valid_o   => rx_data_valid_s,
      data_o         => rx_data_s,
      data_last_o    => open,
      reg_id_i       => reg_id_s,
      reg_id_mask_i  => reg_id_mask_s,
      promiscuous_i  => promiscuous_s,
      busy_o         => rx_busy_s,
      rx_crc_error_o => rx_crc_error_s,
      send_ack_o     => send_ack_s,
      collision_i    => collision_s,
      rxdata_i       => rx_serial_data_s
    );

  ----------------------------------------------------------------------------------
  --PHY MAC
  ----------------------------------------------------------------------------------
  can_phy_u : can_phy
    generic map(
      internal_phy => internal_phy
    )
    port map(
      rst_i             => rst_i,
      mclk_i            => mclk_i,
      tx_clken_i        => tx_clken_s,
      rx_clken_i        => rx_clken_s,
      fb_clken_i        => fb_clken_s,
      force_error_i     => insert_error_s,
      lock_dominant_i   => force_dominant_s,
      loopback_i        => loopback_s,
      stuff_violation_o => stuff_violation_s,
      collision_o       => collision_s,
      channel_ready_o   => channel_ready_s,
      send_ack_i        => send_ack_s,
      tx_i              => tx_serial_data_s,
      tx_en_i           => tx_serial_data_en,
      rx_o              => rx_serial_data_s,
      rx_sync_o         => rx_sync_s,
      txo_o             => txo_o,
      txo_t             => txo_t,
      rxi               => rxi,
      can_l             => can_l,
      can_h             => can_h
    );

end behavior;
