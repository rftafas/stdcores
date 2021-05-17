
Register Bank: can_aximm
========================

# Details
  
Data Width: 32  
Number of registers: 18  
Version: v20210517_1405  
Register Bank auto-generated using the hdltools/regbank_gen.py  

# List of Registers
  

## Register 0: Golden
  
Address: 0x0 | 0   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|g1|ReadOnly|0x0|Reference register for READ_ONLY|

## Register 1: Config 1
  
Address: 0x4 | 4   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|iso_mode|ReadWrite|0x0|Reserved for ISO Modes compatibility. Not Implemented.|
|1|fd_enable|ReadWrite|0x0|Reserved for ISO Modes compatibility. Not Implemented.|
|8|promiscuous|ReadWrite|0x0|Promiscuous mode Enable. Will receive and acknowledge any frames with any ID.|

## Register 2: Config 1
  
Address: 0x8 | 8   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|15-0|sample_rate|ReadWrite|0x0|Sample rate configuration in multiples of 1kHz. Starts with 0kHz.|

## Register 3: IRQ
  
Address: 0xc | 12   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|rx_irq|Write2Clear|0x0||
|1|rx_irq_mask|ReadWrite|0x0||
|8|tx_irq|Write2Clear|0x0||
|9|tx_irq_mask|ReadWrite|0x0||

## Register 4: Line Status
  
Address: 0x10 | 16   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|stuff_violation|Write2Clear|0x0||
|1|collision|Write2Clear|0x0||
|8|channel_ready|ReadOnly|0x0||

## Register 7: TEST Control 1
  
Address: 0x1c | 28   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|loop_enable|ReadWrite|0x0||
|8|insert_error|Write2Pulse|0x0||
|16|force_dominant|ReadWrite|0x0||

## Register 8: RX STATUS
  
Address: 0x20 | 32   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|rx_data_valid|Write2Clear|0x0||
|1|rx_read_done|Write2Pulse|0x0||
|8|rx_busy|ReadOnly|0x0||
|9|rx_crc_error|ReadOnly|0x0||
|16|rx_rtr|ReadOnly|0x0||
|24|rx_ide|ReadOnly|0x0||
|26-25|rx_reserved|ReadOnly|0x0||

## Register 9: ID Filter 1
  
Address: 0x24 | 36   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|id1|ReadWrite|0x0||

## Register 10: ID Filter 1 MASK
  
Address: 0x28 | 40   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|id1_mask|ReadWrite|0x0||

## Register 11: RX DLC
  
Address: 0x2c | 44   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|3-0|rx_size|ReadOnly|0x0||

## Register 12: RX ID
  
Address: 0x30 | 48   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|rx_id|ReadOnly|0x0||

## Register 13: RX DATA0
  
Address: 0x34 | 52   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|rx_data0|ReadOnly|0x0||

## Register 14: RX DATA1
  
Address: 0x38 | 56   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|rx_data1|ReadOnly|0x0||

## Register 16: TX STATUS
  
Address: 0x40 | 64   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|tx_ready|ReadOnly|0x0||
|1|tx_valid|Write2Pulse|0x0||
|8|tx_busy|ReadOnly|0x0||
|9|tx_arb_lost|Write2Clear|0x0||
|10|tx_retry_error|Write2Clear|0x0||
|16|tx_rtr|ReadWrite|0x0||
|24|tx_eff|ReadWrite|0x0||
|26-25|tx_reserved|ReadWrite|0x0||

## Register 17: TX DLC
  
Address: 0x44 | 68   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|3-0|tx_dlc|ReadWrite|0x0||

## Register 18: TX ID
  
Address: 0x48 | 72   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|tx_id|ReadWrite|0x0||

## Register 19: TX DATA0
  
Address: 0x4c | 76   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|tx_data0|ReadWrite|0x0||

## Register 20: TX DATA1
  
Address: 0x50 | 80   

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|tx_data1|ReadWrite|0x0||
  
  
hdltools available at https://github.com/rftafas/hdltools.