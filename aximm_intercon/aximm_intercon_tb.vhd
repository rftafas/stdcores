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
	use expert.std_string.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.prbs_lib.all;
  use stdblocks.scheduler_lib.all;
library std;
  use std.textio.all;
library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.vc_context;

  use work.aximm_intercon_pkg.all;

entity aximm_intercon_tb is
  generic (
    runner_cfg : string;
    run_time : integer := 100
  );
end aximm_intercon_tb;

architecture behavioral of aximm_intercon_tb is

  constant controllers_num : positive := 8;
  constant peripherals_num : positive := 5;
  constant DATA_BYTE_NUM   : positive := 1;
  constant ID_WIDTH        : positive := 4;
  constant ADDR_SIZE       : positive := 8;
  constant num_of_writes   : positive := 16;

  constant add_inc      : integer := size_of(DATA_BYTE_NUM);
  constant register_num : integer := 2**(ADDR_SIZE-size_of(DATA_BYTE_NUM)+1);
  
  constant strb_c  : std_logic_vector(DATA_BYTE_NUM-1 downto 0) := (others=>'1');

  --general
  signal rst_i         : std_logic := '0';
  signal clk_i         : std_logic := '0';
  --------------------------------------------------------------------------
  --AXIS Master Port
  --------------------------------------------------------------------------
  signal M_AXI_AWID    : std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
  signal M_AXI_AWVALID : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_AWREADY : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_AWADDR  : std_logic_array (controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal M_AXI_AWPROT  : std_logic_array (controllers_num-1 downto 0)(2 downto 0);
  --write data channel
  signal M_AXI_WVALID  : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_WREADY  : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_WDATA   : std_logic_array (controllers_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal M_AXI_WSTRB   : std_logic_array (controllers_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
  signal M_AXI_WLAST   : std_logic_vector(controllers_num-1 downto 0);
  --Write Response channel
  signal M_AXI_BVALID  : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_BREADY  : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_BRESP   : std_logic_array (controllers_num-1 downto 0)(1 downto 0);
  signal M_AXI_BID     : std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
  -- Read Address channel
  signal M_AXI_ARVALID : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_ARREADY : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_ARADDR  : std_logic_array (controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal M_AXI_ARPROT  : std_logic_array (controllers_num-1 downto 0)(2 downto 0);
  signal M_AXI_ARID    : std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
  --Read data channel
  signal M_AXI_RVALID  : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_RREADY  : std_logic_vector(controllers_num-1 downto 0);
  signal M_AXI_RDATA   : std_logic_array (controllers_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal M_AXI_RRESP   : std_logic_array (controllers_num-1 downto 0)(1 downto 0);
  signal M_AXI_RID     : std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
  signal M_AXI_RLAST   : std_logic_vector(controllers_num-1 downto 0);
  --------------------------------------------------------------------------
  --AXIS Slave Port
  --------------------------------------------------------------------------
  signal S_AXI_AWID    : std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
  signal S_AXI_AWVALID : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_AWREADY : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_AWADDR  : std_logic_array (peripherals_num-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal S_AXI_AWPROT  : std_logic_array (peripherals_num-1 downto 0)(2 downto 0);
  --write data channel
  signal S_AXI_WVALID  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_WREADY  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_WDATA   : std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_WSTRB   : std_logic_array (peripherals_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_WLAST   : std_logic_vector(peripherals_num-1 downto 0);
  --Write Response channel
  signal S_AXI_BVALID  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_BREADY  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_BRESP   : std_logic_array (peripherals_num-1 downto 0)(1 downto 0);
  signal S_AXI_BID     : std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
  -- Read Address channel
  signal S_AXI_ARVALID : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_ARREADY : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_ARADDR  : std_logic_array (peripherals_num-1 downto 0)(ADDR_SIZE-1 downto 0);
  signal S_AXI_ARPROT  : std_logic_array (peripherals_num-1 downto 0)(2 downto 0);
  signal S_AXI_ARID    : std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
  --Read data channel
  signal S_AXI_RVALID  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_RREADY  : std_logic_vector(peripherals_num-1 downto 0);
  signal S_AXI_RDATA   : std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
  signal S_AXI_RRESP   : std_logic_array (peripherals_num-1 downto 0)(1 downto 0);
  signal S_AXI_RID     : std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
  signal S_AXI_RLAST   : std_logic_vector(peripherals_num-1 downto 0);

  signal addr_map_s : std_logic_array(controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0) := (others=>(others=>'X'));
  signal addr_map_c : std_logic_array(controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0) := (
    ("0000----"),
    ("0001----"),
    ("0010----"),
    ("01------"),
    ("100-----"),
    ("101-----"),
    ("110-----"),
    ("111-----")
  );

  --MASTERS VCI HANDLERS
  --We have to use a different actor for every AXI Master, otherwise their messages get mixed up and
  --result will be garbage. This is also used on AXI Slaves, read and write.
  --Since VHDL does not allows for loops on declaration, the only way to code stuff on architecture is
  --by using functions or procedures.
  type actor_vector_t      is array (natural range <>) of actor_t;
  type bus_master_vector_t is array (peripherals_num-1 downto 0) of bus_master_t;

  impure function actor_vector_init (input : integer; prefix : string) return actor_vector_t is
    variable tmp : actor_vector_t(input-1 downto 0);
  begin
    for j in tmp'range loop
      tmp(j) := new_actor( prefix & "_" & to_string(j) );
    end loop;
    return tmp;
  end actor_vector_init;

  impure function bus_master_init (input : actor_vector_t) return bus_master_vector_t is
    variable tmp : bus_master_vector_t;
  begin
    for j in 0 to peripherals_num-1 loop
      tmp(j) := new_bus(data_length => 8*DATA_BYTE_NUM, address_length => ADDR_SIZE, actor=>input(j) );
    end loop;
    return tmp;
  end bus_master_init;

  constant axi_master_actors : actor_vector_t      := actor_vector_init(peripherals_num,"master");
  constant axi_master_handle : bus_master_vector_t := bus_master_init(axi_master_actors);

  --Slave VCI
  constant memory : memory_t := new_memory;
  constant axi_slave_read_actors  : actor_vector_t := actor_vector_init(controllers_num,"slave_read");
  constant axi_slave_write_actors : actor_vector_t := actor_vector_init(controllers_num,"slave_write");
  type axi_slave_vector_t is array (controllers_num-1 downto 0) of axi_slave_t;

  impure function bus_slave_init (input : actor_vector_t) return axi_slave_vector_t is
    variable tmp : axi_slave_vector_t;
  begin
    for j in 0 to controllers_num-1 loop
      tmp(j) := new_axi_slave(address_fifo_depth => 16, memory => memory, actor=>input(j) );
    end loop;
    return tmp;
  end bus_slave_init;

  
  constant axi_read_slave_handle  : axi_slave_vector_t := bus_slave_init(axi_slave_read_actors);
  constant axi_write_slave_handle : axi_slave_vector_t := bus_slave_init(axi_slave_write_actors);

  shared variable prbs : prbs_t;

begin

  clk_i <= not clk_i after 10 ns;


  -- There are several ways to configure the peripheral address map. It can be made
  -- on signal declaration (see addr_map_c above) or using the set_peripheral_api.
  -- yet, it is possible to make it configurable: just add a register bank (use HDL tools for that!)
  -- and you are good to go.
  config_process : process(all)
    variable addr_map_v : std_logic_array(controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0) := (others=>(others=>'X'));
  begin
    set_peripheral_address(7,"0000----",addr_map_v);
    set_peripheral_address(6,"0001----",addr_map_v);
    set_peripheral_address(5,"001-----",addr_map_v);
    set_peripheral_address(4,"01------",addr_map_v);
    set_peripheral_address(3,"100-----",addr_map_v);
    set_peripheral_address(2,"101-----",addr_map_v);
    set_peripheral_address(1,"110-----",addr_map_v);
    set_peripheral_address(0,"111-----",addr_map_v);
    addr_map_s <= addr_map_v;
  end process;

  --The Testbench
  main : process
    variable rdata_v  : std_logic_array(register_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0) := (others=>(others=>'0'));
    variable data_v   : std_logic_vector(8*DATA_BYTE_NUM-1 downto 0) := (others=>'0');
    variable buffer_v : buffer_t := null_buffer;
  begin
      test_runner_setup(runner, runner_cfg);
      rst_i     <= '1';
      wait until rising_edge(clk_i);
      wait until rising_edge(clk_i);
      rst_i     <= '0';
      wait until rising_edge(clk_i);
      wait until rising_edge(clk_i);

      while test_suite loop
        if run("Sanity check for system.") then
            report "System Sane. Begin tests.";
            check_passed(result("Sanity check for system."));

        elsif run("Simple Run Test") then
            set_timeout(runner, now + 110 us);
            wait for 100 us;
            check_passed(result("Simple Run Test Pass."));

        elsif run("Master 0 write out") then
          info("Writing to VCI Masters.");
          set_timeout(runner, now + 101 us);
          buffer_v := allocate(memory, 2**ADDR_SIZE, "write buffer", alignment => add_inc);
          --we will do a write to every address.
          --address on AXI are byte based so we have to rebase the address to the word size.
          for reg_addr in 0 to register_num-1 loop
            data_v := prbs.get_data(8*DATA_BYTE_NUM);
            set_expected_byte(memory, base_address(buffer_v)+add_inc*reg_addr, to_integer(data_v) );
            write_bus(net,axi_master_handle(0),add_inc*reg_addr,data_v,strb_c);
          end loop;
          info("Write is over.");
          set_timeout(runner, now + (register_num * 250 ns) );
          wait for register_num*200 ns;
          check_passed(result("Master 0 write out."));

        elsif run("All Masters Write Out") then
          info("Writing to VCI Masters.");
          set_timeout(runner, now + (register_num * 300 ns) );
          for j in 0 to peripherals_num-1 loop
            info("Master_" & to_string(j) & ": writing.");
            buffer_v := allocate(memory, 2**ADDR_SIZE, "write buffer", alignment => add_inc);
            for reg_addr in 0 to register_num-1 loop
              data_v      := prbs.get_data(8*DATA_BYTE_NUM);
              set_expected_byte(memory, base_address(buffer_v)+add_inc*reg_addr, to_integer(data_v) );
              write_bus(net,axi_master_handle(j),add_inc*reg_addr,data_v,strb_c);
              wait_until_idle( net, axi_master_handle(j) );
            end loop;
            set_timeout(runner, now + (register_num * 300 ns) );
            wait for register_num*250 ns;
            clear(memory);
            info("Master_" & to_string(j) & ": done.");
          end loop;
          set_timeout(runner, now + (register_num * 250 ns) );
          wait for register_num*200 ns;
          check_passed(result("All Masters Write Out - Pass."));

        elsif run("Master 0 Read Out") then
          info("Reading from VCI Masters.");
          set_timeout(runner, now + (register_num * 250 ns) );
          info("Master_0: reading.");
          buffer_v := allocate(memory, 2**ADDR_SIZE, "read buffer", alignment => add_inc);
          for reg_addr in 0 to register_num-1 loop
            data_v := prbs.get_data(8*DATA_BYTE_NUM);
            write_word(memory,base_address(buffer_v)+add_inc*reg_addr,data_v); 
            check_bus(net,axi_master_handle(0),add_inc*reg_addr,data_v,"Read Ok.");           
          end loop;
          set_timeout(runner, now + (register_num * 250 ns) );
          wait for register_num*200 ns;
          check_passed(result("Master 0 Read Out - Pass."));

        elsif run("All Masters Read Out") then
          info("Reading from VCI Masters.");
          set_timeout(runner, now + (register_num * 300 ns) );
          for j in 0 to peripherals_num-1 loop
            info("Master_" & to_string(j) & ": reading.");
            buffer_v := allocate(memory, 2**ADDR_SIZE, "read buffer", alignment => add_inc);
            for reg_addr in 0 to register_num-1 loop
              data_v := prbs.get_data(8*DATA_BYTE_NUM);
              write_word(memory,base_address(buffer_v)+add_inc*reg_addr,data_v);
              check_bus(net,axi_master_handle(j),add_inc*reg_addr,data_v,"Read Ok.");  
            end loop;
            set_timeout(runner, now + (2 * register_num * 200 ns) );
            wait for register_num*200 ns;
            info("Master_" & to_string(j) & ": done.");
            clear(memory);
          end loop;
          check_passed(result("All Masters Read Out - Pass."));
        end if;
      end loop;
      test_runner_cleanup(runner); -- Simulation ends here
  end process;
  
  test_runner_watchdog(runner, 1 us);


  aximm_intercon_i : aximm_intercon
    generic map (
      controllers_num => controllers_num,
      peripherals_num  => peripherals_num,
      DATA_BYTE_NUM   => DATA_BYTE_NUM,
      ADDR_SIZE       => ADDR_SIZE,
      ID_WIDTH        => ID_WIDTH
    )
    port map (
      rst_i         => rst_i,
      clk_i         => clk_i,
      addr_map_i    => addr_map_s,

      M_AXI_AWID    => M_AXI_AWID,
      M_AXI_AWVALID => M_AXI_AWVALID,
      M_AXI_AWREADY => M_AXI_AWREADY,
      M_AXI_AWADDR  => M_AXI_AWADDR,
      M_AXI_AWPROT  => M_AXI_AWPROT,
      M_AXI_WVALID  => M_AXI_WVALID,
      M_AXI_WREADY  => M_AXI_WREADY,
      M_AXI_WDATA   => M_AXI_WDATA,
      M_AXI_WSTRB   => M_AXI_WSTRB,
      M_AXI_WLAST   => M_AXI_WLAST,
      M_AXI_BVALID  => M_AXI_BVALID,
      M_AXI_BREADY  => M_AXI_BREADY,
      M_AXI_BRESP   => M_AXI_BRESP,
      M_AXI_BID     => M_AXI_BID,
      M_AXI_ARVALID => M_AXI_ARVALID,
      M_AXI_ARREADY => M_AXI_ARREADY,
      M_AXI_ARADDR  => M_AXI_ARADDR,
      M_AXI_ARPROT  => M_AXI_ARPROT,
      M_AXI_ARID    => M_AXI_ARID,
      M_AXI_RVALID  => M_AXI_RVALID,
      M_AXI_RREADY  => M_AXI_RREADY,
      M_AXI_RDATA   => M_AXI_RDATA,
      M_AXI_RRESP   => M_AXI_RRESP,
      M_AXI_RID     => M_AXI_RID,
      M_AXI_RLAST   => M_AXI_RLAST,
      S_AXI_AWID    => S_AXI_AWID,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_AWADDR  => S_AXI_AWADDR,
      S_AXI_AWPROT  => S_AXI_AWPROT,
      S_AXI_WVALID  => S_AXI_WVALID,
      S_AXI_WREADY  => S_AXI_WREADY,
      S_AXI_WDATA   => S_AXI_WDATA,
      S_AXI_WSTRB   => S_AXI_WSTRB,
      S_AXI_WLAST   => S_AXI_WLAST,
      S_AXI_BVALID  => S_AXI_BVALID,
      S_AXI_BREADY  => S_AXI_BREADY,
      S_AXI_BRESP   => S_AXI_BRESP,
      S_AXI_BID     => S_AXI_BID,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_ARADDR  => S_AXI_ARADDR,
      S_AXI_ARPROT  => S_AXI_ARPROT,
      S_AXI_ARID    => S_AXI_ARID,
      S_AXI_RVALID  => S_AXI_RVALID,
      S_AXI_RREADY  => S_AXI_RREADY,
      S_AXI_RDATA   => S_AXI_RDATA,
      S_AXI_RRESP   => S_AXI_RRESP,
      S_AXI_RID     => S_AXI_RID,
      S_AXI_RLAST   => S_AXI_RLAST
    );

  master_vci_gen : for j in 0 to peripherals_num-1 generate
    master_vci_u : entity vunit_lib.axi_lite_master
      generic map (
        bus_handle => axi_master_handle(j)
      )
      port map (
        aclk    => clk_i,
        --areset_n => S_AXI_ARESETN,
        awaddr  => S_AXI_AWADDR(j),
        --awprot => S_AXI_AWPROT(j),
        awvalid => S_AXI_AWVALID(j),
        awready => S_AXI_AWREADY(j),
        wdata   => S_AXI_WDATA(j),
        wstrb   => S_AXI_WSTRB(j),
        wvalid  => S_AXI_WVALID(j),
        wready  => S_AXI_WREADY(j),
        --wlast   => S_AXI_WLAST(j),
        bresp   => S_AXI_BRESP(j),
        bvalid  => S_AXI_BVALID(j),
        bready  => S_AXI_BREADY(j),
        araddr  => S_AXI_ARADDR(j),
        --arprot => S_AXI_ARPROT(j),
        arvalid => S_AXI_ARVALID(j),
        arready => S_AXI_ARREADY(j),
        rdata   => S_AXI_RDATA(j),
        rresp   => S_AXI_RRESP(j),
        rvalid  => S_AXI_RVALID(j),
        rready  => S_AXI_RREADY(j)
      );

      S_AXI_WLAST(j) <= '1';
  end generate;

  slave_vci_gen : for j in 0 to controllers_num-1 generate

    read_slave_vci_u : entity vunit_lib.axi_read_slave
      generic map (
        axi_slave => axi_read_slave_handle(j)
      )
      port map (
        aclk    => clk_i,

        arvalid => M_AXI_ARVALID(j),
        arready => M_AXI_ARREADY(j),
        arid    => M_AXI_ARID(j),
        araddr  => M_AXI_ARADDR(j),
        --aprot   => M_AXI_ARPROT(j),
        arlen   => "00000000",
        arsize  => "000",
        arburst => "00",
        rvalid  => M_AXI_RVALID(j),
        rready  => M_AXI_RREADY(j),
        rid     => M_AXI_RID(j),
        rdata   => M_AXI_RDATA(j),
        rresp   => M_AXI_RRESP(j),
        rlast   => M_AXI_RLAST(j)
      );

    write_slave_vci_u : entity vunit_lib.axi_write_slave
      generic map (
        axi_slave => axi_write_slave_handle(j)
      )
      port map (
        aclk    => clk_i,
        awvalid => M_AXI_AWVALID(j),
        awready => M_AXI_AWREADY(j),
        awid    => M_AXI_AWID(j),
        awaddr  => M_AXI_AWADDR(j),
        --awprot => M_AXI_AWPROT(j),
        awlen   => "00000000",
        awsize  => "000",
        awburst => "00",
        wvalid  => M_AXI_WVALID(j),
        wready  => M_AXI_WREADY(j),
        wdata   => M_AXI_WDATA(j),
        wstrb   => M_AXI_WSTRB(j),
        wlast   => M_AXI_WLAST(j),
        bvalid  => M_AXI_BVALID(j),
        bready  => M_AXI_BREADY(j),
        bid     => M_AXI_BID(j),
        bresp   => M_AXI_BRESP(j)
      );
  
  end generate;

end behavioral;
