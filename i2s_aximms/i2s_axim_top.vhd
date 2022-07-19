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
--Generic Configs:
--Fmclk_hz            - Master clock frequency
--Fref_hz             - Reference clock input frequency
--use_clock_generator - Enables selection of internal NCO as reference and generates sample
--                      frequency from the master clock. Generates LRCLK internally.
--use_adpll           - Enables selection of internal ADPLL, with factionary ration between Sample Frequency
--                      and Reference. Generates LRCLK internally.
--use_int_divider     - Enable selection of integer clock divider of the reference frequency by an integer to
--                      create the Sample Frequency. Generates LRCLK internally.
--enable_bclk_input   - enables using BCLK_I as the base clock. LRCLK_I as the channel signal.
--enable_clock_status - enables selected clock source detection, status, IRQ generation and debug.
---------------------------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.fifo_lib.all;
library stdcores;
  use stdcores.i2s_aximms_pkg.all;

entity i2s_aximms_top is
  generic (
    C_S_AXI_ADDR_WIDTH    : integer := 7;
    C_S_AXI_DATA_WIDTH    : integer := 32;
    Fmclk_hz_c            : real    := 100.0000e+6;
    Fref_hz_c             : real    :=   3.0720e+6;
    enable_bclk_input_c   : boolean := false;
    use_clock_generator_c : boolean := true;
    use_adpll_c           : boolean := true;
    use_int_divider_c     : boolean := true;
    enable_clock_status_c : boolean := true;
    enable_stream_c       : boolean := true;
    golden_reg_value_c    : std_logic_vector(31 downto 0) := x"A1A2A3A4"
  );
  port (
    --general
    rst_i     : in  std_logic;
    mclk_i    : in  std_logic;
    --i2c
    i2s_i     : in  std_logic;
    i2s_o     : out std_logic;
    bclk_i    : in  std_logic;
    lrclk_i   : in  std_logic;
    bclk_o    : out std_logic;
    lrclk_o   : out std_logic;
    --stream input/output
    i2s_m_tvalid  : out std_logic;
    i2s_m_tready  : in  std_logic;
    i2s_m_tlast   : out std_logic;
    i2s_m_tdata   : out std_logic_vector(63 downto 0);
    i2s_s_tvalid  : in  std_logic;
    i2s_s_tready  : out std_logic;
    i2s_s_tlast   : in  std_logic;
    i2s_s_tdata   : in  std_logic_vector(63 downto 0);
    --IRQs
    i2s_irq_o     : out std_logic;
    --AXI-MM
    --M_AXI_AWID    : out std_logic_vector(ID_WIDTH - 1 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;
    M_AXI_AWADDR  : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    --write data channel
    M_AXI_WVALID  : out std_logic;
    M_AXI_WREADY  : in  std_logic;
    M_AXI_WDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB   : out std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    M_AXI_WLAST   : out std_logic;
    --Write Response channel
    M_AXI_BVALID  : in  std_logic;
    M_AXI_BREADY  : out std_logic;
    M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    --M_AXI_BID     : in  std_logic_vector(ID_WIDTH - 1 downto 0);
    -- Read Address channel
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;
    M_AXI_ARADDR  : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    --M_AXI_ARID    : out std_logic_vector(ID_WIDTH - 1 downto 0);
    --Read data channel
    M_AXI_RVALID : in  std_logic;
    M_AXI_RREADY : out std_logic;
    M_AXI_RDATA  : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    M_AXI_RRESP  : in  std_logic_vector(1 downto 0);
    --M_AXI_RID    : in  std_logic_vector(ID_WIDTH - 1 downto 0);
    M_AXI_RLAST  : in  std_logic
  );
end i2s_aximms_top;

architecture behavioral of i2s_aximms_top is

  signal bclk_i_s     :  std_logic;
  signal lrclk_i_s    :  std_logic;

  signal ws_s         : std_logic;
  signal sck_s        : std_logic;
  signal sck_en       : std_logic;


  signal int_tstrb_s  : std_logic_vector( 3 downto 0);
  signal int_tdest_s  : std_logic_vector( 7 downto 0);
  signal int_tdata_s  : std_logic_vector(31 downto 0);
  signal int_tvalid_s : std_logic;

  signal i2s_mm_left_o_s        : std_logic_vector(31 downto 0);
  signal i2s_mm_left_rd_act_en  : std_logic;
  signal i2s_mm_left_wr_act_en  : std_logic;
  signal i2s_mm_right_o_s       : std_logic_vector(31 downto 0);
  signal i2s_mm_right_rd_act_en : std_logic;
  signal i2s_mm_right_wr_act_en : std_logic;


  signal rx_fifo_status_s : fifo_state_t;
  signal tx_fifo_status_s : fifo_state_t;

  alias i2s_mm_left_i_a  : std_logic_vector(31 downto 0) is data_fifo_to_axi_s(63 downto 32);
  alias i2s_mm_right_i_a : std_logic_vector(31 downto 0) is data_fifo_to_axi_s(31 downto  0);

  signal aximm_wdata_en : std_logic;
  signal aximm_rdata_en : std_logic;

begin

  assert Fmclk_hz > 10.000 * Fref_hz
    report "Fmclk must be 10x higher than Fref. Less may cause abormal operation."
    severity error;

  --if BCLK_I is used as input, BCLK_O reflects it. Not used otherwise.
  bclk_gen : if bclk_input generate
    sync_sda_u : sync_r
      generic map(2)
      port map('0', mclk_i, bclk_i, bclk_s);

    sync_sda_u : sync_r
      generic map(2)
      port map('0', mclk_i, lrclk_i, lrclk_s);

    bclk_o  <=  bclk_i;
    lrclk_o <=  lrclk_i;

  else generate

    clock_u : i2s_clock
      generic (
        Fmclk_hz           => 100.0000e+6,
        Fref_hz            =>   3.0720e+6,
        use_clock_generator => use_clock_generator,
        use_adpll           => use_adpll,
        use_int_divider     => use_int_divider
      )
      port (
        --general
        rst_i           => rst_i,
        mclk_i          => mclk_i,
        clkref_i        => clkref_i,
        --spi
        ref_divider_i   => ref_divider_s,
        frame_size_i    => frame_size_s,
        clock_master_i  => clock_master_s,
        --I2S clocks
        lrclk_o         => bclk_s,
        bclk_o          => lrclk_s,
      );

      bclk_o  <=  bclk_s;
      lrclk_o <=  lrclk_s;

  end generate;


  i2s_core_u : i2s_core
    port map(
      rst_i          => rst_i,
      mclk_i         => mclk_i,
      i2s_i          => i2s_i,
      i2s_o          => i2s_o,
      bclk_i         => bclk_s,
      lrclk_i        => lrclk_s,
      audio_enable_o => i2s_core_en,
      audio_data_o   => data_i2s_to_fifo_s,
      audio_data_i   => data_fifo_to_i2s_s
    );

  data_i2s_to_fifo_en <= i2s_core_en;
  data_fifo_to_i2s_en <= i2s_core_en

  input_u : stdfifo2ck
    generic (
      ram_type  => distributed;
      fifo_size => 16,
      port_size => 64
    );
    port (
      --general
      clk_i         => mclk_i,
      rst_i         => rst_i,
      dataa_i       => data_i2s_to_fifo_s,
      datab_o       => data_fifo_to_axi_s,
      ena_i         => data_i2s_to_fifo_en,
      enb_i         => data_fifo_to_axi_en,

      fifo_status_o => input_fifo_status
    );

  data_fifo_to_axi_en <=  not input_fifo_status.empty and i2s_m_tready when enable_stream else
                          aximm_rdata_en;

  i2s_m_tdata    <= data_fifo_to_axi_s          when enable_stream else (others=>'0');
  i2s_m_tvalid   <= not input_fifo_status.empty when enable_stream else '0';
  i2s_m_tlast    <= not input_fifo_status.empty when enable_stream else '0';

  output_u : stdfifo2ck
    generic (
      ram_type  => distributed;
      fifo_size => 16,
      port_size => 64
    );
    port (
      --general
      clk_i         => mclk_i,
      rst_i         => rst_i,
      dataa_i       => data_axi_to_i2s_s,
      datab_o       => data_fifo_to_i2s_s,
      ena_i         => data_axi_to_i2s_en,
      enb_i         => data_fifo_to_i2s_en,

      fifo_status_o => output_fifo_status
    );

  data_axi_to_i2s_s  <= i2s_s_tdata when enable_stream else
                        (i2s_mm_left_o_s & i2s_mm_right_o_s);

  data_axi_to_i2s_en <= not output_fifo_status.full and i2s_s_tvalid when enable_stream else
                        aximm_wdata_en;

  i2s_s_tready       <= not output_fifo_status.full when enable_stream else
                        '0';


------------------------------------
--Regbank
------------------------------------
  S_AXI_ARESETN_s <= not rst_i;

  i2s_regbank_u : i2s_regbank
    generic map (
      C_S_AXI_ADDR_WIDTH => 7,
      C_S_AXI_DATA_WIDTH => 32
    )
    port map (
      S_AXI_ACLK            => mclk_i,
      S_AXI_ARESETN         => S_AXI_ARESETN_s,
      S_AXI_AWADDR          => S_AXI_AWADDR,
      S_AXI_AWPROT          => S_AXI_AWPROT,
      S_AXI_AWVALID         => S_AXI_AWVALID,
      S_AXI_AWREADY         => S_AXI_AWREADY,
      S_AXI_WDATA           => S_AXI_WDATA,
      S_AXI_WSTRB           => S_AXI_WSTRB,
      S_AXI_WVALID          => S_AXI_WVALID,
      S_AXI_WREADY          => S_AXI_WREADY,
      S_AXI_BRESP           => S_AXI_BRESP,
      S_AXI_BVALID          => S_AXI_BVALID,
      S_AXI_BREADY          => S_AXI_BREADY,
      S_AXI_ARADDR          => S_AXI_ARADDR,
      S_AXI_ARPROT          => S_AXI_ARPROT,
      S_AXI_ARVALID         => S_AXI_ARVALID,
      S_AXI_ARREADY         => S_AXI_ARREADY,
      S_AXI_RDATA           => S_AXI_RDATA,
      S_AXI_RRESP           => S_AXI_RRESP,
      S_AXI_RVALID          => S_AXI_RVALID,
      S_AXI_RREADY          => S_AXI_RREADY,
      g1_i                  => golden_reg_value_c,
      bclk_edge_o           => open,
      lrclk_polarity_o      => open,
      lrclk_justified_o     => open,
      frame_size_o          => open,
      clock_source_o        => open,
      sample_rate_o         => open,
      ref_div_o             => open,
      ref_mult_o            => open,
      rxfull_irq_i          => open,
      txempty_irq_i         => open,
      bclk_err_irq_i        => open,
      lrclk_err_irq_i       => open,
      rxfull_irq_mask_o     => open,
      txempty_irq_mask_o    => open,
      bclk_err_irq_mask_o   => open,
      lrclk_err_irq_mask_o  => open,
      rx_fifo_status_i      => rx_fifo_status_s,
      tx_fifo_status_i      => tx_fifo_status_s,
      i2s_mm_left_i         => i2s_mm_left_i_a,
      i2s_mm_left_o         => i2s_mm_left_o_s,
      i2s_mm_left_rd_act_o  => i2s_mm_left_rd_act_en,
      i2s_mm_left_wr_act_o  => i2s_mm_left_wr_act_en,
      i2s_mm_right_i        => i2s_mm_right_i_a,
      i2s_mm_right_o        => i2s_mm_right_o_s,
      i2s_mm_right_rd_act_o => i2s_mm_right_rd_act_en,
      i2s_mm_right_wr_act_o => i2s_mm_right_wr_act_en
  );


  --Align read/write signals from the reagbank when streaming is not in use.
  --So a full read of data means reading both registers. Same for write.
  aximm_rdata_u : stretch_sync
    port map(
      rst_i   => rst_i,
      mclk_i  => mclk_i,
      da_i    => i2s_mm_left_rd_act_en,
      db_i    => i2s_mm_right_rd_act_en,
      dout_o  => aximm_rdata_en
    );

  aximm_wdata_u : stretch_sync
    port map(
      rst_i   => rst_i,
      mclk_i  => mclk_i,
      da_i    => i2s_mm_left_wr_act_en,
      db_i    => i2s_mm_right_wr_act_en,
      dout_o  => aximm_wdata_en
    );

  rx_fifo_status_s <= "00" when input_fifo_status.steady = '1' else
                      "01" when input_fifo_status.full   = '1' else
                      "01" when input_fifo_status.empty  = '1' else
                      "11";

  tx__fifo_status_s <=  "00" when output_fifo_status.steady = '1' else
                        "01" when output_fifo_status.full   = '1' else
                        "01" when output_fifo_status.empty  = '1' else
                        "11";

end behavioral;
