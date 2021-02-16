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
library expert;
  use expert.std_logic_expert.all;
library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.com_context;

package i2cm_vci_pkg is


  constant INTERNAL_BUFFER_SIZE : integer := 8;

  type i2c_message_vector is array (natural range <>) of std_logic_vector(7 downto 0);
  type vci_status_t is ( busy, ready );

  constant WRITE_c                : std_logic  := '1';
  constant READ_c                 : std_logic  := '0';
  constant i2c_bulk_write_msg     : msg_type_t := new_msg_type("bulk write");
  constant i2c_bulk_read_msg      : msg_type_t := new_msg_type("bulk read");
  constant i2c_ram_write_msg      : msg_type_t := new_msg_type("ram write");
  constant i2c_ram_read_msg       : msg_type_t := new_msg_type("ram read");
  constant i2c_ram_read_reply_msg : msg_type_t := new_msg_type("ram read reply");
  constant i2c_timeout            : time       := 500 us;

  type i2c_master_t is protected
    procedure set_opcode        (input : std_logic_vector);
    procedure set_slave_address (input : std_logic_vector);
    procedure ram_write(signal net : inout network_t; addr : in std_logic_vector; data : in i2c_message_vector);
    procedure ram_read (signal net : inout network_t; addr : in std_logic_vector; data : out i2c_message_vector);
    impure function  status return vci_status_t;
    procedure run (
      signal net : inout network_t;
      signal sda : inout std_logic;
      signal scl : out std_logic
    );
  end protected i2c_master_t;

  procedure i2c_start (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    constant clk_period : time
  );

  procedure i2c_send (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    data       : in std_logic_vector(7 downto 0);
    constant clk_period : time
  );

  procedure i2c_get (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    data       : out std_logic_vector(7 downto 0);
    ack        : in boolean;
    constant clk_period : time
  );

  procedure i2c_stop (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    constant clk_period : time
  );

  procedure i2c_send_buffer (
    signal sda  : inout std_logic;
    signal scl  : out std_logic;
    data_buffer : in i2c_message_vector;
    opcode      : in std_logic_vector(3 downto 0);
    slave_addr  : in std_logic_vector(2 downto 0);
    constant clk_period : time
  );

  procedure i2c_get_buffer (
    signal sda  : inout std_logic;
    signal scl  : out std_logic;
    data_buffer : out i2c_message_vector;
    opcode      : in std_logic_vector(3 downto 0);
    slave_addr  : in std_logic_vector(2 downto 0);
    constant clk_period : time
  );

  function to_H (input : std_logic) return std_logic;
  procedure wait_for ( constant period : time ); 
  procedure wait_for_i2c ( variable i2c_bus : inout i2c_master_t; constant timeout : time );


end i2cm_vci_pkg;

