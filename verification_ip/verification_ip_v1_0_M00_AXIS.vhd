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

entity verification_ip_v1_0_M00_AXIS is
	generic (
		-- Users to add parameters here
        test_number     : integer;
        prbs_sel        : string  := "PRBS23";
        packet          : boolean;
        packet_random   : boolean;
        packet_size_max : integer;
        packet_size_min : integer
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line
    -- AXI TEST CONTROL
    TEST_START          : in  BOOLEAN;
		current_packet_size : out integer;
		-- Global ports
		M_AXIS_ACLK	   : in  std_logic;
		M_AXIS_ARESETN : in  std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
		M_AXIS_TVALID	 : out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	 : out std_logic_vector;
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	 : out std_logic_vector;
		-- TUSER is user data.
		M_AXIS_TUSER	 : out std_logic_vector;
		-- TDEST is for AXI routing purposes
		M_AXIS_TDEST	 : out std_logic_vector;
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	 : out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	 : in  std_logic
	);
end verification_ip_v1_0_M00_AXIS;

architecture implementation of verification_ip_v1_0_M00_AXIS is

	--streaming data valid
	signal axis_tvalid	: std_logic;
	--FIFO implementation signals
	signal stream_data_out	: std_logic_vector(M_AXIS_TDATA'range);

	signal tx_en	 : std_logic;
	--The master has issued all the streaming data stored in FIFO
	signal tx_done : std_logic;

  signal packet_data_s         : unsigned(M_AXIS_TDATA'range) := (others => '0');
  signal packet_counter_s      : integer := 0;
  signal prbs_s                : std_logic_vector(23 downto 1) := (others => '1');
	signal random_number         : integer;
	signal current_packet_size_s : integer;
	signal M_AXIS_TLAST_s        : std_logic;
	signal packet_number         : unsigned(M_AXIS_TUSER'range);
	signal random_s         : unsigned(11 downto 1) := (others=>'1');


begin
	-- I/O Connections assignments
  M_AXIS_TDEST(M_AXIS_TDEST'range) <= (others=>'-');
	M_AXIS_TVALID	<= axis_tvalid;
	M_AXIS_TSTRB(M_AXIS_TSTRB'range) <= (others=>'1');

  M_AXIS_TDATA(M_AXIS_TDATA'range) <= (others=>'0')                   when test_number = 0 else
                  										(others=>'1')                   when test_number = 1 else
										                  std_logic_vector(packet_data_s) when test_number = 2 else
										                  stream_data_out                 when test_number = 3 else
										                  std_logic_vector(packet_data_s) when test_number = 4 else
										                  std_logic_vector(packet_data_s) when test_number = 5 else
										                  (others=>'-');

  M_AXIS_TLAST_s <= axis_tvalid when packet_counter_s = current_packet_size_s-1 and packet else
                    '0';

 	M_AXIS_TLAST  <= M_AXIS_TLAST_s;

	process(M_AXIS_ACLK)
		variable prbs  : unsigned(23 downto 1) := (others => '1');
		variable value : integer;
	begin
		if rising_edge(M_AXIS_ACLK) then
			prbs               := prbs(22 downto 1) & (prbs(23) xor prbs(18));
			value := to_integer(prbs) mod packet_size_max;
			if value = 0 then
				value := packet_size_max;
			elsif value < packet_size_min then
				value := packet_size_min;
			end if;
			random_number <= value;
		end if;
	end process;

	process(M_AXIS_ARESETN, M_AXIS_ACLK)
	begin
	  if M_AXIS_ARESETN = '0' then
	    current_packet_size_s <= packet_size_max;
	  elsif rising_edge(M_AXIS_ACLK) then
	    if M_AXIS_TLAST_s = '1' then
	      if packet_random then
	        current_packet_size_s <= random_number;
	      else
	        current_packet_size_s <= packet_size_max;
	      end if;
	    end if;
	  end if;
	end process;

  current_packet_size <= current_packet_size_s;


	process(M_AXIS_ARESETN, M_AXIS_ACLK)
	begin
	  if M_AXIS_ARESETN = '0' then
	    packet_number <= (others => '0');
	  elsif rising_edge(M_AXIS_ACLK) then
	    if M_AXIS_TLAST_s = '1' then

	      packet_number <= packet_number + 1;
	    end if;
	  end if;
	end process;
	M_AXIS_TUSER <= std_logic_vector(packet_number);

	-- single process for verification data.
	process(M_AXIS_ACLK)
	  variable first_loop : boolean                       := true;
	  variable prbs       : std_logic_vector(23 downto 1) := (others => '1');
	begin
	  if rising_edge(M_AXIS_ACLK) then
	    if M_AXIS_ARESETN = '0' then
	      axis_tvalid      <= '0';
	      prbs             := (others => '1');
	      packet_counter_s <= 0;
	      packet_data_s    <= (others => '0');
	    else
	      prbs             := (others => '1');
	      axis_tvalid      <= '0';
	      stream_data_out  <= (others => 'U');
	      packet_counter_s <= 0;
	      packet_data_s    <= (others => '0');

	      if TEST_START then

	        axis_tvalid <= '1';

	        if M_AXIS_TREADY = '1' then
	          for j in stream_data_out'range loop
	            prbs               := prbs(22 downto 1) & (prbs(23) xor prbs(18));
	            stream_data_out(j) <= prbs(23);
	          end loop;
	        end if;

	        if test_number = 4 then  --test input and output for gaped valids.
	          if packet then
	            if packet_counter_s = 0 then
	              axis_tvalid <= '0';
	            elsif packet_counter_s = current_packet_size_s/2 then
	              axis_tvalid <= '0';
	            elsif packet_counter_s = current_packet_size_s-1 then
	              axis_tvalid <= '0';
	            end if;
	          elsif packet_counter_s mod 16 = 0 then
	            axis_tvalid <= '0';
	          end if;
	        end if;

	        if M_AXIS_TREADY = '1' then
	          if axis_tvalid = '1' then
	            packet_data_s <= packet_data_s + 1;
	            if packet then
	              packet_counter_s <= packet_counter_s + 1;
	              if packet_counter_s = current_packet_size_s-1 then
	                packet_counter_s <= 0;
	              --packet_data_s    <= (others => '0');
	              end if;
	            end if;
	          end if;
	        end if;

	        if M_AXIS_TREADY = '0' then
	          first_loop := true;
	        elsif first_loop then
	          first_loop := false;
	        end if;

	        prbs_s <= prbs;

	      end if;
	    end if;
	  end if;

	end process;




end implementation;
