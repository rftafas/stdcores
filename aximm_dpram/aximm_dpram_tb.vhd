----------------------------------------------------------------------------------
--Copyright 2022 Ricardo F Tafas Jr

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
    use IEEE.math_real.all;
library expert;
    use expert.std_logic_expert.all;
library std;
    use std.textio.all;
library stdblocks;
    use stdblocks.prbs_lib.all;
library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.vc_context;

use work.aximm_dpram_pkg.all;

entity aximm_dpram_tb is
    generic (
        runner_cfg : string;
        run_time   : integer := 100
    );
    --port (
    --port_declaration_tag
    --);
end aximm_dpram_tb;

architecture simulation of aximm_dpram_tb is

    constant C_S_AXI_ADDR_WIDTH : integer := 6;
    constant C_S_AXI_DATA_WIDTH : integer := 32;
    constant BYTE_NUM           : integer := C_S_AXI_DATA_WIDTH/8;
    constant MAX_ADDR           : integer := (2**C_S_AXI_ADDR_WIDTH)/BYTE_NUM;

    constant a_axi_handle       : bus_master_t := new_bus(data_length => C_S_AXI_DATA_WIDTH, address_length => C_S_AXI_ADDR_WIDTH);
    constant b_axi_handle       : bus_master_t := new_bus(data_length => C_S_AXI_DATA_WIDTH, address_length => C_S_AXI_ADDR_WIDTH);

    signal mclk_i        : std_logic := '0';
    signal rst_i         : std_logic;

    signal A_AXI_AWADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal A_AXI_AWPROT  : std_logic_vector(2 downto 0);
    signal A_AXI_AWVALID : std_logic;
    signal A_AXI_AWREADY : std_logic;
    signal A_AXI_WDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal A_AXI_WSTRB   : std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
    signal A_AXI_WVALID  : std_logic;
    signal A_AXI_WREADY  : std_logic;
    signal A_AXI_BRESP   : std_logic_vector(1 downto 0);
    signal A_AXI_BVALID  : std_logic;
    signal A_AXI_BREADY  : std_logic;
    signal A_AXI_ARADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal A_AXI_ARPROT  : std_logic_vector(2 downto 0);
    signal A_AXI_ARVALID : std_logic;
    signal A_AXI_ARREADY : std_logic;
    signal A_AXI_RDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal A_AXI_RRESP   : std_logic_vector(1 downto 0);
    signal A_AXI_RVALID  : std_logic;
    signal A_AXI_RREADY  : std_logic;

    signal B_AXI_AWADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal B_AXI_AWPROT  : std_logic_vector(2 downto 0);
    signal B_AXI_AWVALID : std_logic;
    signal B_AXI_AWREADY : std_logic;
    signal B_AXI_WDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal B_AXI_WSTRB   : std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
    signal B_AXI_WVALID  : std_logic;
    signal B_AXI_WREADY  : std_logic;
    signal B_AXI_BRESP   : std_logic_vector(1 downto 0);
    signal B_AXI_BVALID  : std_logic;
    signal B_AXI_BREADY  : std_logic;
    signal B_AXI_ARADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal B_AXI_ARPROT  : std_logic_vector(2 downto 0);
    signal B_AXI_ARVALID : std_logic;
    signal B_AXI_ARREADY : std_logic;
    signal B_AXI_RDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal B_AXI_RRESP   : std_logic_vector(1 downto 0);
    signal B_AXI_RVALID  : std_logic;
    signal B_AXI_RREADY  : std_logic;

