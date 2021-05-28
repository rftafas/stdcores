/*
 This is free and unencumbered software released into the public domain.

 Anyone is free to copy, modify, publish, use, compile, sell, or
 distribute this software, either in source code form or as a compiled
 binary, for any purpose, commercial or non-commercial, and by any
 means.

 In jurisdictions that recognize copyright laws, the author or authors
 of this software dedicate any and all copyright interest in the
 software to the public domain. We make this dedication for the benefit
 of the public at large and to the detriment of our heirs and
 successors. We intend this dedication to be an overt act of
 relinquishment in perpetuity of all present and future rights to this
 software under copyright law.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.

 For more information, please refer to <http://unlicense.org/>
*/
#ifndef CAN_AXIMM_H
#define CAN_AXIMM_H

/*This auto-generated header file was created using hdltools. File version:*/
#define CAN_AXIMM_VERSION "20210528_1505"

/*Register Golden address */
#define GOLDEN_OFFSET 0x0
/*Register Golden field g1 */
#define GOLDEN_G1_FIELD_OFFSET 0
#define GOLDEN_G1_FIELD_WIDTH 32
#define GOLDEN_G1_FIELD_MASK 0xffffffff
#define GOLDEN_G1_RESET 0x0

/*Register Config_1 address */
#define CONFIG_1_OFFSET 0x1
/*Register Config_1 field iso_mode */
#define CONFIG_1_ISO_MODE_FIELD_OFFSET 0
#define CONFIG_1_ISO_MODE_FIELD_WIDTH 1
#define CONFIG_1_ISO_MODE_FIELD_MASK 0x1
#define CONFIG_1_ISO_MODE_RESET 0x0
/*Register Config_1 field fd_enable */
#define CONFIG_1_FD_ENABLE_FIELD_OFFSET 1
#define CONFIG_1_FD_ENABLE_FIELD_WIDTH 1
#define CONFIG_1_FD_ENABLE_FIELD_MASK 0x2
#define CONFIG_1_FD_ENABLE_RESET 0x0
/*Register Config_1 field promiscuous */
#define CONFIG_1_PROMISCUOUS_FIELD_OFFSET 8
#define CONFIG_1_PROMISCUOUS_FIELD_WIDTH 1
#define CONFIG_1_PROMISCUOUS_FIELD_MASK 0x100
#define CONFIG_1_PROMISCUOUS_RESET 0x0

/*Register Config_2 address */
#define CONFIG_2_OFFSET 0x2
/*Register Config_2 field sample_rate */
#define CONFIG_2_SAMPLE_RATE_FIELD_OFFSET 0
#define CONFIG_2_SAMPLE_RATE_FIELD_WIDTH 16
#define CONFIG_2_SAMPLE_RATE_FIELD_MASK 0xffff
#define CONFIG_2_SAMPLE_RATE_RESET 0x0

/*Register IRQ address */
#define IRQ_OFFSET 0x3
/*Register IRQ field rx_data_irq */
#define IRQ_RX_DATA_IRQ_FIELD_OFFSET 0
#define IRQ_RX_DATA_IRQ_FIELD_WIDTH 1
#define IRQ_RX_DATA_IRQ_FIELD_MASK 0x1
#define IRQ_RX_DATA_IRQ_RESET 0x0
/*Register IRQ field rx_error_irq */
#define IRQ_RX_ERROR_IRQ_FIELD_OFFSET 1
#define IRQ_RX_ERROR_IRQ_FIELD_WIDTH 1
#define IRQ_RX_ERROR_IRQ_FIELD_MASK 0x2
#define IRQ_RX_ERROR_IRQ_RESET 0x0
/*Register IRQ field tx_data_irq */
#define IRQ_TX_DATA_IRQ_FIELD_OFFSET 8
#define IRQ_TX_DATA_IRQ_FIELD_WIDTH 1
#define IRQ_TX_DATA_IRQ_FIELD_MASK 0x100
#define IRQ_TX_DATA_IRQ_RESET 0x0
/*Register IRQ field tx_error_irq */
#define IRQ_TX_ERROR_IRQ_FIELD_OFFSET 9
#define IRQ_TX_ERROR_IRQ_FIELD_WIDTH 1
#define IRQ_TX_ERROR_IRQ_FIELD_MASK 0x200
#define IRQ_TX_ERROR_IRQ_RESET 0x0
/*Register IRQ field rx_data_mask */
#define IRQ_RX_DATA_MASK_FIELD_OFFSET 16
#define IRQ_RX_DATA_MASK_FIELD_WIDTH 1
#define IRQ_RX_DATA_MASK_FIELD_MASK 0x10000
#define IRQ_RX_DATA_MASK_RESET 0x0
/*Register IRQ field rx_error_mask */
#define IRQ_RX_ERROR_MASK_FIELD_OFFSET 17
#define IRQ_RX_ERROR_MASK_FIELD_WIDTH 1
#define IRQ_RX_ERROR_MASK_FIELD_MASK 0x20000
#define IRQ_RX_ERROR_MASK_RESET 0x0
/*Register IRQ field tx_data_mask */
#define IRQ_TX_DATA_MASK_FIELD_OFFSET 24
#define IRQ_TX_DATA_MASK_FIELD_WIDTH 1
#define IRQ_TX_DATA_MASK_FIELD_MASK 0x1000000
#define IRQ_TX_DATA_MASK_RESET 0x0
/*Register IRQ field tx_error_mask */
#define IRQ_TX_ERROR_MASK_FIELD_OFFSET 25
#define IRQ_TX_ERROR_MASK_FIELD_WIDTH 1
#define IRQ_TX_ERROR_MASK_FIELD_MASK 0x2000000
#define IRQ_TX_ERROR_MASK_RESET 0x0

