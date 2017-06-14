/****************************************************************
* Mico8 on MachXO2 Pico Board
* SPI Flash access with EFB SPI module.
* SPI Drivers are local files.  The EFB SPI drivers are not used.
*
*****************************************************************/
#include "MicoUtils.h"
#include "DDStructs.h"
#include "MicoUart.h"
#include "system_conf.h"
#include "EFB_SPI.h"

// MACROs for direct memory access 
#define LM8_READ_MEM_BYTE(X, Y) \
	(Y) = (__builtin_import((size_t)(X)))

/* Macros for writing each byte of the Data Register */
#define LM8_WRITE_MEM_BYTE(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)))


// Defines to better describe operation being done
#define SPI_WR_COMMAND 0
#define SPI_WR_DATA    0
#define SPI_RD_DATA    1



////////////////////////////////////////////////////////
// 
//      PROTOTYPES
//
////////////////////////////////////////////////////////

void	sim_spi(void);
void readStatusReg(void);

////////////////////////////////////////////////////////
// 
//      GLOBALS
//
////////////////////////////////////////////////////////


char HexChar[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
	                '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
	                
char DisplayBuf[32];

unsigned char SPI_Addr_hi;
unsigned char SPI_Addr_lo;


/***************************************************************
 * See if new char recvd in UART Rx
 * doesn't read it out, just returns true if a char is avail.								   *
 ***************************************************************/	  
char keyPress(void)
{	
	char rdVal; 
	 
	MICO_UART_RD_LSR(UART_BASE_ADDRESS, rdVal);
			      
    if (rdVal & MICOUART_LSR_RX_RDY_MASK)
    	return(1);
    else
    	return(0);
  
}
      		                
      		                
/**
 * Send a NULL terminated string to the Uart.	
 * Hard-coded to write to UART component "uart" in MSB.
 * 
 */
void SendString(char *str)
{
	while (*str != '\0') 
	{
		MicoUart_putC(&uart_core_uart, *str);
		str++;
	}	
}



char SPI_UnProtectSector0(void)
{
	unsigned char tx_data[4];
	unsigned char rx_data[4];
	char err;


	tx_data[0] = 0x06;  // Write Enable Command
	err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND, // readMode
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							1 // bufferSize
							);
	
	/*
	 * This only needs to be done once at power-up, but the checking might be more code
	 * than it is worth, so just do it every time before we erase.
	 */
	tx_data[0] = 0x39;  // Sector Unprotect Command
	tx_data[1] = 0;  // Address[23:16]
	tx_data[2] = 0;  // Address[15:8]
	tx_data[3] = 0;  // Address[7:0]

	err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							4 // bufferSize
							);
	return(err);
}


/*
 * Erase sector 0 (64kB size).
 * Don't feel like erasing the entire chip cause it can take 7 seconds.
 * Anyway, who is going to log that much data?
 * 64kB = 64k samples @ 0.5sec = 30k sec = 9 hrs.
 * More than enough for a simple demo purpose.
 */
char SPI_EraseSector0(void)
{
	unsigned char tx_data[4];
	unsigned char rx_data[4];
	char err;


	tx_data[0] = 0x06;  // Write Enable Command
	err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND, // readMode
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							1 // bufferSize
							);
	

	tx_data[0] = 0xD8;  // 64kB block erase
	tx_data[1] = 0;  // Address[23:16]
	tx_data[2] = 0;  // Address[15:8]
	tx_data[3] = 0;  // Address[7:0]

	err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND, //
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							4 // bufferSize
							);
							
		// DEBUG: check if Erasing by reading the status register
		readStatusReg();
		SendString(DisplayBuf);
						
#ifndef SIMULATION	
	// Wait for sector to erase					
	MicoSleepMilliSecs(500);
#endif	
	
	// Could check by reading the status register
						
	return(err);
}


/*
 * Write the 2 temperature bytes to the current SPI flash memory location in sector 0.
 * The address is then incremented by 2 to point to the next location.
 * If the address is too big then it fails? 
  */
char SPI_StoreTemp(unsigned char data_hi, unsigned char data_lo)
{
	unsigned char tx_data[8];
	unsigned char rx_data[8];
	char err;

	if ((SPI_Addr_hi == 0xff) && (SPI_Addr_lo == 0xfe))
		return(-1);  // full, at end of sector
	
		tx_data[0] = 0x06;  // Write Enable Command
		err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND, //
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							1 // bufferSize
							);
			
		if (err)
			return(-2);
			
		// DEBUG: check if WEN mode succeeded by reading the status register
		readStatusReg();
		SendString(DisplayBuf);
		
		
		tx_data[0] = 0x02; //  Byte Program command
		tx_data[1] = 0;  // Address[23:16]
		tx_data[2] = SPI_Addr_hi;  // Address[15:8]
		tx_data[3] = SPI_Addr_lo;  // Address[7:0]
		tx_data[4] = data_hi;      // Big endian order
		tx_data[5] = data_lo;
		
		err = MicoEFB_SPITransfer(
							SPI_WR_DATA, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							6 // bufferSize
							);
							
							
		// DEBUG: check if Programming mode succeeded by reading the status register
		readStatusReg();
		SendString(DisplayBuf);
		

		// Next address
		if (SPI_Addr_lo >= 0xfe)
			++SPI_Addr_hi;
		SPI_Addr_lo = SPI_Addr_lo + 2;
		
