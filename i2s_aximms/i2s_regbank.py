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
import sys
import os
import hdltools

i2s_regbank = hdltools.RegisterBank("i2s_regbank", "rtl", 32, 32)

# REG0
i2s_regbank.add(0, "Golden")
# REG0 FIELDS
i2s_regbank.reg[0].add("g1", "ReadOnly", 0, 32)
i2s_regbank.reg[0][0].addDescription("Reference register for READ_ONLY")

# REG1
i2s_regbank.add(1, "Config_1")
# REG1 FIELDS
i2s_regbank.reg[1].add("bclk_edge", "ReadWrite", 0, 1)
i2s_regbank.reg[1][0].addDescription("Sets BCLK edge. Default is sample on RISING, data is sent on FALLING.")
i2s_regbank.reg[1].add("lrclk_polarity", "ReadWrite", 1, 1)
i2s_regbank.reg[1][1].addDescription("Sets LRCLK cycle polarity. Default is 0 to 1.")
i2s_regbank.reg[1].add("lrclk_justified", "ReadWrite", 2, 1)
i2s_regbank.reg[1][2].addDescription("Sets LRCLK alignment to BCLK. Deafault is shifted by 1 bclk. Justified option is 0 bclk.")

i2s_regbank.reg[1].add("frame_size", "ReadWrite", 8, 3)
i2s_regbank.reg[1][8].addDescription("""
Sets the frame size in bits. Possible Values:
000 - 16bits (8 bit / channel )
001 - 32bits (16 bit / channel )
010 - 48bits (24 bit / channel )
011 - 64bits (32 bit / channel )

Obs: Sample Rate is ICLK/frame_size.
""")
i2s_regbank.reg[1].add("clock_source", "ReadWrite", 16, 2)
i2s_regbank.reg[1][16].addDescription("""
Sets the clock source. Possible Values:
00 - Internal NCO. Sampling Frequency is autogenerated using Register 1 (Sample Frequency field).
01 - Integer divider of Ref clock. Division Value using Register 2.
10 - Fractional ADPLL of Ref Clock. Multiply/Division Values using Register 2.
11 - Use BCLK_i as reference. BCLK can be connected on cascade mode (other I2S IP) or from external I2S device.

Obs: Generic configuration must be enabled for a chosen mode.
""")

i2s_regbank.reg[1].add("sample_rate", "ReadWrite", 24, 3)
i2s_regbank.reg[1][24].addDescription("""
Sets the Sample Frequency for the Internal Clock Generator. Possible Values (kHz):
--000 - 48
--001 -  8
--010 - 16
--011 - 24
--100 - 32
--101 - 64
--110 - 96
--111 - 44.1

Obs: Valid only for the Internal Clock. For ADPLL and Integer Divider, check Register 2.
""")

# REG2
i2s_regbank.add(2, "adpll_intdiv_reg")
# REG2 FIELDS
i2s_regbank.reg[2].add("ref_div", "ReadWrite", 0, 16)
i2s_regbank.reg[2][0].addDescription("Sets the M value for ADPLL or Int Divider, Output Clock is N*REfCLK/M")
i2s_regbank.reg[2].add("ref_mult", "ReadWrite", 16, 16)
i2s_regbank.reg[2][16].addDescription("Sets the N value for the ADPLL, Output Clock is N*REfCLK/M")


# REG_3
i2s_regbank.add(3, "Status_IRQ_Map")
# REG_3 FIELDS
i2s_regbank.reg[3].add("rxfull_irq", "ReadOnly", 0, 1)
i2s_regbank.reg[3][0].addDescription("Signals incoming fifo is full.")
i2s_regbank.reg[3].add("txempty_irq", "ReadOnly", 1, 1)
i2s_regbank.reg[3][1].addDescription("Signals outcoming fifo is empty.")
i2s_regbank.reg[3].add("bclk_err_irq", "ReadOnly", 2, 1)
i2s_regbank.reg[3][2].addDescription("BCLK not detected. Depends on Generic.")
i2s_regbank.reg[3].add("lrclk_err_irq", "ReadOnly", 3, 1)
i2s_regbank.reg[3][3].addDescription("LRCLK not detected. Depends on Generic.")
i2s_regbank.reg[3].add("rxfull_irq_mask", "ReadWrite", 8, 1)
i2s_regbank.reg[3][8].addDescription("Enables rxfull_irq.")
i2s_regbank.reg[3].add("txempty_irq_mask", "ReadWrite", 9, 1)
i2s_regbank.reg[3][9].addDescription("Enables txempty_irq.")
i2s_regbank.reg[3].add("bclk_err_irq_mask", "ReadWrite", 10, 1)
i2s_regbank.reg[3][10].addDescription("Enables bclk_err_irq.")
i2s_regbank.reg[3].add("lrclk_err_irq_mask", "ReadWrite", 11, 1)
i2s_regbank.reg[3][11].addDescription("Enables lrclk_err_irq.")
i2s_regbank.reg[3].add("rx_fifo_status", "ReadOnly", 24, 2)
i2s_regbank.reg[3][24].addDescription('''
RX Fifo Status
00 - ok.
01 - full
10 - empty
''')
i2s_regbank.reg[3].add("tx_fifo_status", "ReadOnly", 28, 2)
i2s_regbank.reg[3][28].addDescription('''
TX Fifo Status
00 - ok.
01 - full
10 - empty
''')

# REG_6
i2s_regbank.add(6, "Left_Data_Channel")
# REG_6 FIELDS
i2s_regbank.reg[6].add("i2s_mm_left", "SplitReadWrite", 0, 32)
i2s_regbank.reg[6][0].addDescription("Left Channel data for MM channel Read from FIFO, write to FIFO.")
i2s_regbank.reg[6][0].activitySignal = True

# REG_7
i2s_regbank.add(7, "Right_Data_Channel")
# REG_7 FIELDS
i2s_regbank.reg[7].add("i2s_mm_right", "SplitReadWrite", 0, 32)
i2s_regbank.reg[7][0].addDescription("Right Channel data for MM channel Read from FIFO, write to FIFO.")
i2s_regbank.reg[7][0].activitySignal = True

i2s_regbank()
