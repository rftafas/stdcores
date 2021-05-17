#ifndef CAN_AXIMM_H
#define CAN_AXIMM_H

/*This auto-generated header file was created using hdltools. File version:*/
#define CAN_AXIMM_VERSION "20210517_1405"

/*Register Golden address */
#define GOLDEN_OFFSET 0x0
/*Register Golden field g1 */
#define GOLDEN_G1_FIELD_OFFSET 0
#define GOLDEN_G1_FIELD_WIDTH 32
#define GOLDEN_G1_FIELD_MASK 0xffffffff
#define GOLDEN_G1_RESET 0x0

/*Register Config 1 address */
#define CONFIG 1_OFFSET 0x1
/*Register Config 1 field iso_mode */
#define CONFIG 1_ISO_MODE_FIELD_OFFSET 0
#define CONFIG 1_ISO_MODE_FIELD_WIDTH 1
#define CONFIG 1_ISO_MODE_FIELD_MASK 0x1
#define CONFIG 1_ISO_MODE_RESET 0x0
/*Register Config 1 field fd_enable */
#define CONFIG 1_FD_ENABLE_FIELD_OFFSET 1
#define CONFIG 1_FD_ENABLE_FIELD_WIDTH 1
#define CONFIG 1_FD_ENABLE_FIELD_MASK 0x2
#define CONFIG 1_FD_ENABLE_RESET 0x0
/*Register Config 1 field promiscuous */
#define CONFIG 1_PROMISCUOUS_FIELD_OFFSET 8
#define CONFIG 1_PROMISCUOUS_FIELD_WIDTH 1
#define CONFIG 1_PROMISCUOUS_FIELD_MASK 0x100
#define CONFIG 1_PROMISCUOUS_RESET 0x0

/*Register Config 1 address */
#define CONFIG 1_OFFSET 0x2
/*Register Config 1 field sample_rate */
#define CONFIG 1_SAMPLE_RATE_FIELD_OFFSET 0
#define CONFIG 1_SAMPLE_RATE_FIELD_WIDTH 16
#define CONFIG 1_SAMPLE_RATE_FIELD_MASK 0xffff
#define CONFIG 1_SAMPLE_RATE_RESET 0x0

/*Register IRQ address */
#define IRQ_OFFSET 0x3
/*Register IRQ field rx_irq */
#define IRQ_RX_IRQ_FIELD_OFFSET 0
#define IRQ_RX_IRQ_FIELD_WIDTH 1
#define IRQ_RX_IRQ_FIELD_MASK 0x1
#define IRQ_RX_IRQ_RESET 0x0
/*Register IRQ field rx_irq_mask */
#define IRQ_RX_IRQ_MASK_FIELD_OFFSET 1
#define IRQ_RX_IRQ_MASK_FIELD_WIDTH 1
#define IRQ_RX_IRQ_MASK_FIELD_MASK 0x2
#define IRQ_RX_IRQ_MASK_RESET 0x0
/*Register IRQ field tx_irq */
#define IRQ_TX_IRQ_FIELD_OFFSET 8
#define IRQ_TX_IRQ_FIELD_WIDTH 1
#define IRQ_TX_IRQ_FIELD_MASK 0x100
#define IRQ_TX_IRQ_RESET 0x0
/*Register IRQ field tx_irq_mask */
#define IRQ_TX_IRQ_MASK_FIELD_OFFSET 9
#define IRQ_TX_IRQ_MASK_FIELD_WIDTH 1
#define IRQ_TX_IRQ_MASK_FIELD_MASK 0x200
#define IRQ_TX_IRQ_MASK_RESET 0x0

