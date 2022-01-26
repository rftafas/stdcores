#--------------------------------------------------------------------------------
# Copyright 2022 Ricardo F Tafas Jr
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied. See the License for
# the specific language governing permissions and limitations under the License.
#--------------------------------------------------------------------------------
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
