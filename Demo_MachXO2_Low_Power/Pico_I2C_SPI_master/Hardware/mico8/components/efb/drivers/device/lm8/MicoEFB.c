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
#include "stddef.h"
#include "MicoEFB.h"
#include "MicoUtils.h"

/*
 *****************************************************************************
 * EFB initialization.
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *
 *****************************************************************************
 */
void MicoEFBInit (MicoEFBCtx_t *ctx)
{
	size_t efb_address = (size_t) ctx->base;
	
	// Disable all interrupts (should be enabled by user as reqd)
	if (ctx->i2c1_en == 1) {
		// Disable and clear interrupts
		MICO_EFB_I2C_WRITE_IRQENR (efb_address, 0x0); // I2C 1
		MICO_EFB_I2C_WRITE_IRQSR (efb_address, 0xF);
	}
	if (ctx->i2c2_en == 1) {
		// Disable and clear interrupts
		MICO_EFB_I2C_WRITE_IRQENR (efb_address+0xA, 0x0); // I2C 2
		MICO_EFB_I2C_WRITE_IRQSR (efb_address+0xA, 0xF);
	}
	if (ctx->spi_en == 1) {
		// Disable and clear interrupts
		MICO_EFB_SPI_WRITE_IRQENR (efb_address, 0x0); // SPI
		MICO_EFB_SPI_WRITE_IRQSR (efb_address, 0xF);
	}
	if (ctx->timer_en == 1) {
		// Stop Timer
		MICO_EFB_TIMER_WRITE_CR2 (efb_address, (MICO_EFB_TIMER_CNT_RESET|MICO_EFB_TIMER_CNT_PAUSE));
		// Disable and clear interrupts
		MICO_EFB_TIMER_WRITE_IRQENR (efb_address, 0x0); // Timer
		MICO_EFB_TIMER_WRITE_IRQSR (efb_address, 0xF);
	}
//	if (ctx->ufm_en)
//		MICO_EFB_UFM_WRITE_IRQENR (efb_address, 0x0); // UFM
}

/*
 *****************************************************************************
 * Interrupt handler. Each EFB component has it's own reset handler and must
 * be implemented by the developers in user code to reflect their application
 * behavior.
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *
 *****************************************************************************
 */
#ifndef __MICO_NO_INTERRUPTS__
void MicoEFBISR (MicoEFBCtx_t *ctx)
{
	unsigned char irq_source;
	
	MICO_EFB_READ_IRQR((size_t)(ctx->base), irq_source);
	switch (irq_source) 
	{
#ifndef __MICOEFB_NO_I2C_INTERRUPT__
		case 1: MicoEFB_I2C1ISR(ctx); MICO_EFB_WRITE_IRQR((size_t)(ctx->base), 0x1); break;
		case 2: MicoEFB_I2C2ISR(ctx); MICO_EFB_WRITE_IRQR((size_t)(ctx->base), 0x2); break;
#endif
#ifndef __MICOEFB_NO_SPI_INTERRUPT__
		case 4: MicoEFB_SPIISR(ctx); MICO_EFB_WRITE_IRQR((size_t)(ctx->base), 0x4); break;
#endif
#ifndef __MICOEFB_NO_TC_INTERRUPT__
		case 8: MicoEFB_TimerISR(ctx); MICO_EFB_WRITE_IRQR((size_t)(ctx->base), 0x8); break;
#endif
		default: break;
	}
}
#endif

/*
 *****************************************************************************
 * Initiate a SPI transfer that receives and transmits a configurable number 
 * of bytes.
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char isMaster	: Master (1) or Slave (0)
 *    unsigned char insertStart	: Assert chip select at start of transfer
 *    unsigned char insertStop	: Deassert chip select at enf of transfer
 *    unsigned char *txBuffer	: Bytes to be transmitted
 *    unsigned char *rxBuffer	: Bytes received
 *    unsigned char bufferSize	: Number of bytes to transfer. 0 refers to 1
 * 								  byte. 255 refers to 256 bytes.
 *
 * Return Value:
 *    char:
 *         0 => successful writes
 *
 *****************************************************************************
 */