/*Register Line_Status address */
#define LINE_STATUS_OFFSET 0x4
/*Register Line_Status field stuff_violation */
#define LINE_STATUS_STUFF_VIOLATION_FIELD_OFFSET 0
#define LINE_STATUS_STUFF_VIOLATION_FIELD_WIDTH 1
#define LINE_STATUS_STUFF_VIOLATION_FIELD_MASK 0x1
#define LINE_STATUS_STUFF_VIOLATION_RESET 0x0
/*Register Line_Status field collision */
#define LINE_STATUS_COLLISION_FIELD_OFFSET 1
#define LINE_STATUS_COLLISION_FIELD_WIDTH 1
#define LINE_STATUS_COLLISION_FIELD_MASK 0x2
#define LINE_STATUS_COLLISION_RESET 0x0
/*Register Line_Status field channel_ready */
#define LINE_STATUS_CHANNEL_READY_FIELD_OFFSET 8
#define LINE_STATUS_CHANNEL_READY_FIELD_WIDTH 1
#define LINE_STATUS_CHANNEL_READY_FIELD_MASK 0x100
#define LINE_STATUS_CHANNEL_READY_RESET 0x0

/*Register TEST_Control address */
#define TEST_CONTROL_OFFSET 0x7
/*Register TEST_Control field loop_enable */
#define TEST_CONTROL_LOOP_ENABLE_FIELD_OFFSET 0
#define TEST_CONTROL_LOOP_ENABLE_FIELD_WIDTH 1
#define TEST_CONTROL_LOOP_ENABLE_FIELD_MASK 0x1
#define TEST_CONTROL_LOOP_ENABLE_RESET 0x0
/*Register TEST_Control field insert_error */
#define TEST_CONTROL_INSERT_ERROR_FIELD_OFFSET 8
#define TEST_CONTROL_INSERT_ERROR_FIELD_WIDTH 1
#define TEST_CONTROL_INSERT_ERROR_FIELD_MASK 0x100
#define TEST_CONTROL_INSERT_ERROR_RESET 0x0
/*Register TEST_Control field force_dominant */
#define TEST_CONTROL_FORCE_DOMINANT_FIELD_OFFSET 16
#define TEST_CONTROL_FORCE_DOMINANT_FIELD_WIDTH 1
#define TEST_CONTROL_FORCE_DOMINANT_FIELD_MASK 0x10000
#define TEST_CONTROL_FORCE_DOMINANT_RESET 0x0

