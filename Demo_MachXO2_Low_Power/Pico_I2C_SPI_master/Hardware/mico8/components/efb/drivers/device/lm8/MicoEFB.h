/****************************************************************************
**
**  Description:
**        Implements functions for manipulating LatticeMico32 SPI Flash
**
**  Disclaimer:
**   This source code is intended as a design reference which
**   illustrates how these types of functions can be implemented.  It
**   is the user's responsibility to verify their design for
**   consistency and functionality through the use of formal
**   verification methods.  Lattice Semiconductor provides no warranty
**   regarding the use or functionality of this code.
**
*****************************************************************************
**
**                     Lattice Semiconductor Corporation
**                     5555 NE Moore Court
**                     Hillsboro, OR 97214
**                     U.S.A
**
**                     TEL: 1-800-Lattice (USA and Canada)
**                          (503)268-8001 (other locations)
**
**                     web:   http://www.latticesemi.com
**                     email: techsupport@latticesemi.com
**
*****************************************************************************
**  Change History (Latest changes on top)
**
**  Ver    Date        Description
** --------------------------------------------------------------------------
**  3.0    12/16/2010  Initial Version
**
*****************************************************************************/
#include "DDStructs.h"

/***********************************************************************
 *                                                                     *
 * EFB GLOBAL INTERRUPT                                                *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_IRQ_REGISTER      			(0x77)
#define MICO_EFB_IRQ_TIMER_MASK				(0x08)		
#define MICO_EFB_IRQ_SPI_MASK				(0x04)	
#define MICO_EFB_IRQ_I2C2_MASK				(0x02)	
#define MICO_EFB_IRQ_I2C1_MASK				(0x01)

#define MICO_EFB_READ_IRQR(X, Y) \
		(Y) = (__builtin_import((size_t)(X+MICO_EFB_IRQ_REGISTER)))
		
#define MICO_EFB_WRITE_IRQR(X, Y) \
		(__builtin_export((char)(Y), (size_t)(X+MICO_EFB_IRQ_REGISTER)))




/***********************************************************************
 *                                                                     *
 * EFB GLOBAL USER FUNCTIONS                                            *
 *                                                                     *
 ***********************************************************************/

void MicoEFBInit (MicoEFBCtx_t *ctx);
#ifndef __MICO_NO_INTERRUPTS__
void MicoEFBISR (MicoEFBCtx_t *ctx);
#ifndef __MICOEFB_NO_I2C_INTERRUPT__
void MicoEFB_I2C1ISR (MicoEFBCtx_t *ctx);
void MicoEFB_I2C2ISR (MicoEFBCtx_t *ctx);
#endif
#ifndef __MICOEFB_NO_SPI_INTERRUPT__
void MicoEFB_SPIISR (MicoEFBCtx_t *ctx);
#endif
#ifndef __MICOEFB_NO_TC_INTERRUPT__
void MicoEFB_TimerISR (MicoEFBCtx_t *ctx);
#endif
#endif



