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

can_aximm = hdltools.RegisterBank("can_aximm", "rtl", 32, 32)

# REG0
can_aximm.add(0, "Golden")
# REG0 FIELDS
can_aximm.reg[0].add("g1", "ReadOnly", 0, 32)
can_aximm.reg[0][0].addDescription("Reference register for READ_ONLY")
# REG1
can_aximm.add(1, "Config_1")
# REG1 FIELDS
can_aximm.reg[1].add("iso_mode", "ReadWrite", 0, 1)
can_aximm.reg[1][0].addDescription("Reserved for ISO Modes compatibility. Not Implemented.")

can_aximm.reg[1].add("fd_enable", "ReadWrite", 1, 1)
can_aximm.reg[1][1].addDescription("Reserved for ISO Modes compatibility. Not Implemented.")

can_aximm.reg[1].add("promiscuous", "ReadWrite", 8, 1)
can_aximm.reg[1][8].addDescription("Promiscuous mode Enable. Will receive and acknowledge any frames with any ID.")

# REG2
can_aximm.add(2, "Config_2")
# REG2 FIELDS
can_aximm.reg[2].add("sample_rate", "ReadWrite", 0, 16)
can_aximm.reg[2][0].addDescription("Sample rate configuration in multiples of 1kHz. Starts with 0kHz.")


# REG_3
can_aximm.add(3, "IRQ")
# REG_3 FIELDS
can_aximm.reg[3].add("rx_data_irq", "Write2Clear", 0, 1)
can_aximm.reg[3][0].addDescription("Signals Receive Data IRQ.")
can_aximm.reg[3].add("rx_error_irq", "Write2Clear", 1, 1)
can_aximm.reg[3][1].addDescription("Signals Receive Error IRQ.")
can_aximm.reg[3].add("tx_data_irq", "Write2Clear", 8, 1)
can_aximm.reg[3][8].addDescription("Sample rate configuration in multiples of 1kHz. Starts with 0kHz.")
can_aximm.reg[3].add("tx_error_irq", "Write2Clear", 9, 1)
can_aximm.reg[3][9].addDescription("Sample rate configuration in multiples of 1kHz. Starts with 0kHz.")
can_aximm.reg[3].add("rx_data_mask", "ReadWrite", 16, 1)
can_aximm.reg[3][16].addDescription("Enable rx_data_irq.")
can_aximm.reg[3].add("rx_error_mask", "ReadWrite", 17, 1)
can_aximm.reg[3][17].addDescription("Enable rx_error_irq.")
can_aximm.reg[3].add("tx_data_mask", "ReadWrite", 24, 1)
can_aximm.reg[3][24].addDescription("Enable tx_data_irq.")
can_aximm.reg[3].add("tx_error_mask", "ReadWrite", 25, 1)
can_aximm.reg[3][25].addDescription("Enable tx_error_irq.")

# REG_4
can_aximm.add(4, "Line_Status")
# REG_4 FIELDS
can_aximm.reg[4].add("stuff_violation", "Write2Clear", 0, 1)
can_aximm.reg[4][0].addDescription("Detected 6 consecutive bits and missing of stuff bit.")
can_aximm.reg[4].add("collision", "Write2Clear", 1, 1)
can_aximm.reg[4][1].addDescription("Signals detection onf TX data different from RX Data.")
can_aximm.reg[4].add("channel_ready", "ReadOnly", 8, 1)
can_aximm.reg[4][8].addDescription("Signals CAN bus is not being used.")

# REG_7
can_aximm.add(7, "TEST_Control")
# REG_7 FIELDS
can_aximm.reg[7].add("loop_enable", "ReadWrite", 0, 1)
can_aximm.reg[7][0].addDescription("Creates an internal loop between TX and RX.")
can_aximm.reg[7].add("insert_error", "Write2Pulse", 8, 1)
can_aximm.reg[7][8].addDescription("Inserts an TX CLK aligned error (inverts current bit).")
can_aximm.reg[7].add("force_dominant", "ReadWrite", 16, 1)
can_aximm.reg[7][16].addDescription("Forces CAN Bus to dominant signal.")

# REG_8s
can_aximm.add(8, "RX_STATUS")
# REG_8 FIELDS
can_aximm.reg[8].add("rx_data_valid", "Write2Clear", 0, 1)
can_aximm.reg[8][0].addDescription("Valid RX data available.")
can_aximm.reg[8].add("rx_read_done", "Write2Pulse", 1, 1)
can_aximm.reg[8][1].addDescription("Informs the CAN Controller that current data was read. When written, it will update all frame related information.")
can_aximm.reg[8].add("rx_busy", "ReadOnly", 8, 1)
can_aximm.reg[8][8].addDescription("Can Controller is receiving data.")
can_aximm.reg[8].add("rx_crc_error", "ReadOnly", 9, 1)
can_aximm.reg[8][9].addDescription("CRC Error on last received frame.")
can_aximm.reg[8].add("rx_rtr", "ReadOnly", 16, 1)
can_aximm.reg[8][16].addDescription("RTR Value received with current data.")
can_aximm.reg[8].add("rx_ide", "ReadOnly", 24, 1)
can_aximm.reg[8][24].addDescription("IDE Value received with current data.")
can_aximm.reg[8].add("rx_reserved", "ReadOnly", 25, 2)
can_aximm.reg[8][25].addDescription("Reserved bits received with current data.")


