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
use ieee.math_real.all;

entity verification_top is
  generic (
    test_sel                         : testtype_t       := all_ones;
    prbs_sel                         : prbs_t           := prbs23;
    packet                           : boolean          := false;
    packet_random                    : boolean          := false;
    packet_size_max                  : integer          := 1023;
    packet_size_min                  : integer          := 32;
    TUSER_SIZE                       : integer          := 4;
    -- Verbosisty
    verbose                          : boolean          := false;
    -- Parameters of Axi Master Bus Interface M00_AXI
    C_M00_AXI_START_DATA_VALUE       : std_logic_vector := x"AA000000";
    C_M00_AXI_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"40000000";
    C_M00_AXI_ADDR_WIDTH             : integer          := 32;
    C_M00_AXI_DATA_WIDTH             : integer          := 32;
    C_M00_AXI_TRANSACTIONS_NUM       : integer          := 5;

    -- Parameters of Axi Slave Bus Interface S00_AXIS
    AXI_TDATA_BYTES_WIDTH : integer := 16
  );
  port (
    -- Users to add ports here
    addr_i           : in  std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
    data_i           : in  std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
    data_o           : out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
    command          : in  std_logic_vector(2 downto 0);
    start            : in  std_logic;
    busy             : out std_logic;
    -- Ports of Axi Master Bus Interface M00_AXI
    m00_axi_aclk     : in  std_logic;
    m00_axi_aresetn  : in  std_logic;
    m00_axi_awaddr   : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
    m00_axi_awprot   : out std_logic_vector(2 downto 0);
    m00_axi_awvalid  : out std_logic;
    m00_axi_awready  : in  std_logic;
    m00_axi_wdata    : out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
    m00_axi_wstrb    : out std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0);
    m00_axi_wvalid   : out std_logic;
    m00_axi_wready   : in  std_logic;
    m00_axi_bresp    : in  std_logic_vector(1 downto 0);
    m00_axi_bvalid   : in  std_logic;
    m00_axi_bready   : out std_logic;
    m00_axi_araddr   : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
    m00_axi_arprot   : out std_logic_vector(2 downto 0);
    m00_axi_arvalid  : out std_logic;
    m00_axi_arready  : in  std_logic;
    m00_axi_rdata    : in  std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
    m00_axi_rresp    : in  std_logic_vector(1 downto 0);
    m00_axi_rvalid   : in  std_logic;
    m00_axi_rready   : out std_logic;
    -- Ports of Axi Slave Bus Interface S00_AXIS
    s00_axis_aclk    : in  std_logic;
    s00_axis_aresetn : in  std_logic;
    s00_axis_tready  : out std_logic;
    s00_axis_tdata   : in  std_logic_vector(AXI_TDATA_BYTES_WIDTH*8-1 downto 0);
    s00_axis_tstrb   : in  std_logic_vector(AXI_TDATA_BYTES_WIDTH-1 downto 0);
    s00_axis_tuser   : in  std_logic_vector(TUSER_SIZE-1 downto 0);
    s00_axis_tdest   : in  std_logic_vector(1 downto 0);
    s00_axis_tlast   : in  std_logic;
    s00_axis_tvalid  : in  std_logic;
    -- Ports of Axi Master Bus Interface M00_AXIS
    m00_axis_aclk    : in  std_logic;
    m00_axis_aresetn : in  std_logic;
    m00_axis_tvalid  : out std_logic;
    m00_axis_tdata   : out std_logic_vector(AXI_TDATA_BYTES_WIDTH*8-1 downto 0);
    m00_axis_tuser   : out std_logic_vector(TUSER_SIZE-1 downto 0);
    m00_axis_tdest   : out std_logic_vector(1 downto 0);
    m00_axis_tstrb   : out std_logic_vector(AXI_TDATA_BYTES_WIDTH-1 downto 0);
    m00_axis_tlast   : out std_logic;
    m00_axis_tready  : in  std_logic
  );
end verification_top;


