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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package genecic_block_pkg is

	constant REG_NUM	        : integer := 32;
	constant C_S_AXI_DATA_WIDTH	: integer := 32;

	constant BYTE_NUM           : integer := C_S_AXI_DATA_WIDTH/8;
	constant OPT_MEM_ADDR_BITS  : integer := integer(log2(real( REG_NUM)));
	constant ADDR_LSB           : integer := integer(log2(real(BYTE_NUM)));
	constant C_S_AXI_ADDR_WIDTH : integer := OPT_MEM_ADDR_BITS + ADDR_LSB + 1;

    type reg_t is array (2**OPT_MEM_ADDR_BITS-1 downto 0) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    --mapa de registros.
    --se estiver em '1' é RW.
    --se estiver em '0' é READ ONLY e NO FEEDBACK WRITE. NO FEEDBACK WRITE siginfica não ler o que escreveu.
    constant RW_MAP : reg_t := (
        1  => x"FFFF_FFFF",
        2  => x"FFFF_FFFF",
        3  => x"FFFF_FFFF",
        others => (others => '0')
    );

		component genecic_block_top is
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
		end component genecic_block_top;

		component genecic_block_core is
		    generic (
		        ram_addr     : integer;
		        pipe_num     : integer;
		        data_size    : integer;
		        type heap_t;
		        procedure block_operation (input : in std_logic_vector; output : out std_logic_vector; config_i : in reg_t; status_o : out reg_t; variable heap_io : inout heap_t )
		    );
		    port (
		        mclk_i       : in  std_logic;
		        arst_i       : in  std_logic;

		        --gets data
		        tready_o     : out std_logic;
		        tdata_i      : in  std_logic_vector(data_size-1 downto 0);
		        tvalid_i     : in  std_logic;
		        tlast_i      : in  std_logic;
		        tuser_i      : in  std_logic_vector;
		        tdest_i      : in  std_logic_vector;
		        --puts data
		        tvalid_o     : out std_logic;
		        tdata_o      : out std_logic_vector(data_size-1 downto 0);
		        tlast_o      : out std_logic;
		        tready_i     : in  std_logic;
		        tuser_o      : out std_logic_vector;
		        tdest_o      : out std_logic_vector;

						--status and configuration registers
		        config_i     : reg_t;
		        status_o     : reg_t;
		        busy_o       : out std_logic
		    );
		end component genecic_block_core;

		component genecic_block_regs is
        port (
            oreg_o       : out reg_t;
            ireg_i       : in  reg_t;

            S_AXI_ACLK	    : in  std_logic;
            S_AXI_ARESETN	: in  std_logic;
            S_AXI_AWADDR	: in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT	: in  std_logic_vector(2 downto 0);
            S_AXI_AWVALID	: in  std_logic;
            S_AXI_AWREADY	: out std_logic;
            S_AXI_WDATA	    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB	    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID	: in  std_logic;
            S_AXI_WREADY	: out std_logic;
            S_AXI_BRESP	    : out std_logic_vector(1 downto 0);
            S_AXI_BVALID	: out std_logic;
            S_AXI_BREADY	: in  std_logic;
            S_AXI_ARADDR	: in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT	: in  std_logic_vector(2 downto 0);
            S_AXI_ARVALID	: in  std_logic;
            S_AXI_ARREADY	: out std_logic;
            S_AXI_RDATA	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP	    : out std_logic_vector(1 downto 0);
            S_AXI_RVALID	: out std_logic;
            S_AXI_RREADY	: in  std_logic
        );
    end component genecic_block_regs;

end package;

package body genecic_block_pkg is

end package body;
