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
  use stdblocks.axis_lib.all;

  entity smart_axis_packet_fifo is
      generic (
        ram_type     : fifo_t := blockram;
        fifo_size    : integer := 8;
        meta_size    : integer := 5;
        tdata_size   : integer := 8;
        tdest_size   : integer := 8;
        tuser_size   : integer := 8;
        tuser_enable : boolean := false;
        tdest_enable : boolean := false
      );
      port (
        --general
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;

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

        flush_i      : in  std_logic;
        abort_i      : in  std_logic;
        repeat_i     : in  std_logic;

        fifo_status_o : out fifo_status
      );
  end smart_axis_packet_fifo;

architecture behavioral of smart_axis_packet_fifo is

  --just a note: for a meta parameter fifo, the addresses are data.
  constant meta_param_c : fifo_config_rec := (
    ram_type     => distributed,
    fifo_size    => meta_size,
    tdata_size   => fifo_size,
    tdest_size   => tdest_size,
    tuser_size   => tuser_size,
    packet_mode  => false,
    tuser_enable => tuser_enable,
    tdest_enable => tdest_enable,
    tlast_enable => false,
    cut_through  => true,
    sync_mode    => true
  );

  constant meta_port_size : integer := fifo_size_f(meta_param_c);

  signal meta_data_i_s    : std_logic_vector(meta_port_size-1 downto 0);
  signal meta_data_o_s    : std_logic_vector(meta_port_size-1 downto 0);

  signal rd_pointer_s     : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal wr_pointer_s     : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal end_pointer_s    : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');
  signal abort_pointer_s  : std_logic_vector(fifo_size-1 downto 0) := (others=>'0');

  signal flush_s          : std_logic;
  signal m_tlast_o_s      : std_logic;

  signal enb_i_s          : std_logic;
  signal ena_i_s          : std_logic;
  signal meta_enb_i_s     : std_logic;
  signal meta_ena_i_s     : std_logic;

  signal fifo_status_s    : fifo_status;
  signal meta_status_s    : fifo_status;

begin

  --input, data to fifo
  meta_data_i_s <= fifo_in_f(meta_param_c,wr_pointer_s,s_tuser_i,s_tdest_i,'0');

  --output, data FROM fifo.
  end_pointer_s <= tdata_out_f(meta_param_c,meta_data_o_s);
  m_tuser_o     <= tuser_out_f(meta_param_c,meta_data_o_s);
  m_tdest_o     <= tdest_out_f(meta_param_c,meta_data_o_s);
  m_tlast_o     <= m_tlast_o_s;

  meta_ena_i_s <= '0' when abort_i     = '1'                   else
                  '1' when s_tlast_i   = '1' and ena_i_s = '1' else
                  '0';

  meta_enb_i_s <= '1' when flush_i     = '1'                   else
                  '0' when repeat_i    = '1'                   else
                  '1' when m_tlast_o_s = '1' and enb_i_s = '1' else
                  '0';

  meta_fifo_u : stdfifo1ck
    generic map(
      ram_type  => distributed,
      fifo_size => meta_size,
      port_size => meta_port_size
    )
    port map(
      --general
      clk_i    => clk_i,
      rst_i    => rst_i,
      dataa_i  => meta_data_i_s,
      datab_o  => meta_data_o_s,
      ena_i    => meta_ena_i_s,
      enb_i    => meta_enb_i_s,

      fifo_status_o => meta_status_s
    );

  --enable generation
  s_tready_o      <= (not fifo_status_s.full)  and (not  meta_status_s.full);
  ena_i_s         <= (not fifo_status_s.full)  and (not  meta_status_s.full) and s_tvalid_i;

  m_tvalid_o      <= (not fifo_status_s.empty) and (not meta_status_s.empty);
  enb_i_s         <= (not fifo_status_s.empty) and (not meta_status_s.empty) and m_tready_i;

  --tlast generation
  m_tlast_o_s <= '1' when rd_pointer_s = end_pointer_s else '0';

  data_fifo_u : intfifo1ck
    generic map(
      ram_type  => ram_type,
      fifo_size => fifo_size,
      port_size => tdata_size
    )
    port map(
      --general
      clk_i   => clk_i,
      rst_i   => rst_i,
      dataa_i  => s_tdata_i,
      datab_o  => m_tdata_o,
      ena_i    => ena_i_s,
      enb_i    => enb_i_s,

      pointera_i    => abort_pointer_s,
      pointera_o    => wr_pointer_s,
      pointera_en_i => abort_i,
      pointerb_i    => end_pointer_s,
      pointerb_o    => rd_pointer_s,
      pointerb_en_i => flush_s,

      fifo_status_o => fifo_status_s
    );

    fifo_status_o <= fifo_status_s;

    process(all)
    begin
      if rising_edge(clk_i) then
        if meta_ena_i_s = '1' then
          abort_pointer_s <= wr_pointer_s;
        end if;
        flush_s <= flush_i;
      end if;
    end process;

  end behavioral;
