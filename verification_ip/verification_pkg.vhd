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
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

package verification_pkg is

	-- component declaration
	component verification_ip_MAXI is
		generic (
			verbose                     : boolean := false;
			C_M_AXI_ADDR_WIDTH	        : integer	:= 32;
			C_M_AXI_DATA_WIDTH	        : integer	:= 32
		);
		port (
			addr_i        : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
			data_i        : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
			data_o        : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
			command       : in  std_logic_vector(2 downto 0);
			start         : in  std_logic;
			busy          : out std_logic;
			M_AXI_ACLK	  : in  std_logic;
			M_AXI_ARESETN	: in  std_logic;
			M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
			M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
			M_AXI_AWVALID	: out std_logic;
			M_AXI_AWREADY	: in  std_logic;
			M_AXI_WDATA	  : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
			M_AXI_WSTRB	  : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
			M_AXI_WVALID	: out std_logic;
			M_AXI_WREADY	: in  std_logic;
			M_AXI_BRESP	  : in  std_logic_vector(1 downto 0);
			M_AXI_BVALID	: in  std_logic;
			M_AXI_BREADY	: out std_logic;
			M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
			M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
			M_AXI_ARVALID	: out std_logic;
			M_AXI_ARREADY	: in  std_logic;
			M_AXI_RDATA	  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
			M_AXI_RRESP	  : in  std_logic_vector(1 downto 0);
			M_AXI_RVALID	: in  std_logic;
			M_AXI_RREADY	: out std_logic
		);
	end component verification_ip_MAXI;

	component verification_ip_SAXIS
		generic (
		  test_number     : integer;
		  prbs_sel        : string;
		  packet          : boolean;
		  packet_random   : boolean;
		  packet_size_max : integer;
		  packet_size_min : integer
		);
		port (
		  TEST_START          : in  BOOLEAN;
		  current_packet_size : in  integer;
		  S_AXIS_ACLK         : in  std_logic;
		  S_AXIS_ARESETN      : in  std_logic;
		  S_AXIS_TREADY       : out std_logic;
		  S_AXIS_TDATA        : in  std_logic_vector;
		  S_AXIS_TSTRB        : in  std_logic_vector;
		  S_AXIS_TLAST        : in  std_logic;
		  S_AXIS_TUSER        : in  std_logic_vector;
		  S_AXIS_TDEST        : in  std_logic_vector;
		  S_AXIS_TVALID       : in  std_logic
		);
	end component verification_ip_SAXIS;

	component verification_ip_MAXIS is
    generic (
      test_number     : integer;
      prbs_sel        : string;
      packet          : boolean;
      packet_random   : boolean;
      packet_size_max : integer;
      packet_size_min : integer
    );
    port (
      TEST_START          : in  BOOLEAN;
      current_packet_size : out integer;
      M_AXIS_ACLK         : in  std_logic;
      M_AXIS_ARESETN      : in  std_logic;
      M_AXIS_TVALID       : out std_logic;
      M_AXIS_TDATA        : out std_logic_vector;
      M_AXIS_TSTRB        : out std_logic_vector;
      M_AXIS_TUSER        : out std_logic_vector;
      M_AXIS_TDEST        : out std_logic_vector;
      M_AXIS_TLAST        : out std_logic;
      M_AXIS_TREADY       : in  std_logic
    );
  end component verification_ip_MAXIS;

    type testtype_t is (
        all_zeroes,
        all_ones,
        counter,
        prbs,
        slave_valid_test,
        master_ready_test
    );
    
    type test_list is array (testtype_t'high downto testtype_t'low) of integer;
    
    constant test_decode : test_list := (
        all_zeroes 				=> 0,
        all_ones   				=> 1,
        counter    				=> 2,
        prbs       				=> 3,
        slave_valid_test  => 4,
        master_ready_test => 5
    );

end verification_pkg;

package body verification_pkg is
end verification_pkg;
