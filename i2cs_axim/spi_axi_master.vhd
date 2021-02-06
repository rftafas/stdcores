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
library expert;
	use expert.std_logic_expert.all;
library stdblocks;
	use stdblocks.sync_lib.all;

entity spi_axi_master is
	generic (
		-- Thread ID Width and value
		ID_WIDTH	    : integer	:= 1;
		ID_VALUE	    : integer	:= 1;
		-- Width of Address Bus
		ADDR_BYTE_NUM	: integer	:= 4;
		DATA_BYTE_NUM	: integer	:= 4
		-- Width of User Write Address Bus
	);
	port (
		M_AXI_RESET : in std_logic;
		M_AXI_ACLK	 : in std_logic;
		--internal bus
    bus_addr_i    : in  std_logic_vector(ADDR_BYTE_NUM*8-1 downto 0);
    bus_data_i    : in  std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
    bus_data_o    : out std_logic_vector(DATA_BYTE_NUM*8-1 downto 0);
    bus_write_i   : in  std_logic;
		bus_read_i    : in  std_logic;
		bus_done_o    : out std_logic;
		bus_error_o 	: out std_logic;
		--Write addr channel
		M_AXI_AWID	  : out std_logic_vector(ID_WIDTH-1 downto 0);
		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in  std_logic;
		M_AXI_AWADDR	: out std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		--write data channel
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in  std_logic;
		M_AXI_WDATA	  : out std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
		M_AXI_WSTRB	  : out std_logic_vector(DATA_BYTE_NUM-1 downto 0);
		M_AXI_WLAST	  : out std_logic;
		--Write Response channel
		M_AXI_BVALID : in  std_logic;
		M_AXI_BREADY : out std_logic;
		M_AXI_BRESP	 : in  std_logic_vector(1 downto 0);
		M_AXI_BID	   : in  std_logic_vector(ID_WIDTH-1 downto 0);
		-- Read Address channel
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in  std_logic;
		M_AXI_ARADDR	: out std_logic_vector(8*ADDR_BYTE_NUM-1 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARID	  : out std_logic_vector(ID_WIDTH-1 downto 0);
		--Read data channel
		M_AXI_RVALID	: in  std_logic;
		M_AXI_RREADY	: out std_logic;
		M_AXI_RDATA	  : in  std_logic_vector(8*DATA_BYTE_NUM-1 downto 0);
		M_AXI_RRESP	  : in  std_logic_vector(1 downto 0);
		M_AXI_RID	    : in  std_logic_vector(ID_WIDTH-1 downto 0);
		M_AXI_RLAST	  : in  std_logic
		);
end spi_axi_master;

architecture implementation of spi_axi_master is

	 type state is (IDLE, INIT_WRITE, INIT_READ, BUS_DONE);
	 signal mst_exec_state  : state ;


begin
	-- I/O Connections assignments

	--TRANSACTION ID
	M_AXI_AWID <= to_std_logic_vector(ID_VALUE,ID_WIDTH);
	M_AXI_ARID <= to_std_logic_vector(ID_VALUE,ID_WIDTH);
	--M_AXI_BID  <= to_std_logic_vector(ID_VALUE,ID_WIDTH);
	--Strobe for byte access, not used
	M_AXI_WSTRB	  <= (others => '1');
	M_AXI_ARPROT	<= "000";
	M_AXI_AWPROT	<= "000";

	----------------------------------
	--Control Machine
	----------------------------------
	control_p : process(M_AXI_RESET, M_AXI_ACLK)
	begin
	  if (M_AXI_RESET = '1') then
	    -- reset condition
	    -- All the signals are ed default values under reset condition
	    mst_exec_state <= IDLE;
	    bus_error_o    <= '0';
	    M_AXI_RREADY   <= '0';
	    M_AXI_BREADY   <= '0';
	    M_AXI_ARVALID  <= '0';
	    M_AXI_AWVALID  <= '0';
	    M_AXI_WVALID   <= '0';
	    M_AXI_ARADDR   <= (others=>'0');
	    bus_data_o     <= (others=>'0');
	    M_AXI_WDATA    <= (others=>'0');
	    M_AXI_WLAST	   <= '0';
	  elsif (rising_edge (M_AXI_ACLK)) then
	    -- state transition
	    case (mst_exec_state) is
	      when IDLE =>
	        -- This state is responsible to initiate
	        -- AXI transaction when init_txn_pulse is asserted
	        if bus_write_i = '1' then
	          mst_exec_state <= INIT_WRITE;
	          M_AXI_AWVALID  <= '1';
	          M_AXI_AWADDR   <= bus_addr_i;
	          M_AXI_WVALID   <= '1';
	          M_AXI_WDATA    <= bus_data_i;
	          M_AXI_BREADY   <= '1';
	          M_AXI_WLAST	 <= '1';
	        elsif bus_read_i = '1' then
	          mst_exec_state <= INIT_READ;
						M_AXI_ARVALID  <= '1';
						M_AXI_ARADDR   <= bus_addr_i;
						M_AXI_RREADY   <= '1';
	        else
						bus_error_o    <= '0';
	          mst_exec_state <= IDLE;
						--write signals clear
						M_AXI_AWVALID  <= '0';
	          M_AXI_AWADDR   <= (others => '0');
	          M_AXI_WVALID   <= '0';
	          M_AXI_WLAST	 <= '0';
	          M_AXI_WDATA    <= (others => '0');
	          M_AXI_BREADY   <= '1';
						--read signals clear
	          M_AXI_ARVALID  <= '0';
						M_AXI_ARADDR   <= (others => '0');
						M_AXI_RREADY   <= '0';
						bus_data_o     <= (others => '0');
	        end if;

	      when INIT_WRITE =>
	        if M_AXI_BVALID = '1' then
						if M_AXI_BRESP(1) = '0' then
		          mst_exec_state <= BUS_DONE;
							M_AXI_BREADY   <= '0';
						else
							mst_exec_state <= BUS_DONE;
							M_AXI_BREADY   <= '0';
							bus_error_o    <= '1';
						end if;
	        else
	          mst_exec_state <= INIT_WRITE;
	        end if;
	                                        --limpa flags
	        if M_AXI_AWREADY = '1' then
	          M_AXI_AWVALID  <= '0';
	        end if;
	        if M_AXI_WREADY = '1' then
	          M_AXI_WVALID  <= '0';
	          M_AXI_WLAST	<= '0';
	        end if;

	      when INIT_READ =>
	        if M_AXI_RVALID = '1' then
						if M_AXI_RRESP(1) = '0' then
		          mst_exec_state <= BUS_DONE;
							bus_data_o     <= M_AXI_RDATA;
							M_AXI_RREADY   <= '0';
						else
							mst_exec_state <= BUS_DONE;
							bus_data_o     <= (others => '0');
							M_AXI_RREADY   <= '0';
							bus_error_o    <= '1';
						end if;
	        else
	          mst_exec_state <= INIT_READ;
	        end if;

					if M_AXI_ARREADY = '1' then
						M_AXI_ARVALID <= '0';
						M_AXI_ARADDR  <= (others => '0');
					end if;

	      when BUS_DONE =>
	        bus_error_o     <= '0';
	        mst_exec_state  <= IDLE;

	      when others =>
	        mst_exec_state  <= IDLE;

	    end case;
	  end if;
	end process;

	bus_done_o <= '1' when mst_exec_state = BUS_DONE else '0';

end implementation;
