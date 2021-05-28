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

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.math_real.all;
library expert;
    use expert.std_logic_expert.all;
library std;
    use std.textio.all;
library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.vc_context;

use work.can_aximm_pkg.all;

entity can_aximm_top_tb is
    generic (
        runner_cfg : string;
        run_time   : integer := 100
    );
    --port (
    --port_declaration_tag
    --);
end can_aximm_top_tb;

architecture simulation of can_aximm_top_tb is

    constant axi_handle       : bus_master_t := new_bus(data_length => C_S_AXI_DATA_WIDTH, address_length => C_S_AXI_ADDR_WIDTH);
    constant addr_increment_c : integer      := 4;
    constant data_rate_c      : natural      := 500;
    constant data_period_real : real := real(1000/data_rate_c);
    constant data_period_c    : time := integer(data_period_real) * 1 us;

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

    signal tx_irq_o : std_logic;
    signal rx_irq_o : std_logic;
    signal txo_o    : std_logic;
    signal txo_t    : std_logic;
    signal rxi      : std_logic;
    signal can_l    : std_logic;
    signal can_h    : std_logic;

    signal force_line : boolean := false;

begin

    --architecture_body_tag.
    mclk_i <= not mclk_i after 5 ns;

    main : process
        variable wdata_v : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
        variable rdata_v : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
    begin
        test_runner_setup(runner, runner_cfg);
        rst_i <= '1';
        wait until rising_edge(mclk_i);
        wait until rising_edge(mclk_i);
        rst_i <= '0';
        wait until rising_edge(mclk_i);
        wait until rising_edge(mclk_i);

        while test_suite loop
            if run("Sanity check for system") then
                report "System Sane. Begin tests.";
                check_passed(result("Sanity check for system."));

            elsif run("Simple Run") then
                wait for 100 us;
                check_passed(result("Simple Run: Pass."));

            elsif run("Test Read Golden Reg and Idle Status") then
                --Testing g1_i
                read_bus(net, axi_handle, 0, rdata_v);
                check_equal(rdata_v(31 downto 0), golden_c, result("Test Read: Golden Register."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                --Testing rx_crc_error_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(9), '0', result("Test Read: rx_crc_error_i."));
                --Testing collision_i
                read_bus(net, axi_handle, 16, rdata_v);
                check_equal(rdata_v(1), '0', result("Test Read Ones: collision_i."));
                --Testing tx_ready_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(0), '1', result("Test Read: tx_ready_i."));
                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing tx_arb_lost_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(9), '0', result("Test Read Ones: tx_arb_lost_i."));
                --Testing tx_retry_error_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(10), '0', result("Test Read Ones: tx_retry_error_i."));
                --final test
                check_passed(result("Test Read Golden Reg and Idle Status: Pass."));

            elsif run("Test Read and Write Registers") then
                --Testing iso_mode_o
                wdata_v := "11000101011010101001011110111110";
                write_bus(net, axi_handle, 4, wdata_v, "0001");
                read_bus(net, axi_handle, 4, rdata_v);
                check_equal(rdata_v(0), wdata_v(0), result("Test Readback and Port value: iso_mode_o."));
                --Testing fd_enable_o
                wdata_v := "10110101100101011000011010101110";
                write_bus(net, axi_handle, 4, wdata_v, "0001");
                read_bus(net, axi_handle, 4, rdata_v);
                check_equal(rdata_v(1), wdata_v(1), result("Test Readback and Port value: fd_enable_o."));
                --Testing promiscuous_o
                wdata_v := (8=>'1', others => '0');
                write_bus(net, axi_handle, 4, wdata_v, "0010");
                read_bus(net, axi_handle, 4, rdata_v);
                check_equal(rdata_v(8), wdata_v(8), result("Test Readback and Port value: promiscuous_o."));
                --Testing sample_rate_o
                wdata_v := "10101100110000100010011010010111";
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                read_bus(net, axi_handle, 8, rdata_v);
                check_equal(rdata_v(15 downto 0), wdata_v(15 downto 0), result("Test Readback and Port value: sample_rate_o."));
                --Testing rx_data_mask_o
                wdata_v := (16=>'1', others=>'0');
                write_bus(net,axi_handle,12,wdata_v,"0100");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(16),wdata_v(16),result("Test Readback and Port value: rx_data_mask_o."));
                --Testing rx_error_mask_o
                wdata_v := (17=>'1', others=>'0');
                write_bus(net,axi_handle,12,wdata_v,"0100");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(17),wdata_v(17),result("Test Readback and Port value: rx_error_mask_o."));
                --Testing tx_data_mask_o
                wdata_v := (24=>'1', others=>'0');
                write_bus(net,axi_handle,12,wdata_v,"1000");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(24),wdata_v(24),result("Test Readback and Port value: tx_data_mask_o."));
                --Testing tx_error_mask_o
                wdata_v := (25=>'1', others=>'0');
                write_bus(net,axi_handle,12,wdata_v,"1000");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(25),wdata_v(25),result("Test Readback and Port value: tx_error_mask_o."));
                --Testing loop_enable_o
                wdata_v := "11110101000111000111100111111100";
                write_bus(net, axi_handle, 28, wdata_v, "0001");
                read_bus(net, axi_handle, 28, rdata_v);
                check_equal(rdata_v(0), wdata_v(0), result("Test Readback and Port value: loop_enable_o."));
                --Testing force_dominant_o
                wdata_v := "10010110111011111110110001110000";
                write_bus(net, axi_handle, 28, wdata_v, "0100");
                read_bus(net, axi_handle, 28, rdata_v);
                check_equal(rdata_v(16), wdata_v(16), result("Test Readback and Port value: force_dominant_o."));
                --Testing id1_o
                wdata_v := "01101101000100010111000001101001";
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                read_bus(net, axi_handle, 36, rdata_v);
                check_equal(rdata_v(28 downto 0), wdata_v(28 downto 0), result("Test Readback and Port value: id1_o."));
                --Testing id1_mask_o
                wdata_v := "11011110100010110000101011111111";
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                read_bus(net, axi_handle, 40, rdata_v);
                check_equal(rdata_v(28 downto 0), wdata_v(28 downto 0), result("Test Readback and Port value: id1_mask_o."));
                --Testing tx_rtr_o
                wdata_v := "10010011101110001110110100001011";
                write_bus(net, axi_handle, 64, wdata_v, "0100");
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(16), wdata_v(16), result("Test Readback and Port value: tx_rtr_o."));
                --Testing tx_eff_o
                wdata_v := "01010001101101000001100110100110";
                write_bus(net, axi_handle, 64, wdata_v, "1000");
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(24), wdata_v(24), result("Test Readback and Port value: tx_eff_o."));
                --Testing tx_reserved_o
                wdata_v := "00010010010100011101000101010011";
                write_bus(net, axi_handle, 64, wdata_v, "1000");
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(26 downto 25), wdata_v(26 downto 25), result("Test Readback and Port value: tx_reserved_o."));
                --Testing tx_dlc_o
                wdata_v := "00011011010001000101111011001000";
                write_bus(net, axi_handle, 68, wdata_v, "0001");
                read_bus(net, axi_handle, 68, rdata_v);
                check_equal(rdata_v(3 downto 0), wdata_v(3 downto 0), result("Test Readback and Port value: tx_dlc_o."));
                --Testing tx_id_o
                wdata_v := "10111010101000110100000100111100";
                write_bus(net, axi_handle, 72, wdata_v, "1111");
                read_bus(net, axi_handle, 72, rdata_v);
                check_equal(rdata_v(28 downto 0), wdata_v(28 downto 0), result("Test Readback and Port value: tx_id_o."));
                --Testing tx_data0_o
                wdata_v := "11101101010010100011110011000011";
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                read_bus(net, axi_handle, 76, rdata_v);
                check_equal(rdata_v(31 downto 0), wdata_v(31 downto 0), result("Test Readback and Port value: tx_data0_o."));
                --Testing tx_data1_o
                wdata_v := "10011001111101111101010110100110";
                write_bus(net, axi_handle, 80, wdata_v, "1111");
                read_bus(net, axi_handle, 80, rdata_v);
                check_equal(rdata_v(31 downto 0), wdata_v(31 downto 0), result("Test Readback and Port value: tx_data1_o."));
                check_passed(result("Test Read and Write Registers."));

            elsif run("Test Force Dominant") then
                --Testing force_dominant_o
                wdata_v := x"00010000";
                write_bus(net, axi_handle, 28, wdata_v, "0100");
                read_bus(net, axi_handle, 28, rdata_v);
                rdata_v := rdata_v and x"00010000";
                check_equal(rdata_v(16), wdata_v(16), result("Test Readback and Port value: force_dominant_o."));

                check_equal(txo_o, '0', result("Test Dominant: line forced to '0'."));
                check_equal(txo_t, '1', result("Test Dominant: line control to '1'."));

                wdata_v := x"00000000";
                write_bus(net, axi_handle, 28, wdata_v, "0100");
                read_bus(net, axi_handle, 28, rdata_v);
                rdata_v := rdata_v and x"00010000";
                check_equal(rdata_v(16), wdata_v(16), result("Test Readback and Port value: force_dominant_o."));

                check_equal(txo_o, '1', result("Test Dominant: line released."));
                check_equal(txo_t, '0', result("Test Dominant: line control released."));

                check_passed(result("Test Force Dominant: Pass."));

            elsif run("Test Channel Ready") then
                --Configure Baud rate to 100kbps
                wdata_v := to_std_logic_vector(100, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");

                set_timeout(runner, now + 110 us);
                wait for 100 us;

                --Testing tx_ready_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(0), '1', result("Test First Read: tx_ready_i = 1."));

                rdata_v := x"00010000";
                write_bus(net, axi_handle, 28, rdata_v, "0100");

                set_timeout(runner, now + 110 us);
                wait for 100 us;

                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(0), '1', result("Test Second Read: tx_ready_i = 0."));

                rdata_v := x"00000000";
                write_bus(net, axi_handle, 28, rdata_v, "0100");

                set_timeout(runner, now + 110 us);
                wait for 100 us;

                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(0), '1', result("Test Third Read: tx_ready_i = 1."));

            elsif run("Send 0 bytes, short header, all zeroes") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");
                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0000"), result("Test Read: rx_dlc."));

                check_passed(result("Send 0 bytes, short header, all zeroes: Pass."));

            elsif run("Send 0 bytes, short header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000007FF"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0000"), result("Test Read: rx_busy_i."));

                check_passed(result("Test Send 0 bytes, short header, ID all ones: Pass."));

            elsif run("Send 0 bytes, short header, Promiscuous mode") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --set promiscuous mode
                wdata_v := (8=>'1', others => '0');
                write_bus(net, axi_handle, 4, wdata_v, "0010");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");
                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000007FF"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0000"), result("Test Read: rx_busy_i."));

                check_passed(result("Send 0 bytes, short header, Promiscuous mode: Pass."));

            elsif run("Send 1 byte, short header, all zeroes") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := x"00000000";
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := x"00000000";
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0001"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_data."));

                check_passed(result("Test Send 0 bytes, short header, all zeroes: Pass."));

            elsif run("Send 1 byte, short header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000007FF"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0001"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000000FF"), result("Test Read: rx_data."));

                check_passed(result("Send 1 byte, short header, all ones: Pass."));

            elsif run("Send 8 bytes, short header, all zeroes") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(8, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '0');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '0');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v(11 downto 0), std_logic_vector'(x"000"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("1000"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_data."));
                read_bus(net, axi_handle, 56, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_data."));

                check_passed(result("Send 8 bytes, short header, all ones: Pass."));

            elsif run("Send 8 bytes, short header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(8, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v(11 downto 0), std_logic_vector'(x"7FF"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("1000"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"FFFFFFFF"), result("Test Read: rx_data."));
                read_bus(net, axi_handle, 56, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"FFFFFFFF"), result("Test Read: rx_data."));

                check_passed(result("Send 8 bytes, short header, all ones: Pass."));

            elsif run("Send 0 bytes, long header, all zeroes") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v := (1 => '1', 24 => '1', others =>'0');
                write_bus(net, axi_handle, 64, wdata_v, "1001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                check_equal(rdata_v(24), '1', result("Test Read: rx_eff."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0000"), result("Test Read: rx_busy_i."));

                check_passed(result("Send 0 bytes, long header, all zeroes: Pass."));

            elsif run("Send 0 bytes, long header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v := (1 => '1', 24 => '1', others =>'0');
                write_bus(net, axi_handle, 64, wdata_v, "1001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                check_equal(rdata_v(24), '1', result("Test Read: rx_eff."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"1FFFFFFF"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0000"), result("Test Read: rx_busy_i."));

                check_passed(result("Send 0 bytes, long header, all ones: Pass."));

            elsif run("Send 1 byte, long header, all zeroes") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v := (1 => '1', 24 => '1', others =>'0');
                write_bus(net, axi_handle, 64, wdata_v, "1001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                check_equal(rdata_v(24), '1', result("Test Read: rx_eff."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0001"), result("Test Read: rx_busy_i."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_data."));

                check_passed(result("Send 1 byte, long header, all zeroes: Pass."));

            elsif run("Send 1 byte, long header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (28 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --Setting tx_data
                wdata_v := x"FFFFFFFF";
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := x"FFFFFFFF";
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v := (1 => '1', 24 => '1', others =>'0');
                write_bus(net, axi_handle, 64, wdata_v, "1001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                check_equal(rdata_v(24), '1', result("Test Read: rx_eff."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"1FFFFFFF"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0001"), result("Test Read: rx_busy_i."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000000FF"), result("Test Read: rx_data."));

                check_passed(result("Send 1 byte, long header, all ones: Pass."));

            elsif run("Send 8 bytes, long header, all zeroes") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --data length
                wdata_v := to_std_logic_vector(8, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v := (1 => '1', 24 => '1', others =>'0');
                write_bus(net, axi_handle, 64, wdata_v, "1001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                check_equal(rdata_v(24), '1', result("Test Read: rx_eff."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("1000"), result("Test Read: rx_busy_i."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_data."));
                read_bus(net, axi_handle, 56, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_data."));

                check_passed(result("Send 8 bytes, long header, all zeroes: Pass."));

            elsif run("Send 8 bytes, long header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (28 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --Setting tx_data
                wdata_v := x"FFFFFFFF";
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := x"FFFFFFFF";
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(8, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Command to send
                wdata_v := (1 => '1', 24 => '1', others =>'0');
                write_bus(net, axi_handle, 64, wdata_v, "1001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));
                check_equal(rdata_v(24), '1', result("Test Read: rx_eff."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"1FFFFFFF"), result("Test Read: rx_busy_i."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("1000"), result("Test Read: rx_busy_i."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"FFFFFFFF"), result("Test Read: rx_data."));
                read_bus(net, axi_handle, 56, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"FFFFFFFF"), result("Test Read: rx_data."));

                check_passed(result("Send 8 bytes, long header, all ones: Pass."));

            elsif run("Send 8 bytes, short header, Force DLC to ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := (3 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v(11 downto 0), std_logic_vector'(x"7FF"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("1111"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"FFFFFFFF"), result("Test Read: rx_data."));
                read_bus(net, axi_handle, 56, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"FFFFFFFF"), result("Test Read: rx_data."));

                check_passed(result("Send 8 bytes, long header, all ones: Pass."));

            elsif run("Inject Error, test retry") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v := (1 => '1', others => '0');
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --Injecting error
                wdata_v := (8 => '1', others => '0');
                write_bus(net,axi_handle,28,wdata_v,"0010");
                write_bus(net,axi_handle,28,wdata_v,"0010");

                --RX completed or error.
                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Reading RX DATA IRQ during error."));
                check_equal(rdata_v(1), '1',result("Reading RX ERROR IRQ during error."));
                check_equal(rdata_v(8), '0',result("Reading RX DATA IRQ during error."));
                check_equal(rdata_v(9), '1',result("Reading RX ERROR IRQ during error."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ during error."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ during error."));
                check_equal(rdata_v(8), '0',result("Clearing RX DATA IRQ during error."));
                check_equal(rdata_v(9), '0',result("Clearing RX ERROR IRQ during error."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0001");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000007FF"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0001"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000000FF"), result("Test Read: rx_data."));

                check_passed(result("Inject Error, test retry: Pass."));

            elsif run("Force Error, test retry") then
                --set speed
                wdata_v := to_std_logic_vector(200, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v := (1 => '1', others => '0');
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 1 ms);
                wait for 100 us;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --Forcing error
                wait for 20 * data_period_c;
                force_line <= true;
                wait for 2 * data_period_c;
                force_line <= false;

                --RX completed or error.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Reading RX DATA IRQ during error."));
                check_equal(rdata_v(1), '1',result("Reading RX ERROR IRQ during error."));
                check_equal(rdata_v(8), '0',result("Reading RX DATA IRQ during error."));
                check_equal(rdata_v(9), '1',result("Reading RX ERROR IRQ during error."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ during error."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ during error."));
                check_equal(rdata_v(8), '0',result("Clearing RX DATA IRQ during error."));
                check_equal(rdata_v(9), '0',result("Clearing RX ERROR IRQ during error."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ during error."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ during error."));
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ during error."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ during error."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0001");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ during error."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ during error."));
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ during error."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ during error."));

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000007FF"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0001"), result("Test Read: rx_dlc."));

                --RX DATA
                read_bus(net, axi_handle, 52, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"000000FF"), result("Test Read: rx_data."));

                check_passed(result("Force Error, test retry: Pass."));

            elsif run("Loop Test, send 0 bytes, short header, all ones") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"1100");
                --Turn loop on and damage the channel
                force_line <= true;
                wdata_v := (0 => '1', others => '0');
                write_bus(net,axi_handle,28,wdata_v,"0001");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");
                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --wait for RX completed IRQ.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '1',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0011");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Clearing TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Clearing TX ERROR IRQ."));
                wait for 1 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: tx_busy_i."));

                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '0', result("Test Read: rx_busy_i."));

                --read RXID
                read_bus(net, axi_handle, 48, rdata_v);
                check_equal(rdata_v, std_logic_vector'(x"00000000"), result("Test Read: rx_id."));

                --RX DLC
                read_bus(net, axi_handle, 44, rdata_v);
                check_equal(rdata_v(3 downto 0), std_logic_vector'("0000"), result("Test Read: rx_dlc."));

                check_passed(result("Loop Test, send 0 bytes, short header, all ones: Pass."));

            elsif run("Test TX/RX DATA IRQ MASK") then
                --set speed
                wdata_v := to_std_logic_vector(data_rate_c, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");

                --IRQ Mask
                wdata_v := (others => '0');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --data length
                wdata_v := to_std_logic_vector(0, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");
                --Command to send
                wdata_v(1) := '1';
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 2 ms);
                wait for 10 * data_period_c;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                while rdata_v(8) = '1' loop
                    read_bus(net, axi_handle, 32, rdata_v);
                    wait for 10 * data_period_c;
                end loop;

                --wait for RX completed IRQ.
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(8), '0',result("Reading TX DATA IRQ."));
                check_equal(rdata_v(9), '0',result("Reading TX ERROR IRQ."));

                check_passed(result("Test TX/RX DATA IRQ MASK: Pass."));

            elsif run("Test TX/RX ERROR IRQ MASK") then
                --set speed
                wdata_v := to_std_logic_vector(200, 32);
                write_bus(net, axi_handle, 8, wdata_v, "0011");
                --IRQ Mask
                wdata_v := (16 => '1', 24 => '1', others => '0');
                write_bus(net,axi_handle,12,wdata_v,"1100");

                --set id
                wdata_v := (10 downto 0 => '1', others => '0');
                write_bus(net, axi_handle, 36, wdata_v, "1111");
                write_bus(net, axi_handle, 40, wdata_v, "1111");
                write_bus(net, axi_handle, 72, wdata_v, "1111");

                --data length
                wdata_v := to_std_logic_vector(1, 32);
                write_bus(net, axi_handle, 68, wdata_v, "0001");

                --Setting tx_data
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 76, wdata_v, "1111");
                wdata_v := (others => '1');
                write_bus(net, axi_handle, 80, wdata_v, "1111");

                --Command to send
                wdata_v := (1 => '1', others => '0');
                write_bus(net, axi_handle, 64, wdata_v, "0001");

                set_timeout(runner, now + 1 ms);
                wait for 100 us;

                --Testing tx_busy_i
                read_bus(net, axi_handle, 64, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: tx_busy_i."));
                --Testing rx_busy_i
                read_bus(net, axi_handle, 32, rdata_v);
                check_equal(rdata_v(8), '1', result("Test Read: rx_busy_i."));

                --Forcing error
                wait for 20 * data_period_c;
                force_line <= true;
                wait for 2 * data_period_c;
                force_line <= false;

                --RX completed.
                wait until rx_irq_o = '1';
                wait until tx_irq_o = '1';
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                check_equal(rdata_v(0), '1',result("Reading RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Reading RX ERROR IRQ."));
                wdata_v := (others => '1');
                write_bus(net,axi_handle,12,wdata_v,"0001");
                read_bus(net,axi_handle,12,rdata_v);
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));
                check_equal(rdata_v(0), '0',result("Clearing RX DATA IRQ."));
                check_equal(rdata_v(1), '0',result("Clearing RX ERROR IRQ."));

                check_passed(result("Test TX/RX ERROR IRQ MASK: Pass."));

            end if;
        end loop;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    test_runner_watchdog(runner, 101 us);

    --CAN VCI PROCESS
    -- vci_p: process
    -- begin
    rxi <= '0'   when force_line  else
           txo_o when txo_t = '1' else
           '1';
    --   wait;
    -- end process;

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

    dut_u : can_aximm_top
        generic map(
            system_freq  => 100.0000e+6,
            internal_phy => false
        )
        port map(
            rst_i         => rst_i,
            mclk_i        => mclk_i,
            S_AXI_AWADDR  => S_AXI_AWADDR,
            S_AXI_AWPROT  => S_AXI_AWPROT,
            S_AXI_AWVALID => S_AXI_AWVALID,
            S_AXI_AWREADY => S_AXI_AWREADY,
            S_AXI_WDATA   => S_AXI_WDATA,
            S_AXI_WSTRB   => S_AXI_WSTRB,
            S_AXI_WVALID  => S_AXI_WVALID,
            S_AXI_WREADY  => S_AXI_WREADY,
            S_AXI_BRESP   => S_AXI_BRESP,
            S_AXI_BVALID  => S_AXI_BVALID,
            S_AXI_BREADY  => S_AXI_BREADY,
            S_AXI_ARADDR  => S_AXI_ARADDR,
            S_AXI_ARPROT  => S_AXI_ARPROT,
            S_AXI_ARVALID => S_AXI_ARVALID,
            S_AXI_ARREADY => S_AXI_ARREADY,
            S_AXI_RDATA   => S_AXI_RDATA,
            S_AXI_RRESP   => S_AXI_RRESP,
            S_AXI_RVALID  => S_AXI_RVALID,
            S_AXI_RREADY  => S_AXI_RREADY,
            tx_irq_o      => tx_irq_o,
            rx_irq_o      => rx_irq_o,
            txo_o         => txo_o,
            txo_t         => txo_t,
            rxi           => rxi,
            can_l         => can_l,
            can_h         => can_h
        );

end simulation;
