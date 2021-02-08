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

package i2cm_vci_pkg is

  constant buffer_size        : integer    := 256;
  constant WRITE_c            : std_logic  := '1';
  constant READ_c             : std_logic  := '0';
  constant i2c_bulk_write_msg : msg_type_t := new_msg_type("bulk write");
  constant i2c_bulk_read_msg  : msg_type_t := new_msg_type("bulk read");
  constant i2c_ram_write_msg  : msg_type_t := new_msg_type("ram write");
  constant i2c_ram_read_msg   : msg_type_t := new_msg_type("ram read");

  type i2c_master_t is protected
    procedure set_slave_address (input : std_logic_vector);
    procedure set_slave_address (input : std_logic_vector);
    procedure i2c_ram_write(addr : in std_logic_vector; data : in  std_logic_array);
    procedure i2c_ram_read (addr : in std_logic_vector; data : out std_logic_array);
    procedure i2c_run (
      signal sda : inout std_logic;
      signal scl : out   std_logic;
    );

  end protected i2c_master_t;

  procedure i2c_start (
    signal sda : inout std_logic;
    signal scl : out std_logic;
  );
  procedure i2c_send (
    signal sda    : inout std_logic;
    signal scl    : out std_logic;
    signal data_i : in std_logic_vector(7 downto 0)
  );
  procedure i2c_get (
    signal data_o : out std_logic_vector(7 downto 0);
    signal ack    : in boolean;
    signal sda    : inout std_logic;
    signal scl    : out std_logic;
  );
  procedure i2c_stop (
    signal sda : inout std_logic;
    signal scl : out std_logic;
  );
  procedure i2c_send_buffer (
    signal sda         : inout std_logic;
    signal scl         : out std_logic;
    signal data_buffer : in std_logic_array
  );
  procedure i2c_get_buffer (
    signal sda         : inout std_logic;
    signal scl         : out std_logic;
    signal address     : in std_logic_vector(15 downto 0);
    signal data_buffer : in std_logic_array
  );
end i2c_axim_pkg;

