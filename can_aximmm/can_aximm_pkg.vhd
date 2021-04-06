----------------------------------------------------------------------------------
--Copyright 2021 Ricardo F Tafas Jr

--Licensed under the Apache License, Version 2.0 (the "License"); you may not
--use this file except in compliance with the License. You may obtain a copy of
--the License at

--   http://www.apache.org/licenses/LICENSE-2.0

--Unless required by applicable law or agreed to in writing, software distributed
--under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
--OR CONDITIONS OF ANY KIND, either express or implied. See the License for
--the specific language governing permissions and limitations under the License.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package can_aximm_pkg is


    procedure crc15( signal vector : inout std_logic_vector(14 downto 0); input : in  std_logic);


end can_aximm_pkg;

package body can_aximm_pkg is

    procedure crc15( signal vector : inout std_logic_vector(14 downto 0); input : in  std_logic) is
        variable crc_v : std_logic_vector(15 downto 0);
    begin
        --input and shift
        crc_v(15 downto 1) := vector;
        --xor
        crc_v(0) := crc_v(15) xor crc_v(14) xor crc_v(10) xor crc_v(8) xor crc_v(7) xor crc_v(4) xor crc_v(3) xor din;
        --output
        vector   := crc_v(14 downto 0);
    end procedure;

end can_aximm_pkg;
