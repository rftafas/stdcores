library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
  use IEEE.math_real.all;
library expert;
  use expert.std_logic_expert.all;

package aximm_intercon_pkg is

  component axis_aligner is
    generic (
      number_ports    : positive := 2;
      tdata_byte      : positive := 8;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      switch_on_tlast : boolean  := false
    );
    port (
      clk_i      : in  std_logic;
      rst_i      : in  std_logic;
        --AXIS Master Port
      m_tdata_o  : out std_logic_array (number_ports-1 downto 0)(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_array (number_ports-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array (number_ports-1 downto 0)(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_array (number_ports-1 downto 0)(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic_vector(number_ports-1 downto 0);
      m_tvalid_o : out std_logic_vector(number_ports-1 downto 0);
      m_tlast_o  : out std_logic_vector(number_ports-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  std_logic_array (number_ports-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array (number_ports-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array (number_ports-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array (number_ports-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(number_ports-1 downto 0);
      s_tvalid_i : in  std_logic_vector(number_ports-1 downto 0);
      s_tlast_i  : in  std_logic_vector(number_ports-1 downto 0)
    );
  end component axis_aligner;

  component axis_intercon is
    generic (
      controllers_num : positive := 8;
      peripherals_num : positive := 8;
      tdata_byte      : positive := 8;
      tdest_size      : positive := 8;
      tuser_size      : positive := 8;
      select_auto     : boolean  := false;
      switch_tlast    : boolean  := false;
      interleaving    : boolean  := false;
      max_tx_size     : positive := 10
    );
    port (
      --general
      rst_i       : in  std_logic;
      clk_i       : in  std_logic;
      --AXIS Master Port
      m_tdata_o  : out std_logic_array(controllers_num-1 downto 0)(8*tdata_byte-1 downto 0);
      m_tuser_o  : out std_logic_array(controllers_num-1 downto 0)(tuser_size-1 downto 0);
      m_tdest_o  : out std_logic_array(controllers_num-1 downto 0)(tdest_size-1 downto 0);
      m_tstrb_o  : out std_logic_array(controllers_num-1 downto 0)(tdata_byte-1 downto 0);
      m_tready_i : in  std_logic_vector(controllers_num-1 downto 0);
      m_tvalid_o : out std_logic_vector(controllers_num-1 downto 0);
      m_tlast_o  : out std_logic_vector(controllers_num-1 downto 0);
        --AXIS Slave Port
      s_tdata_i  : in  std_logic_array(peripherals_num-1 downto 0)(8*tdata_byte-1 downto 0);
      s_tuser_i  : in  std_logic_array(peripherals_num-1 downto 0)(tuser_size-1 downto 0);
      s_tdest_i  : in  std_logic_array(peripherals_num-1 downto 0)(tdest_size-1 downto 0);
      s_tstrb_i  : in  std_logic_array(peripherals_num-1 downto 0)(tdata_byte-1 downto 0);
      s_tready_o : out std_logic_vector(peripherals_num-1 downto 0);
      s_tvalid_i : in  std_logic_vector(peripherals_num-1 downto 0);
      s_tlast_i  : in  std_logic_vector(peripherals_num-1 downto 0)
    );
  end component axis_intercon;

  component aximm_intercon
    generic (
      controllers_num : positive := 8;
      peripherals_num : positive := 8;
      DATA_BYTE_NUM   : positive := 8;
      ADDR_SIZE       : positive := 8;
      ID_WIDTH        : positive := 8
    );
    port (
      rst_i         : in  std_logic;
      clk_i         : in  std_logic;
      addr_map_i    : in  std_logic_array(controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_AWID    : out std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_AWVALID : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_AWREADY : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_AWADDR  : out std_logic_array (controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_AWPROT  : out std_logic_array (controllers_num-1 downto 0)(2 downto 0);
      M_AXI_WVALID  : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_WREADY  : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_WDATA   : out std_logic_array (controllers_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_WSTRB   : out std_logic_array (controllers_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
      M_AXI_WLAST   : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_BVALID  : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_BREADY  : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_BRESP   : in  std_logic_array (controllers_num-1 downto 0)(1 downto 0);
      M_AXI_BID     : in  std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_ARVALID : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_ARREADY : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_ARADDR  : out std_logic_array (controllers_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      M_AXI_ARPROT  : out std_logic_array (controllers_num-1 downto 0)(2 downto 0);
      M_AXI_ARID    : out std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_RVALID  : in  std_logic_vector(controllers_num-1 downto 0);
      M_AXI_RREADY  : out std_logic_vector(controllers_num-1 downto 0);
      M_AXI_RDATA   : in  std_logic_array (controllers_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      M_AXI_RRESP   : in  std_logic_array (controllers_num-1 downto 0)(1 downto 0);
      M_AXI_RID     : in  std_logic_array (controllers_num-1 downto 0)(ID_WIDTH-1 downto 0);
      M_AXI_RLAST   : in  std_logic_vector(controllers_num-1 downto 0);
      S_AXI_AWID    : in  std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_AWVALID : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_AWREADY : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_AWADDR  : in  std_logic_array (peripherals_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_array (peripherals_num-1 downto 0)(2 downto 0);
      S_AXI_WVALID  : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_WREADY  : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_WDATA   : in  std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_array (peripherals_num-1 downto 0)(DATA_BYTE_NUM-1 downto 0);
      S_AXI_WLAST   : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_BVALID  : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_BREADY  : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_BRESP   : out std_logic_array (peripherals_num-1 downto 0)(1 downto 0);
      S_AXI_BID     : out std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_ARVALID : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_ARREADY : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_ARADDR  : in  std_logic_array (peripherals_num-1 downto 0)(ADDR_SIZE-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_array (peripherals_num-1 downto 0)(2 downto 0);
      S_AXI_ARID    : in  std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_RVALID  : out std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_RREADY  : in  std_logic_vector(peripherals_num-1 downto 0);
      S_AXI_RDATA   : out std_logic_array (peripherals_num-1 downto 0)(8*DATA_BYTE_NUM-1 downto 0);
      S_AXI_RRESP   : out std_logic_array (peripherals_num-1 downto 0)(1 downto 0);
      S_AXI_RID     : out std_logic_array (peripherals_num-1 downto 0)(ID_WIDTH-1 downto 0);
      S_AXI_RLAST   : out std_logic_vector(peripherals_num-1 downto 0)
    );
  end component aximm_intercon;

  procedure set_peripheral_address (
    port_number : in natural;
    base_addr   : in std_logic_vector;
    table       : inout std_logic_array
  );

  function set_peripheral_address (
           port_number : natural;
           base_addr   : std_logic_vector;
           table       : std_logic_array
  ) return std_logic_array;

  function address_decode(
           address     : std_logic_vector;
           table       : std_logic_array
  ) return natural;

  function address_valid(
    address     : std_logic_vector;
    table       : std_logic_array
) return boolean;

end package;

package body aximm_intercon_pkg is

  function set_peripheral_address (
           port_number : natural;
           base_addr   : std_logic_vector;
           table       : std_logic_array
  ) return std_logic_array is
    variable tmp  : std_logic_array(table'range)(table(0)'range);
  begin
    assert base_addr'length = table(0)'length
      report "Address size must be " & to_string(table(0)'length) & "bits."
      severity failure;
    tmp  := table;
    for j in tmp'range loop
      next when port_number = j;
      assert ( not std_match(base_addr, tmp(j) ) )
        report "Address conflict with peripheral: " & to_string(j) & ", base_address: " & to_string(tmp(j))
        severity failure;
    end loop;
    tmp(port_number) := (others=>'0');
    tmp(port_number) := base_addr;
    return tmp;
  end set_peripheral_address;

  procedure set_peripheral_address (
    port_number : in natural;
    base_addr   : in std_logic_vector;
    table       : inout std_logic_array
  ) is
  begin
    table := set_peripheral_address(port_number,base_addr,table);
  end set_peripheral_address;

  function address_decode (
           address     : std_logic_vector;
           table       : std_logic_array
  ) return natural is
    variable tmp : integer;
  begin
    for j in table'range loop
      tmp := j;
      exit when std_match( address, table(j) );
    end loop;
    return tmp;
  end address_decode;

  function address_valid (
           address     : std_logic_vector;
           table       : std_logic_array
  ) return boolean is
    variable tmp : boolean := false;
  begin
    for j in table'range loop
      tmp := std_match( address, table(j) );
      exit when std_match( address, table(j) );
    end loop;
    return tmp;
  end address_valid;

end package body;