char MicoEFB_SPITransfer (MicoEFBCtx_t *ctx,
							unsigned char isMaster,
							unsigned char slvIndex,
							unsigned char insertStart,
							unsigned char insertStop,
							unsigned char *txBuffer,
							unsigned char *rxBuffer,
							unsigned char bufferSize)
{
	size_t efb_address = (size_t)(ctx->base);
	unsigned char sts;
	
	// Is SPI busy?
	do {
		MICO_EFB_SPI_READ_SR (efb_address, sts);
		if ((sts & MICO_EFB_SPI_SR_TIP) == 0)
			break;
	} while (1);
	
	// Modify baudrate to atleast 6x slower that WISHBONE clock (XO2 limitation)
	MICO_EFB_SPI_WRITE_BR (efb_address, 0x6);
	
	// Set SPI mode (master or slave)
	if (isMaster) {
		if (insertStart) {
			MICO_EFB_SPI_WRITE_CSR (efb_address, ~(0x1<<slvIndex));
			MICO_EFB_SPI_WRITE_CR2 (efb_address, (MICO_EFB_SPI_CR2_MSTR | MICO_EFB_SPI_CR2_MCSH /*| MICO_EFB_SPI_CR2_CPOL | MICO_EFB_SPI_CR2_CPHA */));
		}
	} else {
		MICO_EFB_SPI_WRITE_CR2 (efb_address, 0x00);
	} 
	
#ifdef __01A__
	// Transmit first byte
	MICO_EFB_SPI_WRITE_TXDR (efb_address, *txBuffer);
#endif
	
	unsigned char xferCount = 0;
	do {
#ifndef __01A__
		MICO_EFB_SPI_WRITE_TXDR (efb_address, *txBuffer);
		txBuffer++;
#else
		// Is controller ready to transmit another byte?
		do {
			MICO_EFB_SPI_READ_SR (efb_address, sts);
			if (sts & MICO_EFB_SPI_SR_TRDY)
				break;
		} while (1);
		
		// Transmit byte
		if (xferCount < bufferSize) 
			// Last byte from buffer is already transmitted. A dummy byte
			// needs to be transmitted to read last byte on receive side
			// due to a flaw in silicon 
			txBuffer++;
		MICO_EFB_SPI_WRITE_TXDR (efb_address, *txBuffer);
#endif
		
		// Is controller ready with received byte?
		do {
			MICO_EFB_SPI_READ_SR (efb_address, sts);
			if (sts & MICO_EFB_SPI_SR_RRDY)
				break;
		} while (1);
		
		// Get received byte
		MICO_EFB_SPI_READ_RXDR (efb_address, *rxBuffer);
#ifndef __01A__
		rxBuffer++;
#else
		if (xferCount < bufferSize)
			rxBuffer++;
#endif
		
		if (xferCount == bufferSize)
			break;
		xferCount++;
	} while (1);
	
//	// Perform transfer
//	unsigned char xferCount = 0;
//	do {
//		// Transmit byte
//		MICO_EFB_SPI_WRITE_TXDR (efb_address, *txBuffer);
//		txBuffer++;
//		
//		do {
//			MICO_EFB_SPI_READ_SR (efb_address, sts);
//			if (sts & MICO_EFB_SPI_SR_RRDY)
//				break;
//		} while (1);
//		
//		// Receive byte
//		MICO_EFB_SPI_READ_RXDR (efb_address, *rxBuffer);
//		rxBuffer++;
//		
//		if (xferCount == bufferSize)
//			break;
//		xferCount++;
//	} while (1);
	
	// End transaction
	if (insertStop)
		MICO_EFB_SPI_WRITE_CR2 (efb_address, MICO_EFB_SPI_CR2_MSTR);
	
	return (0);
}

