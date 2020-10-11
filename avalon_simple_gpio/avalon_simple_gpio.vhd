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
-- Why use this code? to avoid bloated Intel GPIO block.

-- altera vhdl_input_version vhdl_2008
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity avalon_simple_gpio is
	generic (
		num_bytes					 : integer := 4;
		write_readback_c   : integer_vector(8*num_bytes-1 downto 0) := (others=>0)
	);
	port(
		mclk_i				: in 		std_logic;
		rst_i					: in 		std_logic;
		--
		reg_clear_i		: in 		std_logic_vector(8*num_bytes-1 downto 0 downto 0);
		reg_i					: in 		std_logic_vector(8*num_bytes-1 downto 0 downto 0);
		reg_o					: out		std_logic_vector(8*num_bytes-1 downto 0 downto 0);
		--
		avalon_cs_i					: in		std_logic;
		avalon_byteenable_i	: in		std_logic_vector(num_bytes downto 0);
		avalon_we_i					: in		std_logic;
		avalon_rd_i					: in		std_logic;
		avalon_rdv_o				: out		std_logic;
		avalon_wait_o				: out		std_logic;
		avalon_data_i				: in		std_logic_vector(8*num_bytes-1 downto 0);
		avalon_data_o				: out		std_logic_vector(8*num_bytes-1 downto 0)
	);
end avalon_simple_gpio;

architecture rtl of avalon_simple_gpio is

	signal reg_s         : std_logic_vector(reg_i'range);
	signal byte_enable_s : std_logic_vector(reg_i'range);

begin

	j_gen : for j in num_bytes-1 downto 0 generate
		byte_enable_s(8*(j+1)-1 downto 8*j) <= avalon_byteenable_i(j);
	end generate;

	reg_p : process(all)
		variable rdv_v : std_logic := '0';
	begin
		if rst_i = '1' then
			reg_s			<= (others=>'0');
			rdv_v			:= '0';
			avalon_data_o	<= (others=>'0');
		elsif mclk_i = '1' and mclk_i'event then
			for j in 8*num_bytes-1 downto 0 loop
				--write and clear
				if reg_clear_i(j) = '1' then
					reg_s(j) <= '0';
				elsif avalon_cs_i = '1' and avalon_we_i = '1' and byte_enable_s(j) = '1' then
					reg_s(j) <= avalon_data_i(j);
				end if;
				--readback
				if avalon_cs_i = '1' and avalon_rd_i = '1' and byte_enable_s(j) = '1' then
					if write_readback_c(j) = 0 then
						avalon_data_o(j) <= reg_i(j);
					else
						avalon_data_o(j) <= reg_s(j);
					end if;
				else
					avalon_data_o(j) <= '0';
				end if;
			end loop;
			rdv_v := avalon_rd_i;
		end if;
		avalon_rdv_o <= rdv_v and not avalon_rd_i;
	end process;

	reg_o <= reg_s;

	wait_p : process(all)
	begin
		if rst_i = '1' then
			avalon_wait_o <= '1';
		elsif mclk_i = '1' and mclk_i'event then
			if avalon_cs_i = '1' and (avalon_rd_i = '1' or avalon_we_i = '1') then
				avalon_wait_o <= '0';
			else
				avalon_wait_o <= '1';
			end if;
		end if;
	end process;


end rtl;