# REG_9
can_aximm.add(9, "ID_Filter")
# REG_9 FIELDS
can_aximm.reg[9].add("id1", "ReadWrite", 0, 29)
can_aximm.reg[9][0].addDescription("ID value to consider RX Frame. For 11 bits, use [10-0].")

# REG_10
can_aximm.add(10, "ID_Filter_MASK")
# REG_10 FIELDS
can_aximm.reg[10].add("id1_mask", "ReadWrite", 0, 29)
can_aximm.reg[10][0].addDescription("MASK to evaluate ID bits. For 11 bits, use [10-0].")

# REG_11
can_aximm.add(11, "RX_DLC")
# REG_11 FIELDS
can_aximm.reg[11].add("rx_size", "ReadOnly", 0, 4)
can_aximm.reg[11][0].addDescription("Current frame DLC content.")


# REG_12
can_aximm.add(12, "RX_ID")
# REG_12 FIELDS
can_aximm.reg[12].add("rx_id", "ReadOnly", 0, 29)
can_aximm.reg[12][0].addDescription("Current frame ID content. For 11 bits, use [10-0].")

# REG_13
can_aximm.add(13, "RX_DATA0")
# REG_13 FIELDS
can_aximm.reg[13].add("rx_data0", "ReadOnly", 0, 32)
can_aximm.reg[13][0].addDescription("RX Data Bytes 3 (31 downto 24) to 0 (7 downto 0).")

# REG14
can_aximm.add(14, "RX_DATA1")
# REG14 FIELDS
can_aximm.reg[14].add("rx_data1", "ReadOnly", 0, 32)
can_aximm.reg[14][0].addDescription("RX Data Bytes 7 (31 downto 24) to 4 (7 downto 0).")


# REG_16
can_aximm.add(16, "TX_STATUS")
# REG_16 FIELDS
can_aximm.reg[16].add("tx_ready", "ReadOnly", 0, 1)
can_aximm.reg[16][0].addDescription("TX Channel is ready to receive new data for transmission.")
can_aximm.reg[16].add("tx_valid", "Write2Pulse", 1, 1)
can_aximm.reg[16][1].addDescription("Send data, start sending data when channel is ready. Will use all frame related registers.")
can_aximm.reg[16].add("tx_busy", "ReadOnly", 8, 1)
can_aximm.reg[16][8].addDescription("TX Controller is sending data.")
can_aximm.reg[16].add("tx_arb_lost", "Write2Clear", 9, 1)
can_aximm.reg[16][9].addDescription("TX arbitration lost detected. Will retry other 7 times.")
can_aximm.reg[16].add("tx_retry_error", "Write2Clear", 10, 1)
can_aximm.reg[16][10].addDescription("All retries failed, aborting.")
can_aximm.reg[16].add("tx_rtr", "ReadWrite", 16, 1)
can_aximm.reg[16][16].addDescription("RTR value to be sent with current frame.")
can_aximm.reg[16].add("tx_eff", "ReadWrite", 24, 1)
can_aximm.reg[16][24].addDescription("IDE Value to be sent with current frame.")
can_aximm.reg[16].add("tx_reserved", "ReadWrite", 25, 2)
can_aximm.reg[16][25].addDescription("Reserved bits value to be sent with current frame.")

# REG_17
can_aximm.add(17, "TX_DLC")
# REG_17 FIELDS
can_aximm.reg[17].add("tx_dlc", "ReadWrite", 0, 4)
can_aximm.reg[17][0].addDescription("TX DLC for current frame. If '0000', no data is sent. If '1111' will transmit 8 bytes max (behave like '1000').")


# REG_18
can_aximm.add(18, "TX_ID")
# REG_18 FIELDS
can_aximm.reg[18].add("tx_id", "ReadWrite", 0, 29)
can_aximm.reg[18][0].addDescription("TX ID to be sent with current frame.")


# REG_19
can_aximm.add(19, "TX_DATA0")
# REG_19 FIELDS
can_aximm.reg[19].add("tx_data0", "ReadWrite", 0, 32)
can_aximm.reg[19][0].addDescription("TX Data Bytes 3 (31 downto 24) to 0 (7 downto 0).")


# REG_20
can_aximm.add(20, "TX_DATA1")
# REG_20 FIELDS
can_aximm.reg[20].add("tx_data1", "ReadWrite", 0, 32)
can_aximm.reg[20][0].addDescription("TX Data Bytes 7 (31 downto 24) to 4 (7 downto 0).")


can_aximm()
