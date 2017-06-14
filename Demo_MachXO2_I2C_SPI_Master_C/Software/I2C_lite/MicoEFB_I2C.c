#include <stddef.h>
#include "system_conf.h"
#include "MicoEFB_I2C.h"
#include "MicoUtils.h"


#define EFB_WB_ADDR ((size_t)SLAVE_EFB_BASE_ADDRESS)


/*
 *****************************************************************************
 * Initiate a START command provided the I2C master can get control of the bus
 *
 * Arguments:
 *    	size_t efb_address		: EFB address off Wishbone Bus
  *    unsigned char address		: Slave device address, already shifted up to 8 bits
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
static char MicoEFB_I2CStart ( 
						unsigned char read,		// Write (0) or Read (1) 
						unsigned char mode,  // 1=start, 2=ReStart (we own the bus already so skip BUSY check)
						unsigned char address)	// Slave address
{

	volatile unsigned char sts;
	
	
	// Removed state checking
	
	
	// Check if I2C is busy with another transaction?
	do 
	{
		MICO_EFB_I2C_READ_SR(EFB_WB_ADDR, sts);
		if ((mode == MICO_EFB_I2C_START) && ((sts & MICO_EFB_I2C_SR_BUSY) == MICO_EFB_I2C_FREE))
			break;
		if ((mode == MICO_EFB_I2C_RESTART) && (sts & MICO_EFB_I2C_SR_TRRDY))
			break;   // Busy will be set in ReStart case, just check Tx/Rx is ready

	} while (1);

	
	// Load slave address and setup write to transmit the address
	MICO_EFB_I2C_WRITE_TXDR (EFB_WB_ADDR, (address | read));
	MICO_EFB_I2C_WRITE_CMDR (EFB_WB_ADDR, (MICO_EFB_I2C_CMDR_STA | MICO_EFB_I2C_CMDR_WR));
	
#ifndef __01A__
	// Check if transmission is in progress?
	do {
		MICO_EFB_I2C_READ_SR (EFB_WB_ADDR, sts);
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
			break; 
	} while (1);
	
#if 0 //------------------------------------------------------------------
	// JJM:
	// What do we do if the operation fails?????
	// Therefore, remove error checking to save space.
	// Check if acknowledge is rcvd
	if ((sts & MICO_EFB_I2C_SR_RARC) == MICO_EFB_I2C_ACK_NOT_RCVD) {
		return (-1);
	}
	
	// Check if arbitration was lost
	if ((sts & MICO_EFB_I2C_SR_ARBL) == MICO_EFB_I2C_ARB_LOST) {
		return (-2);
	}
#endif //------------------------------------------------------------------

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
 *    size_t efb_address		: EFB address on Wishbone bus
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
 * 
 * 
 * JJM: remove address, slave transfer, i2c_idx cause only doing Master on #1
 *****************************************************************************
 */
