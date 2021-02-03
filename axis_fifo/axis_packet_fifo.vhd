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
  use expert.std_logic_gray.all;
library stdblocks;
  use stdblocks.sync_lib.all;
  use stdblocks.ram_lib.all;
  use stdblocks.fifo_lib.all;

  use work.axis_fifo_pkg.all;

entity axis_packet_fifo is
    generic (
      ram_type     : fifo_t   := blockram;
      fifo_size    : positive := 8;
      tdata_size   : positive := 8;
      tdest_size   : positive := 8;
      tuser_size   : positive := 8;
      tuser_enable : boolean  := false;
      tdest_enable : boolean  := false;
      sync_mode    : boolean  := false
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
end axis_packet_fifo;

architecture behavioral of axis_packet_fifo is

  constant fifo_param_c : fifo_config_rec := (
    ram_type     => blockram,
    fifo_size    => fifo_size,
    tdata_size   => tdata_size,
    tdest_size   => tdest_size,
    tuser_size   => tuser_size,
    packet_mode  => true,
    tuser_enable => tuser_enable,
    tlast_enable => true,
    tdest_enable => tdest_enable,
    sync_mode    => sync_mode,
    cut_through  => false
  );

  constant input_vector_size : integer := metadata_size_f(fifo_param_c) + tdata_size;

  signal   fifo_data_i_s  : std_logic_vector(input_vector_size-1 downto 0);
  signal   fifo_data_o_s  : std_logic_vector(input_vector_size-1 downto 0);

  signal enb_i_s       : std_logic;
  signal ena_i_s       : std_logic;

  signal fifo_status_a_s : fifo_status;
  signal fifo_status_b_s : fifo_status;

begin

  --input, data to fifo
  fifo_in_f(fifo_param_c,fifo_data_i_s,s_tdata_i,s_tuser_i,s_tdest_i,s_tlast_i);

  --output, data FROM fifo.
  fifo_out_f(fifo_param_c,fifo_data_o_s,m_tdata_o,m_tuser_o,m_tdest_o,m_tlast_o);


  s_tready_o <= not fifo_status_a_s.full;
  ena_i_s    <= not fifo_status_a_s.full and s_tvalid_i;

  m_tvalid_o <= not fifo_status_b_s.empty;
  enb_i_s    <= not fifo_status_b_s.empty and m_tready_i;

  fifo_status_a_o <= fifo_status_a_s;
  fifo_status_b_o <= fifo_status_b_s;

  --this is not that smart fifo. it counts number of TLAST in to announce how many packats
  --it contains.


  sync_fifo_gen : if not sync_mode generate
    fifo_u : stdfifo2ck
        generic map(
          ram_type  => ram_type,
          fifo_size => fifo_size,
          port_size => input_vector_size
        )
        port map(
          --general
          clka_i   => clka_i,
          rsta_i   => rsta_i,
          clkb_i   => clkb_i,
          rstb_i   => rstb_i,
          dataa_i  => fifo_data_i_s(fifo_size-1 downto 0),
          datab_o  => fifo_data_o_s(fifo_size-1 downto 0),
          ena_i    => ena_i_s,
          enb_i    => enb_i_s,

          fifo_status_a_o => fifo_status_a_s,
          fifo_status_b_o => fifo_status_b_s
        );

    else generate
      fifo_u : stdfifo1ck
          generic map(
            ram_type  => ram_type,
            fifo_size => fifo_size,
            port_size => input_vector_size
          )
          port map(
            --general
            clk_i   => clka_i,
            rst_i   => rsta_i,
            dataa_i  => fifo_data_i_s(fifo_size-1 downto 0),
            datab_o  => fifo_data_o_s(fifo_size-1 downto 0),
            ena_i    => ena_i_s,
            enb_i    => enb_i_s,


          fifo_status_o => fifo_status_a_s
        );

        fifo_status_b_s <= fifo_status_a_s;
        
    end generate;

end behavioral;