/*
 *****************************************************************************
 * Initiate a byte transmit
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char data		: Data byte to transfer
 *
 * Return Value:
 *    char:
 *         0 => status register contents prior to transmit of data
 *
 *****************************************************************************
 */
char MicoEFB_SPITxData (MicoEFBCtx_t *ctx, 
						unsigned char data)
{
    size_t efb_address = (size_t)(ctx->base);
	volatile unsigned char sts;
    
    // Check if transmit register is empty?
    do {
        MICO_EFB_SPI_READ_SR (efb_address, sts);
        if ((sts & MICO_EFB_SPI_SR_TRDY) != 0) 
        	break;
    } while (1);
    
    // Write byte to transmit register
    MICO_EFB_SPI_WRITE_TXDR (efb_address, data);
    
    return sts;
}

/*
 *****************************************************************************
 * Initiate a byte receive
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char data		: Data byte received
 *
 * Return Value:
 *    char:
 *         0 => status register contents after receive of data
 *
 *****************************************************************************
 */
char MicoEFB_SPIRxData (MicoEFBCtx_t *ctx,
						unsigned char *data)
{
    size_t efb_address = (size_t)(ctx->base);
	volatile unsigned char sts;
    
    // Check if receive register is full?
    do {
        MICO_EFB_SPI_READ_SR (efb_address, sts);
        if ((sts & MICO_EFB_SPI_SR_RRDY) != 0) 
        	break;
    } while (1);
    
    // Get byte from receive register
    MICO_EFB_SPI_READ_RXDR (efb_address, *data);
    
    return sts;
}

/*
 *****************************************************************************
 * Initiate a START command provided the I2C master can get control of the bus
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char i2c_idx		: I2C 1 (1) or 2 (2)
 *    unsigned char address		: Slave device address
 *    unsigned char read		: Read (1) or Write (0)
 *
 * Return Value:
 *    char:
 *         0 => successful writes
 *        -1 => failed to receive ack during addressing
 *        -2 => failed to receive ack when writing data
 *        -3 => arbitration lost during the operation
 *
 *****************************************************************************
 */
char MicoEFB_I2CStart (MicoEFBCtx_t *ctx, 
						unsigned char i2c_idx,	// I2C 1 or 2
						unsigned char read,		// Write (0) or Read (1) 
						unsigned char address)	// Slave address
{
	size_t efb_address = (size_t)(ctx->base);
	if (i2c_idx == 2) {
		efb_address += 10;
	}
	
	// Check if I2C is busy with another transaction?
	volatile unsigned char sts;
	do {
		MICO_EFB_I2C_READ_SR (efb_address, sts);
		if ((sts & MICO_EFB_I2C_SR_BUSY) == MICO_EFB_I2C_FREE)
			break;
	} while (1);
	
	// Load slave address and setup write to transmit the address
	MICO_EFB_I2C_WRITE_TXDR (efb_address, ((address << 1)|read));
	MICO_EFB_I2C_WRITE_CMDR (efb_address, (MICO_EFB_I2C_CMDR_STA | MICO_EFB_I2C_CMDR_WR));
	
#ifndef __01A__
	// Check if transmission is in progress?
	do {
		MICO_EFB_I2C_READ_SR (efb_address, sts);
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
			break; 
	} while (1);
	
	// Check if acknowledge is rcvd
	if ((sts & MICO_EFB_I2C_SR_RARC) == MICO_EFB_I2C_ACK_NOT_RCVD) {
		return (-1);
	}
	
	// Check if arbitration was lost
	if ((sts & MICO_EFB_I2C_SR_ARBL) == MICO_EFB_I2C_ARB_LOST) {
		return (-2);
	}
#endif
	
	return (0);
}


