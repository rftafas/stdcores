
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
vu.add_osvvm()
vu.add_verification_components()

try:
    expert = vu.add_library("expert")
    expert.add_source_files(join(root, "stdexpert/src/*.vhd"))
except:
    print("Missing std_logic_expert. Please, run:")
    print("git clone https://github.com/rftafas/stdexpert.git")
    exit()

lib = vu.add_library("can_aximm")
lib.add_source_files(join(root, "./*.vhd"))
test_tb = lib.entity("can_aximm_tb")
test_tb.scan_tests_from_file(join(root, "can_aximm_tb.vhd"))

test_tb.add_config(
    name="run_time",
    generics=dict(run_time=100)
)

vu.main()