/***********************************************************************
 *                                                                     *
 * EFB SPI CONTROLLER PHYSICAL DEVICE SPECIFIC INFORMATION             *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_SPI_CR0					(0x54)
#define MICO_EFB_SPI_CR1					(0x55)
#define MICO_EFB_SPI_CR2					(0x56)
#define MICO_EFB_SPI_BR						(0x57)
#define MICO_EFB_SPI_CSR					(0x58)
#define MICO_EFB_SPI_TXDR					(0x59)
#define MICO_EFB_SPI_SR						(0x5a)
#define MICO_EFB_SPI_RXDR					(0x5b)
#define MICO_EFB_SPI_IRQSR					(0x5c)
#define MICO_EFB_SPI_IRQENR					(0x5d)


// Control Register 1 Bit Masks
#define MICO_EFB_SPI_CR1_SPE				(0x80)
#define MICO_EFB_SPI_CR1_WKUPEN				(0x40)
// Control Register 2 Bit Masks
#define MICO_EFB_SPI_CR2_LSBF				(0x01)
#define MICO_EFB_SPI_CR2_CPHA				(0x02)
#define MICO_EFB_SPI_CR2_CPOL				(0x04)
#define MICO_EFB_SPI_CR2_SFSEL_NORMAL		(0x00)
#define MICO_EFB_SPI_CR2_SFSEL_LATTICE		(0x08)
#define MICO_EFB_SPI_CR2_SRME				(0x20)
#define MICO_EFB_SPI_CR2_MCSH				(0x40)
#define MICO_EFB_SPI_CR2_MSTR				(0x80)
// Status Register Bit Masks
#define MICO_EFB_SPI_SR_TIP					(0x80)
#define MICO_EFB_SPI_SR_TRDY				(0x10)
#define MICO_EFB_SPI_SR_RRDY				(0x08)
#define MICO_EFB_SPI_SR_TOE					(0x04)
#define MICO_EFB_SPI_SR_ROE					(0x02)
#define MICO_EFB_SPI_SR_MDF					(0x01)

/***********************************************************************
 *                                                                     *
 * EFB SPI USER MACROS                                                 *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_SPI_WRITE_CR0(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_SPI_CR0))

#define MICO_EFB_SPI_READ_CR0(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_CR0))
	
#define MICO_EFB_SPI_WRITE_CR1(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_SPI_CR1))

#define MICO_EFB_SPI_READ_CR1(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_CR1))
	
#define MICO_EFB_SPI_WRITE_CR2(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_SPI_CR2))

#define MICO_EFB_SPI_READ_CR2(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_CR2))
	
#define MICO_EFB_SPI_WRITE_BR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_SPI_BR))

#define MICO_EFB_SPI_READ_BR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_BR))
	
#define MICO_EFB_SPI_WRITE_CSR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_SPI_CSR))

#define MICO_EFB_SPI_READ_CSR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_CSR))
	
#define MICO_EFB_SPI_WRITE_TXDR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_SPI_TXDR))

#define MICO_EFB_SPI_READ_RXDR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_RXDR))
	
#define MICO_EFB_SPI_READ_SR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_SR))
	
#define MICO_EFB_SPI_WRITE_IRQSR(X, Y) \
	(__builtin_export((char)(Y & 0x1F), (size_t)(X)+MICO_EFB_SPI_IRQSR))
	
#define MICO_EFB_SPI_READ_IRQSR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_IRQSR))

#define MICO_EFB_SPI_WRITE_IRQENR(X, Y) \
	(__builtin_export((char)(Y & 0x1F), (size_t)(X)+MICO_EFB_SPI_IRQENR))
	
#define MICO_EFB_SPI_READ_IRQENR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_SPI_IRQENR))

	
/***********************************************************************
 *                                                                     *
 * EFB SPI USER FUNCTIONS                                              *
 *                                                                     *
 ***********************************************************************/
char MicoEFB_SPITransfer (MicoEFBCtx_t *ctx,
							unsigned char isMaster,
							unsigned char slvIndex,
							unsigned char insertStart,
							unsigned char insertStop,
							unsigned char *txBuffer,
							unsigned char *rxBuffer,
							unsigned char bufferSize);
char MicoEFB_SPITxData (MicoEFBCtx_t *ctx,
						unsigned char data);
char MicoEFB_SPIRxData (MicoEFBCtx_t *ctx,
						unsigned char *data);




/***********************************************************************
 *                                                                     *
 * EFB I2C CONTROLLER PHYSICAL DEVICE SPECIFIC INFORMATION             *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_I2C_CR						(0x40)//4a
#define MICO_EFB_I2C_CMDR					(0x41)//4b
#define MICO_EFB_I2C_BLOR					(0x42)//4c
#define MICO_EFB_I2C_BHIR					(0x43)//4d
#define MICO_EFB_I2C_TXDR					(0x44)//4e
#define MICO_EFB_I2C_SR						(0x45)//4f
#define MICO_EFB_I2C_GCDR					(0x46)//50
#define MICO_EFB_I2C_RXDR					(0x47)//51
#define MICO_EFB_I2C_IRQSR					(0x48)//52
#define MICO_EFB_I2C_IRQENR					(0x49)//53

// Control Register Bit Masks
#define MICO_EFB_I2C_CR_I2CEN				(0x80)
#define MICO_EFB_I2C_CR_GCEN				(0x40)
#define MICO_EFB_I2C_CR_WKUPEN				(0x20)
// Status Register Bit Masks
#define MICO_EFB_I2C_SR_TIP					(0x80)
#define MICO_EFB_I2C_SR_BUSY				(0x40)
#define MICO_EFB_I2C_SR_RARC				(0x20)
#define MICO_EFB_I2C_SR_SRW					(0x10)
#define MICO_EFB_I2C_SR_ARBL				(0x08)
#define MICO_EFB_I2C_SR_TRRDY				(0x04)
#define MICO_EFB_I2C_SR_TROE				(0x02)
#define MICO_EFB_I2C_SR_HGC					(0x01)
// Command Register Bit Masks 
#define MICO_EFB_I2C_CMDR_STA				(0x80)
#define MICO_EFB_I2C_CMDR_STO				(0x40)
#define MICO_EFB_I2C_CMDR_RD				(0x20)
#define MICO_EFB_I2C_CMDR_WR				(0x10)
#define MICO_EFB_I2C_CMDR_NACK				(0x08)
#define MICO_EFB_I2C_CMDR_CKSDIS			(0x04)

/***********************************************************************
 *                                                                     *
 * EFB I2C USER DEFINE                                                 *
 *                                                                     *
 ***********************************************************************/