/*Register Line Status address */
#define LINE STATUS_OFFSET 0x4
/*Register Line Status field stuff_violation */
#define LINE STATUS_STUFF_VIOLATION_FIELD_OFFSET 0
#define LINE STATUS_STUFF_VIOLATION_FIELD_WIDTH 1
#define LINE STATUS_STUFF_VIOLATION_FIELD_MASK 0x1
#define LINE STATUS_STUFF_VIOLATION_RESET 0x0
/*Register Line Status field collision */
#define LINE STATUS_COLLISION_FIELD_OFFSET 1
#define LINE STATUS_COLLISION_FIELD_WIDTH 1
#define LINE STATUS_COLLISION_FIELD_MASK 0x2
#define LINE STATUS_COLLISION_RESET 0x0
/*Register Line Status field channel_ready */
#define LINE STATUS_CHANNEL_READY_FIELD_OFFSET 8
#define LINE STATUS_CHANNEL_READY_FIELD_WIDTH 1
#define LINE STATUS_CHANNEL_READY_FIELD_MASK 0x100
#define LINE STATUS_CHANNEL_READY_RESET 0x0

/*Register TEST Control 1 address */
#define TEST CONTROL 1_OFFSET 0x7
/*Register TEST Control 1 field loop_enable */
#define TEST CONTROL 1_LOOP_ENABLE_FIELD_OFFSET 0
#define TEST CONTROL 1_LOOP_ENABLE_FIELD_WIDTH 1
#define TEST CONTROL 1_LOOP_ENABLE_FIELD_MASK 0x1
#define TEST CONTROL 1_LOOP_ENABLE_RESET 0x0
/*Register TEST Control 1 field insert_error */
#define TEST CONTROL 1_INSERT_ERROR_FIELD_OFFSET 8
#define TEST CONTROL 1_INSERT_ERROR_FIELD_WIDTH 1
#define TEST CONTROL 1_INSERT_ERROR_FIELD_MASK 0x100
#define TEST CONTROL 1_INSERT_ERROR_RESET 0x0
/*Register TEST Control 1 field force_dominant */
#define TEST CONTROL 1_FORCE_DOMINANT_FIELD_OFFSET 16
#define TEST CONTROL 1_FORCE_DOMINANT_FIELD_WIDTH 1
#define TEST CONTROL 1_FORCE_DOMINANT_FIELD_MASK 0x10000
#define TEST CONTROL 1_FORCE_DOMINANT_RESET 0x0

/*Register RX STATUS address */
#define RX STATUS_OFFSET 0x8
/*Register RX STATUS field rx_data_valid */
#define RX STATUS_RX_DATA_VALID_FIELD_OFFSET 0
#define RX STATUS_RX_DATA_VALID_FIELD_WIDTH 1
#define RX STATUS_RX_DATA_VALID_FIELD_MASK 0x1
#define RX STATUS_RX_DATA_VALID_RESET 0x0
/*Register RX STATUS field rx_read_done */
#define RX STATUS_RX_READ_DONE_FIELD_OFFSET 1
#define RX STATUS_RX_READ_DONE_FIELD_WIDTH 1
#define RX STATUS_RX_READ_DONE_FIELD_MASK 0x2
#define RX STATUS_RX_READ_DONE_RESET 0x0
/*Register RX STATUS field rx_busy */
#define RX STATUS_RX_BUSY_FIELD_OFFSET 8
#define RX STATUS_RX_BUSY_FIELD_WIDTH 1
#define RX STATUS_RX_BUSY_FIELD_MASK 0x100
#define RX STATUS_RX_BUSY_RESET 0x0
/*Register RX STATUS field rx_crc_error */
#define RX STATUS_RX_CRC_ERROR_FIELD_OFFSET 9
#define RX STATUS_RX_CRC_ERROR_FIELD_WIDTH 1
#define RX STATUS_RX_CRC_ERROR_FIELD_MASK 0x200
#define RX STATUS_RX_CRC_ERROR_RESET 0x0
/*Register RX STATUS field rx_rtr */
#define RX STATUS_RX_RTR_FIELD_OFFSET 16
#define RX STATUS_RX_RTR_FIELD_WIDTH 1
#define RX STATUS_RX_RTR_FIELD_MASK 0x10000
#define RX STATUS_RX_RTR_RESET 0x0
/*Register RX STATUS field rx_ide */
#define RX STATUS_RX_IDE_FIELD_OFFSET 24
#define RX STATUS_RX_IDE_FIELD_WIDTH 1
#define RX STATUS_RX_IDE_FIELD_MASK 0x1000000
#define RX STATUS_RX_IDE_RESET 0x0
/*Register RX STATUS field rx_reserved */
#define RX STATUS_RX_RESERVED_FIELD_OFFSET 25
#define RX STATUS_RX_RESERVED_FIELD_WIDTH 2
#define RX STATUS_RX_RESERVED_FIELD_MASK 0x6000000
#define RX STATUS_RX_RESERVED_RESET 0x0

