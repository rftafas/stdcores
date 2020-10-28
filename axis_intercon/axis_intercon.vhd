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

entity axis_intercon is
    generic (
      master_portnum : positive := 8;
      slave_portnum  : positive := 8;
      tdata_size     : positive := 8;
      tdest_size     : positive := 8;
      tuser_size     : positive := 8;
      select_auto    : boolean  := false;
      switch_tlast   : boolean  := false;
      interleaving   : boolean  := false;
      max_tx_size    : positive := 10;
      mode           : integer  := 10
    );
    port (
      --general
      rst_i       : in  std_logic;
      clk_i       : in  std_logic;
      --AXIS Master Port
      m_tdata_o  : out std_logic_array (number_masters-1 downto 0,tdata_size-1 downto 0);
      m_tuser_o  : out std_logic_array (number_masters-1 downto 0,tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array (number_masters-1 downto 0,tdest_size-1 downto 0);
      m_tready_i : in  std_logic_vector(number_masters-1 downto 0);
      m_tvalid_o : out std_logic_vector(number_masters-1 downto 0);
      m_tlast_o  : out std_logic_vector(number_masters-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  std_logic_array (number_slaves-1 downto 0,tdata_size-1 downto 0);
      s_tuser_i  : in  std_logic_array (number_slaves-1 downto 0,tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array (number_slaves-1 downto 0,tdest_size-1 downto 0);
      s_tready_o : out std_logic_vector(number_slaves-1 downto 0);
      s_tvalid_i : in  std_logic_vector(number_slaves-1 downto 0);
      s_tlast_i  : in  std_logic_vector(number_slaves-1 downto 0)
    );
end axis_intercon;

architecture behavioral of axis_intercon is

  constant number_masters : integer := 2;
  constant number_slaves  : integer := 2;

  component axis_demux is
    generic (
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      select_auto  : boolean := false;
      switch_tlast : boolean := false;
      max_tx_size  : integer := 10
    );
    port (
      --general
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      --AXIS Master Port 0
      m0_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      m0_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      m0_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m0_tready_i   : in  std_logic;
      m0_tvalid_o   : out std_logic;
      m0_tlast_o    : out std_logic;
      --AXIS Master Port 1
      m1_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      m1_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      m1_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m1_tready_i   : in  std_logic;
      m1_tvalid_o   : out std_logic;
      m1_tlast_o    : out std_logic;
      --AXIS Master port
      s_tdata_i  : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o : out std_logic;
      s_tvalid_i : in  std_logic;
      s_tlast_i  : in  std_logic
    );
  end component;

  component axis_mux
    generic (
      number_ports : positive := 2;
      tdata_size   : positive := 8;
      tdest_size   : positive := 8;
      tuser_size   : positive := 8;
      select_auto  : boolean := false;
      switch_tlast : boolean := false;
      interleaving : boolean := false;
      max_tx_size  : positive := 10;
      mode         : integer := 10
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      s_tdata_i  : in  vector_array(number_ports-1 downto 0)(tdata_size-1 downto 0);
      s_tuser_i  : in  vector_array(number_ports-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  vector_array(number_ports-1 downto 0)(tdest_size-1 downto 0);
      s_tready_o : out std_logic_vector(number_ports-1 downto 0);
      s_tvalid_i : in  std_logic_vector(number_ports-1 downto 0);
      s_tlast_i  : in  std_logic_vector(number_ports-1 downto 0);
      m_tdata_o  : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i : in  std_logic;
      m_tvalid_o : out std_logic;
      m_tlast_o  : out std_logic
    );
  end component axis_mux;

  component axis_demux
    generic (
      number_masters : integer := 2;
      tdata_size     : integer := 8;
      tdest_size     : integer := 8;
      tuser_size     : integer := 8;
      select_auto    : boolean := false;
      switch_tlast   : boolean := false;
      max_tx_size    : integer := 10
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      m_tdata_o  : out vector_array(number_ports-1 downto 0)(tdata_size-1 downto 0);
      m_tuser_o  : out vector_array(number_ports-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out vector_array(number_ports-1 downto 0)(tdest_size-1 downto 0);
      m_tready_i : in  std_logic_vector(number_ports-1 downto 0);
      m_tvalid_o : out std_logic_vector(number_ports-1 downto 0);
      m_tlast_o  : out std_logic_vector(number_ports-1 downto 0);
      s_tdata_i  : in  std_logic_vector(tdata_size-1 downto 0);
      s_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s_tready_o : out std_logic;
      s_tvalid_i : in  std_logic;
      s_tlast_i  : in  std_logic
    );
  end component axis_demux;

  type axi_array is array (natural range <>) of vector_array;

  constant n_signals : integer := number_slaves*number_masters;

  signal demux_tdata_s  : vector_array(n_signals-1 downto 0);
  signal demux_tuser_s  : vector_array(n_signals-1 downto 0);
  signal demux_tdest_s  : vector_array(n_signals-1 downto 0);
  signal demux_tvalid_s : std_logic_vector(n_signals-1 downto 0);
  signal demux_tlast_s  : std_logic_vector(n_signals-1 downto 0);
  signal demux_tready_s : std_logic_vector(n_signals-1 downto 0);

  signal mux_tdata_s    : vector_array(n_signals-1 downto 0);
  signal mux_tuser_s    : vector_array(n_signals-1 downto 0);
  signal mux_tdest_s    : vector_array(n_signals-1 downto 0);
  signal mux_tvalid_s   : std_logic_vector(n_signals-1 downto 0);
  signal mux_tlast_s    : std_logic_vector(n_signals-1 downto 0);
  signal mux_tready_s   : std_logic_vector(n_signals-1 downto 0);

begin

  mux_gen : for j in master_portnum-1 downto 0 generate
    intercon_mux_u : axis_mux
      generic map (
        number_ports => slave_portnum,
        tdata_size   => tdata_size,
        tdest_size   => tdest_size,
        tuser_size   => tuser_size,
        select_auto  => select_auto,
        switch_tlast => switch_tlast,
        interleaving => interleaving,
        max_tx_size  => max_tx_size,
        mode         => mode
      )
      port map (
        clk_i      => clk_i,
        rst_i      => rst_i,
        --Slave s0
        s_tvalid_i => mux_tvalid_s(slave_portnum*(j+1)-1 downto slave_portnum*j),
        s_tlast_i  =>  mux_tlast_s(slave_portnum*(j+1)-1 downto slave_portnum*j),
        s_tready_o => mux_tready_s(slave_portnum*(j+1)-1 downto slave_portnum*j),
        s_tdata_i  =>  mux_tdata_s(slave_portnum*(j+1)-1 downto slave_portnum*j),
        s_tuser_i  =>  mux_tuser_s(slave_portnum*(j+1)-1 downto slave_portnum*j),
        s_tdest_i  =>  mux_tdest_s(slave_portnum*(j+1)-1 downto slave_portnum*j),

        m_tdata_o  => m_tdata_s(j),
        m_tuser_o  => m_tuser_s(j),
        m_tdest_o  => m_tdest_s(j),
        m_tready_i => m_tready_s(j),
        m_tvalid_o => m_tvalid_s(j),
        m_tlast_o  => m_tlast_s(j)
      );

  end generate;

  demux_gen : for j in slave_portnum-1 downto 0 generate

    intercon_demux_u : axis_demux
      generic map (
        number_ports => master_portnum,
        tdata_size   => tdata_size,
        tdest_size   => tdest_size,
        tuser_size   => tuser_size,
        select_auto  => select_auto,
        switch_tlast => switch_tlast,
        max_tx_size  => max_tx_size
      )
      port map (
        clk_i      => clk_i,
        rst_i      => rst_i,
        --master
        m_tvalid_o => mux_tvalid_s(master_portnum*(j+1)-1 downto master_portnum*j),
        m_tlast_o  => mux_tlast_s(master_portnum*(j+1)-1  downto master_portnum*j),
        m_tready_i => mux_tready_s(master_portnum*(j+1)-1 downto master_portnum*j),
        m_tdata_o  => mux_tdata_s(master_portnum*(j+1)-1  downto master_portnum*j),
        m_tuser_o  => mux_tuser_s(master_portnum*(j+1)-1  downto master_portnum*j),
        m_tdest_o  => mux_tdest_s(master_portnum*(j+1)-1  downto master_portnum*j),
        --slave
        s_tdata_i  => s_tdata_i(j),
        s_tuser_i  => s_tuser_i(j),
        s_tdest_i  => s_tdest_i(j),
        s_tready_o => s_tready_o(j),
        s_tvalid_i => s_tvalid_i(j),
        s_tlast_i  => s_tlast_i(j)
      );

    end generate;

end behavioral;
