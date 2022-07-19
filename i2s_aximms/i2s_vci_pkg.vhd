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
library expert;
	package protected_blocks_8 is new expert.protected_blocks
		generic map (
			data_sizes_c	=> 8
		);
	use work.protected_blocks_8.all;

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;
library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.com_context;

package i2s_vci_pkg is

  constant i2s_reset_msg          : msg_type_t := new_msg_type("buffer write");
  constant i2s_start_msg          : msg_type_t := new_msg_type("buffer read");

  type i2s_vci_t is protected
    procedure set_clock_dir   (input : boolean);
    procedure set_lr_inverted (input : boolean);
    procedure set_justified   (input : boolean);
    procedure set_sample_size (input : integer);
    procedure set_sample_rate (input : real);
    procedure write_tx_buffer (signal net : inout network_t; left : in  std_logic_vector; right : in  std_logic_vector);
    procedure read_rx_buffer  (signal net : inout network_t; left : out std_logic_vector; right : out std_logic_vector);
    impure function  status return vci_status_t;
    procedure run (
        signal net   : inout network_t;
    );
  end protected i2s_vci_t;

  procedure i2s_send (
    left         : in    std_logic_vector;
    right        : in    std_logic_vector;
    data         : out   std_logic
  );

  procedure i2s_receive (
    signal bclk  : inout std_logic;
    signal lrclk : inout std_logic;
    left         : out   std_logic_vector;
    right        : out   std_logic_vector;
    data         : in    std_logic
  );

  procedure i2s_clocking (
    signal bclk  : inout std_logic;
    signal lrclk : inout std_logic
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


end i2s_vci_pkg;

--a arquitetura
package body i2s_vci_pkg is

  type i2s_vci_t is protected body
    constant queue           : actor_t  := new_actor("i2s queue");
    variable tx_buffer_v     : buffer_t := allocate(memory, 64, "read buffer", alignment => 4);
    variable rx_buffer_v     : buffer_t := allocate(memory, 64, "read buffer", alignment => 4);
    variable clock_as_input  : boolean;
    variable lr_inverted     : boolean;
    variable justified       : boolean;
    variable sample_size     : boolean;
    variable sample_rate     : real;
    variable status_v        : vci_status_t := ready;
    variable half_bit_period : time := 500 ns;

    impure function status return vci_status_t is
    begin
      return status_v;
    end status;

    procedure set_clock_as_input (input : boolean) is
    begin
      clock_as_input := input;
      info("Clock Direction Input = " & to_string(input) & " .");
    end set_clock_dir;

    procedure set_lr_inverted (input : boolean) is
    begin
      lr_inverted := input;
      info("LR Inverted = " & to_string(input) & " .");
    end set_lr_inverted;

    procedure set_justified (input : boolean) is
    begin
      Justified := input;
      info("Justified = " & to_string(input) & " .");
    end set_justified;

    procedure set_sample_size (input : integer) is
    begin
      sample_size := input;
      half_bit_period := update_half_bit_period(sample_rate,sample_size);
      info("Sample Size (each channel) = " & to_string(input) & " .");
    end set_sample_size;

    procedure set_sample_rate (input : real) is
    begin
      sample_rate := input;
      half_bit_period := update_half_bit_period(sample_rate,sample_size);
      info("Sample Rate = " & to_string(input) & " .");
    end set_sample_rate;

    procedure ram_write (
      signal net       : inout network_t;
      left             : in std_logic_vector;
      right            : in std_logic_vector
    ) is
      variable i2s_msg : msg_t := new_msg(i2s_ram_write_msg);
    begin
      push(i2s_msg, left);
      push(i2s_msg, right);
      send(net, queue, i2c_msg);
    end ram_write;

    procedure run (
      signal net : inout network_t;
      signal bclk     : inout std_logic;
      signal lrclk    : inout std_logic;
      signal d_in     : in    std_logic;
      signal d_out    : out   std_logic
    ) is
    begin
      if has_message(queue) then
        receive(net, queue, request_msg);
        msg_type   := message_type(request_msg);
        if msg_type = i2s_start_msg then
          --read
          if clock_as_input then
          else
            i2s_data_clock_out(
              bclk,
              lrclk,
              d_in,
              d_out,
              --left_data_i     : in std_logic_vector;
              --right_data_i    : in std_logic_vector;
              --left_data_o     : out std_logic_vector;
              --right_data_o    : out std_logic_vector;
              frame_size,
              half_bit_period
            );
          end if;
          --write
        elsif msg_type = i2s_reset_msg then
        end if;
    end run;

  end protected body i2c_master_t;

  procedure i2s_data_clock_out (
    signal bclk     : in  std_logic;
    signal lrclk    : in  std_logic;
    signal d_in     : in  std_logic;
    signal d_out    : out std_logic;
    left_data_i     : in std_logic_vector;
    right_data_i    : in std_logic_vector;
    left_data_o     : out std_logic_vector;
    right_data_o    : out std_logic_vector;
    frame_size      : in integer;
    half_bit_period : in time;
  ) is
    left_data_v  : in std_logic_vector( left_data_o'range);
    right_data_v : in std_logic_vector(right_data_o'range);
  begin

    for j in frame_size-1 downto 0 loop
      check_true(lrclk = '0');
      check_true(bclk = '1');
      if j = 1 then
        lrclk <= '1';
      end if;
      d_out <= left_data_i(j);
      bclk <= '0';
      wait half_bit_period;
      left_data_v(j) := d_in;
      bclk <= '1';
      wait for half_bit_period;
    end loop;

    for j in frame_size-1 downto 0 loop
      check_true(lrclk = '1');
      check_true(bclk = '1');
      if j = 1 then
        lrclk <= '0';
      end if;
      d_out <= right_data_i(j);
      bclk <= '0';
      wait half_bit_period;
      right_data_v(j) := d_in;
      bclk <= '1';
      wait for half_bit_period;
    end loop;

    left_data_o  := left_data_v;
    right_data_o := right_data_v;

  end i2s_data_clock_out;


  function update_half_bit_period( sample_rate : real, sample_size : integer ) return time is
    variable bit_period :
  begin
    return ( integer( 1.0000e12 / ( sample_rate * 4 * sample_size )) * 1 ps );
    --magic number 4 reason: because a frame is 2 * sample size and and half period = period /2
  end function;

end i2s_vci_pkg;
