library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;
library expert;
  use expert.std_logic_expert.all;
library stdblocks;
    use stdblocks.ram_lib.all;
    use stdblocks.fifo_lib.all;

package stdcores_pkg is

  type fifo_config_rec is record
    ram_type     :  fifo_t;
    fifo_size    : integer;
    tdata_size   : integer;
    tdest_size   : integer;
    tuser_size   : integer;
    packet_mode  : boolean;
    tuser_enable : boolean;
    tlast_enable : boolean;
    tdest_enable : boolean;
    sync_mode    : boolean;
    cut_through  : boolean;
  end record;

end package;

package body stdcores_pkg is


end package body;