/*Register RX_STATUS address */
#define RX_STATUS_OFFSET 0x8
/*Register RX_STATUS field rx_data_valid */
#define RX_STATUS_RX_DATA_VALID_FIELD_OFFSET 0
#define RX_STATUS_RX_DATA_VALID_FIELD_WIDTH 1
#define RX_STATUS_RX_DATA_VALID_FIELD_MASK 0x1
#define RX_STATUS_RX_DATA_VALID_RESET 0x0
/*Register RX_STATUS field rx_read_done */
#define RX_STATUS_RX_READ_DONE_FIELD_OFFSET 1
#define RX_STATUS_RX_READ_DONE_FIELD_WIDTH 1
#define RX_STATUS_RX_READ_DONE_FIELD_MASK 0x2
#define RX_STATUS_RX_READ_DONE_RESET 0x0
/*Register RX_STATUS field rx_busy */
#define RX_STATUS_RX_BUSY_FIELD_OFFSET 8
#define RX_STATUS_RX_BUSY_FIELD_WIDTH 1
#define RX_STATUS_RX_BUSY_FIELD_MASK 0x100
#define RX_STATUS_RX_BUSY_RESET 0x0
/*Register RX_STATUS field rx_crc_error */
#define RX_STATUS_RX_CRC_ERROR_FIELD_OFFSET 9
#define RX_STATUS_RX_CRC_ERROR_FIELD_WIDTH 1
#define RX_STATUS_RX_CRC_ERROR_FIELD_MASK 0x200
#define RX_STATUS_RX_CRC_ERROR_RESET 0x0
/*Register RX_STATUS field rx_rtr */
#define RX_STATUS_RX_RTR_FIELD_OFFSET 16
#define RX_STATUS_RX_RTR_FIELD_WIDTH 1
#define RX_STATUS_RX_RTR_FIELD_MASK 0x10000
#define RX_STATUS_RX_RTR_RESET 0x0
/*Register RX_STATUS field rx_ide */
#define RX_STATUS_RX_IDE_FIELD_OFFSET 24
#define RX_STATUS_RX_IDE_FIELD_WIDTH 1
#define RX_STATUS_RX_IDE_FIELD_MASK 0x1000000
#define RX_STATUS_RX_IDE_RESET 0x0
/*Register RX_STATUS field rx_reserved */
#define RX_STATUS_RX_RESERVED_FIELD_OFFSET 25
#define RX_STATUS_RX_RESERVED_FIELD_WIDTH 2
#define RX_STATUS_RX_RESERVED_FIELD_MASK 0x6000000
#define RX_STATUS_RX_RESERVED_RESET 0x0

/*Register ID_Filter address */
#define ID_FILTER_OFFSET 0x9
/*Register ID_Filter field id1 */
#define ID_FILTER_ID1_FIELD_OFFSET 0
#define ID_FILTER_ID1_FIELD_WIDTH 29
#define ID_FILTER_ID1_FIELD_MASK 0x1fffffff
#define ID_FILTER_ID1_RESET 0x0

/*Register ID_Filter_MASK address */
#define ID_FILTER_MASK_OFFSET 0xa
/*Register ID_Filter_MASK field id1_mask */
#define ID_FILTER_MASK_ID1_MASK_FIELD_OFFSET 0
#define ID_FILTER_MASK_ID1_MASK_FIELD_WIDTH 29
#define ID_FILTER_MASK_ID1_MASK_FIELD_MASK 0x1fffffff
#define ID_FILTER_MASK_ID1_MASK_RESET 0x0

/*Register RX_DLC address */
#define RX_DLC_OFFSET 0xb
/*Register RX_DLC field rx_size */
#define RX_DLC_RX_SIZE_FIELD_OFFSET 0
#define RX_DLC_RX_SIZE_FIELD_WIDTH 4
#define RX_DLC_RX_SIZE_FIELD_MASK 0xf
#define RX_DLC_RX_SIZE_RESET 0x0

/*Register RX_ID address */
#define RX_ID_OFFSET 0xc
/*Register RX_ID field rx_id */
#define RX_ID_RX_ID_FIELD_OFFSET 0
#define RX_ID_RX_ID_FIELD_WIDTH 29
#define RX_ID_RX_ID_FIELD_MASK 0x1fffffff
#define RX_ID_RX_ID_RESET 0x0

/*Register RX_DATA0 address */
#define RX_DATA0_OFFSET 0xd
/*Register RX_DATA0 field rx_data0 */
#define RX_DATA0_RX_DATA0_FIELD_OFFSET 0
#define RX_DATA0_RX_DATA0_FIELD_WIDTH 32
#define RX_DATA0_RX_DATA0_FIELD_MASK 0xffffffff
#define RX_DATA0_RX_DATA0_RESET 0x0

/*Register RX_DATA1 address */
#define RX_DATA1_OFFSET 0xe
/*Register RX_DATA1 field rx_data1 */
#define RX_DATA1_RX_DATA1_FIELD_OFFSET 0
#define RX_DATA1_RX_DATA1_FIELD_WIDTH 32
#define RX_DATA1_RX_DATA1_FIELD_MASK 0xffffffff
#define RX_DATA1_RX_DATA1_RESET 0x0