char MicoEFB_I2CWrite ( 
						unsigned char buffersize,   // Number of bytes to be transfered (min 1 and max 256) 
						unsigned char *data,        // Buffer containing the data to be transferred
						unsigned char insert_start, // Master: Insert Start or ReStart prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address)		// Slave address
{

	
	unsigned char sts;
	if (insert_start) 
	{
		sts = MicoEFB_I2CStart(MICO_EFB_I2C_WR_SEQUENCE, insert_start, address);
		if (sts != 0)
			return sts;
	}
	
	// Wait until previous byte transfer is done
	do {
		MICO_EFB_I2C_READ_SR(EFB_WB_ADDR, sts);
#ifndef __01A__
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
#else
		if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
#endif
			break;
	} while (1);
	
	// Transfer bytes from buffer
	unsigned char i = 1;  // JJM: fixed to start at 1, otherwise writes 1 too many
	do {
		
		// Transfer byte
		MICO_EFB_I2C_WRITE_TXDR(EFB_WB_ADDR, *data);
		MICO_EFB_I2C_WRITE_CMDR(EFB_WB_ADDR, MICO_EFB_I2C_CMDR_WR);
		
		// Wait until transfer is complete
		do {
			MICO_EFB_I2C_READ_SR(EFB_WB_ADDR, sts);
#ifndef __01A__
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
#else
		if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
#endif
			break;
		} while (1);


#if 0 //------------------------------------------------------------------
	// JJM:
	// What do we do if the operation fails?????
	// Tehrefore, remove error checking to save space.
	// Check if acknowledge is rcvd
		
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
#endif //------------------------------------------------------------------		


		// Exit if done
		if (i == buffersize) 
		{
			if (insert_stop) 
			{
				// Issue STOP command for a I2C master
				MICO_EFB_I2C_WRITE_CMDR(EFB_WB_ADDR, MICO_EFB_I2C_CMDR_STO);
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
 *    size_t efb_address		: EFB address on Wishbone bus
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
 * 
 * * JJM: remove address, slave transfer, i2c_idx cause only doing Master on #1
 * 
 *****************************************************************************
 */
char MicoEFB_I2CRead (
						unsigned char buffersize,   // Number of bytes to be received (min 1 and max 256) 
						unsigned char *data,        // Buffer to put received data in to
						unsigned char insert_start, // Master: 1=Insert Start, 2=ReStart prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address)		// Slave address
{

	
	unsigned char sts;
	
	if (insert_start) 
	{
		sts = MicoEFB_I2CStart(MICO_EFB_I2C_RD_SEQUENCE, insert_start, address);
		if (sts != 0)
			return sts;
	}
	
#ifndef __01A__
	// Wait until previous byte transfer is done
	do {
		MICO_EFB_I2C_READ_SR(EFB_WB_ADDR, sts);
		if ((sts & MICO_EFB_I2C_SR_TIP) == MICO_EFB_I2C_TRANSMISSION_DONE)
			break;
	} while (1);
#endif
	
	// Transfer bytes from buffer
	unsigned char i = 1;  // JJM: simplify, maybe save some code space?
	do 
	{
		
		// Initiate transfer
		MICO_EFB_I2C_WRITE_CMDR(EFB_WB_ADDR, MICO_EFB_I2C_CMDR_RD);
		
		// Wait until transfer is complete
		do 
		{
			MICO_EFB_I2C_READ_SR(EFB_WB_ADDR, sts);
			if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
				break;
		} while (1);
	
	
// JJM: Remove check???	
		// Check if arbitration was lost
		if ((sts & MICO_EFB_I2C_SR_ARBL) == MICO_EFB_I2C_ARB_LOST)
		{
			return (-2);
		}
		
		// Read incoming data byte
		MICO_EFB_I2C_READ_RXDR(EFB_WB_ADDR, *data);
		
		////////////////////////////////////////////////////////////////
		// Enter exit condition after getting next to last byte
		////////////////////////////////////////////////////////////////
		if (i == buffersize - 1) 
		{
			if (insert_stop) 
			{
				// Issue STOP command for a I2C master
				MICO_EFB_I2C_WRITE_CMDR(EFB_WB_ADDR, MICO_EFB_I2C_CMDR_RD +
													  MICO_EFB_I2C_CMDR_STO + 
													  MICO_EFB_I2C_CMDR_NACK);  // JJM: was missing NAK
			}
			
	
			// Wait until transfer is complete
			do 
			{
				MICO_EFB_I2C_READ_SR(EFB_WB_ADDR, sts);
				if ((sts & MICO_EFB_I2C_SR_TRRDY) == MICO_EFB_I2C_DATA_READY)
					break;
			} while (1);
			
			// Retrieve last byte
			data++;
			MICO_EFB_I2C_READ_RXDR(EFB_WB_ADDR, *data);
			
			break;
		}
		
		// Increment buffer pointer and loop iterator
		i++;
		data++;
				
	} while (1);
	
    return (0);
}