--a arquitetura
package body i2cm_vci_pkg is

  type i2c_master_t is protected body

    constant queue : actor_t := new_actor("i2c queue");
    --variable opcode        : std_logic_vector(4 downto 0);
    --variable slave_address : std_logic_vector(9 downto 0);
    variable internal_buffer : i2c_message_vector(INTERNAL_BUFFER_SIZE+1 downto 0);
    variable opcode          : std_logic_vector(3 downto 0);
    variable slave_address   : std_logic_vector(2 downto 0);
    variable add10bitmode    : boolean := false;
    variable status_v        : vci_status_t := ready;
    constant clk_period      : time := 200 ns;
    
    impure function status return vci_status_t is
    begin
      return status_v;
    end status;

    procedure set_opcode (input : std_logic_vector) is
    begin
      if input'length = 4 then
        opcode(3 downto 0) := input;
        info("Using OPCODE = " & to_string(opcode) & " .");
      elsif input'length = 5 then
        opcode := input;
      else
        error("Wrong opcode size.");
      end if;
    end set_opcode;

    procedure set_slave_address (input : std_logic_vector) is
    begin
      if input'length = 3 then
        slave_address(2 downto 0) := input;
        info("Using SLAVE ADDRESS = " & to_string(slave_address) & " .");
      elsif input'length = 10 then
        slave_address := input;
      else
        error("Wrong opcode size.");
      end if;
    end set_slave_address;

    procedure ram_write (
      signal net       : inout network_t;
      addr             : in std_logic_vector;
      data             : in i2c_message_vector
    ) is
      variable i2c_msg : msg_t                         := new_msg(i2c_ram_write_msg);
      variable size    : integer                       := data'length;
      variable addr_v  : std_logic_vector(15 downto 0) := (others => '0');
    begin
      assert addr'length < 17
      report "i2c_ram_write: input must be 16 bits or less."
        severity failure;

      addr_v(15 downto 8) := get_slice(addr, 8, 1);
      addr_v(7 downto 0)  := get_slice(addr, 8, 0);

      push(i2c_msg, addr_v);
      push(i2c_msg, size);
      for j in data'range loop
        push(i2c_msg, data(j));
      end loop;
      send(net, queue, i2c_msg);
    end ram_write;

    procedure ram_read (
      signal net             : inout network_t;
      addr                   : in std_logic_vector;
      data                   : out i2c_message_vector
    ) is
      variable i2c_msg       : msg_t                         := new_msg(i2c_ram_read_msg);
      variable i2c_reply_msg : msg_t                         := new_msg(i2c_ram_read_reply_msg);
      variable size          : integer                       := data'length;
      variable addr_v        : std_logic_vector(15 downto 0) := (others => '0');
    begin
      assert addr'length < 17
        report "i2c_ram_write: input must be 16 bits or less."
        severity failure;

      size := data'length;
      
      addr_v(15 downto 8) := get_slice(addr, 8, 1);
      addr_v(7 downto 0)  := get_slice(addr, 8, 0);
      
      push(i2c_msg, addr_v);
      push(i2c_msg, size);
      
      for j in data'range loop
        push(i2c_msg, data(j));
      end loop;
      send(net, queue, i2c_msg);
      receive_reply(net, i2c_msg, i2c_reply_msg);
      for j in size - 1 downto 0 loop
        data(j) := pop(i2c_reply_msg);
      end loop;
    end ram_read;

    procedure run (
      signal net : inout network_t;
      signal sda : inout std_logic;
      signal scl : out std_logic
    ) is
      variable request_msg : msg_t;
      variable reply_msg   : msg_t;
      variable msg_type    : msg_type_t;
      variable addr        : std_logic_vector(15 downto 0);
      variable size        : integer;
      variable slave_addr  : std_logic_vector(2 downto 0);
    begin
      if has_message(queue) then
        receive(net, queue, request_msg);
        msg_type   := message_type(request_msg);
        slave_addr := slave_address(2 downto 0);
        if msg_type = i2c_ram_write_msg then
          addr := pop(request_msg);
          size := pop(request_msg);
          for j in size + 1 downto 2 loop
            internal_buffer(j) := pop(request_msg);
          end loop;
          internal_buffer(1) := get_slice(addr, 8, 1);
          internal_buffer(0) := get_slice(addr, 8, 0);
          status_v := busy;
          i2c_send_buffer(sda, scl, internal_buffer(size + 1 downto 0), opcode, slave_addr, clk_period);
          status_v := ready;

        elsif msg_type = i2c_ram_read_msg then
          addr    := pop(request_msg);
          size    := pop(request_msg);
          internal_buffer(1) := get_slice(addr, 8, 1);
          internal_buffer(0) := get_slice(addr, 8, 0);
          status_v := busy;
          i2c_send_buffer(sda, scl, internal_buffer(1 downto 0), opcode, slave_addr, clk_period);
          i2c_get_buffer (sda, scl, internal_buffer(size - 1 downto 0), opcode, slave_addr, clk_period);

          reply_msg := new_msg(i2c_ram_read_reply_msg);

          for j in size - 1 downto 0 loop
            push(reply_msg, internal_buffer(j));
          end loop;
          
          reply(net, request_msg, reply_msg);
          status_v := ready;
          
        else
          unexpected_msg_type(msg_type);

        end if;
      else
        wait_for(10 ns);
      end if;
    end run;

  end protected body i2c_master_t;

  procedure i2c_start (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    constant clk_period : time
  ) is
  begin
    scl <= 'Z';
    sda <= 'Z';
    info("Starting I2C Transfer.");
    wait for clk_period/2;
    sda <= '0';
    wait for clk_period/2;
  end procedure;

  procedure i2c_send (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    data       : in std_logic_vector(7 downto 0);
    constant clk_period : time
  ) is
    variable end_time : time;
  begin
    for j in 7 downto 0 loop
      scl <= '0';
      sda <= to_H(data(j));
      wait for clk_period/2;
      check_equal(to_H(data(j)), sda, result("I2C Bus: SDA Value Error."));
      scl <= 'Z';
      wait for clk_period/2;
      
    end loop;
    scl <= '0';
    sda <= 'Z';
    wait for clk_period/2;
    scl <= 'Z';
    sda <= '0';
    wait for clk_period/2;
  end i2c_send;

  procedure i2c_get (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    data       : out std_logic_vector(7 downto 0);
    ack        : in boolean;
    constant clk_period : time
  ) is
  begin
    for j in 7 downto 0 loop
      scl <= '0';
      sda <= 'Z';
      wait for clk_period/2;
      scl <= 'Z';
      sda <= 'Z';
      wait for clk_period/2;
      data(j) := to_X01(sda);
    end loop;
    scl <= '0';
    if ack then
      sda <= '0';
    else
      sda <= 'Z';
    end if;
    wait for clk_period/2;
    scl <= 'Z';
    wait for clk_period/2;
  end i2c_get;

  procedure i2c_stop (
    signal sda : inout std_logic;
    signal scl : out std_logic;
    constant clk_period : time
  ) is
  begin
    info("Ending I2C Transfer.");
    scl <= 'Z';
    sda <= 'Z';
    wait for clk_period/2;
  end i2c_stop;

  procedure i2c_send_buffer (
    signal sda  : inout std_logic;
    signal scl  : out std_logic;
    data_buffer : in i2c_message_vector;
    opcode      : in std_logic_vector(3 downto 0);
    slave_addr  : in std_logic_vector(2 downto 0);
    constant clk_period : time
  ) is
    variable tmp_buffer : i2c_message_vector(data_buffer'length-1 downto 0);
  begin
    tmp_buffer := data_buffer;
    i2c_start(sda, scl, clk_period);
    i2c_send(sda, scl, opcode & slave_addr & write_c, clk_period);
    for j in 0 to data_buffer'length-1 loop
      i2c_send(sda, scl, tmp_buffer(j), clk_period);
    end loop;
    i2c_stop(sda, scl, clk_period);
  end i2c_send_buffer;

  procedure i2c_get_buffer (
    signal sda  : inout std_logic;
    signal scl  : out std_logic;
    data_buffer : out i2c_message_vector;
    opcode      : in std_logic_vector(3 downto 0);
    slave_addr  : in std_logic_vector(2 downto 0);
    constant clk_period : time
  ) is
  begin
    i2c_start(sda, scl, clk_period);
    i2c_send(sda, scl, opcode & slave_addr & read_c, clk_period);
    for j in data_buffer'range loop
      if j = data_buffer'right then
        i2c_get(sda, scl, data_buffer(j), false, clk_period);
      else
        i2c_get(sda, scl, data_buffer(j), true, clk_period);
      end if;
    end loop;
    i2c_stop(sda, scl, clk_period);
  end i2c_get_buffer;

  function to_H (input : std_logic) return std_logic is
  begin
    if input = '1' then
      return 'H';
    end if;
    return input;
  end to_H;

  procedure wait_for (
    constant period : time
  ) is
  begin
    wait for period;
  end procedure;

  procedure wait_for_i2c ( variable i2c_bus : inout i2c_master_t; constant timeout : time ) is
    variable timer_cnt : integer := timeout/(10 ns);
  begin
    while true loop
      exit when timer_cnt = 0;
      exit when i2c_bus.status = busy;
      wait for 10 ns;
      timer_cnt := timer_cnt - 1;
    end loop;
    while true loop
      exit when timer_cnt = 0;
      exit when i2c_bus.status = ready;
      wait for 10 ns;
      timer_cnt := timer_cnt - 1;
    end loop;
    check_false(timer_cnt = 0, result("I2C Master timeout."));
  end procedure;

end i2cm_vci_pkg;
