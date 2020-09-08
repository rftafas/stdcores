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
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;
    use stdblocks.fifo_lib.all;

package axis_fifo_pkg is

  type fifo_config_rec is record
    ram_type     :  fifo_t;
    fifo_size    : integer;
    tdata_size   : integer;
    tdest_size   : integer;
    tuser_size   : integer;
    packet_mode  : boolean;
    tuser_enable : boolean;
    tlast_enable : boolean;
    tdest_enable : boolean;
    sync_mode    : boolean;
    cut_through  : boolean;
  end record;

  function header_size_f ( param : fifo_config_rec
  ) return integer;
  function fifo_size_f   ( param : fifo_config_rec
  ) return integer;
  function fifo_in_f     ( param : fifo_config_rec;
                           tdata : std_logic_vector;
                           tuser : std_logic_vector;
                           tdest : std_logic_vector;
                           tlast : std_logic
  ) return std_logic_vector;

  function tdata_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic_vector;

  function tdest_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic_vector;

  function tuser_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic_vector;

  function tlast_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic;

end package;

package body axis_fifo_pkg is

  function header_size_f ( param : fifo_config_rec ) return integer is
      variable tmp : integer;
  begin
    tmp := 0;

    if param.packet_mode or param.tlast_enable then
      tmp := 1;
    end if;

    if param.tuser_enable then
      tmp := param.tuser_size + tmp;
    end if;

    if param.tdest_enable then
      tmp := tmp + param.tdest_size;
    end if;

    return tmp;
  end header_size_f;

  function fifo_size_f ( param : fifo_config_rec ) return integer is
      variable tmp : integer;
  begin
    tmp := param.tdata_size + header_size_f(param);
    return tmp;
  end fifo_size_f;

  function fifo_in_f (  param : fifo_config_rec;
                        tdata : std_logic_vector;
                        tuser : std_logic_vector;
                        tdest : std_logic_vector;
                        tlast : std_logic
  ) return std_logic_vector is
    variable tmp : std_logic_vector(fifo_size_f(param)-1 downto 0);
  begin
  --
    if param.packet_mode or param.tlast_enable then
      tmp(0) := tlast;
    end if;

    if param.tuser_enable then
      tmp := tmp sll param.tuser_size;
      tmp(param.tuser_size-1 downto 0) := tuser;
    end if;

    if param.tdest_enable then
      tmp := tmp sll param.tdest_size;
      tmp(param.tdest_size-1 downto 0) := tdest;
    end if;

    tmp := tmp sll param.tdata_size;
    tmp(param.tdata_size-1 downto 0) := tdata;

    return tmp;
  end fifo_in_f;

  function tdata_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic_vector is
  begin

    return input_data(param.tdata_size-1 downto 0);

  end tdata_out_f;

  function tdest_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic_vector is
    variable tmp  : std_logic_vector(input_data'range);
  begin
    tmp := input_data;
    tmp := tmp srl param.tdata_size;
    return tmp(param.tdest_size-1 downto 0);

  end tdest_out_f;

  function tuser_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic_vector is
    variable tmp  : std_logic_vector(input_data'range);
  begin
    tmp := input_data;
    tmp := tmp srl param.tdata_size;
    tmp := tmp srl param.tdest_size;
    return tmp(param.tuser_size-1 downto 0);

  end tuser_out_f;

  function tlast_out_f (  param      : fifo_config_rec;
                          input_data : std_logic_vector
  ) return std_logic is
  begin
    return input_data(input_data'high);

  end tlast_out_f;

end package body;
