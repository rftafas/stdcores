import sys
import os
import hdltools

can_aximm = hdltools.RegisterBank("can_aximm", "rtl", 32, 32)

# REG0
can_aximm.add(0, "Golden")
# REG0 FIELDS
can_aximm.reg[0].add("g1", "ReadOnly", 0, 32)

# REG1
can_aximm.add(1, "Config 1")
# REG1 FIELDS
can_aximm.reg[1].add("iso_mode", "ReadWrite", 0, 1)
can_aximm.reg[1].add("fd_enable", "ReadWrite", 1, 1)

# REG2
can_aximm.add(2, "Config 1")
# REG2 FIELDS
can_aximm.reg[2].add("sample_rate", "ReadWrite", 0, 16)

# REG_3
can_aximm.add(3, "IRQ")
# REG_3 FIELDS
can_aximm.reg[3].add("rx_irq", "Write2Clear", 0, 1)
can_aximm.reg[3].add("rx_irq_mask", "ReadWrite", 1, 1)
can_aximm.reg[3].add("tx_irq", "Write2Clear", 8, 1)
can_aximm.reg[3].add("tx_irq_mask", "ReadWrite", 9, 1)

# REG_4
can_aximm.add(4, "Line Status")
# REG_4 FIELDS
can_aximm.reg[4].add("stuff_violation", "Write2Clear", 0, 1)
can_aximm.reg[4].add("collision", "Write2Clear", 1, 1)
can_aximm.reg[4].add("channel_ready", "ReadOnly", 8, 1)

# REG_7
can_aximm.add(7, "TEST Control 1")
# REG_7 FIELDS
can_aximm.reg[7].add("loop_enable", "ReadWrite", 0, 1)
can_aximm.reg[7].add("insert_error", "Write2Pulse", 8, 1)
can_aximm.reg[7].add("force_dominant", "ReadWrite", 16, 1)

# REG_8s
can_aximm.add(8, "RX STATUS")
# REG_8 FIELDS
can_aximm.reg[8].add("rx_data_valid", "Write2Clear", 0, 1)
can_aximm.reg[8].add("rx_read_done", "Write2Pulse", 1, 1)
can_aximm.reg[8].add("rx_busy", "ReadOnly", 8, 1)
can_aximm.reg[8].add("rx_crc_error", "ReadOnly", 9, 1)
can_aximm.reg[8].add("rx_rtr", "ReadOnly", 16, 1)
can_aximm.reg[8].add("rx_ide", "ReadOnly", 24, 1)
can_aximm.reg[8].add("rx_reserved", "ReadOnly", 25, 2)

# REG_9
can_aximm.add(9, "ID Filter 1")
# REG_9 FIELDS
can_aximm.reg[9].add("id1", "ReadWrite", 0, 29)

# REG_10
can_aximm.add(10, "ID Filter 1 MASK")
# REG_10 FIELDS
can_aximm.reg[10].add("id1_mask", "ReadWrite", 0, 29)

# REG_11
can_aximm.add(11, "RX DLC")
# REG_11 FIELDS
can_aximm.reg[11].add("rx_size", "ReadOnly", 0, 4)

# REG_12
can_aximm.add(12, "RX ID")
# REG_12 FIELDS
can_aximm.reg[12].add("rx_id", "ReadOnly", 0, 29)

# REG_13
can_aximm.add(13, "RX DATA0")
# REG_13 FIELDS
can_aximm.reg[13].add("rx_data0", "ReadOnly", 0, 32)

# REG14
can_aximm.add(14, "RX DATA1")
# REG14 FIELDS
can_aximm.reg[14].add("rx_data1", "ReadOnly", 0, 32)

# REG_16
can_aximm.add(16, "TX STATUS")
# REG_16 FIELDS
can_aximm.reg[16].add("tx_ready", "ReadOnly", 0, 1)
can_aximm.reg[16].add("tx_valid", "Write2Pulse", 1, 1)
can_aximm.reg[16].add("tx_busy", "ReadOnly", 8, 1)
can_aximm.reg[16].add("tx_arb_lost", "Write2Clear", 9, 1)
can_aximm.reg[16].add("tx_retry_error", "Write2Clear", 10, 1)
can_aximm.reg[16].add("tx_rtr", "ReadWrite", 16, 1)
can_aximm.reg[16].add("tx_eff", "ReadWrite", 24, 1)
can_aximm.reg[16].add("tx_reserved", "ReadWrite", 25, 2)

# REG_17
can_aximm.add(17, "TX DLC")
# REG_17 FIELDS
can_aximm.reg[17].add("tx_dlc", "ReadWrite", 0, 4)

# REG_18
can_aximm.add(18, "TX ID")
# REG_18 FIELDS
can_aximm.reg[18].add("tx_id", "ReadWrite", 0, 29)

# REG_19
can_aximm.add(19, "TX DATA0")
# REG_19 FIELDS
can_aximm.reg[19].add("tx_data0", "ReadWrite", 0, 32)

# REG_20
can_aximm.add(20, "TX DATA1")
# REG_20 FIELDS
can_aximm.reg[20].add("tx_data1", "ReadWrite", 0, 32)

can_aximm()