/*Register ID Filter 1 address */
#define ID FILTER 1_OFFSET 0x9
/*Register ID Filter 1 field id1 */
#define ID FILTER 1_ID1_FIELD_OFFSET 0
#define ID FILTER 1_ID1_FIELD_WIDTH 29
#define ID FILTER 1_ID1_FIELD_MASK 0x1fffffff
#define ID FILTER 1_ID1_RESET 0x0

/*Register ID Filter 1 MASK address */
#define ID FILTER 1 MASK_OFFSET 0xa
/*Register ID Filter 1 MASK field id1_mask */
#define ID FILTER 1 MASK_ID1_MASK_FIELD_OFFSET 0
#define ID FILTER 1 MASK_ID1_MASK_FIELD_WIDTH 29
#define ID FILTER 1 MASK_ID1_MASK_FIELD_MASK 0x1fffffff
#define ID FILTER 1 MASK_ID1_MASK_RESET 0x0

/*Register RX DLC address */
#define RX DLC_OFFSET 0xb
/*Register RX DLC field rx_size */
#define RX DLC_RX_SIZE_FIELD_OFFSET 0
#define RX DLC_RX_SIZE_FIELD_WIDTH 4
#define RX DLC_RX_SIZE_FIELD_MASK 0xf
#define RX DLC_RX_SIZE_RESET 0x0

/*Register RX ID address */
#define RX ID_OFFSET 0xc
/*Register RX ID field rx_id */
#define RX ID_RX_ID_FIELD_OFFSET 0
#define RX ID_RX_ID_FIELD_WIDTH 29
#define RX ID_RX_ID_FIELD_MASK 0x1fffffff
#define RX ID_RX_ID_RESET 0x0

/*Register RX DATA0 address */
#define RX DATA0_OFFSET 0xd
/*Register RX DATA0 field rx_data0 */
#define RX DATA0_RX_DATA0_FIELD_OFFSET 0
#define RX DATA0_RX_DATA0_FIELD_WIDTH 32
#define RX DATA0_RX_DATA0_FIELD_MASK 0xffffffff
#define RX DATA0_RX_DATA0_RESET 0x0

/*Register RX DATA1 address */
#define RX DATA1_OFFSET 0xe
/*Register RX DATA1 field rx_data1 */
#define RX DATA1_RX_DATA1_FIELD_OFFSET 0
#define RX DATA1_RX_DATA1_FIELD_WIDTH 32
#define RX DATA1_RX_DATA1_FIELD_MASK 0xffffffff
#define RX DATA1_RX_DATA1_RESET 0x0