/*
 *****************************************************************************
 * Performs block writes. In addition it also allows the user to optionally:
 * 1. Initiate a START command prior to performing the block writes if the I2C
 *    is an I2C Master.
 * 2. Initiate a STOP command after performing the block writes if the I2C is 
 *    an I2C Master.
 * 3. Hold the SCL line low (i.e., clock stretching) after performing the 
 *    block writes if the I2C is an I2C Slave.
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char i2c_idx		: I2C 1 (1) or 2 (2)
 *    unsigned char slv_xfer	: I2C Master (0) or I2C Slave (1)
 *    unsigned char buffersize  : Number of bytes to be transferred. 0 refers
 *                                to 1 byte. 255 refers to 256 bytes.
 *    unsigned char *data		: Pointer to bytes to write
 *    unsigned char address		: Slave device address
 *    unsigned char insert_start: Insert START command prior to block transfer
 *    unsigned char insert_stop : Insert STOP command after the block transfer 
 *                                for I2C Master. Enable clock stretching 
 *                                after the block transfer for I2C Slave.
 *
 * Return Value:
 *    char:
 *         0 => successful writes
 *        -1 => failed to receive ack during addressing
 *        -2 => failed to receive ack when writing data
 *        -3 => arbitration lost during the operation
 *
 *****************************************************************************
 */
