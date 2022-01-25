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


--TODO: add more tests. List:
--Stuff Violation
--Test wrond ID
--Test ID MASK for RX
--test bad mask selection
--Test Collision
--test RTR, R0 and R1 bits
--ID and DATA alternating 0 and 1 (AA)
--test random data
--test multiple transmissions in a row

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

use work.aximm_ram_pkg.all;

entity aximm_ram_tb is
    generic (
        runner_cfg : string;
        run_time   : integer := 100
    );
    --port (
    --port_declaration_tag
    --);
end aximm_ram_tb;

architecture simulation of aximm_ram_tb is

    constant C_S_AXI_ADDR_WIDTH : integer := 6;
    constant C_S_AXI_DATA_WIDTH : integer := 32;
    constant BYTE_NUM           : integer := C_S_AXI_DATA_WIDTH/8;
    constant MAX_ADDR           : integer := (2**C_S_AXI_ADDR_WIDTH)/BYTE_NUM;

    constant axi_handle       : bus_master_t := new_bus(data_length => C_S_AXI_DATA_WIDTH, address_length => C_S_AXI_ADDR_WIDTH);

    signal mclk_i        : std_logic := '0';
    signal rst_i         : std_logic;
    signal S_AXI_AWADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal S_AXI_AWPROT  : std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : std_logic;
    signal S_AXI_AWREADY : std_logic;
    signal S_AXI_WDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal S_AXI_WSTRB   : std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
    signal S_AXI_WVALID  : std_logic;
    signal S_AXI_WREADY  : std_logic;
    signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : std_logic;
    signal S_AXI_BREADY  : std_logic;
    signal S_AXI_ARADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal S_AXI_ARPROT  : std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : std_logic;
    signal S_AXI_ARREADY : std_logic;
    signal S_AXI_RDATA   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : std_logic;
    signal S_AXI_RREADY  : std_logic;

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
                    write_bus(net, axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read All Zeroes"));
                end loop;
                check_passed(result("Test Write and Read All Zeroes: Pass."));

            elsif run("Test Write and Read All Ones") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := (others=>'1');
                    write_bus(net, axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read All Ones"));
                end loop;
                check_passed(result("Test Write and Read All Ones: Pass."));

            elsif run("Test Write and Read Random Values") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := prbs.get_data(C_S_AXI_DATA_WIDTH);
                    write_bus(net, axi_handle, BYTE_NUM*j, wdata_v, "0001");
                    read_bus(net, axi_handle, BYTE_NUM*j, rdata_v);
                    check_equal(rdata_v, wdata_v, result("Test Write and Read Random Values"));
                end loop;
                check_passed(result("Test Write and Read Random Values: Pass."));

            elsif run("Test Full Write then Full Read Random Values") then
                for j in 0 to MAX_ADDR-1 loop
                    wdata_v := prbs.get_data(C_S_AXI_DATA_WIDTH);
                    write_bus(net, axi_handle, BYTE_NUM*j, wdata_v, "0001");
                end loop;

                for j in 0 to MAX_ADDR-1 loop
                    read_bus(net, axi_handle, BYTE_NUM*j, rdata_v);
                    check_true(prbs.check_data(rdata_v), result("Test Full Write then Full Read Random Values"));
                end loop;

                check_passed(result("Test Full Write then Full Read Random Values: Pass."));

            elsif run("Test Delaying Write Response") then
                check_passed(result("Test Delaying Write Response: Pass."));
            elsif run("Test Delaying Read Response") then
                check_passed(result("Test Delaying Read Response: Pass."));
            elsif run("Test Write Response Timeout") then
                check_passed(result("Test Write Response Timeout: Pass."));
            elsif run("Test Read Response Timeout") then
                check_passed(result("Test Read Response Timeout: Pass."));


            end if;
        end loop;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    axi_master_u : entity vunit_lib.axi_lite_master
        generic map(
            bus_handle => axi_handle
        )
        port map(
            aclk => mclk_i,
            --areset_n => rst_i,
            awaddr => S_AXI_AWADDR,
            --awprot => S_AXI_AWPROT,
            awvalid => S_AXI_AWVALID,
            awready => S_AXI_AWREADY,
            wdata   => S_AXI_WDATA,
            wstrb   => S_AXI_WSTRB,
            wvalid  => S_AXI_WVALID,
            wready  => S_AXI_WREADY,
            bresp   => S_AXI_BRESP,
            bvalid  => S_AXI_BVALID,
            bready  => S_AXI_BREADY,
            araddr  => S_AXI_ARADDR,
            --arprot => S_AXI_ARPROT,
            arvalid => S_AXI_ARVALID,
            arready => S_AXI_ARREADY,
            rdata   => S_AXI_RDATA,
            rresp   => S_AXI_RRESP,
            rvalid  => S_AXI_RVALID,
            rready  => S_AXI_RREADY
        );

    dut_u : aximm_ram
        generic map(
            C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
            C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
        )
        port map(
            AXI_ARESETN => rst_i,
            AXI_ACLK    => mclk_i,
            AXI_AWADDR  => S_AXI_AWADDR,
            AXI_AWPROT  => S_AXI_AWPROT,
            AXI_AWVALID => S_AXI_AWVALID,
            AXI_AWREADY => S_AXI_AWREADY,
            AXI_WDATA   => S_AXI_WDATA,
            AXI_WSTRB   => S_AXI_WSTRB,
            AXI_WVALID  => S_AXI_WVALID,
            AXI_WREADY  => S_AXI_WREADY,
            AXI_BRESP   => S_AXI_BRESP,
            AXI_BVALID  => S_AXI_BVALID,
            AXI_BREADY  => S_AXI_BREADY,
            AXI_ARADDR  => S_AXI_ARADDR,
            AXI_ARPROT  => S_AXI_ARPROT,
            AXI_ARVALID => S_AXI_ARVALID,
            AXI_ARREADY => S_AXI_ARREADY,
            AXI_RDATA   => S_AXI_RDATA,
            AXI_RRESP   => S_AXI_RRESP,
            AXI_RVALID  => S_AXI_RVALID,
            AXI_RREADY  => S_AXI_RREADY
        );

end simulation;
