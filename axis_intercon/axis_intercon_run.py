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
stdcores_filelist = glob.glob("../axis_mux/*.vhd")
stdcores_filelist = stdcores_filelist + glob.glob("../axis_demux/*.vhd")
for vhd_file in stdcores_filelist:
    if "_tb" not in vhd_file:
        stdcores.add_source_files(vhd_file)

stdcores.add_source_files(join(root, "./*.vhd"))

test_tb = stdcores.entity("axis_intercon_tb")
test_tb.scan_tests_from_file(join(root, "axis_intercon_tb.vhd"))

vu.main()
