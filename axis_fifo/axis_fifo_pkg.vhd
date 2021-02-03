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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;
library expert;
use expert.std_logic_expert.all;
library stdblocks;
use stdblocks.ram_lib.all;
use stdblocks.fifo_lib.all;

package axis_fifo_pkg is

  type fifo_config_rec is record
    ram_type     : fifo_t;
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

  function metadata_size_f (
    param : fifo_config_rec
  ) return integer;

  procedure fifo_in_f (
    constant param : in  fifo_config_rec;
    signal   fifo  : out std_logic_vector;
    signal   tdata : in  std_logic_vector;
    signal   tuser : in  std_logic_vector;
    signal   tdest : in  std_logic_vector;
    signal   tlast : in  std_logic
  );

  procedure fifo_out_f (
    constant param : in  fifo_config_rec;
    signal   fifo  : in  std_logic_vector;
    signal   tdata : out std_logic_vector;
    signal   tuser : out std_logic_vector;
    signal   tdest : out std_logic_vector;
    signal   tlast : out std_logic
  );

  component axis_fifo is
    generic (
      ram_type     :  fifo_t := blockram;
      fifo_size    : integer := 8;
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      packet_mode  : boolean := false;
      tuser_enable : boolean := false;
      tlast_enable : boolean := false;
      tdest_enable : boolean := false;
      sync_mode    : boolean := false;
      cut_through  : boolean := false
    );
    port (
      --general
      clka_i       : in  std_logic;
      rsta_i       : in  std_logic;
      clkb_i       : in  std_logic;
      rstb_i       : in  std_logic;

      s_tdata_i    : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i    : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i    : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o   : out std_logic;
      s_tvalid_i   : in  std_logic;
      s_tlast_i    : in  std_logic;

      m_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i   : in  std_logic;
      m_tvalid_o   : out std_logic;
      m_tlast_o    : out std_logic;

      fifo_status_a_o : out fifo_status;
      fifo_status_b_o : out fifo_status
    );
  end component axis_fifo;

end package;

package body axis_fifo_pkg is

  function metadata_size_f (
    param : fifo_config_rec
  ) return integer is
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
  end metadata_size_f;

  procedure fifo_in_f (
    constant param : in fifo_config_rec;
    signal fifo    : out std_logic_vector;
    signal tdata   : in std_logic_vector;
    signal tuser   : in std_logic_vector;
    signal tdest   : in std_logic_vector;
    signal tlast   : in std_logic
  ) is
    variable tmp : std_logic_vector(metadata_size_f(param) + param.tdata_size - 1 downto 0);
  begin

    if param.packet_mode or param.tlast_enable then
      tmp(0) := tlast;
    end if;

    if param.tuser_enable then
      tmp                                := tmp sll param.tuser_size;
      tmp(param.tuser_size - 1 downto 0) := tuser;
    end if;

    if param.tdest_enable then
      tmp                                := tmp sll param.tdest_size;
      tmp(param.tdest_size - 1 downto 0) := tdest;
    end if;

    tmp                                := tmp sll param.tdata_size;
    tmp(param.tdata_size - 1 downto 0) := tdata;

    fifo <= tmp;
  end fifo_in_f;

  procedure fifo_out_f (
    constant param : in fifo_config_rec;
    signal fifo    : in std_logic_vector;
    signal tdata   : out std_logic_vector;
    signal tuser   : out std_logic_vector;
    signal tdest   : out std_logic_vector;
    signal tlast   : out std_logic
  ) is
    variable tmp : std_logic_vector(metadata_size_f(param) + param.tdata_size - 1 downto 0);
  begin
    tmp := fifo;

    tdata <= tmp(param.tdata_size - 1 downto 0);
    tmp := tmp srl param.tdata_size;

    if param.tdest_enable then
      tdest <= tmp(param.tdest_size - 1 downto 0);
      tmp := tmp srl param.tdest_size;
    end if;

    if param.tuser_enable then
      tuser <= tmp(param.tuser_size - 1 downto 0);
      tmp := tmp srl param.tuser_size;
    end if;

    if param.packet_mode or param.tlast_enable then
      tlast <= tmp(0);
    end if;
  end fifo_out_f;

end package body;