#define MICO_EFB_I2C_WR_SEQUENCE			(0)
#define MICO_EFB_I2C_RD_SEQUENCE			(1)
#define MICO_EFB_I2C_TRANSMISSION_DONE		(0x00)
#define MICO_EFB_I2C_TRANSMISSION_ONGOING	(0x80)
#define MICO_EFB_I2C_FREE                   (0x00)
#define MICO_EFB_I2C_BUSY                   (0x40)
#define MICO_EFB_I2C_ACK_NOT_RCVD			(0x20)
#define MICO_EFB_I2C_ACK_RCVD				(0x00)
#define MICO_EFB_I2C_ARB_LOST				(0x08)
#define MICO_EFB_I2C_ARB_NOT_LOST			(0x00)
#define MICO_EFB_I2C_DATA_READY				(0x04)

/***********************************************************************
 *                                                                     *
 * EFB I2C USER MACROS                                                 *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_I2C_WRITE_CR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_I2C_CR))
	
#define MICO_EFB_I2C_READ_CR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_CR))
	
#define MICO_EFB_I2C_WRITE_CMDR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_I2C_CMDR));\
	(MicoSleepMicroSecs (100))
	
#define MICO_EFB_I2C_READ_CMDR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_CMDR))
	
#define MICO_EFB_I2C_WRITE_PRESCALE_LO(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_I2C_BLOR))
	
#define MICO_EFB_I2C_READ_PRESCALE_LO(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_BLOR))
	
#define MICO_EFB_I2C_WRITE_PRESCALE_HI(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_I2C_BHIR))
	
#define MICO_EFB_I2C_READ_PRESCALE_HI(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_BHIR))
	
#define MICO_EFB_I2C_WRITE_TXDR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_I2C_TXDR))
	
#define MICO_EFB_I2C_READ_RXDR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_RXDR))
	
#define MICO_EFB_I2C_READ_SR(X, Y) \
	(Y) = (__builtin_import((size_t)(X+MICO_EFB_I2C_SR)))
	
#define MICO_EFB_I2C_WRITE_IRQSR(X, Y) \
	(__builtin_export((char)(Y & 0xF), (size_t)(X)+MICO_EFB_I2C_IRQSR))
	
#define MICO_EFB_I2C_READ_IRQSR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_IRQSR))

#define MICO_EFB_I2C_WRITE_IRQENR(X, Y) \
	(__builtin_export((char)(Y & 0xF), (size_t)(X)+MICO_EFB_I2C_IRQENR))
	
#define MICO_EFB_I2C_READ_IRQENR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_I2C_IRQENR))
	
/***********************************************************************
 *                                                                     *
 * EFB I2C USER FUNCTIONS                                                      *
 *                                                                     *
 ***********************************************************************/
char MicoEFB_I2CStart (MicoEFBCtx_t *ctx, 
						unsigned char i2c_idx,		// I2C 1 or 2
						unsigned char read,			// Write (0) or Read (1) 
						unsigned char address);		// Slave address
