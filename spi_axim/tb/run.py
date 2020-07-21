# -*- coding: utf-8 -*-
from os.path import join , dirname, abspath
import subprocess
from vunit.ghdl_interface import GHDLInterface
from vunit.simulator_factory import SIMULATOR_FACTORY
from vunit   import VUnit, VUnitCLI

##############################################################################
##############################################################################
##############################################################################

#Check GHDL backend.
code_coverage=False
try:
  if( GHDLInterface.determine_backend("")=="gcc" or  GHDLInterface.determine_backend("")=="GCC"):
    code_coverage=True
  else:
    code_coverage=False
except:
  print("")

#Check simulator.
print ("=============================================")
simulator_class = SIMULATOR_FACTORY.select_simulator()
simname = simulator_class.name
print (simname)
if (simname == "modelsim"):
  f= open("modelsim.do","w+")
  f.write("add wave * \nlog -r /*\nvcd file\nvcd add -r /*\n")
  f.close()
print ("=============================================")

##############################################################################
##############################################################################
##############################################################################

#VUnit instance.
ui = VUnit.from_argv()

##############################################################################
##############################################################################
##############################################################################

#Add array pkg.
ui.add_array_util()

ui.add_osvvm()
ui.add_array_util()
ui.add_verification_components()

#Add module sources.
run_src_lib = ui.add_library("stdblocks")
run_src_lib.add_source_files("../../../stdblocks/sync_lib/*.vhd", allow_empty=False)
run_src_lib = ui.add_library("stdcores")
run_src_lib.add_source_files("../../../stdcores/*/*.vhd", allow_empty=False)
run_src_lib = ui.add_library("expert")
run_src_lib.add_source_files("../../../stdexpert/src/*.vhd", allow_empty=False)


#Add tb sources.
run_tb_lib = ui.add_library("tb_lib")
run_tb_lib.add_source_files("*.vhd")

##############################################################################
##############################################################################
##############################################################################

#GHDL parameters.
if(code_coverage==True):
  run_src_lib.add_compile_option   ("ghdl.flags"     , [  "-fprofile-arcs","-ftest-coverage" ])
  run_tb_lib.add_compile_option("ghdl.flags"     , [  "-fprofile-arcs","-ftest-coverage" ])
  ui.set_sim_option("ghdl.elab_flags"      , [ "-Wl,-lgcov" ])
  ui.set_sim_option("modelsim.init_files.after_load" ,["modelsim.do"])
else:
  ui.set_sim_option("modelsim.init_files.after_load" ,["modelsim.do"])


#Run tests.
try:
  ui.main()
except SystemExit as exc:
  all_ok = exc.code == 0

#Code coverage.
if all_ok:
  if(code_coverage==True):
    subprocess.call(["lcov", "--capture", "--directory", "avl_parallel2bram_top.gcda", "--output-file",  "code_0.info" ])
    subprocess.call(["lcov", "--capture", "--directory", "sync_input.gcda", "--output-file",  "code_1.info" ])
    subprocess.call(["genhtml","code_0.info","code_1.info","--output-directory", "html"])
  else:
    exit(0)
else:
  exit(1)
