----------------------------------------------------------------------------------------------------------
-- SPI-AXI-Controller Machine.
-- Ricardo Tafas
-- This is open source code licensed under LGPL.
-- By using it on your system you agree with all LGPL conditions.
-- This code is provided AS IS, without any sort of warranty.
-- Author: Ricardo F Tafas Jr
-- 2019
---------------------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

package spi_axi_pkg is

  constant WRITE_c       : std_logic_vector(7 downto 0) := x"02";
  constant READ_c        : std_logic_vector(7 downto 0) := x"03";
  constant FAST_WRITE_c  : std_logic_vector(7 downto 0) := x"0A";
  constant FAST_READ_c   : std_logic_vector(7 downto 0) := x"0B";
  constant WRITE_BURST_c : std_logic_vector(7 downto 0) := x"42";
  constant READ_BURST_c  : std_logic_vector(7 downto 0) := x"4B";
  constant EDIO_c        : std_logic_vector(7 downto 0) := x"3B";
  constant EQIO_c        : std_logic_vector(7 downto 0) := x"38";
  constant RSTIO_c       : std_logic_vector(7 downto 0) := x"FF";
  constant RDMR_c        : std_logic_vector(7 downto 0) := x"05";
  constant WRMR_c        : std_logic_vector(7 downto 0) := x"01";
  constant RDID_c        : std_logic_vector(7 downto 0) := x"9F";
  constant RUID_c        : std_logic_vector(7 downto 0) := x"4C";
  constant WRSN_c        : std_logic_vector(7 downto 0) := x"C2";
  constant RDSN_c        : std_logic_vector(7 downto 0) := x"C3";
  constant DPD_c         : std_logic_vector(7 downto 0) := x"BA";
  constant HBN_c         : std_logic_vector(7 downto 0) := x"B9";
  constant IRQR_c        : std_logic_vector(7 downto 0) := x"A4";
  constant STAT_c        : std_logic_vector(7 downto 0) := x"A5";

end spi_axi_pkg;

--a arquitetura
package body spi_axi_pkg is
end spi_axi_pkg;
