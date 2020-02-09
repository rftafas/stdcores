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
library expert;
    use expert.std_logic_expert.all;
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
