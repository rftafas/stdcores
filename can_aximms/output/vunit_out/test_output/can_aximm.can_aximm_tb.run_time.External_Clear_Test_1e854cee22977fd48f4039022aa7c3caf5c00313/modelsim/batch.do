onerror {quit -code 1}
source "/home/rftafas/Projects/stdcores/can_aximms/output/vunit_out/test_output/can_aximm.can_aximm_tb.run_time.External_Clear_Test_1e854cee22977fd48f4039022aa7c3caf5c00313/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
