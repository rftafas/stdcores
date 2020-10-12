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
library stdblocks;
    use stdblocks.sync_lib.all;


entity spi_irq_ctrl is
    port (
      --general
      rst_i        : in  std_logic;
      mclk_i       : in  std_logic;
      master_irq_o : out std_logic;
      vector_irq_o : out std_logic_vector(7 downto 0);
      vector_irq_i : in  std_logic_vector(7 downto 0);
      vector_clr_i : in  std_logic_vector(7 downto 0);
      vector_msk_i : in  std_logic_vector(7 downto 0)
    );
end spi_irq_ctrl;

architecture behavioral of spi_irq_ctrl is


begin

  irq_p : process(rst_i, mclk_i)
    variable irq_flag : std_logic_vector(7 downto 0);
  begin
    if rst_i = '1' then
      vector_irq_o <= "00000000";
      irq_flag     := "00000000";
      master_irq_o <= '0';
    elsif mclk_i = '1' and mclk_i'event then
      for j in 7 downto 0 loop
        if vector_msk_i(j) = '1' then
          irq_flag(j) := '0';
        elsif vector_clr_i(j) = '1' then
          irq_flag(j) := '0';
        elsif vector_irq_i(j) = '1' then
          irq_flag(j) := '1';
        end if;
        vector_irq_o(j) <= irq_flag(j);
      end loop;

      --output
      if irq_flag /= "00000000" then
        master_irq_o <= '1';
      else
        master_irq_o <= '0';
      end if;
    end if;
  end process;

end behavioral;
