---------------------------------------------------------------------------------
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
--
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-- For more information, please refer to <http://unlicense.org/>
---------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
library expert;
  use expert.std_logic_expert.all;

use work.can_aximm_pkg.all;

entity can_aximm is
  generic (
    C_S_AXI_ADDR_WIDTH : integer := 7;
    C_S_AXI_DATA_WIDTH : integer := 32
  );
  port (
    S_AXI_ACLK : in std_logic;
    S_AXI_ARESETN : in std_logic;
    S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT : in std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID : in std_logic;
    S_AXI_WREADY : out std_logic;
    S_AXI_BRESP : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_BREADY : in std_logic;
    S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT : in std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_RREADY : in std_logic;
    g1_i : in std_logic_vector(31 downto 0);
    iso_mode_o : out std_logic;
    fd_enable_o : out std_logic;
    promiscuous_o : out std_logic;
    sample_rate_o : out std_logic_vector(15 downto 0);
    rx_data_irq_i : in std_logic;
    rx_error_irq_i : in std_logic;
    tx_data_irq_i : in std_logic;
    tx_error_irq_i : in std_logic;
    rx_data_mask_o : out std_logic;
    rx_error_mask_o : out std_logic;
    tx_data_mask_o : out std_logic;
    tx_error_mask_o : out std_logic;
    stuff_violation_i : in std_logic;
    collision_i : in std_logic;
    channel_ready_i : in std_logic;
    loop_enable_o : out std_logic;
    insert_error_o : out std_logic;
    force_dominant_o : out std_logic;
    rx_data_valid_i : in std_logic;
    rx_read_done_o : out std_logic;
    rx_busy_i : in std_logic;
    rx_crc_error_i : in std_logic;
    rx_rtr_i : in std_logic;
    rx_ide_i : in std_logic;
    rx_reserved_i : in std_logic_vector(1 downto 0);
    id1_o : out std_logic_vector(28 downto 0);
    id1_mask_o : out std_logic_vector(28 downto 0);
    rx_size_i : in std_logic_vector(3 downto 0);
    rx_id_i : in std_logic_vector(28 downto 0);
    rx_data0_i : in std_logic_vector(31 downto 0);
    rx_data1_i : in std_logic_vector(31 downto 0);
    tx_ready_i : in std_logic;
    tx_valid_o : out std_logic;
    tx_busy_i : in std_logic;
    tx_arb_lost_i : in std_logic;
    tx_retry_error_i : in std_logic;
    tx_rtr_o : out std_logic;
    tx_eff_o : out std_logic;
    tx_reserved_o : out std_logic_vector(1 downto 0);
    tx_dlc_o : out std_logic_vector(3 downto 0);
    tx_id_o : out std_logic_vector(28 downto 0);
    tx_data0_o : out std_logic_vector(31 downto 0);
    tx_data1_o : out std_logic_vector(31 downto 0)
  );
end can_aximm;

architecture rtl of can_aximm is

  --architecture_declaration_tag


  constant register_bank_version_c : String := "20210528_1505";
  constant C_S_AXI_ADDR_LSB : integer := 2;
  constant REG_NUM : integer := 2**(C_S_AXI_ADDR_WIDTH-C_S_AXI_ADDR_LSB);

  type reg_t is array (REG_NUM-1 downto 0) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);


  signal awaddr_s : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal awready_s : std_logic;
  signal wready_s : std_logic;
  signal wtimeout_sr : std_logic_vector(15 downto 0) := ( 0 => '1', others=>'0');
  signal wtimeout_s : std_logic;
  signal bresp_s : std_logic_vector(1 downto 0);
  signal bvalid_s : std_logic;
  signal bresp_timer_sr : std_logic_vector(15 downto 0) := ( 0 => '1', others=>'0');
  signal araddr_s : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal arready_s : std_logic;
  signal rresp_s : std_logic_vector(1 downto 0);
  signal rvalid_s : std_logic;
  signal rtimeout_sr : std_logic_vector(15 downto 0) := ( 0 => '1', others=>'0');
  signal rtimeout_s : std_logic;
  signal regwrite_s : reg_t := (others=>(others=>'0'));
  signal regread_s : reg_t := (others=>(others=>'0'));
  signal regclear_s : reg_t := (others=>(others=>'0'));
  signal regset_s : reg_t := (others=>(others=>'0'));
  signal regread_en : std_logic;
  signal regwrite_en : std_logic;