architecture arch_imp of verification_top is
  signal TEST_START       : BOOLEAN := TRUE;

	type size_array is array (2**TUSER_SIZE-1 downto 0) of integer;
	signal size_buffer : size_array := (others => 0);

	signal m00_axis_tlast_s       : std_logic;
	signal m00_axis_tuser_s       : std_logic_vector(m00_axis_tuser'range);
	signal s00_axis_tuser_s       : std_logic_vector(s00_axis_tuser'range);
	signal current_packet_size_rx : integer;
	signal current_packet_size_s  : integer;

begin

    -- Instantiation of Axi Bus Interface M00_AXI
    verification_ip_MAXI_u : verification_ip_MAXI
        generic map (
          verbose                 => verbose,
          C_M_AXI_ADDR_WIDTH	    => C_M00_AXI_ADDR_WIDTH,
          C_M_AXI_DATA_WIDTH	    => C_M00_AXI_DATA_WIDTH
        )
        port map (
			    addr_i    => addr_i,
			    data_i    => data_i,
			    data_o    => data_o,
			    command   => command,
			    start     => start,
			    busy      => busy,
          M_AXI_ACLK	    => m00_axi_aclk,
          M_AXI_ARESETN	=> m00_axi_aresetn,
          M_AXI_AWADDR	=> m00_axi_awaddr,
          M_AXI_AWPROT	=> m00_axi_awprot,
          M_AXI_AWVALID	=> m00_axi_awvalid,
          M_AXI_AWREADY	=> m00_axi_awready,
          M_AXI_WDATA	  => m00_axi_wdata,
          M_AXI_WSTRB	  => m00_axi_wstrb,
          M_AXI_WVALID	=> m00_axi_wvalid,
          M_AXI_WREADY	=> m00_axi_wready,
          M_AXI_BRESP	  => m00_axi_bresp,
          M_AXI_BVALID	=> m00_axi_bvalid,
          M_AXI_BREADY	=> m00_axi_bready,
          M_AXI_ARADDR	=> m00_axi_araddr,
          M_AXI_ARPROT	=> m00_axi_arprot,
          M_AXI_ARVALID	=> m00_axi_arvalid,
          M_AXI_ARREADY	=> m00_axi_arready,
          M_AXI_RDATA	  => m00_axi_rdata,
          M_AXI_RRESP	  => m00_axi_rresp,
          M_AXI_RVALID	=> m00_axi_rvalid,
          M_AXI_RREADY	=> m00_axi_rready
        );

    -- Instantiation of Axi Bus Interface S00_AXIS
    verification_ip_SAXIS_u : verification_ip_SAXIS
        generic map (
            test_number     => test_number,
            prbs_sel        => prbs_sel,
            packet          => packet,
						packet_random   => packet_random,
            packet_size_max => packet_size_max,
            packet_size_min => packet_size_min
        )
        port map (
            TEST_START          => TEST_START,
						current_packet_size => current_packet_size_rx,
						--
            S_AXIS_ACLK	   => s00_axis_aclk,
            S_AXIS_ARESETN => s00_axis_aresetn,
            S_AXIS_TREADY	 => s00_axis_tready,
            S_AXIS_TDATA	 => s00_axis_tdata,
            S_AXIS_TSTRB	 => s00_axis_tstrb,
            S_AXIS_TLAST	 => s00_axis_tlast,
            S_AXIS_TUSER	 => s00_axis_tuser_s,
            S_AXIS_TDEST	 => s00_axis_tdest,
            S_AXIS_TVALID	 => s00_axis_tvalid
        );

		s00_axis_tuser_s <= s00_axis_tuser;
		current_packet_size_rx <= size_buffer(to_integer(unsigned(s00_axis_tuser_s)));

    -- Instantiation of Axi Bus Interface M00_AXIS
    verification_ip_MAXIS_u : verification_ip_MAXIS
        generic map (
            test_number     => test_number,
            prbs_sel        => prbs_sel,
            packet          => packet,
            packet_random   => packet_random,
            packet_size_max => packet_size_max,
            packet_size_min => packet_size_min
        )
        port map (
            TEST_START          => TEST_START,
						current_packet_size => current_packet_size_s,
						--
            M_AXIS_ACLK	   => m00_axis_aclk,
            M_AXIS_ARESETN => m00_axis_aresetn,
            M_AXIS_TVALID	 => m00_axis_tvalid,
            M_AXIS_TDATA	 => m00_axis_tdata,
            M_AXIS_TSTRB	 => m00_axis_tstrb,
            M_AXIS_TLAST	 => m00_axis_tlast_s,
            M_AXIS_TUSER	 => m00_axis_tuser_s,
            M_AXIS_TDEST	 => m00_axis_tdest,
            M_AXIS_TREADY	 => m00_axis_tready
        );

	m00_axis_tlast <= m00_axis_tlast_s;
  m00_axis_tuser <= m00_axis_tuser_s;

	process(m00_axis_tuser_s)
	begin
		size_buffer(to_integer(unsigned(m00_axis_tuser_s))) <= current_packet_size_s;
	end process;

	--contratos
	contract_gen : if packet_random generate

			assert packet_size_min > 0
		 		report "Minimun packet size for test must be > 0"
		 		severity error;
		  assert packet_size_max > 1
		 		report "Minimun packet size for random size test must be > 1"
		 		severity error;
			assert packet_size_max > packet_size_min
				report "packet_size_max must be greater than packet_size_min"
				severity error;

	end generate;

	assert packet_size_max > 1
		report "Minimun packet size for fixed size test must be > 0"
		severity failure;

	assert C_M00_AXI_DATA_WIDTH mod 8 = 0
	  report "AXI MM data port must be multiple of BYTE."
	  severity failure;
	assert C_M00_AXI_DATA_WIDTH > 0
	  report "AXI MM data port must be non-zero."
	  severity failure;
	assert C_M00_AXI_ADDR_WIDTH > 0
	  report "AXI MM address port must be non-zero."
	  severity failure;



end arch_imp;
