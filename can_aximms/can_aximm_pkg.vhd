---------------------------------------------------------------------------------
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
--
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-- For more information, please refer to <http://unlicense.org/>
---------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

package can_aximm_pkg is

  --generic  (
    --Package Generics go here.
  --);
  constant golden_c           : std_logic_vector(31 downto 0) := x"A1A2A3A4";
  constant C_S_AXI_ADDR_WIDTH : integer := 7;
  constant C_S_AXI_DATA_WIDTH : integer := 32;
  constant package_version_c  : String := "20210423_1504";

  component can_aximm_top is
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
  end component;

  component can_clk is
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
  end component;

  component can_rx is
    port (
        rst_i          : in  std_logic;
        mclk_i         : in  std_logic;
        rx_clken_i     : in  std_logic;
        fb_clken_i     : in  std_logic;
        --can signals can be bundled in TUSER
        usr_eff_o      : out std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_id_o       : out std_logic_vector(28 downto 0); -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_rtr_o      : out std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_dlc_o      : out std_logic_vector(3 downto 0);
        usr_rsvd_o     : out std_logic_vector(1 downto 0);
        data_o         : out std_logic_vector(63 downto 0);
        data_ready_i   : in  std_logic;
        data_valid_o   : out std_logic;
        data_last_o    : out std_logic;
        --status
        reg_id_i       : in  std_logic_vector(28 downto 0);
        reg_id_mask_i  : in  std_logic_vector(28 downto 0);
        busy_o         : out std_logic;
        rx_crc_error_o : out std_logic;
        send_ack_o     : out std_logic;
        --Signals to PHY
        collision_i    : in  std_logic;
        rxdata_i       : in  std_logic
    );
  end component;

  component can_tx is
    port (
        rst_i        : in  std_logic;
        mclk_i       : in  std_logic;
        tx_clken_i   : in  std_logic;
        fb_clken_i   : in  std_logic;
        --can signals can be bundled in TUSER
        usr_eff_i    : in  std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_id_i     : in  std_logic_vector(28 downto 0); -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_rtr_i    : in  std_logic;                     -- 32 bit can_id + eff/rtr/err flags             can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags
        usr_dlc_i    : in  std_logic_vector(3 downto 0);
        usr_rsvd_i   : in  std_logic_vector(1 downto 0);
        data_i       : in  std_logic_vector(63 downto 0);
        data_ready_o : out std_logic;
        data_valid_i : in  std_logic;
        data_last_i  : in  std_logic;
        --status
        rtry_error_o : out std_logic;
        ack_error_o  : out std_logic;
        arb_lost_o   : out std_logic;
        busy_o       : out std_logic;
        --Signals to PHY
        ch_ready_i   : in  std_logic;
        collision_i  : in  std_logic;
        txdata_o     : out std_logic;
        txen_o       : out std_logic
    );
  end component;

  component can_phy is
    generic (
        internal_phy      : boolean := false
    );
    port (
        rst_i             : in  std_logic;
        mclk_i            : in  std_logic;
        --configs
        force_error_i     : in  std_logic;
        lock_dominant_i   : in  std_logic;
        loopback_i        : in  std_logic;
        --stats
        stuff_violation_o : out std_logic;
        collision_o       : out std_logic;
        channel_ready_o   : out std_logic;
        --commands
        send_ack_i        : in  std_logic;
        -- data channel;
        tx_clken_i        : in  std_logic;
        rx_clken_i        : in  std_logic;
        fb_clken_i        : in  std_logic;
        tx_i              : in  std_logic;
        tx_en_i           : in  std_logic;
        rx_o              : out std_logic;
        rx_sync_o         : out std_logic;
        --external PHY
        txo_o : out   std_logic;
        txo_t : out   std_logic;
        rxi   : in    std_logic;
        --internal phy
        can_l : inout std_logic;
        can_h : inout std_logic
    );
  end component;

  component can_aximm is
    generic (
      C_S_AXI_ADDR_WIDTH : integer := 7;
      C_S_AXI_DATA_WIDTH : integer := 32
    );
    port (
      S_AXI_ACLK        : in  std_logic;
      S_AXI_ARESETN     : in  std_logic;
      S_AXI_AWADDR      : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_AWPROT      : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID     : in  std_logic;
      S_AXI_AWREADY     : out std_logic;
      S_AXI_WDATA       : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_WSTRB       : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
      S_AXI_WVALID      : in  std_logic;
      S_AXI_WREADY      : out std_logic;
      S_AXI_BRESP       : out std_logic_vector(1 downto 0);
      S_AXI_BVALID      : out std_logic;
      S_AXI_BREADY      : in  std_logic;
      S_AXI_ARADDR      : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
      S_AXI_ARPROT      : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID     : in  std_logic;
      S_AXI_ARREADY     : out std_logic;
      S_AXI_RDATA       : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
      S_AXI_RRESP       : out std_logic_vector(1 downto 0);
      S_AXI_RVALID      : out std_logic;
      S_AXI_RREADY      : in  std_logic;
      g1_i              : in  std_logic_vector(31 downto 0);
      iso_mode_o        : out std_logic;
      fd_enable_o       : out std_logic;
      sample_rate_o     : out std_logic_vector(15 downto 0);
      rx_irq_i          : in  std_logic;
      rx_irq_mask_o     : out std_logic;
      tx_irq_i          : in  std_logic;
      tx_irq_mask_o     : out std_logic;
      stuff_violation_i : in  std_logic;
      collision_i       : in  std_logic;
      channel_ready_i   : in  std_logic;
      loop_enable_o     : out std_logic;
      insert_error_o    : out std_logic;
      force_dominant_o  : out std_logic;
      rx_data_valid_i   : in  std_logic;
      rx_read_done_o    : out std_logic;
      rx_busy_i         : in  std_logic;
      rx_crc_error_i    : in  std_logic;
      rx_rtr_i          : in  std_logic;
      rx_ide_i          : in  std_logic;
      rx_reserved_i     : in  std_logic_vector(1 downto 0);
      id1_o             : out std_logic_vector(28 downto 0);
      id1_mask_o        : out std_logic_vector(28 downto 0);
      rx_size_i         : in  std_logic_vector(3 downto 0);
      rx_id_i           : in  std_logic_vector(28 downto 0);
      rx_data0_i        : in  std_logic_vector(31 downto 0);
      rx_data1_i        : in  std_logic_vector(31 downto 0);
      tx_ready_i        : in  std_logic;
      tx_valid_o        : out std_logic;
      tx_busy_i         : in  std_logic;
      tx_arb_lost_i     : in  std_logic;
      tx_retry_error_i  : in  std_logic;
      tx_rtr_o          : out std_logic;
      tx_eff_o          : out std_logic;
      tx_reserved_o     : out std_logic_vector(1 downto 0);
      tx_dlc_o          : out std_logic_vector(3 downto 0);
      tx_id_o           : out std_logic_vector(28 downto 0);
      tx_data0_o        : out std_logic_vector(31 downto 0);
      tx_data1_o        : out std_logic_vector(31 downto 0)
    );
  end component;

  procedure crc15(        vector : inout std_logic_vector(14 downto 0); input : in  std_logic);
  --procedure crc15( signal vector : inout std_logic_vector(14 downto 0); input : in  std_logic);

end can_aximm_pkg;

package body can_aximm_pkg is

  procedure crc15( vector : inout std_logic_vector(14 downto 0); input : in  std_logic) is
    variable crc_v : std_logic_vector(15 downto 0);
  begin
      --input and shift
      crc_v(15 downto 1) := vector;
      --xor
      crc_v(0) := crc_v(15) xor crc_v(14) xor crc_v(10) xor crc_v(8) xor crc_v(7) xor crc_v(4) xor crc_v(3) xor input;
      --output
      vector   := crc_v(14 downto 0);
  end procedure;

  -- procedure crc15( signal vector : inout std_logic_vector(14 downto 0); input : in  std_logic) is
  --   variable crc_v : std_logic_vector(14 downto 0);
  -- begin
  --   crc_v := vector;
  --   crc15(crc_v,input);
  --   vector <= crc_v;
  -- end procedure;

end package body;