begin

    --architecture_body_tag.
    mclk_i <= not mclk_i after 5 ns;

    main : process
        variable prbs    : prbs_t;
        variable wdata_v : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
        variable rdata_v : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
    begin
        test_runner_setup(runner, runner_cfg);
        rst_i <= '0';
        wait until rising_edge(mclk_i);
        wait until rising_edge(mclk_i);
        rst_i <= '1';
        wait until rising_edge(mclk_i);
        wait until rising_edge(mclk_i);

        while test_suite loop
            if run("Sanity check for system") then
                report "System Sane. Begin tests.";
                check_passed(result("Sanity check for system."));

            elsif run("Simple Run") then
                wait for 100 us;
                check_passed(result("Simple Run: Pass."));

            elsif run("Test Write and Read All Zeroes") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := (others=>'0');
                    write_bus(net, a_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, a_axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read All Zeroes"));
                end loop;

                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := (others=>'0');
                    write_bus(net, b_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, b_axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read All Zeroes"));
                end loop;
                check_passed(result("Test Write and Read All Zeroes: Pass."));

            elsif run("Test Write and Read All Ones") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := (others=>'1');
                    write_bus(net, a_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, a_axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read All Ones"));
                end loop;

                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := (others=>'1');
                    write_bus(net, b_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, b_axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read All Ones"));
                end loop;

                check_passed(result("Test Write and Read All Ones: Pass."));

            elsif run("Test Write and Read Random Values") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := prbs.get_data(C_S_AXI_DATA_WIDTH);
                    write_bus(net, a_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, a_axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read Random Values"));
                end loop;

                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := prbs.get_data(C_S_AXI_DATA_WIDTH);
                    write_bus(net, b_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, b_axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read Random Values"));
                end loop;

                check_passed(result("Test Write and Read Random Values: Pass."));

            elsif run("Test Full Write then Full Read Random Values") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := prbs.get_data(C_S_AXI_DATA_WIDTH);
                    write_bus(net, a_axi_handle, BYTE_NUM*j, wdata_v, "0001");
                end loop;

                for j in 0 to MAX_ADDR-1 loop
                    read_bus(net, b_axi_handle, BYTE_NUM*j, rdata_v);
                    check_true(prbs.check_data(rdata_v), result("Test Full Write then Full Read Random Values"));
                end loop;
                check_passed(result("Test Full Write then Full Read Random Values: Pass."));

            end if;
        end loop;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    a_axi_master_u : entity vunit_lib.axi_lite_master
        generic map(
            bus_handle => a_axi_handle
        )
        port map(
            aclk => mclk_i,
            --areset_n => rst_i,
            awaddr   => A_AXI_AWADDR,
            --awprot => A_AXI_AWPROT,
            awvalid  => A_AXI_AWVALID,
            awready  => A_AXI_AWREADY,
            wdata    => A_AXI_WDATA,
            wstrb    => A_AXI_WSTRB,
            wvalid   => A_AXI_WVALID,
            wready   => A_AXI_WREADY,
            bresp    => A_AXI_BRESP,
            bvalid   => A_AXI_BVALID,
            bready   => A_AXI_BREADY,
            araddr   => A_AXI_ARADDR,
            --arprot => A_AXI_ARPROT,
            arvalid  => A_AXI_ARVALID,
            arready  => A_AXI_ARREADY,
            rdata    => A_AXI_RDATA,
            rresp    => A_AXI_RRESP,
            rvalid   => A_AXI_RVALID,
            rready   => A_AXI_RREADY
        );

    b_axi_master_u : entity vunit_lib.axi_lite_master
        generic map(
            bus_handle => b_axi_handle
        )
        port map(
            aclk => mclk_i,
            --areset_n => rst_i,
            awaddr   => B_AXI_AWADDR,
            --awprot => B_AXI_AWPROT,
            awvalid  => B_AXI_AWVALID,
            awready  => B_AXI_AWREADY,
            wdata    => B_AXI_WDATA,
            wstrb    => B_AXI_WSTRB,
            wvalid   => B_AXI_WVALID,
            wready   => B_AXI_WREADY,
            bresp    => B_AXI_BRESP,
            bvalid   => B_AXI_BVALID,
            bready   => B_AXI_BREADY,
            araddr   => B_AXI_ARADDR,
            --arprot => B_AXI_ARPROT,
            arvalid  => B_AXI_ARVALID,
            arready  => B_AXI_ARREADY,
            rdata    => B_AXI_RDATA,
            rresp    => B_AXI_RRESP,
            rvalid   => B_AXI_RVALID,
            rready   => B_AXI_RREADY
        );

    dut_u : aximm_dpram
        generic map(
            C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
            C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
        )
        port map(
            A_AXI_ARESETN => rst_i,
            A_AXI_ACLK    => mclk_i,
            A_AXI_AWADDR  => A_AXI_AWADDR,
            A_AXI_AWPROT  => A_AXI_AWPROT,
            A_AXI_AWVALID => A_AXI_AWVALID,
            A_AXI_AWREADY => A_AXI_AWREADY,
            A_AXI_WDATA   => A_AXI_WDATA,
            A_AXI_WSTRB   => A_AXI_WSTRB,
            A_AXI_WVALID  => A_AXI_WVALID,
            A_AXI_WREADY  => A_AXI_WREADY,
            A_AXI_BRESP   => A_AXI_BRESP,
            A_AXI_BVALID  => A_AXI_BVALID,
            A_AXI_BREADY  => A_AXI_BREADY,
            A_AXI_ARADDR  => A_AXI_ARADDR,
            A_AXI_ARPROT  => A_AXI_ARPROT,
            A_AXI_ARVALID => A_AXI_ARVALID,
            A_AXI_ARREADY => A_AXI_ARREADY,
            A_AXI_RDATA   => A_AXI_RDATA,
            A_AXI_RRESP   => A_AXI_RRESP,
            A_AXI_RVALID  => A_AXI_RVALID,
            A_AXI_RREADY  => A_AXI_RREADY,

            B_AXI_ARESETN => rst_i,
            B_AXI_ACLK    => mclk_i,
            B_AXI_AWADDR  => B_AXI_AWADDR,
            B_AXI_AWPROT  => B_AXI_AWPROT,
            B_AXI_AWVALID => B_AXI_AWVALID,
            B_AXI_AWREADY => B_AXI_AWREADY,
            B_AXI_WDATA   => B_AXI_WDATA,
            B_AXI_WSTRB   => B_AXI_WSTRB,
            B_AXI_WVALID  => B_AXI_WVALID,
            B_AXI_WREADY  => B_AXI_WREADY,
            B_AXI_BRESP   => B_AXI_BRESP,
            B_AXI_BVALID  => B_AXI_BVALID,
            B_AXI_BREADY  => B_AXI_BREADY,
            B_AXI_ARADDR  => B_AXI_ARADDR,
            B_AXI_ARPROT  => B_AXI_ARPROT,
            B_AXI_ARVALID => B_AXI_ARVALID,
            B_AXI_ARREADY => B_AXI_ARREADY,
            B_AXI_RDATA   => B_AXI_RDATA,
            B_AXI_RRESP   => B_AXI_RRESP,
            B_AXI_RVALID  => B_AXI_RVALID,
            B_AXI_RREADY  => B_AXI_RREADY
        );

end simulation;
