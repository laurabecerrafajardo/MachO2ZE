#include "DDStructs.h"


/* lm8 instance LM8*/
struct st_LatticeMico8Ctx_t lm8_LM8 = {
    "LM8"};


/* uart_core instance uart*/
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
  /* array declaration for rxBuffer */
   unsigned char _uart_core_uart_rxBuffer[4];
#endif
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
  /* array declaration for txBuffer */
   unsigned char _uart_core_uart_txBuffer[4];
#endif
#endif
struct st_MicoUartCtx_t uart_core_uart = {
    "uart",
    0x0100,
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    0,
#endif
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    0,
#endif
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    4,
#endif
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    4,
#endif
#endif
#ifdef __MICOUART_BLOCKING__
    1,
#endif
#ifdef __MICOUART_BLOCKING__
    1,
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    0,
#endif
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    _uart_core_uart_rxBuffer,
#endif
#endif
#ifndef __MICO_NO_INTERRUPTS__
#ifdef __MICOUART_INTERRUPT__
    _uart_core_uart_txBuffer,
#endif
#endif
};


/* slave_passthru instance slave_LCD*/
struct st_MicoPassthruCtx_t slave_passthru_slave_LCD = {
    "slave_LCD",
    0x0200,
    1};


/* slave_passthru instance slave_EFB*/
struct st_MicoPassthruCtx_t slave_passthru_slave_EFB = {
    "slave_EFB",
    0x0000,
    2};

