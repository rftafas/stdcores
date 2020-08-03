----------------------------------------------------------------------------------------------------------
-- SPI MASTER / AXI SLAVE
-- Ricardo Tafas
-- This is open source code licensed under LGPL.
-- By using it on your system you agree with all LGPL conditions.
-- This code is provided AS IS, without any sort of warranty.
-- Author: Ricardo F Tafas Jr
-- 2019
---------------------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

package axis_s_spim_pkg is

	function edge_config (CPOL : std_logic; CPHA: std_logic) return std_logic;
	type spi_clock_t is (native, oversampled);

	component axis_s_spi_m is
		generic (
			TLAST_ENABLE	  : boolean	:= true;
			TKEEP_ENABLE	  : boolean	:= true;
			SLAVE_NUM     	: integer	:= 4;
			TDATA_BYTE_NUM	: integer	:= 4;
			clock_mode      : spi_clock_t := oversampled
		);
		port (
			rst_i        : in std_logic;
			mclk_i	     : in std_logic;
		  ref_clk_i  	 : in std_logic;
			--slave axi port
			s_tdata_i    : in  std_logic_vector(TDATA_BYTE_NUM*8-1 downto 0);
			s_tkeep_i    : in  std_logic_vector(TDATA_BYTE_NUM-1 downto 0);
			s_tdest_i    : in  std_logic_vector(SLAVE_NUM-1 downto 0);
			s_tready_o   : out std_logic;
			s_tvalid_i   : in  std_logic;
			s_tlast_i    : in  std_logic;
			--master axi port
			m_tdata_o    : out std_logic_vector(TDATA_BYTE_NUM*8-1 downto 0);
			m_tkeep_o    : out std_logic_vector(TDATA_BYTE_NUM-1 downto 0);
			m_tdest_o    : out std_logic_vector(SLAVE_NUM-1 downto 0);
			m_tready_i   : in  std_logic;
			m_tvalid_o   : out std_logic;
			m_tlast_o    : out std_logic;
			--spi master
			mosi_o       : out std_logic;
			miso_i       : in  std_logic;
			spck_o       : out std_logic;
			spcs_o       : out std_logic_vector(SLAVE_NUM-1 downto 0)
			);
	end component;

	component spi_master is
	  generic (
	    edge       : std_logic   := '0';
	    clock_mode : spi_clock_t := oversampled
	  );
	  port (
	    --general
	    rst_i          : in  std_logic;
	    mclk_i         : in  std_logic;
	    refclk_i       : in  std_logic;
	    --spi
	    spck_o         : out std_logic;
	    miso_i         : in  std_logic;
	    mosi_o         : out std_logic;
	    spcs_o         : out std_logic;
	    --Internal
	    spi_tx_valid_i : in  std_logic;
	    spi_rxen_o     : out std_logic;
	    spi_txen_o     : out std_logic;
	    spi_rxdata_o   : out std_logic_vector(7 downto 0);
	    spi_txdata_i   : in  std_logic_vector(7 downto 0)
	  );
	end component;

end axis_s_spim_pkg;

package body axis_s_spim_pkg is

	function edge_config (CPOL : std_logic; CPHA: std_logic) return std_logic is
	begin
		return CPOL xnor CPHA;
	end edge_config;

end axis_s_spim_pkg;