/*Register TX_STATUS address */
#define TX_STATUS_OFFSET 0x10
/*Register TX_STATUS field tx_ready */
#define TX_STATUS_TX_READY_FIELD_OFFSET 0
#define TX_STATUS_TX_READY_FIELD_WIDTH 1
#define TX_STATUS_TX_READY_FIELD_MASK 0x1
#define TX_STATUS_TX_READY_RESET 0x0
/*Register TX_STATUS field tx_valid */
#define TX_STATUS_TX_VALID_FIELD_OFFSET 1
#define TX_STATUS_TX_VALID_FIELD_WIDTH 1
#define TX_STATUS_TX_VALID_FIELD_MASK 0x2
#define TX_STATUS_TX_VALID_RESET 0x0
/*Register TX_STATUS field tx_busy */
#define TX_STATUS_TX_BUSY_FIELD_OFFSET 8
#define TX_STATUS_TX_BUSY_FIELD_WIDTH 1
#define TX_STATUS_TX_BUSY_FIELD_MASK 0x100
#define TX_STATUS_TX_BUSY_RESET 0x0
/*Register TX_STATUS field tx_arb_lost */
#define TX_STATUS_TX_ARB_LOST_FIELD_OFFSET 9
#define TX_STATUS_TX_ARB_LOST_FIELD_WIDTH 1
#define TX_STATUS_TX_ARB_LOST_FIELD_MASK 0x200
#define TX_STATUS_TX_ARB_LOST_RESET 0x0
/*Register TX_STATUS field tx_retry_error */
#define TX_STATUS_TX_RETRY_ERROR_FIELD_OFFSET 10
#define TX_STATUS_TX_RETRY_ERROR_FIELD_WIDTH 1
#define TX_STATUS_TX_RETRY_ERROR_FIELD_MASK 0x400
#define TX_STATUS_TX_RETRY_ERROR_RESET 0x0
/*Register TX_STATUS field tx_rtr */
#define TX_STATUS_TX_RTR_FIELD_OFFSET 16
#define TX_STATUS_TX_RTR_FIELD_WIDTH 1
#define TX_STATUS_TX_RTR_FIELD_MASK 0x10000
#define TX_STATUS_TX_RTR_RESET 0x0
/*Register TX_STATUS field tx_eff */
#define TX_STATUS_TX_EFF_FIELD_OFFSET 24
#define TX_STATUS_TX_EFF_FIELD_WIDTH 1
#define TX_STATUS_TX_EFF_FIELD_MASK 0x1000000
#define TX_STATUS_TX_EFF_RESET 0x0
/*Register TX_STATUS field tx_reserved */
#define TX_STATUS_TX_RESERVED_FIELD_OFFSET 25
#define TX_STATUS_TX_RESERVED_FIELD_WIDTH 2
#define TX_STATUS_TX_RESERVED_FIELD_MASK 0x6000000
#define TX_STATUS_TX_RESERVED_RESET 0x0

/*Register TX_DLC address */
#define TX_DLC_OFFSET 0x11
/*Register TX_DLC field tx_dlc */
#define TX_DLC_TX_DLC_FIELD_OFFSET 0
#define TX_DLC_TX_DLC_FIELD_WIDTH 4
#define TX_DLC_TX_DLC_FIELD_MASK 0xf
#define TX_DLC_TX_DLC_RESET 0x0

/*Register TX_ID address */
#define TX_ID_OFFSET 0x12
/*Register TX_ID field tx_id */
#define TX_ID_TX_ID_FIELD_OFFSET 0
#define TX_ID_TX_ID_FIELD_WIDTH 29
#define TX_ID_TX_ID_FIELD_MASK 0x1fffffff
#define TX_ID_TX_ID_RESET 0x0

/*Register TX_DATA0 address */
#define TX_DATA0_OFFSET 0x13
/*Register TX_DATA0 field tx_data0 */
#define TX_DATA0_TX_DATA0_FIELD_OFFSET 0
#define TX_DATA0_TX_DATA0_FIELD_WIDTH 32
#define TX_DATA0_TX_DATA0_FIELD_MASK 0xffffffff
#define TX_DATA0_TX_DATA0_RESET 0x0

/*Register TX_DATA1 address */
#define TX_DATA1_OFFSET 0x14
/*Register TX_DATA1 field tx_data1 */
#define TX_DATA1_TX_DATA1_FIELD_OFFSET 0
#define TX_DATA1_TX_DATA1_FIELD_WIDTH 32
#define TX_DATA1_TX_DATA1_FIELD_MASK 0xffffffff
#define TX_DATA1_TX_DATA1_RESET 0x0


