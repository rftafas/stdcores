# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

"""
JSON-for-VHDL
-------------

Demonstrates the ``JSON-for-VHDL`` library which can be used to parse JSON content.
The content can be read from a file, or passed as a stringified generic.
This is an alternative to composite generics, that supports any depth in the content structure.
"""

from os.path import join, dirname
from vunit import VUnit, read_json, encode_json

root = dirname(__file__)

vu = VUnit.from_argv()

lib = vu.add_library("test")
lib.add_source_files(join(root, "../hdl/*.vhd"))
lib.add_source_files(join(root, "../src/*.vhd"))
#lib.add_source_files(join(root, "../src/*.vhd"))

if __name__ == '__main__':
    vu.main()
