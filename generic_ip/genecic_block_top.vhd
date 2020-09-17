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
library stdcores;
	use stdcores.genecic_block_pkg.all;

entity genecic_block_top is
	generic (
		ram_addr            : positive := 9;
		tdata_size					: positive := 128;
		tdest_size					: positive := 1;
		tuser_size					: positive := 1;
		pipe_num						: positive := 1
		type heap_t;
		procedure block_operation (input : in std_logic_vector; output : out std_logic_vector; config_i : in reg_t; status_o : out reg_t; variable heap_io : inout heap_t )
	);
	port (
	   -- Users to add ports here
	   mclk_i	  : in std_logic;
	   resetn_i	: in std_logic;
		-- User ports ends

		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_awaddr	: in  std_logic_vector(7 downto 0);
		s00_axi_awprot	: in  std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in  std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	  : in  std_logic_vector(31 downto 0);
		s00_axi_wstrb	  : in  std_logic_vector(3 downto 0);
		s00_axi_wvalid	: in  std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	  : out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in  std_logic;
		s00_axi_araddr	: in  std_logic_vector(7 downto 0);
		s00_axi_arprot	: in  std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in  std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	  : out std_logic_vector(31 downto 0);
		s00_axi_rresp	  : out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in  std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in  std_logic_vector(tdata_size-1 downto 0);
		s00_axis_tstrb  : in  std_logic_vector(tdata_size/8-1 downto 0);
		s00_axis_tlast	: in  std_logic;
		s00_axis_tvalid	: in  std_logic;
		s00_axis_tuser	: in  std_logic_vector(tuser_size-1 downto 0);
		s00_axis_tdest	: in  std_logic_vector(tdest_size-1 downto 0);

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(tdata_size-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector(tdata_size/8-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in  std_logic;
		m00_axis_tuser	: out std_logic_vector(tuser_size-1 downto 0);
		m00_axis_tdest	: out std_logic_vector(tdest_size-1 downto 0)
	);
end genecic_block_top;

architecture top_arch of genecic_block_top is

	alias s00_axi_aclk	    : std_logic is mclk_i;
	alias s00_axi_aresetn	  : std_logic is resetn_i;
	alias s00_axis_aclk	    : std_logic is mclk_i;
	alias s00_axis_aresetn  : std_logic is resetn_i;
	alias m00_axis_aclk	    : std_logic is mclk_i;
	alias m00_axis_aresetn	: std_logic is resetn_i;

	signal data_o_s 	         : std_logic_vector(tdata_size-1 downto 0);
  signal empty_o_s	         : std_logic;
  signal oen_i_s	           : std_logic;
  signal data_i_s            : std_logic_vector(tdata_size-1 downto 0);
  signal ien_i_s             : std_logic;
  signal full_o_s            : std_logic;
	signal start_s             : std_logic;
	signal stop_s              : std_logic;

  signal oreg_o_s         : reg_t;
  signal ireg_i_s         : reg_t;

  signal fifo_full_o_s    : std_logic;
  signal fifo_empty_o_s   : std_logic;
  signal busy_o_s         : std_logic;

begin

-- Instantiation of Axi Bus Interface S00_AXI
	regbank_u : genecic_block_regs
	  port map (
	    oreg_o    => oreg_o_s,
	    ireg_i    => ireg_i_s,
	    pulse_o   => pulse_o_s,
	    capture_i => capture_i_s,

	    S_AXI_ACLK    => s00_axi_aclk,
	    S_AXI_ARESETN => s00_axi_aresetn,
	    S_AXI_AWADDR  => s00_axi_awaddr,
	    S_AXI_AWPROT  => s00_axi_awprot,
	    S_AXI_AWVALID => s00_axi_awvalid,
	    S_AXI_AWREADY => s00_axi_awready,
	    S_AXI_WDATA   => s00_axi_wdata,
	    S_AXI_WSTRB   => s00_axi_wstrb,
	    S_AXI_WVALID  => s00_axi_wvalid,
	    S_AXI_WREADY  => s00_axi_wready,
	    S_AXI_BRESP   => s00_axi_bresp,
	    S_AXI_BVALID  => s00_axi_bvalid,
	    S_AXI_BREADY  => s00_axi_bready,
	    S_AXI_ARADDR  => s00_axi_araddr,
	    S_AXI_ARPROT  => s00_axi_arprot,
	    S_AXI_ARVALID => s00_axi_arvalid,
	    S_AXI_ARREADY => s00_axi_arready,
	    S_AXI_RDATA   => s00_axi_rdata,
	    S_AXI_RRESP   => s00_axi_rresp,
	    S_AXI_RVALID  => s00_axi_rvalid,
	    S_AXI_RREADY  => s00_axi_rready
	  );

	-- Add user logic here
	generic_block_inst: genecic_block_core
    generic map(
      ram_addr        => ram_addr,
      data_size       => tdata_size,
			pipe_num	      => 1,
			heap_t          => heap_t,
			block_operation => block_operation
    )
    port map(
      mclk_i       => mclk_i,
			arst_i       => resetn_i,

      --gets data
      tready_o     => s00_axis_tready,
      tdata_i      => s00_axis_tdata,
      tvalid_i     => s00_axis_tvalid,
			tlast_i      => s00_axis_tlast,
			tuser_i      => s00_axis_tuser,
			tdest_i      => s00_axis_tdest,

      --puts data
      tvalid_o     => m00_axis_tvalid,
      tdata_o      => m00_axis_tdata,
      tlast_o      => m00_axis_tlast,
			tready_i     => m00_axis_tready,
			tuser_o      => m00_axis_tuser,
			tdest_o      => m00_axis_tdest,

      --status and configuration registers
			config_i     => oreg_o_s;
			status_o     => ireg_i_s;
      busy_o       => busy_o_s
    );

end top_arch;