char MicoEFB_I2CWrite (MicoEFBCtx_t *ctx, 
						unsigned char i2c_idx,      // I2C 1 or 2  
						unsigned char slv_xfer,     // Is I2C the master (0) or slave (1)
						unsigned char buffersize,   // Number of bytes to be transfered (min 1 and max 256) 
						unsigned char *data,        // Buffer containing the data to be transferred
						unsigned char insert_start, // Master: Insert Start (or repeated Start) prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address);		// Slave address
char MicoEFB_I2CRead (MicoEFBCtx_t *ctx, 
						unsigned char i2c_idx,      // I2C 1 or 2  
						unsigned char slv_xfer,     // Is I2C the master (0) or slave (1)
						unsigned char buffersize,   // Number of bytes to be received (min 1 and max 256) 
						unsigned char *data,        // Buffer to put received data in to
						unsigned char insert_start, // Master: Insert Start (or repeated Start) prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address);		// Slave address

						
						
						
/***********************************************************************
 *                                                                     *
 * EFB TIMER PHYSICAL DEVICE SPECIFIC INFORMATION                      *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_TIMER_CR0					(0x5E)
#define MICO_EFB_TIMER_CR1					(0x5F)
#define MICO_EFB_TIMER_TOP_SET_LO			(0x60)
#define MICO_EFB_TIMER_TOP_SET_HI			(0x61)
#define MICO_EFB_TIMER_OCR_SET_LO			(0x62)
#define MICO_EFB_TIMER_OCR_SET_HI			(0x63)
#define MICO_EFB_TIMER_CR2					(0x64)
#define MICO_EFB_TIMER_CNT_SR_LO			(0x65)
#define MICO_EFB_TIMER_CNT_SR_HI			(0x66)
#define MICO_EFB_TIMER_TOP_SR_LO			(0x67)
#define MICO_EFB_TIMER_TOP_SR_HI			(0x68)
#define MICO_EFB_TIMER_OCR_SR_LO			(0x69)
#define MICO_EFB_TIMER_OCR_SR_HI			(0x6A)
#define MICO_EFB_TIMER_ICR_SR_LO			(0x6B)
#define MICO_EFB_TIMER_ICR_SR_HI			(0x6C)
#define MICO_EFB_TIMER_SR					(0x6D)
#define MICO_EFB_TIMER_IRQSR				(0x6E)
#define MICO_EFB_TIMER_IRQENR				(0x6F)

// Control Register 0
#define MICO_EFB_TIMER_RSTN_MASK			(0x80)
#define MICO_EFB_TIMER_GSRN_MASK			(0x40)
#define MICO_EFB_TIMER_GSRN_ENABLE			(0x40)
#define MICO_EFB_TIMER_GSRN_DISABLE			(0x00)
#define MICO_EFB_TIMER_CCLK_MASK			(0x38)
#define MICO_EFB_TIMER_CCLK_DIV_0			(0x00)
#define MICO_EFB_TIMER_CCLK_DIV_1			(0x08)
#define MICO_EFB_TIMER_CCLK_DIV_8			(0x10)
#define MICO_EFB_TIMER_CCLK_DIV_64			(0x18)
#define MICO_EFB_TIMER_CCLK_DIV_256			(0x20)
#define MICO_EFB_TIMER_CCLK_DIV_1024		(0x28)
#define MICO_EFB_TIMER_SCLK_MASK			(0x07)
#define MICO_EFB_TIMER_SCLK_CIB_RE			(0x00)
#define MICO_EFB_TIMER_SCLK_OSC_RE			(0x02)
#define MICO_EFB_TIMER_SCLK_CIB_FE			(0x04)
#define MICO_EFB_TIMER_SCLK_OSC_FE			(0x06)
// Control Register 1
#define MICO_EFB_TIMER_TOP_SEL_MASK			(0x80)
#define MICO_EFB_TIMER_TOP_MAX				(0x00)
#define MICO_EFB_TIMER_TOP_USER_SELECT		(0x10)
#define MICO_EFB_TIMER_OC_MODE_MASK			(0x0C)
#define MICO_EFB_TIMER_OC_MODE_STATIC_ZERO	(0x00)
#define MICO_EFB_TIMER_OC_MODE_TOGGLE		(0x04)
#define MICO_EFB_TIMER_OC_MODE_CLEAR		(0x08)
#define MICO_EFB_TIMER_OC_MODE_SET			(0x0C)
#define MICO_EFB_TIMER_MODE_MASK			(0x03)
#define MICO_EFB_TIMER_MODE_WATCHDOG		(0x00)
#define MICO_EFB_TIMER_MODE_CTC				(0x01)
#define MICO_EFB_TIMER_MODE_FAST_PWM		(0x02)
#define MICO_EFB_TIMER_MODE_TRUE_PWM		(0x03)
// Control Register 2
#define MICO_EFB_TIMER_OC_FORCE				(0x04)
#define MICO_EFB_TIMER_CNT_RESET			(0x02)
#define MICO_EFB_TIMER_CNT_PAUSE			(0x01)
// Status Register
#define MICO_EFB_TIMER_SR_OVERFLOW			(0x01)
#define MICO_EFB_TIMER_SR_COMPARE_MATCH		(0x02)
#define MICO_EFB_TIMER_SR_CAPTURE			(0x04)

/***********************************************************************
 *                                                                     *
 * EFB TIMER USER MACROS                                                 *
 *                                                                     *
 ***********************************************************************/

#define MICO_EFB_TIMER_WRITE_CR0(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_TIMER_CR0))
	
#define MICO_EFB_TIMER_READ_CR0(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_TIMER_CR0))

#define MICO_EFB_TIMER_WRITE_CR1(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_TIMER_CR1))
	
#define MICO_EFB_TIMER_READ_CR1(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_TIMER_CR1))

#define MICO_EFB_TIMER_WRITE_CR2(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_TIMER_CR2))
	
#define MICO_EFB_TIMER_READ_CR2(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_TIMER_CR2))

#define MICO_EFB_TIMER_SET_TOP(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X+MICO_EFB_TIMER_TOP_SET_LO)));\
	(__builtin_export((char)(Y>>8), (size_t)(X)+MICO_EFB_TIMER_TOP_SET_HI))

#define MICO_EFB_TIMER_SET_OCR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_TIMER_OCR_SET_LO));\
	(__builtin_export((char)(Y>>8), (size_t)(X)+MICO_EFB_TIMER_OCR_SET_HI))

#define MICO_EFB_TIMER_GET_CNT(X, Y) \
	(Y) = ((((unsigned int)__builtin_import((size_t)(X)+MICO_EFB_TIMER_CNT_SR_HI)) << 8) | ((unsigned int)(__builtin_import((size_t)(X)+MICO_EFB_TIMER_CNT_SR_LO))))

#define MICO_EFB_TIMER_GET_TOP(X, Y) \
	(Y) = ((((unsigned int)__builtin_import((size_t)(X)+MICO_EFB_TIMER_TOP_SR_HI)) << 8) | ((unsigned int)(__builtin_import((size_t)(X)+MICO_EFB_TIMER_TOP_SR_LO))))

#define MICO_EFB_TIMER_GET_OCR(X, Y) \
	(Y) = ((((unsigned int)__builtin_import((size_t)(X)+MICO_EFB_TIMER_OCR_SR_HI)) << 8) | ((unsigned int)(__builtin_import((size_t)(X)+MICO_EFB_TIMER_OCR_SR_LO))))

#define MICO_EFB_TIMER_GET_ICR(X, Y) \
	(Y) = ((((unsigned int)__builtin_import((size_t)(X)+MICO_EFB_TIMER_ICR_SR_HI)) << 8) | ((unsigned int)(__builtin_import((size_t)(X)+MICO_EFB_TIMER_ICR_SR_LO))))

#define MICO_EFB_TIMER_READ_SR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_TIMER_SR))

#define MICO_EFB_TIMER_STOP_N_RESET(X) \
	(__builtin_export((char)(MICO_EFB_TIMER_CNT_RESET|MICO_EFB_TIMER_CNT_PAUSE), (size_t)(X)+MICO_EFB_TIMER_CR2))

#define MICO_EFB_TIMER_STOP(X) \
	(__builtin_export((char)(MICO_EFB_TIMER_CNT_PAUSE), (size_t)(X)+MICO_EFB_TIMER_CR2))

#define MICO_EFB_TIMER_RESET(X) \
	(__builtin_export((char)(MICO_EFB_TIMER_CNT_RESET), (size_t)(X)+MICO_EFB_TIMER_CR2))

#define MICO_EFB_TIMER_START(X) \
	(__builtin_export((char)(0x00), (size_t)(X)+MICO_EFB_TIMER_CR2))

#define MICO_EFB_TIMER_WRITE_IRQSR(X, Y) \
	(__builtin_export((char)(Y & 0xF), (size_t)(X)+MICO_EFB_TIMER_IRQSR))
	
#define MICO_EFB_TIMER_READ_IRQSR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_TIMER_IRQSR))

#define MICO_EFB_TIMER_WRITE_IRQENR(X, Y) \
	(__builtin_export((char)(Y & 0xF), (size_t)(X)+MICO_EFB_TIMER_IRQENR))
	
#define MICO_EFB_TIMER_READ_IRQENR(X, Y) \
	(Y) = (__builtin_import((size_t)(X)+MICO_EFB_TIMER_IRQENR))

/***********************************************************************
 *                                                                     *
 * EFB TIMER USER FUNCTIONS                                            *
 *                                                                     *
 ***********************************************************************/
void MicoEFB_TimerStart (MicoEFBCtx_t *ctx,
							unsigned char mode,
							unsigned char ocmode,
							unsigned char sclk,
							unsigned char cclk,
							unsigned char interrupt,
							unsigned int timerCount,
							unsigned int compareCount);
	
