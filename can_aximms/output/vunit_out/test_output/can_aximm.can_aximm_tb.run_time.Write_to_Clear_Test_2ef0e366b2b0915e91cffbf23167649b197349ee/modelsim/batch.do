onerror {quit -code 1}
source "/home/rftafas/Projects/stdcores/can_aximms/output/vunit_out/test_output/can_aximm.can_aximm_tb.run_time.Write_to_Clear_Test_2ef0e366b2b0915e91cffbf23167649b197349ee/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