begin

  --architecture_body_tag.

  assert register_bank_version_c = package_version_c
    report "Package and Register Bank version mismatch."
    severity warning;

  
      ------------------------------------------------------------------------------------------------
      -- I/O Connections assignments
      ------------------------------------------------------------------------------------------------
      S_AXI_AWREADY <= awready_s;
      S_AXI_WREADY  <= wready_s;
      S_AXI_BRESP   <= bresp_s;
      S_AXI_BVALID  <= bvalid_s;
      S_AXI_ARREADY <= arready_s;
      S_AXI_RRESP   <= rresp_s;
      S_AXI_RVALID  <= rvalid_s;
  
      ------------------------------------------------------------------------------------------------
      --write
      ------------------------------------------------------------------------------------------------
      waddr_p : process(S_AXI_ARESETN, S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              awready_s <= '1';
              awaddr_s  <= (others => '1');
          elsif rising_edge(S_AXI_ACLK) then
              if S_AXI_AWVALID = '1' then
                  awready_s <= '0';
                  awaddr_s <= S_AXI_AWADDR;
              elsif (S_AXI_BREADY = '1' and bvalid_s = '1') then
                  awready_s <= '1';
              elsif wtimeout_s = '1' then
                  awready_s <= '1';
              end if;
          end if;
      end process;
  
      wdata_p : process (S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              wready_s <= '1';
          elsif rising_edge(S_AXI_ACLK) then
              if S_AXI_WVALID = '1' then
                  wready_s <= '0';
              elsif (S_AXI_BREADY = '1' and bvalid_s = '1') then
                  wready_s <= '1';
              elsif wtimeout_s = '1' then
                  wready_s <= '1';
              end if;
          end if;
      end process;
  
      wreg_en_p : process (S_AXI_ACLK)
          variable lock_v : std_logic;
      begin
          if S_AXI_ARESETN = '0' then
              regwrite_en <= '0';
              lock_v := '0';
          elsif rising_edge(S_AXI_ACLK) then
              if lock_v = '1' then
                  regwrite_en <= '0';
                  if (S_AXI_BREADY = '1' and bvalid_s = '1') then
                      lock_v := '0';
                  end if;
              elsif (wready_s = '0' or S_AXI_WVALID = '1' ) and ( awready_s = '0' or S_AXI_AWVALID = '1' )then
                  regwrite_en <= '1';
                  lock_v := '1';
              elsif wtimeout_s = '1' then
                  regwrite_en <= '0';
                  lock_v := '0';
              end if;
          end if;
      end process;
  
      wresp_p : process (S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              bvalid_s  <= '0';
              bresp_s   <= "00";
          elsif rising_edge(S_AXI_ACLK) then
              if (wready_s = '1' and awready_s = '1' ) then
                  bvalid_s <= '1';
                  bresp_s  <= "00";
                  bresp_timer_sr <= ( 0 => '1', others=>'0' );
              elsif wtimeout_s = '1' then
                  bvalid_s <= '1';
                  bresp_s  <= "10";
                  bresp_timer_sr <= ( 0 => '1', others=>'0' );
              elsif bvalid_s = '1' then
                  bresp_timer_sr <= bresp_timer_sr(14 downto 0) & bresp_timer_sr(15);
                  if S_AXI_BREADY = '1' or bresp_timer_sr(15) = '1' then
                      bvalid_s <= '0';
                      bresp_s  <= "00";
                      bresp_timer_sr <= ( 0 => '1', others=>'0' );
                  end if;
              end if;
          end if;
      end process;
  
      wtimer_p : process (S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              wtimeout_s   <= '0';
          elsif rising_edge(S_AXI_ACLK) then
              wtimeout_s <= wtimeout_sr(15);
              if wready_s = '1' or awready_s = '1' then
                  wtimeout_sr <= ( 0 => '1', others=>'0');
              elsif wready_s = '1' and awready_s = '1' then
                  wtimeout_sr <= (others=>'0');
              else
                  wtimeout_sr <= wtimeout_sr(14 downto 0) & wtimeout_sr(15);
              end if;
          end if;
      end process;
  
      wreg_p : process (S_AXI_ACLK)
          variable loc_addr : INTEGER;
      begin
          if S_AXI_ARESETN = '0' then
              regwrite_s <= (others => (others => '0'));
          elsif rising_edge(S_AXI_ACLK) then
              loc_addr := to_integer(awaddr_s(C_S_AXI_ADDR_WIDTH - 1 downto C_S_AXI_ADDR_LSB));
              for j in regwrite_s'range loop
                  for k in C_S_AXI_DATA_WIDTH - 1 downto 0 loop
                      if regclear_s(j)(k) = '1' then
                          regwrite_s(j)(k) <= '0';
                      elsif regwrite_en = '1' then
                          if j = loc_addr then
                              if S_AXI_WSTRB(k/8) = '1' then
                                  regwrite_s(j)(k) <= S_AXI_WDATA(k);
                              end if;
                          end if;
                      end if;
                  end loop;
              end loop;
          end if;
      end process;
  
      ------------------------------------------------------------------------------------------------
      --Read
      ------------------------------------------------------------------------------------------------
      raddr_p : process (S_AXI_ARESETN, S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              arready_s  <= '1';
              regread_en <= '0';
              araddr_s   <= (others => '1');
          elsif rising_edge(S_AXI_ACLK) then
              if S_AXI_ARVALID = '1' then
                  arready_s  <= '0';
                  araddr_s   <= S_AXI_ARADDR;
                  regread_en <= '1';
              elsif rvalid_s = '1' and S_AXI_RREADY = '1' then
                  arready_s  <= '1';
                  regread_en <= '0';
              elsif rtimeout_s = '1' then
                  arready_s  <= '1';
                  regread_en <= '0';
              else
                  regread_en <= '0';
              end if;
          end if;
      end process;
  
      --AXI uses same channel for data and response.
      --one can consider that AXI-S RRESP is sort of TUSER.
      rresp_rdata_p : process (S_AXI_ARESETN, S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              rvalid_s <= '0';
              rresp_s  <= "00";
          elsif rising_edge(S_AXI_ACLK) then
              if regread_en = '1' then --there is an address waiting for us.
                  rvalid_s <= '1';
                  rresp_s  <= "00"; -- 'OKAY' response
              elsif S_AXI_RREADY = '1' then
                  --Read data is accepted by the master
                  rvalid_s <= '0';
              elsif rtimeout_s = '1' then
                  --when it times out? when after doing my part, master does not respond
                  --with the RREADY, meaning he havent read my data.
                  rvalid_s <= '0';
                  rresp_s  <= "10"; -- No one is expected to read this. Debug only.
              else
                  rvalid_s <= '0';
                  rresp_s  <= "00"; -- No one is expected to read this. Debug only.
              end if;
          end if;
      end process;
  
      rtimer_p : process (S_AXI_ACLK)
      begin
          if S_AXI_ARESETN = '0' then
              rtimeout_s   <= '0';
          elsif rising_edge(S_AXI_ACLK) then
              rtimeout_s <= rtimeout_sr(15);
              if S_AXI_RREADY = '1' then
                  rtimeout_sr <= ( 0 => '1', others=>'0');
              elsif rvalid_s = '1' then
                  rtimeout_sr <= rtimeout_sr(14 downto 0) & rtimeout_sr(15);
              end if;
          end if;
      end process;
  
      --get data from ports to bus
      read_reg_p : process( S_AXI_ACLK ) is
          variable loc_addr : integer;
          variable reg_tmp  : reg_t := (others => (others => '0'));
          variable reg_lock : reg_t := (others => (others => '0'));
      begin
          if (S_AXI_ARESETN = '0') then
              reg_tmp     := (others => (others => '0'));
              reg_lock    := (others => (others => '0'));
              S_AXI_RDATA <= (others => '0');
          elsif (rising_edge (S_AXI_ACLK)) then
              for j in regread_s'range loop
                  for k in regread_s(0)'range loop
                      if regclear_s(j)(k) = '1' then
                          reg_tmp(j)(k)  := '0';
                          reg_lock(j)(k) := '0';
                      elsif regset_s(j)(k) = '1' then
                          reg_tmp(j)(k)  := '1';
                          reg_lock(j)(k) := '1';
                      elsif reg_lock(j)(k) = '0' then
                          reg_tmp(j)(k) := regread_s(j)(k);
                      end if;
                  end loop;
              end loop;
              --
              loc_addr := to_integer(araddr_s(C_S_AXI_ADDR_WIDTH-1 downto C_S_AXI_ADDR_LSB));
              if regread_en = '1' then
                  S_AXI_RDATA  <= reg_tmp(loc_addr);
              end if;
          end if;
      end process;

    --Register Connection
    regread_s(0)(31 downto 0) <= g1_i;
    iso_mode_o <= regwrite_s(1)(0);
    regread_s(1)(0) <= regwrite_s(1)(0);
    fd_enable_o <= regwrite_s(1)(1);
    regread_s(1)(1) <= regwrite_s(1)(1);
    promiscuous_o <= regwrite_s(1)(8);
    regread_s(1)(8) <= regwrite_s(1)(8);
    sample_rate_o <= regwrite_s(2)(15 downto 0);
    regread_s(2)(15 downto 0) <= regwrite_s(2)(15 downto 0);
    rx_data_mask_o <= regwrite_s(3)(16);
    regread_s(3)(16) <= regwrite_s(3)(16);
    rx_error_mask_o <= regwrite_s(3)(17);
    regread_s(3)(17) <= regwrite_s(3)(17);
    tx_data_mask_o <= regwrite_s(3)(24);
    regread_s(3)(24) <= regwrite_s(3)(24);
    tx_error_mask_o <= regwrite_s(3)(25);
    regread_s(3)(25) <= regwrite_s(3)(25);
    regread_s(4)(8) <= channel_ready_i;
    loop_enable_o <= regwrite_s(7)(0);
    regread_s(7)(0) <= regwrite_s(7)(0);
    insert_error_o <= regwrite_s(7)(8);
    force_dominant_o <= regwrite_s(7)(16);
    regread_s(7)(16) <= regwrite_s(7)(16);
    rx_read_done_o <= regwrite_s(8)(1);
    regread_s(8)(8) <= rx_busy_i;
    regread_s(8)(9) <= rx_crc_error_i;
    regread_s(8)(16) <= rx_rtr_i;
    regread_s(8)(24) <= rx_ide_i;
    regread_s(8)(26 downto 25) <= rx_reserved_i;
    id1_o <= regwrite_s(9)(28 downto 0);
    regread_s(9)(28 downto 0) <= regwrite_s(9)(28 downto 0);
    id1_mask_o <= regwrite_s(10)(28 downto 0);
    regread_s(10)(28 downto 0) <= regwrite_s(10)(28 downto 0);
    regread_s(11)(3 downto 0) <= rx_size_i;
    regread_s(12)(28 downto 0) <= rx_id_i;
    regread_s(13)(31 downto 0) <= rx_data0_i;
    regread_s(14)(31 downto 0) <= rx_data1_i;
    regread_s(16)(0) <= tx_ready_i;
    tx_valid_o <= regwrite_s(16)(1);
    regread_s(16)(8) <= tx_busy_i;
    tx_rtr_o <= regwrite_s(16)(16);
    regread_s(16)(16) <= regwrite_s(16)(16);
    tx_eff_o <= regwrite_s(16)(24);
    regread_s(16)(24) <= regwrite_s(16)(24);
    tx_reserved_o <= regwrite_s(16)(26 downto 25);
    regread_s(16)(26 downto 25) <= regwrite_s(16)(26 downto 25);
    tx_dlc_o <= regwrite_s(17)(3 downto 0);
    regread_s(17)(3 downto 0) <= regwrite_s(17)(3 downto 0);
    tx_id_o <= regwrite_s(18)(28 downto 0);
    regread_s(18)(28 downto 0) <= regwrite_s(18)(28 downto 0);
    tx_data0_o <= regwrite_s(19)(31 downto 0);
    regread_s(19)(31 downto 0) <= regwrite_s(19)(31 downto 0);
    tx_data1_o <= regwrite_s(20)(31 downto 0);
    regread_s(20)(31 downto 0) <= regwrite_s(20)(31 downto 0);
  

    --Set Connection for Write to Clear
    regset_s(3)(0) <= rx_data_irq_i;
    regset_s(3)(1) <= rx_error_irq_i;
    regset_s(3)(8) <= tx_data_irq_i;
    regset_s(3)(9) <= tx_error_irq_i;
    regset_s(4)(0) <= stuff_violation_i;
    regset_s(4)(1) <= collision_i;
    regset_s(8)(0) <= rx_data_valid_i;
    regset_s(16)(9) <= tx_arb_lost_i;
    regset_s(16)(10) <= tx_retry_error_i;
  
    --External Clear Connection
    regclear_s(3)(0) <= regwrite_s(3)(0);
    regclear_s(3)(1) <= regwrite_s(3)(1);
    regclear_s(3)(8) <= regwrite_s(3)(8);
    regclear_s(3)(9) <= regwrite_s(3)(9);
    regclear_s(4)(0) <= regwrite_s(4)(0);
    regclear_s(4)(1) <= regwrite_s(4)(1);
    regclear_s(7)(8) <= regwrite_s(7)(8);
    regclear_s(8)(0) <= regwrite_s(8)(0);
    regclear_s(8)(1) <= regwrite_s(8)(1);
    regclear_s(16)(1) <= regwrite_s(16)(1);
    regclear_s(16)(9) <= regwrite_s(16)(9);
    regclear_s(16)(10) <= regwrite_s(16)(10);

end rtl;