--a arquitetura
package body i2c_axim_pkg is

  type i2c_master_t is protected body

    constant queue         : actor_t := new_actor("i2c queue");
    variable opcode        : std_logic_vector(4 downto 0);
    variable slave_address : std_logic_vector(9 downto 0);
    variable add10bitmode  : boolean := false;

    procedure set_opcode (input : std_logic_vector) is
    begin
      if input'length = 4 then
        opcode(3 downto 0) := input;
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
      elsif input'length = 10 then
        slave_address := input;
      else
        error("Wrong opcode size.");
      end if;
    end set_slave_address;

    procedure i2c_ram_write (addr : in std_logic_vector; data : in std_logic_array) is
      variable i2c_msg : msg_t                         := new_msg(i2c_ram_write_msg);
      variable size    : integer                       := data'length;
      variable addr_v  : std_logic_vector(15 downto 0) := (others => '0');
    begin
      assert addr'length < 17
      report "i2c_ram_write: input must be 16 bits or less."
        severity failure;

      addr_v(15 downto 8) := get_slice(addr, 8, 1)
      addr_v(7 downto 0)  := get_slice(addr, 8, 0)

      push(i2c_msg, addr_v);
      push(i2c_msg, size);
      for j in data'range loop
        push(i2c_msg, data(j));
      end loop;
      send(net, queue, i2c_msg);
    end i2c_ram_write;

    procedure i2c_ram_read (addr : in std_logic_vector; data : out std_logic_array) is
      variable i2c_msg       : msg_t                         := new_msg(i2c_ram_write_msg);
      variable i2c_reply_msg : msg_t                         := new_msg(i2c_ram_write_msg);
      variable size          : integer                       := data'length;
      variable addr_v        : std_logic_vector(15 downto 0) := (others => '0');
    begin
      assert addr'length < 17
      report "i2c_ram_write: input must be 16 bits or less."
        severity failure;

      addr_v(15 downto 8) := get_slice(addr, 8, 1)
      addr_v(7 downto 0)  := get_slice(addr, 8, 0)

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
    end i2c_ram_read;

    procedure i2c_run (
      signal sda : inout std_logic;
      signal scl : out std_logic;
    ) is
      variable request_msg : msg_t;
      variable reply_msg   : msg_t;
      variable msg_type    : msg_type_t;
      variable addr        : std_logic_vector;
      variable size        : integer;
      variable data        : std_logic_array(buffer_size - 1 downto 0)(7 downto 0);
    begin
      receive(net, queue, request_msg);
      msg_type := message_type(request_msg);

      case msg_type is
        when i2c_ram_write_msg =>
          addr := pop(request_msg);
          size := pop(request_msg);
          for j in size - 1 downto 0 loop
            data(j) := pop(request_msg);
          end loop;
          data_size(size + 1) := get_slice(addr, 8, 1);
          data_size(size)     := get_slice(addr, 8, 0);
          i2c_send_buffer(sda, scl, data, opcode, slave_addr);

        elsif msg_type = read_msg then
          addr         := pop(request_msg);
          size         := pop(request_msg);
          data_size(1) := get_slice(addr, 8, 1);
          data_size(0) := get_slice(addr, 8, 0);
          i2c_send_buffer(sda, scl, data(1 downto 0), opcode, slave_addr);
          i2c_get_buffer (sda, scl, data(size - 1 downto 0), opcode, slave_addr);

          for j in size - 1 downto 0 loop
            push(reply_msg, data(j));
          end loop;

          reply_msg := new_msg(read_reply_msg);
          reply(net, request_msg, reply_msg);

        else
          unexpected_msg_type(msg_type);
      end if;
    end i2c_run;

  end protected body i2c_master_t;
  procedure i2c_start (
    signal sda : inout std_logic;
    signal scl : out std_logic;
  ) is
  begin
    scl <= '1';
    sda <= 'H';
    wait for 50 ns;
    sda <= '0';
    wait for 50 ns;
  end procedure;

  procedure i2c_send (
    signal sda  : inout std_logic;
    signal scl  : out std_logic;
    signal data : in std_logic_vector(7 downto 0)
  ) is
  begin
    scl <= '0';
    for j in 7 downto 0 loop
      sda <= to_H(data(j));
      wait for 50 ns;
      scl <= '1';
      wait for 50 ns;
      scl <= '0';
    end loop;
    wait for 50 ns;
    wait until sda = '0';
    scl <= '1';
    wait for 50 ns;
  end i2c_send;

  procedure i2c_get (
    signal sda  : inout std_logic;
    signal scl  : out std_logic;
    signal data : out std_logic_vector(7 downto 0);
    signal ack  : in boolean
  ) is
  begin
    scl <= '0';
    for j in 7 downto 0 loop
      wait for 50 ns
      scl <= '1';
      wait for 50 ns;
      data(j) <= to_X01(sda);
      scl     <= '0';
    end loop;

    if ack then
      sda <= '0';
    else
      sda <= '1';
    end if;

    wait for 50 ns;
    scl <= '1';
    wait for 50 ns;
  end i2c_send;

  procedure i2c_stop (
    signal sda : inout std_logic;
    signal scl : out std_logic;
  ) is
  begin
    sda <= '1';
    wait for 50 ns;
  end i2c_send;

  procedure i2c_send_buffer (
    signal sda         : inout std_logic;
    signal scl         : out std_logic;
    signal data_buffer : in std_logic_array;
    signal opcode      : in std_logic_vector(3 downto 0);
    signal slave_addr  : in std_logic_vector(2 downto 0)
  ) is
  begin
    i2c_start(sda, scl);
    i2c_send(sda, scl, opcode & slave_addr & write_c);
    for j in data_buffer'range loop
      i2c_send(sda, scl, data_buffer(j));
    end loop;
    i2c_stop(sda, scl);
  end send_buffer;

  procedure i2c_get_buffer (
    signal sda         : inout std_logic;
    signal scl         : out std_logic;
    signal address     : in std_logic_vector(15 downto 0);
    signal data_buffer : in std_logic_array;
    signal opcode      : in std_logic_vector(3 downto 0);
    signal slave_addr  : in std_logic_vector(2 downto 0)
  ) is
  begin
    i2c_start(sda, scl);
    i2c_send(sda, scl, opcode & slave_addr & read_c);
    for j in data_buffer'range loop
      if j = data_buffer'right then
        i2c_get(sda, scl, data_buffer(j), '1');
      else
        i2c_get(sda, scl, data_buffer(j), '0');
      end if;
    end loop;
    i2c_stop(sda, scl);
  end read_buffer;

end i2c_axim_pkg;
