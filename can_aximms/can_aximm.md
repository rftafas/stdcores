
Register Bank: can_aximm
========================

# Details

Data Width: 32
Number of registers: 18
Version: v20210524_1005
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
|0|rx_data_irq|Write2Clear|0x0|Signals Receive Data IRQ.|
|1|rx_error_irq|Write2Clear|0x0|Signals Receive Error IRQ.|
|8|tx_data_irq|Write2Clear|0x0|Sample rate configuration in multiples of 1kHz. Starts with 0kHz.|
|9|tx_error_irq|Write2Clear|0x0|Sample rate configuration in multiples of 1kHz. Starts with 0kHz.|
|16|rx_data_mask|ReadWrite|0x0|Enable rx_data_irq.|
|17|rx_error_mask|ReadWrite|0x0|Enable rx_error_irq.|
|24|tx_data_mask|Write2Clear|0x0|Enable tx_data_irq.|
|25|tx_error_mask|ReadWrite|0x0|Enable tx_error_irq.|

## Register 4: Line Status

Address: 0x10 | 16

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|stuff_violation|Write2Clear|0x0|Detected 6 consecutive bits and missing of stuff bit.|
|1|collision|Write2Clear|0x0|Signals detection onf TX data different from RX Data.|
|8|channel_ready|ReadOnly|0x0|Signals CAN bus is not being used.|

## Register 7: TEST Control 1

Address: 0x1c | 28

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|loop_enable|ReadWrite|0x0|Creates an internal loop between TX and RX.|
|8|insert_error|Write2Pulse|0x0|Inserts an TX CLK aligned error (inverts current bit).|
|16|force_dominant|ReadWrite|0x0|Forces CAN Bus to dominant signal.|

## Register 8: RX STATUS

Address: 0x20 | 32

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|rx_data_valid|Write2Clear|0x0|Valid RX data available.|
|1|rx_read_done|Write2Pulse|0x0|Informs the CAN Controller that current data was read. When written, it will update all frame related information.|
|8|rx_busy|ReadOnly|0x0|Can Controller is receiving data.|
|9|rx_crc_error|ReadOnly|0x0|CRC Error on last received frame.|
|16|rx_rtr|ReadOnly|0x0|RTR Value received with current data.|
|24|rx_ide|ReadOnly|0x0|IDE Value received with current data.|
|26-25|rx_reserved|ReadOnly|0x0|Reserved bits received with current data.|

## Register 9: ID Filter 1

Address: 0x24 | 36

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|id1|ReadWrite|0x0|ID value to consider RX Frame. For 11 bits, use [10-0].|

## Register 10: ID Filter 1 MASK

Address: 0x28 | 40

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|id1_mask|ReadWrite|0x0|MASK to evaluate ID bits. For 11 bits, use [10-0].|

## Register 11: RX DLC

Address: 0x2c | 44

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|3-0|rx_size|ReadOnly|0x0|Current frame DLC content.|

## Register 12: RX ID

Address: 0x30 | 48

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|rx_id|ReadOnly|0x0|Current frame ID content. For 11 bits, use [10-0].|

## Register 13: RX DATA0

Address: 0x34 | 52

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|rx_data0|ReadOnly|0x0|RX Data Bytes 3 (31 downto 24) to 0 (7 downto 0).|

## Register 14: RX DATA1

Address: 0x38 | 56

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|rx_data1|ReadOnly|0x0|RX Data Bytes 7 (31 downto 24) to 4 (7 downto 0).|

## Register 16: TX STATUS

Address: 0x40 | 64

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|0|tx_ready|ReadOnly|0x0|TX Channel is ready to receive new data for transmission.|
|1|tx_valid|Write2Pulse|0x0|Send data, start sending data when channel is ready. Will use all frame related registers.|
|8|tx_busy|ReadOnly|0x0|TX Controller is sending data.|
|9|tx_arb_lost|Write2Clear|0x0|TX arbitration lost detected. Will retry other 7 times.|
|10|tx_retry_error|Write2Clear|0x0|All retries failed, aborting.|
|16|tx_rtr|ReadWrite|0x0|RTR value to be sent with current frame.|
|24|tx_eff|ReadWrite|0x0|IDE Value to be sent with current frame.|
|26-25|tx_reserved|ReadWrite|0x0|Reserved bits value to be sent with current frame.|

## Register 17: TX DLC

Address: 0x44 | 68

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|3-0|tx_dlc|ReadWrite|0x0|TX DLC for current frame. If '0000', no data is sent. If '1111' will transmit 8 bytes max (behave like '1000').|

## Register 18: TX ID

Address: 0x48 | 72

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|28-0|tx_id|ReadWrite|0x0|TX ID to be sent with current frame.|

## Register 19: TX DATA0

Address: 0x4c | 76

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|tx_data0|ReadWrite|0x0|TX Data Bytes 3 (31 downto 24) to 0 (7 downto 0).|

## Register 20: TX DATA1

Address: 0x50 | 80

|Bit|Field|Type|Reset|Description|
| :---: | :---: | :---: | :---: | :---: |
|31-0|tx_data1|ReadWrite|0x0|TX Data Bytes 7 (31 downto 24) to 4 (7 downto 0).|


hdltools available at https://github.com/rftafas/hdltools.