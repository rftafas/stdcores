
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/verification_ip_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {AXI-MM Master}]
  set C_M00_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -name "C_M00_AXI_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {Width of M_AXI address bus.      -- The master generates the read and write addresses of width specified as C_M_AXI_ADDR_WIDTH.} ${C_M00_AXI_ADDR_WIDTH}
  set C_M00_AXI_DATA_WIDTH [ipgui::add_param $IPINST -name "C_M00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of M_AXI data bus.      -- The master issues write data and accept read data where the width of the data bus is C_M_AXI_DATA_WIDTH} ${C_M00_AXI_DATA_WIDTH}
  ipgui::add_param $IPINST -name "verbose" -parent ${Page_0}

  #Adding Page
  set Page_1 [ipgui::add_page $IPINST -name "Page 1" -display_name {AXI-S Configuration}]
  #Adding Group
  set Test_configuration [ipgui::add_group $IPINST -name "Test configuration" -parent ${Page_1} -display_name {Test Setup} -layout horizontal]
  #Adding Group
  set tt [ipgui::add_group $IPINST -name "tt" -parent ${Test_configuration} -display_name {Test configuration}]
  set test_number [ipgui::add_param $IPINST -name "test_number" -parent ${tt}]
  set_property tooltip {selects one of possible tests to be executed.} ${test_number}
  set prbs_sel [ipgui::add_param $IPINST -name "prbs_sel" -parent ${tt} -widget comboBox]
  set_property tooltip {Selects a PRBS data for testing.} ${prbs_sel}

  #Adding Group
  set t [ipgui::add_group $IPINST -name "t" -parent ${Test_configuration} -display_name {Test Types}]
  ipgui::add_static_text $IPINST -name "Test Types" -parent ${t} -text {0) All zeroes
1) All ones
2) Counter
3) PRBS
4) Slave VALID response testing
5) Master READY response testing}


  #Adding Group
  set AXI_Interface_Config [ipgui::add_group $IPINST -name "AXI Interface Config" -parent ${Page_1}]
  set AXI_TDATA_BYTES_WIDTH [ipgui::add_param $IPINST -name "AXI_TDATA_BYTES_WIDTH" -parent ${AXI_Interface_Config}]
  set_property tooltip {Number of bytes on AXI STREAM interface} ${AXI_TDATA_BYTES_WIDTH}
  ipgui::add_param $IPINST -name "TUSER_SIZE" -parent ${AXI_Interface_Config}

  #Adding Group
  set packet [ipgui::add_group $IPINST -name "packet" -parent ${Page_1} -display_name {Packet Mode}]
  ipgui::add_param $IPINST -name "packet_size_max" -parent ${packet}
  ipgui::add_param $IPINST -name "packet_size_min" -parent ${packet}
  ipgui::add_param $IPINST -name "packet_random" -parent ${packet}
  set packet [ipgui::add_param $IPINST -name "packet" -parent ${packet}]
  set_property tooltip {Enable Packet Mode Generation and Verification} ${packet}



}

proc update_PARAM_VALUE.packet_random { PARAM_VALUE.packet_random PARAM_VALUE.packet } {
	# Procedure called to update packet_random when any of the dependent parameters in the arguments change
	
	set packet_random ${PARAM_VALUE.packet_random}
	set packet ${PARAM_VALUE.packet}
	set values(packet) [get_property value $packet]
	if { [gen_USERPARAMETER_packet_random_ENABLEMENT $values(packet)] } {
		set_property enabled true $packet_random
	} else {
		set_property enabled false $packet_random
	}
}

proc validate_PARAM_VALUE.packet_random { PARAM_VALUE.packet_random } {
	# Procedure called to validate packet_random
	return true
}

proc update_PARAM_VALUE.packet_size_max { PARAM_VALUE.packet_size_max PARAM_VALUE.packet } {
	# Procedure called to update packet_size_max when any of the dependent parameters in the arguments change
	
	set packet_size_max ${PARAM_VALUE.packet_size_max}
	set packet ${PARAM_VALUE.packet}
	set values(packet) [get_property value $packet]
	if { [gen_USERPARAMETER_packet_size_max_ENABLEMENT $values(packet)] } {
		set_property enabled true $packet_size_max
	} else {
		set_property enabled false $packet_size_max
	}
}

proc validate_PARAM_VALUE.packet_size_max { PARAM_VALUE.packet_size_max } {
	# Procedure called to validate packet_size_max
	return true
}

proc update_PARAM_VALUE.packet_size_min { PARAM_VALUE.packet_size_min PARAM_VALUE.packet } {
	# Procedure called to update packet_size_min when any of the dependent parameters in the arguments change
	
	set packet_size_min ${PARAM_VALUE.packet_size_min}
	set packet ${PARAM_VALUE.packet}
	set values(packet) [get_property value $packet]
	if { [gen_USERPARAMETER_packet_size_min_ENABLEMENT $values(packet)] } {
		set_property enabled true $packet_size_min
	} else {
		set_property enabled false $packet_size_min
	}
}

proc validate_PARAM_VALUE.packet_size_min { PARAM_VALUE.packet_size_min } {
	# Procedure called to validate packet_size_min
	return true
}

