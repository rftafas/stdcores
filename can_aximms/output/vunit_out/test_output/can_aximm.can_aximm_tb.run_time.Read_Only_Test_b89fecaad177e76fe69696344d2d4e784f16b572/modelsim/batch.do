onerror {quit -code 1}
source "/home/rftafas/Projects/stdcores/can_aximms/output/vunit_out/test_output/can_aximm.can_aximm_tb.run_time.Read_Only_Test_b89fecaad177e76fe69696344d2d4e784f16b572/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