char MicoEFB_I2CWrite (MicoEFBCtx_t *ctx, 
						unsigned char i2c_idx,      // I2C 1 or 2  
						unsigned char slv_xfer,     // Is I2C the master (0) or slave (1)
						unsigned char buffersize,   // Number of bytes to be transfered (min 1 and max 256) 
						unsigned char *data,        // Buffer containing the data to be transferred
						unsigned char insert_start, // Master: Insert Start (or repeated Start) prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address)		// Slave address
{
	size_t efb_address = (size_t)(ctx->base);
	if (i2c_idx == 2) {
		efb_address += 10;
	}
	
	unsigned char sts;
	if ((slv_xfer == 0) && insert_start) {
		sts = MicoEFB_I2CStart (ctx, i2c_idx, MICO_EFB_I2C_WR_SEQUENCE, address);
		if (sts != 0)
			return sts;
	}
	
	// Wait until previous byte transfer is done
	do {
		MICO_EFB_I2C_READ_SR (efb_address, sts);
#ifndef __01A__
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
#else
		if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
#endif
			break;
	} while (1);
	
	// Transfer bytes from buffer
	unsigned char i = 0;
	do {
		
		// Transfer byte
		MICO_EFB_I2C_WRITE_TXDR (efb_address, *data);
		MICO_EFB_I2C_WRITE_CMDR (efb_address, MICO_EFB_I2C_CMDR_WR);
		
		// Wait until transfer is complete
		do {
			MICO_EFB_I2C_READ_SR (efb_address, sts);
#ifndef __01A__
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
#else
		if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
#endif
			break;
		} while (1);
		
		// Check if acknowledge is rcvd
		if (slv_xfer && (insert_stop == 0) && (i == buffersize)) {
			// If I2C is slave, it does not expect an acknowledge on the last transfer.
			;
		} else {
			if ((sts & MICO_EFB_I2C_SR_RARC) == MICO_EFB_I2C_ACK_NOT_RCVD) {
				return (-1);
			}
		}
		
		// Check if arbitration was lost
		if ((slv_xfer == 0) && ((sts & MICO_EFB_I2C_SR_ARBL) == MICO_EFB_I2C_ARB_LOST)) {
			return (-2);
		}
		
		// Exit if done
		if (i == buffersize) {
			if (insert_stop && (slv_xfer == 0)) {
				// Issue STOP command for a I2C master
				MICO_EFB_I2C_WRITE_CMDR (efb_address, MICO_EFB_I2C_CMDR_STO);
			}
				
			if ((insert_stop == 0) && slv_xfer) {
				// Disable clock stretching for a I2C slave
				MICO_EFB_I2C_WRITE_CMDR (efb_address, MICO_EFB_I2C_CMDR_CKSDIS);
			}
				  
			break;
		}
		
		// Increment buffer pointer and loop iterator
		i++;
		data++;
		
	} while (1);
	
	return (0);
}


/*
 *****************************************************************************
 * Performs block reads. In addition it also allows the user to optionally:
 * 1. Initiate a START command prior to performing the block reads if the I2C
 *    is an I2C Master.
 * 2. Initiate a STOP command after performing the block reads if the I2C is 
 *    an I2C Master.
 * 3. Hold the SCL line low (i.e., clock stretching) after performing the 
 *    block reads if the I2C is an I2C Slave.
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char i2c_idx		: I2C 1 (1) or 2 (2)
 *    unsigned char slv_xfer	: I2C Master (0) or I2C Slave (1)
 *    unsigned char buffersize  : Number of bytes to be transferred. 0 refers
 *                                to 1 byte. 255 refers to 256 bytes.
 *    unsigned char *data		: Pointer to buffer in which rcvd bytes are put
 *    unsigned char address		: Slave device address
 *    unsigned char insert_start: Insert START command prior to block transfer
 *    unsigned char insert_stop : Insert STOP command after the block transfer 
 *                                for I2C Master. Enable clock stretching 
 *                                after the block transfer for I2C Slave.
 *
 * Return Value:
 *    char:
 *         0 => successful reads
 *        -1 => failed to receive ack during addressing
 *        -2 => failed to receive ack when writing data
 *        -3 => arbitration lost during the operation
 *
 *****************************************************************************
 */
char MicoEFB_I2CRead (MicoEFBCtx_t *ctx, 
						unsigned char i2c_idx,      // I2C 1 or 2  
						unsigned char slv_xfer,     // Is I2C the master (0) or slave (1)
						unsigned char buffersize,   // Number of bytes to be received (min 1 and max 256) 
						unsigned char *data,        // Buffer to put received data in to
						unsigned char insert_start, // Master: Insert Start (or repeated Start) prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address)		// Slave address
{
	size_t efb_address = (size_t)(ctx->base);
	if (i2c_idx == 2) {
		efb_address += 10;
	}
	
	unsigned char sts;
	if ((slv_xfer == 0) && insert_start) {
		sts = MicoEFB_I2CStart (ctx, i2c_idx, MICO_EFB_I2C_RD_SEQUENCE, address);
		if (sts != 0)
			return sts;
	}
	
#ifndef __01A__
	// Wait until previous byte transfer is done
	do {
		MICO_EFB_I2C_READ_SR (efb_address, sts);
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
			break;
	} while (1);
#endif
	
	// Transfer bytes from buffer
	unsigned char i = 0;
	do {
		
		// Initiate transfer
		MICO_EFB_I2C_WRITE_CMDR (efb_address, MICO_EFB_I2C_CMDR_RD);
		
		// Wait until transfer is complete
		do {
			MICO_EFB_I2C_READ_SR (efb_address, sts);
			if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
				break;
		} while (1);
		
		// Check if arbitration was lost
		if ((slv_xfer == 0) && ((sts & MICO_EFB_I2C_SR_ARBL) == MICO_EFB_I2C_ARB_LOST)) {
			return (-2);
		}
		
		// Read incoming data byte
		MICO_EFB_I2C_READ_RXDR (efb_address, *data);
		
		// Exit if done
		if (i == (buffersize - 1)) {
			if (insert_stop && (slv_xfer == 0)) {
				// Issue STOP command for a I2C master
				MICO_EFB_I2C_WRITE_CMDR (efb_address, MICO_EFB_I2C_CMDR_STO);
			}
			
			if ((insert_stop == 0) && slv_xfer) {
				// Disable clock stretching for a I2C slave
				MICO_EFB_I2C_WRITE_CMDR (efb_address, MICO_EFB_I2C_CMDR_CKSDIS);
			}
			
			// Retrieve last byte
			data++;
			MICO_EFB_I2C_READ_RXDR (efb_address, *data);
			
			break;
		}
		
		// Increment buffer pointer and loop iterator
		i++;
		data++;
				
	} while (1);
	
    return (0);
}

/*
 *****************************************************************************
 * Sets up timer configuration and starts timer.
 *
 * Arguments:
 *    MicoEFBCtx_t *ctx			: EFB context
 *    unsigned char mode        : Timer mode
 *                                0 - Watchdog
 *                                1 - Clear Timer on Compare (CTC) Match
 *                                2 - Fast PWM
 *                                3 - Correct PWM
 *    unsigned char ocmode      : Timer counter output signal's mode
 *                                0 - Always zero
 *                                1 - Toggle on TOP match (non-PWM modes)
 *                                    Toggle on OCR match (Fast PWM mode)
 *                                    Toggle on OCR match (Correct PWM mode)
 *                                2 - Clear on TOP match (non-PWM modes)
 *                                    Clear on TOP match, set on OCR match (Fast PWM mode)
 *                                    Clear on OCR match when CNT incrementing, set on OCR match when CNT decrementing (Correct PWM mode)
 *                                3 - Set on TOP match (non-PWM modes)
 *                                    Set on TOP match, clear on OCR match (Fast PWM mode)
 *                                    Set on OCR match when CNT incrementing, clear on OCR match when CNT decrementing (Correct PWM mode)
 *    unsigned char sclk        : Clock source selection
 *                                0 - WISHBONE clock (rising edge)
 *                                2 - On-chip oscillator (rising edge)
 *                                4 - WISHBONE clock (falling edge)
 *                                6 - On-chip oscillator (falling edge)
 *    unsigned char cclk        : Divider selection
 *                                0 - Static 0
 *                                1 - sclk/1
 *                                1 - sclk/8
 *                                1 - sclk/64
 *                                1 - sclk/256
 *                                1 - sclk/1024
 *    unsigned char interrupt   : Enable (1) / Disable (0) interrupts
 *    unsigned int timerCount   : Timer TOP value (maximum 0xFFFF)
 *    unsigned int compareCount : Timer OCR (compare) value (maximum 0xFFFF)
 * 
 *****************************************************************************
 */
void MicoEFB_TimerStart (MicoEFBCtx_t *ctx,
							unsigned char mode,
							unsigned char ocmode,
							unsigned char sclk,
							unsigned char cclk,
							unsigned char interrupt,
							unsigned int timerCount,
							unsigned int compareCount)
{
	size_t efb_address = (size_t)(ctx->base);
	
	// Stop Timer
	MICO_EFB_TIMER_WRITE_CR2 (efb_address, (MICO_EFB_TIMER_CNT_RESET|MICO_EFB_TIMER_CNT_PAUSE));
	
	// Disable and clear interrupts
	MICO_EFB_TIMER_WRITE_IRQENR (efb_address, 0x00);
	MICO_EFB_TIMER_WRITE_IRQSR (efb_address, 0x0F);
	
	// Set up timer configuration
	MICO_EFB_TIMER_WRITE_CR0 (efb_address, (MICO_EFB_TIMER_GSRN_ENABLE | (cclk<<3) | sclk));
	MICO_EFB_TIMER_WRITE_CR1 (efb_address, (MICO_EFB_TIMER_TOP_USER_SELECT | (ocmode<<2) | mode));
	MICO_EFB_TIMER_SET_TOP (efb_address, timerCount);
	MICO_EFB_TIMER_SET_OCR (efb_address, compareCount);
	if (interrupt)
		MICO_EFB_TIMER_WRITE_IRQENR (efb_address, 0x0F);
	
	// Start timer
	MICO_EFB_TIMER_WRITE_CR2 (efb_address, 0x00);
}


