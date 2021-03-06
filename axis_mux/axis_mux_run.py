from os.path import join, dirname
import sys
import glob

try:
    from vunit import VUnit
except:
    print("Please, intall vunit_hdl with 'pip install vunit_hdl'")
    print("Also, make sure to have either GHDL or Modelsim installed.")
    exit()


root = dirname(__file__)

vu = VUnit.from_argv()
vu.add_verification_components()

expert = vu.add_library("expert")
expert.add_source_files(join(root, "../dependencies/stdblocks/libraries/stdexpert/src/*.vhd"))

stdblocks = vu.add_library("stdblocks")
stdblocks_filelist = glob.glob("../dependencies/stdblocks/sync_lib/*.vhd")
stdblocks_filelist = stdblocks_filelist + glob.glob("../dependencies/stdblocks/ram_lib/*.vhd")
stdblocks_filelist = stdblocks_filelist + glob.glob("../dependencies/stdblocks/fifo_lib/*.vhd")
stdblocks_filelist = stdblocks_filelist + glob.glob("../dependencies/stdblocks/prbs_lib/*.vhd")
stdblocks_filelist = stdblocks_filelist + glob.glob("../dependencies/stdblocks/scheduler_lib/*.vhd")
for vhd_file in stdblocks_filelist:
    if "_tb" not in vhd_file:
        stdblocks.add_source_files(vhd_file)

stdcores = vu.add_library("stdcores")
stdcores.add_source_files(join(root, "./*.vhd"))
test_tb = stdcores.entity("axis_mux_tb")
test_tb.scan_tests_from_file(join(root, "axis_mux_tb.vhd"))

vu.main()
