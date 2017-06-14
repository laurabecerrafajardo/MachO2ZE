/****************************************************************************
**
**  Description:
** Customized SPI drivers that remove anything other than the bare minimum
*  to get the job done in an XO2-1200
* 
*  
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
#include "EFB_SPI.h"
#include "MicoUtils.h"
#include "system_conf.h"



#define EFB_WB_ADDR ((size_t)SLAVE_EFB_BASE_ADDRESS)

#define SPI_SLAVE_INDEX (1)


/**
 * Set any specific initial conditions for the SPI controller
 * in Master mode.
 */
void MicoEFB_SPIInit(void)
{
	// Modify baudrate to atleast 6x slower that WISHBONE clock (XO2 limitation)
	MICO_EFB_SPI_WRITE_BR(EFB_WB_ADDR, 0x6);
}




/**
 * Clock out a sequence of bytes performing either a write to the slave,
 * or a read from the slave.
 * 
 * clocking out the write buffer also clocks in return data from the slave into
 * the receive buffer.  To read 8 bytes, 8 "bytes" from the txBuffer need to
 * be sent so the byte clocks run long enough to receive 8 bytes into rxBuffer.
 * 
 * This only works in Master Mode (i.e. initiating accesses to a slave)
 * This only works for SPI #1.
 * This is hard-coded for slave0 (one CSn)
 * This always does a Start, byte transfer, then Stop.
 * 
 * @param readMode set if doing a read, then an extra byte clocking cycle is 
 * done to get the last word read in correctly to the rxbuffer.
 * @param txBuffer pointer to bytes that comprise the command and data to send
 * to the SPI slave device.
 * @param rxBuffer pointer to storage for bytes red from the SPI slave device.
  *@param bufferSize number of bytes in the txBuffer to send
  * 
  * @note this has only been tested against an ATMEL SPI Flash slave device
 */
char MicoEFB_SPITransfer (
							unsigned char readMode,
							unsigned char *txBuffer,
							unsigned char *rxBuffer,
							unsigned char bufferSize)
{
	unsigned char sts;
	unsigned char dummy;
	
	// Is SPI busy?
	do 
	{
		MICO_EFB_SPI_READ_SR (EFB_WB_ADDR, sts);
		if ((sts & MICO_EFB_SPI_SR_TIP) == 0)
			break;
	} while (1);
	
	
	// Set SPI mode (only master supported)

	MICO_EFB_SPI_WRITE_CSR (EFB_WB_ADDR, ~(SPI_SLAVE_INDEX));			
	MICO_EFB_SPI_WRITE_CR2 (EFB_WB_ADDR, (MICO_EFB_SPI_CR2_MSTR | MICO_EFB_SPI_CR2_MCSH /*| MICO_EFB_SPI_CR2_CPOL | MICO_EFB_SPI_CR2_CPHA */));
	

	if (readMode)
		++bufferSize;   // need to read one extra time to get bytes out of SPI rx data register
		
	unsigned char xferCount = 1;
	
	do 
	{
		// Write byte to be sent to SPI slave
		MICO_EFB_SPI_WRITE_TXDR(EFB_WB_ADDR, *txBuffer);
		txBuffer++;
		
		// Is controller ready with received byte?
		do 
		{
			MICO_EFB_SPI_READ_SR(EFB_WB_ADDR, sts);
			if (sts & MICO_EFB_SPI_SR_RRDY)
				break;
		} while (1);
		
		// Get received byte into RxBuffer if reading
		if (readMode && (xferCount < bufferSize))
	    {
			MICO_EFB_SPI_READ_RXDR(EFB_WB_ADDR, *rxBuffer);
			rxBuffer++;
	    }
		else  // just throw away recvd byte
		{
			MICO_EFB_SPI_READ_RXDR(EFB_WB_ADDR, dummy);		
		}
		
		if (xferCount == bufferSize)
			break;
			
		xferCount++;
		
	} while (1);
	
	// End transaction
	MICO_EFB_SPI_WRITE_CR2(EFB_WB_ADDR, MICO_EFB_SPI_CR2_MSTR);  // stop command
		
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
char MicoEFB_SPITxData ( 
						unsigned char data)
{
 	volatile unsigned char sts;
    
    // Check if transmit register is empty?
    do 
    {
        MICO_EFB_SPI_READ_SR (EFB_WB_ADDR, sts);
        if ((sts & MICO_EFB_SPI_SR_TRDY) != 0) 
        	break;
    } while (1);
    
    // Write byte to transmit register
    MICO_EFB_SPI_WRITE_TXDR (EFB_WB_ADDR, data);
    
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
char MicoEFB_SPIRxData (
						unsigned char *data)
{
	volatile unsigned char sts;
    
    // Check if receive register is full?
    do 
    {
        MICO_EFB_SPI_READ_SR (EFB_WB_ADDR, sts);
        if ((sts & MICO_EFB_SPI_SR_RRDY) != 0) 
        	break;
    } while (1);
    
    // Get byte from receive register
    MICO_EFB_SPI_READ_RXDR (EFB_WB_ADDR, *data);
    
    return sts;
}



