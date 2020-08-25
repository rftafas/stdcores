----------------------------------------------------------------------------------
-- Priority Engine for granting resources to those requesting it.
-- Usage: choose one of the priority types.
-- Raise the request input to request a resource. wait for grant.
-- when done using, ack it.
-- This block does not prevent bad behavior. that can be made outside with
-- nice counters.
--
-- if you are asking why natural, try asking the guys from vivadosim.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity priority_engine is
    generic (
      n_elements : integer := 8;
      mode       : integer := 0
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --python script port creation starts
      request_i    : in  std_logic_vector(n_elements-1 downto 0);
      ack_i        : in  std_logic_vector(n_elements-1 downto 0);
      grant_o      : out std_logic_vector(n_elements-1 downto 0);
      index_o      : out natural
    );
end priority_engine;

architecture behavioral of priority_engine is

  function integer_count ( input : integer; limit : integer; up_cnt : boolean) return integer is
    variable tmp : integer;
  begin
    if up_cnt then
      if input = limit then
        tmp := 0;
      else
        tmp := input+1;
      end if;
    else
      if input = 0 then
        tmp := limit-1;
      else
        tmp := input-1;
      end if;
    end if;
    return tmp;
  end integer_count;

  type index_sr_t is array (n_elements-1 downto 0) of integer;
  signal index_sr         : index_sr_t := (others=>0);
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin



  mode_gen: case mode generate

    --when 0 =>  value 0 is covered on others. this is just a reminder.

    when 1 =>
      -- type 1:
      -- very hard round robin. it only shifts IF current channel acknowledges it had its chance.
      -- Provided everychannel has data to send and/or is a fair player, it grants a fair share.
      -- it will get stuck if a channel gets no data. so care must be taken.
      --
      -- for those questioning themselves why is it worth to risk starvation, it is very good when
      -- you have a metadata fifo (with IP headers, for example) and data fifo (with IP payload, for
      -- example) and another third fifo with a tail and we must transmit something like
      -- (HEADER-PAYLOAD-TAIL)----(HEADER-PAYLOAD-TAIL)...
      -- If for wharever reason one block is not done, we dont scramble things. we wait for it.
      -- Also, it never messes with packet order.
      process(all)
      begin
        if rst_i = '1' then
          grant_o <= (others=>'0');
          moving_index_s <= 0;
        elsif rising_edge(clk_i) then
          for j in n_elements-1 downto 0 loop
            if moving_index_s = j then
              if ack_i(j) = '1' then
                moving_index_s <= integer_count(moving_index_s,n_elements-1,true);
              end if;
              if request_i(j) = '1' then
                grant_o(j) <= '1';
              end if;
            else
              grant_o(j) <= '0';
            end if;
          end loop;
        end if;
      end process;
      index_o <= moving_index_s;

    when 2 =>
      -- type 2:
      -- it will offer the channel according a moving priority. It resonably ensures that at
      -- least once per cycle a channel has priority. Unfortunately it makes a mess on channel order.
      process(all)
        variable locked : boolean := false;
      begin
        if rst_i = '1' then
          grant_o <= (others=>'0');
          locked  := false;
          priority_index_s <= 0;
          moving_index_s   <= 0;
        elsif rising_edge(clk_i) then
          if locked and ack_i(moving_index_s) = '1' then
              locked := false;
              grant_o(moving_index_s) <= '0';
              priority_index_s <= priority_index_s + 1;
              moving_index_s   <= priority_index_s + 1;
          elsif request_i(moving_index_s) = '1' then
            grant_o(moving_index_s) <= '1';
            locked := true;
          else
            moving_index_s <= integer_count(moving_index_s,n_elements-1,false);
          end if;
        end if;
      end process;
      index_o <= moving_index_s;

    when 3 =>
      -- type 3:
      -- Transmitters go last.
      -- priority is given to channels that are not trasmitting. this ensures no starvation.
      -- Packet order is lost.
      process(all)
        variable locked : boolean := false;
      begin
        if rst_i = '1' then
          grant_o  <= (others=>'0');
          locked   := false;
          index_sr <= (others=>0);
          moving_index_s <= 0;
        elsif rising_edge(clk_i) then
          if locked and ack_i(moving_index_s) = '1' then
              locked := false;
              grant_o(moving_index_s) <= '0';
              index_sr(moving_index_s downto 0) <= index_sr(moving_index_s-1 downto 0) & index_sr(moving_index_s);
              moving_index_s <= n_elements-1;
          elsif request_i(moving_index_s) = '1' then
            grant_o(moving_index_s) <= '1';
            locked := true;
          else
            moving_index_s <= integer_count(moving_index_s,n_elements-1,false);
          end if;
        end if;
      end process;
      index_o <= moving_index_s;

    when others =>
        -- type 0
        -- fixed priority. channel 0 is the least to be transmitted.
        -- channels will starve if a higher priority channel never lets them get the channel.
        process(all)
            variable locked : boolean := false;
        begin
          if rst_i = '1' then
            index_o <= 0;
            grant_o <= (others=>'0');
            locked  := false;
          elsif rising_edge(clk_i) then
            locked := false;
            for j in n_elements-1 downto 0 loop
              if ack_i(j) = '1' then
                grant_o(j) <= '0';
              elsif request_i(j) = '1' and not locked then
                  grant_o(j) <= '1';
                  locked := true;
                  index_o <= j;
              else
                grant_o(j) <= '0';
              end if;
            end loop;
          end if;
        end process;

    end generate mode_gen;


end behavioral;
