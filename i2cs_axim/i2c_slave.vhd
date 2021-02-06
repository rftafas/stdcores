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
library stdblocks;
    use stdblocks.sync_lib.all;
library stdcores;
    use stdcores.spi_axim_pkg.all;

entity i2c_slave is
  generic (
    stop_hold   : positive := 4; --number of mck after scl edge up for SDA edge up.
  );
  port (
    --general
    rst_i  : in  std_logic;
    mclk_i : in  std_logic;
    --I2C
    scl_i  : in  std_logic;
    scl_o  : out std_logic;
    sda_i  : in  std_logic;
    sda_o  : out std_logic;
    --Internal
    i2c_busy_o   : out std_logic;
    i2c_rxen_o   : out std_logic;
    i2c_rxdata_o : out std_logic_vector(7 downto 0);
    i2c_ack_o    : out std_logic;
    i2c_txen_i   : in  std_logic;
    i2c_txdata_i : in  std_logic_vector(7 downto 0);
    i2c_ack_i    : in  std_logic
  );
end i2c_slave;

architecture behavioral of i2c_slave is

  signal scl_s     : std_logic;
  signal scl_up_en : std_logic;
  signal scl_dn_en : std_logic;

  signal sda_s     : std_logic;
  signal sda_up_en : std_logic;
  signal sda_dn_en : std_logic;

  signal rx_en          : std_logic;
  signal data_en        : std_logic_vector(7 downto 0) := "00000001";
  signal rxdata_en      : std_logic;
  signal busy_s         : std_logic;

  signal output_sr      : std_logic_vector(6 downto 0);
  signal input_sr       : std_logic_vector(6 downto 0);
  signal rxdata_s       : std_logic_vector(7 downto 0);

  signal output_latch_s : std_logic;

  constant edge_c : std_logic := edge_set(edge,clock_mode);

begin

  sync_busy_u : sync_r
  generic map (2)
  port map ('0',mclk_i,scl_i,scl_s);

  det_rxen_u : det_up
  port map ('0',mclk_i,scl_s,scl_up_en);

  det_rxen_u : det_down
  port map ('0',mclk_i,scl_s,scl_dn_en);

  sync_busy_u : sync_r
  generic map (2)
  port map ('0',mclk_i,sda_i,sda_s);

  det_rxen_u : det_up
  port map ('0',mclk_i,sda_s,sda_up_en);

  det_rxen_u : det_down
  port map ('0',mclk_i,sda_s,sda_dn_en);



  control_p : process(spcs_s, spck_s)
    variable counter_v : integer := 7;
  begin
    if rst_i = '1' then
      i2c_mq    <= idle_st;
      counter_v := 7;
    elsif spck_s = edge_c and spck_s'event then
      case i2c_mq is
        when idle_st =>
          counter_v := 7;
          if sda_dn_en = '1' and scl_s = '1' then --start condition
            i2c_mq <= data_st;
          end if;

        when data_st =>
          if scl_dn_en = '1' then
            counter_v := counter_v - 1;
            if counter_v := 0 then
              i2c_mq <= ack_st;
            end if;
          end if;

        when ack_st =>
          if scl_up_en = '1' then
            i2c_mq <= stop_st;
          end if;

        when stop_st =>
          if sda_up_en = '1' then
            i2c_mq <= idle_st;
          elsif scl_dn_en = '1' then
            i2c_mq <= data_st;
          end if;          

          when others =>
          i2c_mq <= idle_st;

      end if;
    end if;
  end process;

  i2c_busy_o <= '0' when i2c_mq = idle_st else
                '1';

  ack_p : process(all)
  begin
    if rst_i = '1' then
      i2c_ack_o  <= '0';
    elsif mclk_i = '1' and mclk_i'event then
      if scl_up_en = '1' and i2c_mq = ack_st then
        i2c_ack_o <= sda_s;
      end if;
    end if;
  end process;
            
  input_sr_p : process(all)
  begin
    if rst_i = '1' then
      i2c_rxen_o <= '0';
      input_sr   <= (others=>'0');
    elsif mclk_i = '1' and mclk_i'event then
      if scl_up_en = '1' then
        if i2c_mq = data_st then
          input_sr <= input_sr(6 downto 0) & sda_s;
        elsif i2c_mq = ack_st then
          i2c_rxen_o   <= '1';
          i2c_rxdata_o <= input_sr;
        end if;
      else
        i2c_rxen_o <= '0';
      end if;
    end if;
  end process;

  output_sr_p : process(all)
  begin
    if rst_i = '1' then
      output_sr(6 downto 0) <= "1111111";
    elsif mclk_i = '1' and mclk_i'event then
        if i2c_txen_i = '1' then
          output_sr <= i2c_txdata_i;
        elsif scl_dn_en = '1' then
          output_sr <= output_sr(6 downto 0) & '1';
        end if;
      end if;
    end if;
  end process;

  sda_o <=  output_sr(7) when i2c_mq = data_st else
            ack_i        when i2c_mq = ack_st  else
            '1';



end behavioral;