#ifndef SIMULATION
		MicoSleepMilliSecs(5);  // Max Page Program time
#endif

	return(err);
}


/*
 * Read the 2 temperature bytes from the current SPI flash memory location in sector 0.
 * The address is then incremented by 2 to point to the next location.
 * If the address is too big then it fails? 
  */
char SPI_RecallTemp(unsigned char *data_hi, unsigned char *data_lo)
{
	unsigned char tx_data[8];
	unsigned char rx_data[8];
	char err;

	if ((SPI_Addr_hi == 0xff) && (SPI_Addr_lo == 0xfe))
		return(-1);  // full, at end of sector
	
		// Setup Read Command from Address
		tx_data[0] = 0x03;  // Sequential Read Array (slow rate) command
		tx_data[1] = 0;  // Address[23:16]
		tx_data[2] = SPI_Addr_hi;  // Address[15:8]
		tx_data[3] = SPI_Addr_lo;  // Address[7:0]
		tx_data[4] = 0;  // dummy for clocking out first read byte
		tx_data[5] = 0;  // dummy for clocking out 2nd read byte
		
		err = MicoEFB_SPITransfer(
								SPI_RD_DATA, // 
								tx_data, // *txBuffer,
								rx_data, // *rxBuffer,
								6 // bufferSize
								);

		*data_hi = rx_data[4];
		*data_lo = rx_data[5];

		// Compute next address
		if (SPI_Addr_lo >= 0xfe)
			++SPI_Addr_hi;
		SPI_Addr_lo = SPI_Addr_lo + 2;
		
	return(err);
}



void readDevID(void)
{
	unsigned char tx_data[8];
	unsigned char rx_data[8];
	char err;
	char *p;
	unsigned char i;
	
	p = DisplayBuf;
	
	tx_data[0] = 0x9f;  // read Manf. ID
	tx_data[1] = 0;  // dummy to shift out read byte 1
	tx_data[2] = 0;  // dummy to shift out read byte 2
	tx_data[3] = 0;  // dummy to shift out read byte 3
	tx_data[4] = 0;  // dummy to shift out read byte 4
	tx_data[5] = 0;  // dummy to shift out read byte 4
	
	err = MicoEFB_SPITransfer (
							SPI_RD_DATA, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							6 // bufferSize
                          );
                
    for (i = 1; i < 6; i++)
    {   
  		*p++ = HexChar[rx_data[i]>>4];
		*p++ = HexChar[rx_data[i] & 0x0f];
		*p++ = 	' ';			
    }
 
	*p++ = '\r';
	*p++ = '\n';
	*p++ = '\0';

							
}


void readStatusReg(void)
{
	unsigned char tx_data[4];
	unsigned char rx_data[4];
	char err;
	char *p;

	DisplayBuf[0] = 'S';
	DisplayBuf[1] = ':';
	p = &DisplayBuf[3];
	
	tx_data[0] = 0x05;  // read status reg
	tx_data[1] = 0;  // dummy to shift out read byte 1
	
	err = MicoEFB_SPITransfer (
							SPI_RD_DATA, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							2 // bufferSize
                          );
                
 
    
  	*p++ = HexChar[rx_data[1]>>4];
	*p++ = HexChar[rx_data[1] & 0x0f];

	*p++ = '\r';
	*p++ = '\n';
	*p++ = '\0';

							
}


/***************************************************************
 * Print the main menu on the hyperterminal	
 * 
 *
 ***************************************************************/
void showMainMenu(void)
{
	// Print Main menu
	SendString ("\t-- MAIN MENU: SPI --\r\n");
	SendString ("\tD - Diag\r\n");
	SendString ("\tE - Erase\r\n");
	SendString ("\tS - Store\r\n");
	SendString ("\tR - Recall\r\n");
	SendString ("> ");
	
}



/*************************
 * USER-MAIN ENTRY POINT *
 * 
 *************************/
