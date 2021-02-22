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
      controllers_num : positive := 8;
      peripherals_num : positive := 8;
      tdata_byte      : positive := 8;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      select_auto     : boolean  := false;
      switch_tlast    : boolean  := false;
      interleaving    : boolean  := false;
      max_tx_size     : positive := 10
    );
    port (
      --general
      rst_i       : in  std_logic;
      clk_i       : in  std_logic;
      --AXIS Master Port
      m_tdata_o  : out std_logic_array(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_array(peripherals_num-1 downto 0)(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic_vector(peripherals_num-1 downto 0);
      m_tvalid_o : out std_logic_vector(peripherals_num-1 downto 0);
      m_tlast_o  : out std_logic_vector(peripherals_num-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  std_logic_array(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(controllers_num-1 downto 0);
      s_tvalid_i : in  std_logic_vector(controllers_num-1 downto 0);
      s_tlast_i  : in  std_logic_vector(controllers_num-1 downto 0)
    );
end axis_intercon;

architecture behavioral of axis_intercon is

  component axis_demux is
    generic (
      peripherals_num : integer  := 2;
      tdata_byte      : positive := 8;
      tdest_size      : integer  := 8;
      tuser_size      : integer  := 8;
      select_auto     : boolean  := false;
      switch_tlast    : boolean  := false;
      max_tx_size     : integer  := 10
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --AXIS Master Port
      m_tdata_o  : out std_logic_array(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_array(peripherals_num-1 downto 0)(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic_vector(peripherals_num-1 downto 0);
      m_tvalid_o : out std_logic_vector(peripherals_num-1 downto 0);
      m_tlast_o  : out std_logic_vector(peripherals_num-1 downto 0);
      --AXIS Slave Port
      s_tdata_i  : in  std_logic_vector(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_vector(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_vector(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_vector(tdata_byte-1 downto 0);
      s_tready_o : out std_logic;
      s_tvalid_i : in  std_logic;
      s_tlast_i  : in  std_logic
    );
  end component;

  component axis_mux
    generic (
      controllers_num : positive := 2;
      tdata_byte      : positive := 1;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      select_auto     : boolean  := false;
      switch_tlast    : boolean  := false;
      interleaving    : boolean  := false;
      max_tx_size     : positive := 10;
      mode            : integer  := 10
    );
    port (
      --general
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
      --AXIS Slave Port
      s_tdata_i  : in  std_logic_array(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(controllers_num-1 downto 0);
      s_tvalid_i : in  std_logic_vector(controllers_num-1 downto 0);
      s_tlast_i  : in  std_logic_vector(controllers_num-1 downto 0);
      --AXIS Master port
      m_tdata_o  : out std_logic_vector(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_vector(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_vector(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic;
      m_tvalid_o : out std_logic;
      m_tlast_o  : out std_logic
    );
  end component;

  --this is a 4 dimension vector. synthesis tools may complaint it is a complex memory but actually is
  --just a bunch of signals... it should result into no extra hardware.
  type intercon_vector_matrix is array (natural range <>) of std_logic_array;

  signal demux_tdata_s  : intercon_vector_matrix(controllers_num-1 downto 0)(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
  signal demux_tuser_s  : intercon_vector_matrix(controllers_num-1 downto 0)(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
  signal demux_tdest_s  : intercon_vector_matrix(controllers_num-1 downto 0)(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
  signal demux_tstrb_s  : intercon_vector_matrix(controllers_num-1 downto 0)(peripherals_num-1 downto 0)(tdata_byte-1 downto 0);
  signal demux_tvalid_s : std_logic_array(controllers_num-1 downto 0)(peripherals_num-1 downto 0);
  signal demux_tlast_s  : std_logic_array(controllers_num-1 downto 0)(peripherals_num-1 downto 0);
  signal demux_tready_s : std_logic_array(controllers_num-1 downto 0)(peripherals_num-1 downto 0);

  signal mux_tdata_s    : intercon_vector_matrix(peripherals_num-1 downto 0)(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
  signal mux_tuser_s    : intercon_vector_matrix(peripherals_num-1 downto 0)(controllers_num-1 downto 0)(tuser_size-1 downto 0);
  signal mux_tdest_s    : intercon_vector_matrix(peripherals_num-1 downto 0)(controllers_num-1 downto 0)(tdest_size-1 downto 0);
  signal mux_tstrb_s    : intercon_vector_matrix(peripherals_num-1 downto 0)(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
  signal mux_tvalid_s   : std_logic_array(peripherals_num-1 downto 0)(controllers_num-1 downto 0);
  signal mux_tlast_s    : std_logic_array(peripherals_num-1 downto 0)(controllers_num-1 downto 0);
  signal mux_tready_s   : std_logic_array(peripherals_num-1 downto 0)(controllers_num-1 downto 0);

begin

  mux_gen : for j in peripherals_num-1 downto 0 generate

    intercon_mux_u : axis_mux
      generic map (
        controllers_num => controllers_num,
        tdata_byte      => tdata_byte,
        tdest_size      => tdest_size,
        tuser_size      => tuser_size,
        select_auto     => select_auto,
        switch_tlast    => switch_tlast,
        interleaving    => interleaving,
        max_tx_size     => max_tx_size
      )
      port map (
        clk_i      => clk_i,
        rst_i      => rst_i,
        --Slave s0
        s_tvalid_i => mux_tvalid_s(j),
        s_tlast_i  =>  mux_tlast_s(j),
        s_tready_o => mux_tready_s(j),
        s_tdata_i  =>  mux_tdata_s(j),
        s_tuser_i  =>  mux_tuser_s(j),
        s_tdest_i  =>  mux_tdest_s(j),
        s_tstrb_i  =>  mux_tstrb_s(j),

        m_tdata_o  => m_tdata_o(j),
        m_tuser_o  => m_tuser_o(j),
        m_tdest_o  => m_tdest_o(j),
        m_tstrb_o  => m_tstrb_o(j),
        m_tready_i => m_tready_i(j),
        m_tvalid_o => m_tvalid_o(j),
        m_tlast_o  => m_tlast_o(j)
      );

  end generate;

  demux_gen : for j in controllers_num-1 downto 0 generate

    intercon_demux_u : axis_demux
      generic map (
        peripherals_num => peripherals_num,
        tdata_byte      => tdata_byte,
        tdest_size      => tdest_size,
        tuser_size      => tuser_size,
        select_auto     => select_auto,
        switch_tlast    => switch_tlast,
        max_tx_size     => max_tx_size
      )
      port map (
        clk_i      => clk_i,
        rst_i      => rst_i,
        --master
        m_tvalid_o => demux_tvalid_s(j),
        m_tlast_o  =>  demux_tlast_s(j),
        m_tready_i => demux_tready_s(j),
        m_tdata_o  =>  demux_tdata_s(j),
        m_tuser_o  =>  demux_tuser_s(j),
        m_tdest_o  =>  demux_tdest_s(j),
        m_tstrb_o  =>  demux_tstrb_s(j),
        --slave
        s_tdata_i  => s_tdata_i(j),
        s_tuser_i  => s_tuser_i(j),
        s_tdest_i  => s_tdest_i(j),
        s_tstrb_i  => s_tstrb_i(j),
        s_tready_o => s_tready_o(j),
        s_tvalid_i => s_tvalid_i(j),
        s_tlast_i  => s_tlast_i(j)
      );

    end generate;

    controller_gen : for j in 0 to peripherals_num-1 generate
      periph_gen : for k in 0 to controllers_num-1 generate

        mux_tvalid_s(j)(k)   <= demux_tvalid_s(k)(j);
        mux_tlast_s(j)(k)    <= demux_tlast_s(k)(j);
        mux_tdata_s(j)(k)    <= demux_tdata_s(k)(j);
        mux_tdest_s(j)(k)    <= demux_tdest_s(k)(j);
        mux_tstrb_s(j)(k)    <= demux_tstrb_s(k)(j);
        mux_tuser_s(j)(k)    <= demux_tuser_s(k)(j);
        demux_tready_s(k)(j) <= mux_tready_s(j)(k);

      end generate;
    end generate;


end behavioral;