/*Register TX STATUS address */
#define TX STATUS_OFFSET 0x10
/*Register TX STATUS field tx_ready */
#define TX STATUS_TX_READY_FIELD_OFFSET 0
#define TX STATUS_TX_READY_FIELD_WIDTH 1
#define TX STATUS_TX_READY_FIELD_MASK 0x1
#define TX STATUS_TX_READY_RESET 0x0
/*Register TX STATUS field tx_valid */
#define TX STATUS_TX_VALID_FIELD_OFFSET 1
#define TX STATUS_TX_VALID_FIELD_WIDTH 1
#define TX STATUS_TX_VALID_FIELD_MASK 0x2
#define TX STATUS_TX_VALID_RESET 0x0
/*Register TX STATUS field tx_busy */
#define TX STATUS_TX_BUSY_FIELD_OFFSET 8
#define TX STATUS_TX_BUSY_FIELD_WIDTH 1
#define TX STATUS_TX_BUSY_FIELD_MASK 0x100
#define TX STATUS_TX_BUSY_RESET 0x0
/*Register TX STATUS field tx_arb_lost */
#define TX STATUS_TX_ARB_LOST_FIELD_OFFSET 9
#define TX STATUS_TX_ARB_LOST_FIELD_WIDTH 1
#define TX STATUS_TX_ARB_LOST_FIELD_MASK 0x200
#define TX STATUS_TX_ARB_LOST_RESET 0x0
/*Register TX STATUS field tx_retry_error */
#define TX STATUS_TX_RETRY_ERROR_FIELD_OFFSET 10
#define TX STATUS_TX_RETRY_ERROR_FIELD_WIDTH 1
#define TX STATUS_TX_RETRY_ERROR_FIELD_MASK 0x400
#define TX STATUS_TX_RETRY_ERROR_RESET 0x0
/*Register TX STATUS field tx_rtr */
#define TX STATUS_TX_RTR_FIELD_OFFSET 16
#define TX STATUS_TX_RTR_FIELD_WIDTH 1
#define TX STATUS_TX_RTR_FIELD_MASK 0x10000
#define TX STATUS_TX_RTR_RESET 0x0
/*Register TX STATUS field tx_eff */
#define TX STATUS_TX_EFF_FIELD_OFFSET 24
#define TX STATUS_TX_EFF_FIELD_WIDTH 1
#define TX STATUS_TX_EFF_FIELD_MASK 0x1000000
#define TX STATUS_TX_EFF_RESET 0x0
/*Register TX STATUS field tx_reserved */
#define TX STATUS_TX_RESERVED_FIELD_OFFSET 25
#define TX STATUS_TX_RESERVED_FIELD_WIDTH 2
#define TX STATUS_TX_RESERVED_FIELD_MASK 0x6000000
#define TX STATUS_TX_RESERVED_RESET 0x0

/*Register TX DLC address */
#define TX DLC_OFFSET 0x11
/*Register TX DLC field tx_dlc */
#define TX DLC_TX_DLC_FIELD_OFFSET 0
#define TX DLC_TX_DLC_FIELD_WIDTH 4
#define TX DLC_TX_DLC_FIELD_MASK 0xf
#define TX DLC_TX_DLC_RESET 0x0

/*Register TX ID address */
#define TX ID_OFFSET 0x12
/*Register TX ID field tx_id */
#define TX ID_TX_ID_FIELD_OFFSET 0
#define TX ID_TX_ID_FIELD_WIDTH 29
#define TX ID_TX_ID_FIELD_MASK 0x1fffffff
#define TX ID_TX_ID_RESET 0x0

/*Register TX DATA0 address */
#define TX DATA0_OFFSET 0x13
/*Register TX DATA0 field tx_data0 */
#define TX DATA0_TX_DATA0_FIELD_OFFSET 0
#define TX DATA0_TX_DATA0_FIELD_WIDTH 32
#define TX DATA0_TX_DATA0_FIELD_MASK 0xffffffff
#define TX DATA0_TX_DATA0_RESET 0x0

/*Register TX DATA1 address */
#define TX DATA1_OFFSET 0x14
/*Register TX DATA1 field tx_data1 */
#define TX DATA1_TX_DATA1_FIELD_OFFSET 0
#define TX DATA1_TX_DATA1_FIELD_WIDTH 32
#define TX DATA1_TX_DATA1_FIELD_MASK 0xffffffff
#define TX DATA1_TX_DATA1_RESET 0x0