int main (void)
{
#ifdef SIMULATION 
	sim_spi();   // never returns
#else
	
	char err;
	char selection;
	unsigned char i, x, y;
	unsigned char val;
	unsigned char save_hi, save_lo;
	
	val = 0;
	
	SendString("\033[2JMachXO2 SPI Master Access Demo\r\n");	
		
	MicoEFB_SPIInit();   // setup SPI Master controller for operation
	SPI_UnProtectSector0();


	do 
	{
		err = 0;
		
		// Print Main menu and wait for user input
		showMainMenu();
		
		MicoUart_getC(&uart_core_uart, &selection);
		MicoUart_putC(&uart_core_uart, selection);
		
		// Select operation based on user input
		switch (selection)
		{
		
			case 'd':   // Diagnostics
			case 'D':   // 
				 SendString("\r\nDevID: ");
				 readDevID();   // works, returns what is in data sheet
				 SendString(DisplayBuf);

				 readStatusReg();
				 SendString(DisplayBuf);
				 break;
				 
			case 'e':   // Erase SPI flash sector
			case 'E':   // 
				err = SPI_EraseSector0();
				SPI_Addr_hi = 0;
				SPI_Addr_lo = 0;
				
				 break;
				 
				 
			case 's':   // Store values into SPI flash
			case 'S':   // Address keeps incrementing
				for (i = 0; i < 8; i++)
				{
					err = SPI_StoreTemp(val, val + 1);
					if (err)
						break;
					val = val + 2;
				}
				break;

			case 'r':   // Read values from SPI Flash
			case 'R':   // until we get to unwritten (erased) memory
				save_hi = SPI_Addr_hi;
				save_lo = SPI_Addr_lo;
				
				SPI_Addr_hi = 0;
				SPI_Addr_lo = 0;
				do
				{
					err = SPI_RecallTemp(&x, &y);
					
					DisplayBuf[0] = HexChar[x>>4];
					DisplayBuf[1] = HexChar[x & 0x0f];
					DisplayBuf[2] = ' ';	
					DisplayBuf[3] = HexChar[y>>4];
					DisplayBuf[4] = HexChar[y & 0x0f];
					DisplayBuf[5] = ' ';
					DisplayBuf[6] = '\0'; 
					SendString(DisplayBuf);
				} while(!((x == 0xff) && (y == 0xff)) && !err);
				SPI_Addr_hi = save_hi;
				SPI_Addr_lo = save_lo;
				SendString("\r\n");
				
				break;
				
			default: 
				break;
		}
		
		if (err)
			SendString("ERROR!\r\n");
	
	} while (1);
	
#endif	

	return(0);
}



//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

#ifdef SIMULATION 
void	sim_spi(void)
{
	unsigned char tx_data[64];
	unsigned char rx_data[64];
	char err;

	MicoEFB_SPIInit();
	
	
	/*****************************************
	 * Show we are here on LCD 
	 *****************************************/
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, 0xAA);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, 0xBB);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, 0xCC);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, 0xDD);
	
	
	/*****************************************
	 * Read Flash Device ID code 
	 *****************************************/
	
	tx_data[0] = 0x9f;  // read Manf. ID
	tx_data[1] = 0;  // dummy to shift out read byte 1
	tx_data[2] = 0;  // dummy to shift out read byte 2
	tx_data[3] = 0;  // dummy to shift out read byte 3
	tx_data[4] = 0;  // dummy to shift out read byte 4
	tx_data[5] = 0;  // dummy to shift out read byte 4
 

	err = MicoEFB_SPITransfer (
							SPI_RD_DATA, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							6 // bufferSize
							);
		
	/*****************************************
	 * Display returned values
	 *****************************************/
							
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, rx_data[1]);		// first read byte is junk
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, rx_data[2]);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, rx_data[3]);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, rx_data[4]);


	/*****************************************
	 * Erase Sector
	 *****************************************/
	SPI_EraseSector0();
	

	/*****************************************
	 * Write a Sequence
	 *****************************************/
	SPI_Addr_hi = 0;
	SPI_Addr_lo = 0;
	SPI_StoreTemp(0xBE, 0xEF);
	SPI_StoreTemp(0x11, 0x22);
	SPI_StoreTemp(0x33, 0x44);
	SPI_StoreTemp(0xDE, 0xAD);	
	
	/*****************************************
	 * Read a Sequence and display
	 *****************************************/
	SPI_Addr_hi = 0;
	SPI_Addr_lo = 0;
	
	SPI_RecallTemp(&rx_data[0], &rx_data[1]);
	SPI_RecallTemp(&rx_data[2], &rx_data[3]);
	
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, rx_data[0]);		
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, rx_data[1]);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, rx_data[2]);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, rx_data[3]);

	SPI_RecallTemp(&rx_data[0], &rx_data[1]);
	SPI_RecallTemp(&rx_data[2], &rx_data[3]);
	
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, rx_data[0]);		
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, rx_data[1]);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, rx_data[2]);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, rx_data[3]);
	
	
}
#endif		
