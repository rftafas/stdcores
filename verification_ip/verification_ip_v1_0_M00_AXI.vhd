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

entity verification_ip_v1_0_M00_AXI is
	generic (
		-- Users to add parameters here
        verbose : boolean := false;
		-- Width of M_AXI address bus.
        -- The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		-- Width of M_AXI data bus.
        -- The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH
		C_M_AXI_DATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		addr_i    : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		data_i    : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		data_o    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		command   : in  std_logic_vector(2 downto 0);
		start     : in  std_logic;
		busy      : out std_logic;
		-- Do not modify the ports beyond this line
		-- AXI clock signal
		M_AXI_ACLK	    : in std_logic;
		-- AXI active low reset signal
		M_AXI_ARESETN	: in std_logic;
		-- Master Interface Write Address Channel ports. Write address (issued by master)
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type.
        -- This signal indicates the privilege and security level of the transaction,
        -- and whether the transaction is a data access or an instruction access.
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		-- Write address valid.
        -- This signal indicates that the master signaling valid write address and control information.
		M_AXI_AWVALID	: out std_logic;
		-- Write address ready.
        -- This signal indicates that the slave is ready to accept an address and associated control signals.
		M_AXI_AWREADY	: in std_logic;
		-- Master Interface Write Data Channel ports. Write data (issued by master)
		M_AXI_WDATA	    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes.
        -- This signal indicates which byte lanes hold valid data.
        -- There is one write strobe bit for each eight bits of the write data bus.
		M_AXI_WSTRB	    : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		-- Write valid. This signal indicates that valid write data and strobes are available.
		M_AXI_WVALID	: out std_logic;
		-- Write ready. This signal indicates that the slave can accept the write data.
		M_AXI_WREADY	: in std_logic;
		-- Master Interface Write Response Channel ports.
        -- This signal indicates the status of the write transaction.
		M_AXI_BRESP	    : in std_logic_vector(1 downto 0);
		-- Write response valid.
        -- This signal indicates that the channel is signaling a valid write response
		M_AXI_BVALID	: in std_logic;
		-- Response ready. This signal indicates that the master can accept a write response.
		M_AXI_BREADY	: out std_logic;
		-- Master Interface Read Address Channel ports. Read address (issued by master)
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type.
        -- This signal indicates the privilege and security level of the transaction,
        -- and whether the transaction is a data access or an instruction access.
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		-- Read address valid.
        -- This signal indicates that the channel is signaling valid read address and control information.
		M_AXI_ARVALID	: out std_logic;
		-- Read address ready.
        -- This signal indicates that the slave is ready to accept an address and associated control signals.
		M_AXI_ARREADY	: in std_logic;
		-- Master Interface Read Data Channel ports. Read data (issued by slave)
		M_AXI_RDATA	    : in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the read transfer.
		M_AXI_RRESP	    : in std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is signaling the required read data.
		M_AXI_RVALID	: in std_logic;
		-- Read ready. This signal indicates that the master can accept the read data and response information.
		M_AXI_RREADY	: out std_logic
	);
end verification_ip_v1_0_M00_AXI;

architecture implementation of verification_ip_v1_0_M00_AXI is


	-- Example user application signals

	-- TRANS_NUM_BITS is the width of the index counter for
	-- number of write or read transaction..
	constant addr_low     : integer := integer(log2(real(C_M_AXI_DATA_WIDTH/8)));

    signal axi_awaddr_high : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto addr_low);
    signal axi_awaddr_low  : std_logic_vector(          addr_low-1 downto        0);
    signal axi_araddr_high : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto addr_low);
    signal axi_araddr_low  : std_logic_vector(          addr_low-1 downto        0);

begin
	-- I/O Connections assignments
	M_AXI_AWPROT	<= "000";
	M_AXI_ARPROT	<= "000";--001
  M_AXI_WSTRB	    <= (others=>'1');

  M_AXI_AWADDR(C_M_AXI_ADDR_WIDTH-1 downto addr_low) <= axi_awaddr_high;
  M_AXI_AWADDR(          addr_low-1 downto        0) <=  axi_awaddr_low;
  M_AXI_ARADDR(C_M_AXI_ADDR_WIDTH-1 downto addr_low) <= axi_araddr_high;
  M_AXI_ARADDR(          addr_low-1 downto        0) <=  axi_araddr_low;


	----------------------------------
	--Test
	----------------------------------
    --implement master command interface state machine
    MASTER_EXECUTION_PROC:process(M_AXI_ACLK)
        variable READYtmp : boolean := false;
        variable VALIDtmp : boolean := false;
        variable addr_ok  : boolean := false;
    begin
        if rising_edge(M_AXI_ACLK) then
        if start = '1' then
            busy <= '1';
            case command is
                when "000"  =>
                    M_AXI_RREADY    <= '0';
                    if not READYtmp then
                        M_AXI_RREADY    <= '1';
                        if M_AXI_RVALID  = '1' then
                            M_AXI_RREADY    <= '0';
                            READYtmp := true;
                            data_o   <= M_AXI_RDATA;
                            busy     <= '0';
                        end if;
                    end if;

                    M_AXI_ARVALID   <= '0';
                    if not addr_ok then
                        axi_araddr_high <= addr_i(axi_araddr_high'range);
                        axi_araddr_low  <= (others=>'0');
                        M_AXI_ARVALID <= '1';
                        if M_AXI_ARREADY = '1' then
                            M_AXI_ARVALID <= '0';
                            addr_ok := true;
                        end if;
                    end if;

                when "001"  =>
                    M_AXI_WVALID    <= '0';
                    M_AXI_WDATA     <= (others=>'U');
                    if not READYtmp then
                        M_AXI_WVALID    <= '1';
                        M_AXI_WDATA     <= data_i;
                        if M_AXI_WREADY  = '1' then
                            M_AXI_WVALID    <= '0';
                            READYtmp := true;
                        end if;
                    end if;

                    M_AXI_BREADY    <= '0';
                    if not VALIDtmp then
                        M_AXI_BREADY    <= '1';
                        if M_AXI_BVALID = '1' then
                            M_AXI_BREADY    <= '0';
                            VALIDtmp := true;
                            busy     <= '0';
                        end if;
                    end if;

                M_AXI_AWVALID   <= '0';
                if not addr_ok then
                    M_AXI_AWVALID   <= '1';
                    axi_awaddr_high <= addr_i(axi_awaddr_high'range);
                    axi_awaddr_low  <= (others=>'0');
                    if M_AXI_AWREADY = '1' then
                        M_AXI_AWVALID   <= '0';
                        addr_ok := true;
                    end if;
                end if;

                when "010"  =>
                    report "Byte write not implemented yet.";

                when "011"  =>
                    report "Byte read not implemented yet.";

                when "100"  =>
                    report "Burst write not implemented yet.";

                when "101" =>
                    report "Burst read not implemented yet.";

                when others  =>
                    report "doing nothing.";

            end case;



        else
            addr_ok  := false;
            READYtmp := false;
            VALIDtmp := false;
            M_AXI_WVALID    <= '0';
            M_AXI_WDATA     <= (others=>'U');
            M_AXI_BREADY    <= '0';
            busy <= '0';
            --read signal cleanup
            M_AXI_RREADY    <= '0';
            data_o <= (others=>'U');
            M_AXI_ARVALID   <= '0';
            axi_araddr_high <= (others=>'U');
            axi_araddr_low  <= (others=>'U');
            M_AXI_AWVALID   <= '0';
            axi_awaddr_high <= (others=>'U');
            axi_awaddr_low  <= (others=>'U');
        end if;
        end if;

    end process;

end implementation;
