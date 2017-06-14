`define LATTICE_FAMILY "MachXO2"
`define LATTICE_FAMILY_MachXO2
`ifndef SYSTEM_CONF
`define SYSTEM_CONF
`timescale 1ns / 100 ps
`define I_WB_DAT_WIDTH 8
`define D_WB_DAT_WIDTH 8
`define CFG_REGISTER_COUNT 16
`define LM8CFG_REGISTER_16
`define CFG_CALL_STACK 16
`define LM8CFG_CALL_STACK_16
`define LM8CFG_PROM_SIZE 2048
`define LM8CFG_PROM_INIT_FILE "C:/JoeM/XO2_AE_projects/XO2_Pico_AE7/Software/prom_init.mem"
`define LM8CFG_PROM_INIT_FILE_FORMAT "hex"
`define SP_ADDRESS_LOCK
`define SP_PORT_TYPE "Memory"
`define LM8SP_PORT_ENABLE
`define LM8CFG_SP_INIT_FILE "C:/JoeM/XO2_AE_projects/XO2_Pico_AE7/Software/scratchpad_init.mem"
`define LM8CFG_SP_INIT_FILE_FORMAT "hex"
`define CFG_EXT_SIZE 16
`define LM8CFG_EXT_SIZE_16
`define CFG_IO_BASE_ADDRESS 32'h80000000
`define LM8LATTICE_FAMILY "MachXO2"
`define SP_ADDRESS_LOCK
`define ADDRESS_LOCK
`define uartUART_WB_DAT_WIDTH 8
`define uartUART_WB_ADR_WIDTH 4
`define uartCLK_IN_MHZ 0
`define uartBAUD_RATE 115200
`define BLOCK_WRITE
`define BLOCK_READ
`define CharIODevice
`define uartLCR_DATA_BITS 8
`define uartLCR_STOP_BITS 1
`define ADDRESS_LOCK
`define slave_LCDS_WB_DAT_WIDTH 8
`define S_WB_SEL_WIDTH 4
`define slave_LCDS_WB_ADR_WIDTH 32
`define ADDRESS_LOCK
`define slave_EFBS_WB_DAT_WIDTH 8
`define S_WB_SEL_WIDTH 4
`define slave_EFBS_WB_ADR_WIDTH 32
`endif // SYSTEM_CONF
