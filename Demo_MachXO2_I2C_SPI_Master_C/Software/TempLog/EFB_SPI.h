/****************************************************************************
**
**  Description:
**  NOTE:
 * This is a customized version of the Mico EFB all-inclusive driver file
 * that gets imported into a project when an EFB component is added to a 
 * Mico System.  Unfortunately the full EFB, with all drivers for SPI, I2C, Timer
 * etc. is too large for the XO2-1200, so this reduced size driver file is used.
 * The same #defines from the full EFB are borrowed, so conflicts will arise
 * if the auto-generated/included MSB EFB header is also present in the same
 * project.  Use one method or the other.
*        
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
 void MicoEFB_SPIInit(void);
 
char MicoEFB_SPITransfer (
							unsigned char readMode,
							unsigned char *txBuffer,
							unsigned char *rxBuffer,
							unsigned char bufferSize);
char MicoEFB_SPITxData (
						unsigned char data);
char MicoEFB_SPIRxData (
						unsigned char *data);



	
