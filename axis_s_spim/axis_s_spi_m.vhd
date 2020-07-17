----------------------------------------------------------------------------------------------------------
-- SPI-AXI-Controller Machine.
-- Ricardo Tafas
-- This is open source code licensed under LGPL.
-- By using it on your system you agree with all LGPL conditions.
-- This code is provided AS IS, without any sort of warranty.
-- Author: Ricardo F Tafas Jr
-- 2019
---------------------------------------------------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;
library expert;
library stdblocks;
	use stdblocks.sync_lib.all;

entity axis_s_spi_m is
	generic (
		TLAST_ENABLE	  : boolean	:= true;
		SLAVE_NUM     	: integer	:= 4;
		TDATA_BYTE_NUM	: integer	:= 4
	);
	port (
		M_AXI_RESET  : in std_logic;
		M_AXI_ACLK	 : in std_logic;
		--internal axis
		s_tdata_i    : in  std_logic_vector(TDATA_BYTE_NUM*8-1 downto 0);
		s_tdest_i    : in  std_logic_vector(SLAVE_NUM-1 downto 0);
		s_tready_o   : out std_logic;
		s_tvalid_i   : in  std_logic;
		s_tlast_i    : in  std_logic;

		s_tdata_o    : in  std_logic_vector(TDATA_BYTE_NUM*8-1 downto 0);
		s_tdest_o    : in  std_logic_vector(size_for(SLAVE_NUM)-1 downto 0);
		s_tready_i   : out std_logic;
		s_tvalid_o   : in  std_logic;
		s_tlast_o    : in  std_logic;
		--spi master
		mosi_o   : out std_logic;
		miso_i   : in  std_logic;
		spck_o   : out std_logic;
		spcs_o   : out std_logic_vector(SLAVE_NUM-1 downto 0)
		);
end axis_s_spi_m;

architecture implementation of axis_s_spi_m is

	 type state is (IDLE, INIT_WRITE, INIT_READ, BUS_DONE);
	 signal mst_exec_state  : state ;


begin

	process(all)
	begin
		if M_AXI_RESET = '1' then
		elsif rising_edge(M_AXI_ACLK) then
			if shift_en = '0' then
			 	if load_en = '1' then
					load_en <= '0';
					shift_en  <= '1';
				elsif s_tvalid_i = '1' then
					load_en <= '1';
				end if;
				byte_cnt <= 0;
				bit_cnt  <= 0;
			else
				if ck_en = '1' then
					bit_cnt <= bit_cnt + 1;
					if byte_cnt = TDATA_BYTE_NUM then
						if not tlast_enable then
							shift_en   <= '0';
						elsif s_tlast_i = '1' then
							shift_en   <= '0';
						end if;
						unload_en <= '1';
						byte_cnt  <= 0;
					else
						byte_cnt <= byte_cnt + 1;
					end if;
				else
					unload_en <= '0';
				end if;

			end if;
		end if;
	end process;

	process(all)
	begin
		if M_AXI_RESET = '1' then
		elsif rising_edge(M_AXI_ACLK) then
			if load_en = '1' then
				mosi_sr   <= s_tdata_i;
			elsif shift_en = 1 then
				mosi_sr   <= mosi_sr(mosi_sr'high-1 downto 0) & '0';
			end if;
		end if;
	end process;

	process(all)
	begin
		if M_AXI_RESET = '1' then
		elsif rising_edge(M_AXI_ACLK) then
			if shift_en = 1 then
				miso_sr   <= miso_sr(miso_sr'high-1 downto 0) & miso_i;
			end if;
		end if;
	end process;

	process(all)
	begin
		if M_AXI_RESET = '1' then
		elsif rising_edge(M_AXI_ACLK) then
			if unload_en = 1 then
				if m_tready_i = '1' or m_tvalid_s = '0' then
					m_tvalid_s <= '1';
					m_tdata_o  <= miso_sr;
					m_tdest_o  <= s_tdest_i
				end if;
			elsif m_tready_i = '1' then
				m_tvalid_s <= '0';
			end if;
		end if;
	end process;

  m_tvalid_o <= m_tvalid_s;
	m_tdest_o  <= s_tdest_i
	s_tready_o <= load_en;

	mosi_o <= mosi_sr(mosi_sr'high);

	cs_gen : for j in 0 to SLAVE_NUM-1 generate
		spcs_o(j) <= not busy_s when j = to_integer(s_tdest_i) else '0';
	end generate;

end implementation;
