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
	use ieee.math_real.all;
library expert;
	use expert.std_logic_expert.all;
library stdblocks;
	use stdblocks.sync_lib.all;
library stdcores;
	use stdcores.axis_s_spim_pkg.all;

entity axis_s_spi_m is
	generic (
		TLAST_ENABLE	  : boolean	:= true;
		TKEEP_ENABLE	  : boolean	:= true;
		SLAVE_SIZE     	: integer	:= 4;
		TDATA_BYTE_NUM	: integer	:= 4;
		clock_mode      : spi_clock_t := oversampled
	);
	port (
		rst_i        : in std_logic;
		mclk_i	     : in std_logic;
	  refclk_i  	 : in std_logic;
		--slave axi port
		s_tdata_i    : in  std_logic_vector(TDATA_BYTE_NUM*8-1 downto 0);
		s_tkeep_i    : in  std_logic_vector(TDATA_BYTE_NUM-1 downto 0);
		s_tdest_i    : in  std_logic_vector(SLAVE_SIZE-1 downto 0);
		s_tready_o   : out std_logic;
		s_tvalid_i   : in  std_logic;
		s_tlast_i    : in  std_logic;
		--master axi port
		m_tdata_o    : out std_logic_vector(TDATA_BYTE_NUM*8-1 downto 0);
		m_tkeep_o    : out std_logic_vector(TDATA_BYTE_NUM-1 downto 0);
		m_tdest_o    : out std_logic_vector(SLAVE_SIZE-1 downto 0);
		m_tready_i   : in  std_logic;
		m_tvalid_o   : out std_logic;
		m_tlast_o    : out std_logic;
		--spi master
		mosi_o       : out std_logic;
		miso_i       : in  std_logic;
		spck_o       : out std_logic;
		spcs_o       : out std_logic_vector(2**SLAVE_SIZE-1 downto 0)
		);
end axis_s_spi_m;

