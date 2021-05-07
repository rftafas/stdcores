onerror {quit -code 1}
source "/home/rftafas/Projects/stdcores/can_aximms/output/vunit_out/test_output/can_aximm.can_aximm_tb.run_time.Split_Read_Write_Test_71d5cad6bc9174ebd689bd138ea65a8cd28060d8/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
