from os.path import join, dirname
import sys

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
stdblocks.add_source_files(join(root, "../dependencies/stdblocks/sync_lib/*.vhd"))
stdblocks.add_source_files(join(root, "../dependencies/stdblocks/ram_lib/*.vhd"))
stdblocks.add_source_files(join(root, "../dependencies/stdblocks/fifo_lib/*.vhd"))
stdblocks.add_source_files(join(root, "../dependencies/stdblocks/prbs_lib/*.vhd"))

stdcores = vu.add_library("stdcores")
stdcores.add_source_files(join(root, "./*.vhd"))
test_tb = stdcores.entity("axis_reg_tb")
test_tb.scan_tests_from_file(join(root, "axis_reg_tb.vhd"))

vu.main()
