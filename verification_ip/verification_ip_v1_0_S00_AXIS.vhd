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

entity verification_ip_v1_0_S00_AXIS is
	generic (
        test_number     : integer;
        prbs_sel        : string  := "PRBS23";
        packet          : boolean := false;
        packet_random   : boolean := false;
        packet_size_max : integer := 1;
        packet_size_min : integer := 1
	);
	port (
		-- Users to add ports here
    TEST_START          : in  BOOLEAN;
		--missing_packet      : out std_logic;
		--payload_error       : out std_logic;
		current_packet_size : in  integer;
		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector;
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector;
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- User AXI-S data
		S_AXIS_TUSER	: in std_logic_vector;
		-- AXI-S routing information
		S_AXIS_TDEST	: in std_logic_vector;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end verification_ip_v1_0_S00_AXIS;

architecture arch_imp of verification_ip_v1_0_S00_AXIS is

	signal axis_tready	: std_logic;
  signal packet_data  : unsigned(S_AXIS_TDATA'range) := (others => '0');
	signal current_packet_size_s : integer;

	signal int_probe : integer;

	type mq_last_t is (idle, wait_valid, alarm, wait_reload);
	signal mq_last : mq_last_t;

begin
	-- I/O Connections assignments

	S_AXIS_TREADY	<= axis_tready;

	--seleciona a avaliação de modo de pacote.
	current_packet_size_s <= current_packet_size when packet_random else
		 											 packet_size_max;

	process(S_AXIS_ACLK)
	  variable packet_counter : integer                              := 0;
	  variable packet_number  : integer                              := 0;
	  variable prbs           : std_logic_vector(23 downto 1)        := (others => '1');
	  constant all_zeros      : std_logic_vector(S_AXIS_TDATA'range) := (others => '0');
	  constant all_ones       : std_logic_vector(S_AXIS_TDATA'range) := (others => '1');
	begin

	  if S_AXIS_ACLK'event and S_AXIS_ACLK = '1' then
	    if S_AXIS_ARESETN = '0' then
	      packet_counter := 0;
	      packet_data    <= (others => '0');
	      prbs           := (others => '1');
	      axis_tready    <= '0';
	    else
	      -- whenever a test stops, clean registers.
	      packet_counter := 0;
	      packet_data    <= (others => '0');
	      prbs           := (others => '1');
	      axis_tready    <= '0';

	      if TEST_START then

	        if test_number = 5 then
          	axis_tready <= S_AXIS_TVALID;
	        else
	          axis_tready <= '1';
	        end if;

	        if S_AXIS_TVALID = '1' then

	          --TESTS for TLAST
	          if packet then
	            if packet_counter = current_packet_size_s-1 and S_AXIS_TLAST = '0' then
	              report "error, missing TLAST at end of packet";
	            end if;

	          end if;

	          --DATA TESTS
	          case test_number is
	            --may change for VUNIT tests in the future.
	            when 0 =>
	              if S_AXIS_TDATA /= all_zeros then
	                report "Detected error on All Zeros test.";
	              end if;

	            when 1 =>
	              if S_AXIS_TDATA /= all_ones then
	                report "Detected error on All Zeros test.";
	              end if;

	            when 2 =>
	              if S_AXIS_TDATA /= std_logic_vector(packet_data) then
	                report "Error on sequential packet counter.";
	                --fixes the sequence.
	                packet_data <= unsigned(S_AXIS_TDATA);
	              end if;

	            when 3 =>
	              for j in S_AXIS_TDATA'range loop
	                prbs := prbs(22 downto 1) & (prbs(23) xor prbs(18));
	                if S_AXIS_TDATA(j) /= prbs(23) then
	                  report "PRBS Error.";
	                end if;
	              end loop;

	            when 4 =>
	              if S_AXIS_TDATA /= std_logic_vector(packet_data) then
	                report "Error on start/end of sequence.";
	              end if;

	            when 5 =>
	              if packet_counter = current_packet_size_s/2 then
	                axis_tready <= '0';  --stops data. waits until master present Valid.
	              elsif packet_counter = current_packet_size_s-2 then
	                axis_tready <= '0';  --tlast should not be asserted without tvalid.
	              end if;

	            when others =>
	              report "Invalid Test Number.";

	          end case;

	          if axis_tready = '1' then

	            packet_data <= packet_data + 1;
	            if packet then
	              packet_counter := packet_counter + 1;
	              if packet_counter = current_packet_size_s then
	                packet_counter := 0;
	              --packet_data    <= (others => '0');
	              end if;
	            end if;

	            if S_AXIS_TLAST = '1' then
	              if to_integer(unsigned(S_AXIS_TUSER)) /= packet_number then
	                packet_number := to_integer(unsigned(S_AXIS_TUSER));
	                report "Packet number error.";
	              end if;
	              packet_number := packet_number + 1;
								--garanto que o inteiro vai dobrar no limite do tuser.
								packet_number := packet_number mod (2**S_AXIS_TUSER'length);

	            end if;

	          end if;
	        end if;

	      end if;
	    end if;
			int_probe <= packet_number;
	  end if;
	end process;

	process(S_AXIS_ACLK)
	begin
	  if falling_edge(S_AXIS_ACLK) then
			case mq_last is
				when idle =>
					if S_AXIS_TLAST = '1' then
						if S_AXIS_TVALID = '1' then
							mq_last <= wait_reload;
						else
							mq_last <= wait_valid;
						end if;
					end if;

				when wait_valid =>
					if S_AXIS_TLAST = '0' then
						mq_last <= alarm;
					elsif S_AXIS_TVALID = '0' then
						mq_last <= wait_reload;
					end if;

				when wait_reload =>
					if S_AXIS_TLAST = '0' then
						mq_last <= idle;
					end if;

				when alarm =>
					mq_last <= idle;
					assert packet
						report "TLAST suspicious activity."
						severity failure;

			end case;

			if S_AXIS_TLAST = '1' then
		  	assert packet
		    	report "TLAST action detected on no-packet mode."
		      severity warning;
			end if;

	  end if;
	end process;


	process(S_AXIS_TDATA)
	begin
	  if S_AXIS_TVALID = '0' then
	    report "Detected TDATA changed without TVALID.";
	  end if;
	end process;

end arch_imp;