proc update_PARAM_VALUE.AXI_TDATA_BYTES_WIDTH { PARAM_VALUE.AXI_TDATA_BYTES_WIDTH } {
	# Procedure called to update AXI_TDATA_BYTES_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_TDATA_BYTES_WIDTH { PARAM_VALUE.AXI_TDATA_BYTES_WIDTH } {
	# Procedure called to validate AXI_TDATA_BYTES_WIDTH
	return true
}

proc update_PARAM_VALUE.TUSER_SIZE { PARAM_VALUE.TUSER_SIZE } {
	# Procedure called to update TUSER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TUSER_SIZE { PARAM_VALUE.TUSER_SIZE } {
	# Procedure called to validate TUSER_SIZE
	return true
}

proc update_PARAM_VALUE.packet { PARAM_VALUE.packet } {
	# Procedure called to update packet when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.packet { PARAM_VALUE.packet } {
	# Procedure called to validate packet
	return true
}

proc update_PARAM_VALUE.prbs_sel { PARAM_VALUE.prbs_sel } {
	# Procedure called to update prbs_sel when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.prbs_sel { PARAM_VALUE.prbs_sel } {
	# Procedure called to validate prbs_sel
	return true
}

proc update_PARAM_VALUE.test_number { PARAM_VALUE.test_number } {
	# Procedure called to update test_number when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.test_number { PARAM_VALUE.test_number } {
	# Procedure called to validate test_number
	return true
}

proc update_PARAM_VALUE.verbose { PARAM_VALUE.verbose } {
	# Procedure called to update verbose when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.verbose { PARAM_VALUE.verbose } {
	# Procedure called to validate verbose
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_START_DATA_VALUE { PARAM_VALUE.C_M00_AXI_START_DATA_VALUE } {
	# Procedure called to update C_M00_AXI_START_DATA_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_START_DATA_VALUE { PARAM_VALUE.C_M00_AXI_START_DATA_VALUE } {
	# Procedure called to validate C_M00_AXI_START_DATA_VALUE
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR { PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR } {
	# Procedure called to update C_M00_AXI_TARGET_SLAVE_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR { PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR } {
	# Procedure called to validate C_M00_AXI_TARGET_SLAVE_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_ADDR_WIDTH { PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_M00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_ADDR_WIDTH { PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_M00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_DATA_WIDTH { PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to update C_M00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_DATA_WIDTH { PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM { PARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM } {
	# Procedure called to update C_M00_AXI_TRANSACTIONS_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM { PARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM } {
	# Procedure called to validate C_M00_AXI_TRANSACTIONS_NUM
	return true
}


proc update_MODELPARAM_VALUE.C_M00_AXI_START_DATA_VALUE { MODELPARAM_VALUE.C_M00_AXI_START_DATA_VALUE PARAM_VALUE.C_M00_AXI_START_DATA_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_START_DATA_VALUE}] ${MODELPARAM_VALUE.C_M00_AXI_START_DATA_VALUE}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR { MODELPARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR}] ${MODELPARAM_VALUE.C_M00_AXI_TARGET_SLAVE_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM { MODELPARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM PARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM}] ${MODELPARAM_VALUE.C_M00_AXI_TRANSACTIONS_NUM}
}

proc update_MODELPARAM_VALUE.test_number { MODELPARAM_VALUE.test_number PARAM_VALUE.test_number } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.test_number}] ${MODELPARAM_VALUE.test_number}
}

proc update_MODELPARAM_VALUE.prbs_sel { MODELPARAM_VALUE.prbs_sel PARAM_VALUE.prbs_sel } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.prbs_sel}] ${MODELPARAM_VALUE.prbs_sel}
}

proc update_MODELPARAM_VALUE.packet { MODELPARAM_VALUE.packet PARAM_VALUE.packet } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.packet}] ${MODELPARAM_VALUE.packet}
}

proc update_MODELPARAM_VALUE.packet_random { MODELPARAM_VALUE.packet_random PARAM_VALUE.packet_random } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.packet_random}] ${MODELPARAM_VALUE.packet_random}
}

proc update_MODELPARAM_VALUE.packet_size_max { MODELPARAM_VALUE.packet_size_max PARAM_VALUE.packet_size_max } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.packet_size_max}] ${MODELPARAM_VALUE.packet_size_max}
}

proc update_MODELPARAM_VALUE.packet_size_min { MODELPARAM_VALUE.packet_size_min PARAM_VALUE.packet_size_min } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.packet_size_min}] ${MODELPARAM_VALUE.packet_size_min}
}

proc update_MODELPARAM_VALUE.AXI_TDATA_BYTES_WIDTH { MODELPARAM_VALUE.AXI_TDATA_BYTES_WIDTH PARAM_VALUE.AXI_TDATA_BYTES_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_TDATA_BYTES_WIDTH}] ${MODELPARAM_VALUE.AXI_TDATA_BYTES_WIDTH}
}

proc update_MODELPARAM_VALUE.verbose { MODELPARAM_VALUE.verbose PARAM_VALUE.verbose } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.verbose}] ${MODELPARAM_VALUE.verbose}
}

proc update_MODELPARAM_VALUE.TUSER_SIZE { MODELPARAM_VALUE.TUSER_SIZE PARAM_VALUE.TUSER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TUSER_SIZE}] ${MODELPARAM_VALUE.TUSER_SIZE}
}

