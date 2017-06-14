/*
 * NOTE:
 * This is a customized version of the Mico EFB all-inclusive driver file
 * that gets imported into a project when an EFB component is added to a 
 * Mico System.  Unfortunately the full EFB, with all drivers afor SPI, I2C, Timer
 * etc. is too large for the XO2-1200, so this reduced size driver file is used.
 * The same #defines from the full EFB are borrowed, so conflicts will arise
 * if the auto-generated/included MSB EFB header is also present in the same
 * project.  Use one method or the other.
 */ 

#ifndef MICOEFB_I2C_H_
#define MICOEFB_I2C_H_


#define MICO_EFB_I2C_NOSTART 0
#define MICO_EFB_I2C_START   1
#define MICO_EFB_I2C_RESTART 2
	


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
	
	
	// JJM" the delay concerns me...
#define MICO_EFB_I2C_WRITE_CMDR(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)+MICO_EFB_I2C_CMDR));\
	(MicoSleepMicroSecs (20))
	
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
	
	
	
	
	
char MicoEFB_I2CWrite ( 
						unsigned char buffersize,   // Number of bytes to be transfered (min 1 and max 256) 
						unsigned char *data,        // Buffer containing the data to be transferred
						unsigned char insert_start, // Master: Insert Start (or repeated Start) prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address);		// Slave address	
						
char MicoEFB_I2CRead (
						unsigned char buffersize,   // Number of bytes to be received (min 1 and max 256) 
						unsigned char *data,        // Buffer to put received data in to
						unsigned char insert_start, // Master: Insert Start (or repeated Start) prior to data transfer  
						unsigned char insert_stop,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
						unsigned char address);		// Slave address
				
						
						
						
#endif /*MICOEFB_I2C_H_*/
