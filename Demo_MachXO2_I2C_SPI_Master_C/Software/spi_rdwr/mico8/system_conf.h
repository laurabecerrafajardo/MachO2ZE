#ifndef __SYSTEM_CONFIG_H_
#define __SYSTEM_CONFIG_H_


#define FPGA_DEVICE_FAMILY    "MachXO2"
#define PLATFORM_NAME         "mico8"
#define USE_PLL               (0)
#define CPU_FREQUENCY         (12000000)


/* FOUND 1 CPU UNIT(S) */

/*
 * CPU Instance LM8 component configuration
 */
#define CPU_NAME "LM8"

/*
 * uart component configuration
 */
#define UART_NAME  "uart"
#define UART_BASE_ADDRESS  (0x80000100)
#define UART_SIZE  (16)
#define UART_IRQ (0)
#define UART_CHARIO_IN        (1)
#define UART_CHARIO_OUT       (1)
#define UART_CHARIO_TYPE      "RS-232"
#define UART_ADDRESS_LOCK  (1)
#define UART_DISABLE  (0)
#define UART_MODEM  (0)
#define UART_WB_DAT_WIDTH  (8)
#define UART_WB_ADR_WIDTH  (4)
#define UART_BAUD_RATE  (115200)
#define UART_IB_SIZE  (4)
#define UART_OB_SIZE  (4)
#define UART_BLOCK_WRITE  (1)
#define UART_BLOCK_READ  (1)
#define UART_STDOUT_SIM  (0)
#define UART_STDOUT_SIMFAST  (0)
#define UART_RXRDY_ENABLE  (0)
#define UART_TXRDY_ENABLE  (0)
#define UART_INTERRUPT_DRIVEN  (0)
#define UART_LCR_DATA_BITS  (8)
#define UART_LCR_STOP_BITS  (1)
#define UART_LCR_PARITY_ENABLE  (0)
#define UART_LCR_PARITY_ODD  (0)
#define UART_LCR_PARITY_STICK  (0)
#define UART_LCR_SET_BREAK  (0)
#define UART_FIFO  (0)

/*
 * slave_LCD component configuration
 */
#define SLAVE_LCD_NAME  "slave_LCD"
#define SLAVE_LCD_BASE_ADDRESS  (0x80000200)
#define SLAVE_LCD_SIZE  (16)
#define SLAVE_LCD_IRQ (1)
#define SLAVE_LCD_CHARIO_IN        (0)
#define SLAVE_LCD_CHARIO_OUT       (0)
#define SLAVE_LCD_ADDRESS_LOCK  (1)
#define SLAVE_LCD_DISABLE  (0)
#define SLAVE_LCD_WB_DAT_WIDTH  (8)
#define SLAVE_LCD_WB_SEL_WIDTH  (4)
#define SLAVE_LCD_WB_ADR_WIDTH  (32)

/*
 * slave_EFB component configuration
 */
#define SLAVE_EFB_NAME  "slave_EFB"
#define SLAVE_EFB_BASE_ADDRESS  (0x80000000)
#define SLAVE_EFB_SIZE  (256)
#define SLAVE_EFB_IRQ (2)
#define SLAVE_EFB_CHARIO_IN        (0)
#define SLAVE_EFB_CHARIO_OUT       (0)
#define SLAVE_EFB_ADDRESS_LOCK  (1)
#define SLAVE_EFB_DISABLE  (0)
#define SLAVE_EFB_WB_DAT_WIDTH  (8)
#define SLAVE_EFB_WB_SEL_WIDTH  (4)
#define SLAVE_EFB_WB_ADR_WIDTH  (32)


#endif /* __SYSTEM_CONFIG_H_ */