architecture implementation of axis_s_spi_m is

	 signal spcs_s        : std_logic;

	 type state is (IDLE, LOAD, RUN, STALLED, DONE);
	 signal tx_mq         : state;
	 signal rx_mq         : state;

	 signal timer_sr      : std_logic_vector(15 downto 0);

	 signal tx_load_en    : std_logic;
	 signal tx_done_en    : std_logic;
	 signal tx_run_en     : std_logic;
	 signal tx_timer_en   : std_logic;
	 signal tx_idle_en    : std_logic;
	 signal spi_tx_en     : std_logic;
	 signal spi_txdata_s  : std_logic_vector(7 downto 0);
	 signal spi_txdata_sr : std_logic_vector(s_tdata_i'range);

	 signal txkeep_s      : std_logic_vector(s_tkeep_i'range);
	 signal txdest_s      : std_logic_vector(s_tdest_i'range);
	 signal txlast_s      : std_logic;

	 signal rx_done_en    : std_logic;
	 signal rx_load_en    : std_logic;
	 signal rx_run_en     : std_logic;
	 signal rx_idle_en    : std_logic;
	 signal spi_rx_en     : std_logic;
	 signal spi_rxdata_s  : std_logic_vector(7 downto 0);
   signal spi_rxdata_sr : std_logic_vector(s_tdata_i'range);

	 signal rxkeep_s      : std_logic_vector(s_tkeep_i'range);
   signal rxdest_s      : std_logic_vector(s_tdest_i'range);
	 signal rxlast_s      : std_logic;

begin

	--control MQ
	main_p : process(all)
	begin
		if rst_i = '1' then
		elsif rising_edge(mclk_i) then
			case tx_mq is
				when idle =>
					if s_tvalid_i = '1' and rx_idle_en = '1' then
						tx_mq <= load;
					end if;

				when load =>
					tx_mq <= run;

				when run =>
					if txkeep_s = 0 then
						tx_mq <= done;
					end if;

				when done =>
					if TLAST_ENABLE then
						if s_tvalid_i = '1' then
							if s_tdest_i /= txdest_s then
								if txlast_s = '1' then
									tx_mq <= idle;
								else
									tx_mq <= load;
								end if;
							else
								tx_mq <= idle;
							end if;
						else
							tx_mq <= stalled;
						end if;
					else
						tx_mq <= idle;
					end if;

				when stalled =>
					if timer_sr(15) = '0' then
						tx_mq <= idle;
					elsif s_tvalid_i = '1' then
						tx_mq <= load;
					end if;

				when others =>
					tx_mq <= idle;

			end case;
		end if;
	end process;

	tx_load_en  <= '1' when tx_mq = load    else '0';
	tx_run_en   <= '1' when tx_mq = run     else '0';
	tx_timer_en <= '1' when tx_mq = stalled else '0';
	tx_idle_en  <= '1' when tx_mq = idle    else '0';

	s_tready_o  <= '1' when tx_mq = load    else '0';

	timer_p : process(all)
	begin
		if rising_edge(rst_i) then
			if tx_timer_en = '1' then
				timer_sr <= timer_sr sll 1;
			else
				timer_sr <= (0=>'1', others=>'0');
			end if;
		end if;
	end process;

	tx_p : process(all)
		variable index        : integer;
		variable range_v      : range_t;
		variable spi_txdata_v : std_logic_vector(s_tdata_i'range);
	begin
		if rst_i = '1' then
		elsif rising_edge(mclk_i) then
			if tx_idle_en = '1' then
				spi_txdata_sr <= (others=>'0');
				txkeep_s      <= (others=>'0');
				txlast_s      <= '0';
			elsif tx_load_en = '1' then
				spi_txdata_sr <= s_tdata_i;
				txdest_s 			<= s_tdest_i;
				txlast_s      <= s_tlast_i;
				if TKEEP_ENABLE then
					txkeep_s      <= s_tkeep_i;
				else
					txkeep_s      <= (others=>'1');
				end if;
			elsif tx_run_en = '1' and spi_tx_en = '1' then
				txkeep_s      <= txkeep_s srl 1;
			end if;
			index        := index_of_1(txkeep_s);
			range_v      := range_of(index,8);
			spi_txdata_s <= spi_txdata_v(range_v.high downto range_v.low);
		end if;
	end process;

	aux_p : process(all)
	begin
		if rst_i = '1' then
		elsif rising_edge(mclk_i) then
			case rx_mq is
				when idle =>
					if tx_idle_en = '0' then
						rx_mq <= run;
					end if;

				when run =>
					if tx_done_en = '1' then
						rx_mq <= done;
					end if;

				when done =>
					if spi_rx_en = '1' then
						rx_mq <= load;
					end if;

				when load =>
					if tx_idle_en = '1' then
						rx_mq <= idle;
					else
						rx_mq <= run;
					end if;

				when others =>
					rx_mq <= idle;

			end case;
		end if;
	end process;

	rx_idle_en <= '1' when rx_mq = idle else '0';
	rx_done_en <= '1' when rx_mq = done else '0';
	rx_load_en <= '1' when rx_mq = load else '0';
	rx_run_en  <= '1' when rx_mq = run  else '0';

	rx_p : process(all)
		variable spi_rxdata_v : std_logic_vector(s_tdata_i'range);
	begin
		if rst_i = '1' then
		elsif rising_edge(mclk_i) then
			if spi_rx_en = '1' then
				spi_rxdata_sr <= spi_rxdata_sr sll 8;
				spi_rxdata_s(7 downto 0) <= spi_rxdata_s;
				rxkeep_s    <= rxkeep_s sll 1;
				rxkeep_s(0) <= '1';
			end if;
		end if;
	end process;

	rx_out_p : process(all)
		variable spi_rxdata_v : std_logic_vector(s_tdata_i'range);
	begin
		if rst_i = '1' then
		elsif rising_edge(mclk_i) then
			if rx_load_en = '1' then
				spi_rxdata_sr <= (others=>'0');
				rxkeep_s      <= (others=>'0');
				rxlast_s      <= txlast_s;
				m_tdata_o     <= spi_rxdata_sr;
				m_tvalid_o    <= '1';
			else
				m_tvalid_o    <= '0';
				rxlast_s      <= '0';
			end if;
		end if;
	end process;

	spcs_gen : for j in txdest_s'range generate
		spcs_o(j) <= spcs_s and (not tx_timer_en) when txdest_s = j else '1';
	end generate;

	spi_master_u : spi_master
	  generic map(
	    edge       => '1',
	    clock_mode => clock_mode
	  )
	  port map(
	    --general
	    rst_i          => rst_i,
	    mclk_i         => mclk_i,
	    refclk_i       => refclk_i,
	    --spi
	    spck_o         => spck_o,
	    miso_i         => miso_i,
	    mosi_o         => mosi_o,
	    spcs_o         => spcs_s,
	    --Internal
	    spi_tx_valid_i => tx_run_en,
	    spi_rxen_o     => spi_rx_en,
	    spi_txen_o     => spi_tx_en,
	    spi_rxdata_o   => spi_rxdata_s,
	    spi_txdata_i   => spi_txdata_s
	  );



end implementation;
