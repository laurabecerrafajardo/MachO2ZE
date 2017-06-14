/****************************************************************
*   MachXO2-1200 Pico Board Temperature Logging Demo
* 
* This application demonstrates using the LM8 and C drivers and 
* application code to read temperature values from an I2C sensor,
* display the values on the LCD and terminal (UART) and record
* the readings in SPI flash for later recall.
* 
* Major Points:
* - Max 2144 instructions will fit in the XO2-1200 (4 EBRs) 
* - EFB component is not used so custom drivers can be compiled in
* - I2C and SPI drivers are customized to be as small as possible
* - limitted user interaction due to code size (i.e. no temperature 
* 		display in Fahrenheit) or features like recording min/max
* 		or setting alarms (TMP101 supports this)
* 
*****************************************************************/
#include "MicoUtils.h"
#include "DDStructs.h"
#include "MicoUart.h"
#include "system_conf.h"
#include "MicoEFB_I2C.h"
#include "EFB_SPI.h"

#define I2C_READ  (1)
#define I2C_WRITE (0)


#define TMP101_I2C_ADDR (0x4a<<1)   // 7 bit address:100_1010 shifted up to 8 bit


//#define DISPLAY_RAW_HEX_DATA 1   // define this to display the raw binary temperature data

// Precision of the Temperature A/D converter
// The define is the exact bit position in the Command Register
// so no upshifting is needed when writing to the register.
#define TEMP9BIT  0x00
#define TEMP10BIT 0x20 
#define TEMP11BIT 0x40
#define TEMP12BIT 0x60


// Defines to better describe operation being done
#define SPI_WR_COMMAND 0
#define SPI_WR_DATA    0
#define SPI_RD_DATA    1




// MACROs for direct memory access 
#define LM8_READ_MEM_BYTE(X, Y) \
	(Y) = (__builtin_import((size_t)(X)))

#define LM8_WRITE_MEM_BYTE(X, Y) \
	(__builtin_export((char)(Y), (size_t)(X)))

#define EFB_WB_ADDR ((size_t)SLAVE_EFB_BASE_ADDRESS)


////////////////////////////////////////////////////////
// 
//      PROTOTYPES
//
////////////////////////////////////////////////////////
void	sim_test_i2c_eeprom(void);



////////////////////////////////////////////////////////
// 
//      GLOBALS
//
////////////////////////////////////////////////////////
char TempConv;
unsigned char RawTempValLo;
unsigned char RawTempValHi;
unsigned char Precision;

unsigned char Logging;

unsigned char SPI_Addr_hi;
unsigned char SPI_Addr_lo;

char *CFractional[16 * 2] =
{
	// positive temperatures
	".0 C",      // 0x00 = 0/16
	".0625 C",   // 0x10 = 1/16
	".125 C",    // 0x20 = 2/16
	".1875 C",   // 0x30 = 3/16
	".25 C",     // 0x40 = 4/16
	".3125 C",   // 0x50 = 5/16
	".375 C",    // 0x60 = 6/16
	".4375 C",   // 0x70 = 7/16
	".5 C",      // 0x80 = 8/16
	".5625 C",   // 0x90 = 9/16
	".625 C",    // 0xA0 = 10/16
	".6875 C",   // 0xB0 = 11/16
	".75 C",     // 0xC0 = 12/16
	".8125 C",   // 0xD0 = 13/16
	".875 C",    // 0xE0 = 14/16
	".9375 C",    // 0xF0 = 15/16
	
	// negative temperatures
	".0 C",      // 0x00   -0/16
	".9375 C",   // 0x10   -15/16
	".875 C",    // 0x20   -14/16
	".8125 C",   // 0x30   -13/16
	".75 C",     // 0x40   -12/16
	".6875 C",   // 0x50   -11/16
	".625 C",    // 0x60   -10/16
	".5625 C",   // 0x70    -9/16
	".5 C",      // 0x80    -8/16
	".4375 C",   // 0x90    -7/16
	".375 C",    // 0xA0    -6/16
	".3125 C",   // 0xB0    -5/16
	".25 C",     // 0xC0    -4/16
	".1875 C",   // 0xD0    -3/16
	".125 C",    // 0xE0    -2/16
	".0625 C"    // 0xF0    -1/16
};
	
		                
char DisplayBuf[32];


/**
 * Convert a Hex nibble (4 bits) into the ASCII printable character.
 * This is actually smaller than a look-up table in this particular
 * LM8/XO2 implementation.  Otehr memory model size/application may
 * find the lookup table is smaller code size.
 */
char Hex2Char(unsigned char x)
{
	if (x > 9)
		return(('A' - 10) + x);
	else
		return('0' + x);
}

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
 * METRIC:
 */
void SendString(char *str)
{
	while (*str != '\0') 
	{
		MicoUart_putC(&uart_core_uart, *str);
		str++;
	}	
}




void SPI_UnProtectSector0(void)
{
	unsigned char tx_data[4];
	unsigned char rx_data[4];

	tx_data[0] = 0x06;  // Write Enable Command
	MicoEFB_SPITransfer(
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

	MicoEFB_SPITransfer(
							SPI_WR_COMMAND, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							4 // bufferSize
							);
}


/*
 * Erase sector 0 (64kB size).
 * Don't feel like erasing the entire chip cause it can take 7 seconds.
 * Anyway, who is going to log that much data?
 * 64kB = 64k samples @ 0.5sec = 30k sec = 9 hrs.
 * More than enough for a simple demo purpose.
 */
void SPI_EraseSector0(void)
{
	unsigned char tx_data[4];
	unsigned char rx_data[4];

	tx_data[0] = 0x06;  // Write Enable Command
	MicoEFB_SPITransfer(
							SPI_WR_COMMAND, // readMode
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							1 // bufferSize
							);
	

	tx_data[0] = 0xD8;  // 64kB block erase
	tx_data[1] = 0;  // Address[23:16]
	tx_data[2] = 0;  // Address[15:8]
	tx_data[3] = 0;  // Address[7:0]

	MicoEFB_SPITransfer(
							SPI_WR_COMMAND, //
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							4 // bufferSize
							);
			
	
	// Wait for sector to erase					
	MicoSleepMilliSecs(500);
	
	
	// Could check by reading the status register
						
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

	if ((SPI_Addr_hi == 0xff) && (SPI_Addr_lo == 0xfe))
		return(-1);  // full, at end of sector
	
		tx_data[0] = 0x06;  // Write Enable Command
		MicoEFB_SPITransfer(
							SPI_WR_COMMAND, //
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							1 // bufferSize
							);
			
			
		// DEBUG: check if WEN mode succeeded by reading the status register
	
		
		tx_data[0] = 0x02; //  Byte Program command
		tx_data[1] = 0;  // Address[23:16]
		tx_data[2] = SPI_Addr_hi;  // Address[15:8]
		tx_data[3] = SPI_Addr_lo;  // Address[7:0]
		tx_data[4] = data_hi;      // Big endian order
		tx_data[5] = data_lo;
		
		MicoEFB_SPITransfer(
							SPI_WR_DATA, // 
							tx_data, // *txBuffer,
							rx_data, // *rxBuffer,
							6 // bufferSize
							);
							
							
		// DEBUG: check if Programming mode succeeded by reading the status register
		

		// Next address
		if (SPI_Addr_lo >= 0xfe)
			++SPI_Addr_hi;
		SPI_Addr_lo = SPI_Addr_lo + 2;
		

		MicoSleepMilliSecs(5);  // Max Page Program time


	return(0);
}


/*
 * Read the 2 temperature bytes from the current SPI flash memory location in sector 0.
 * The address is then incremented by 2 to point to the next location.
 * If the address is too big then it fails? 
  */
char SPI_RecallTemp(void)
{
	unsigned char tx_data[8];
	unsigned char rx_data[8];


	if ((SPI_Addr_hi == 0xff) && (SPI_Addr_lo == 0xfe))
		return(-1);  // full, at end of sector
	
		// Setup Read Command from Address
		tx_data[0] = 0x03;  // Sequential Read Array (slow rate) command
		tx_data[1] = 0;  // Address[23:16]
		tx_data[2] = SPI_Addr_hi;  // Address[15:8]
		tx_data[3] = SPI_Addr_lo;  // Address[7:0]
		tx_data[4] = 0;  // dummy for clocking out first read byte
		tx_data[5] = 0;  // dummy for clocking out 2nd read byte
		
		MicoEFB_SPITransfer(
								SPI_RD_DATA, // 
								tx_data, // *txBuffer,
								rx_data, // *rxBuffer,
								6 // bufferSize
								);

		RawTempValHi = rx_data[4];
		RawTempValLo = rx_data[5];

		// Compute next address
		if (SPI_Addr_lo >= 0xfe)
			++SPI_Addr_hi;
		SPI_Addr_lo = SPI_Addr_lo + 2;
		
	return(0);
}



/**
 * Read the 2 byte Temperature Register value from the TMP101 I2C device.
 * The upper byte is the signed temperature in Celsius.
 * 0x7f = +128C
 * 0x00 = 0C
 * 0x80 = -128C
 * The lower byte is the fractional part, and based on the set precision.
 * For 9bit (default): 1/2 C resolution : 0x80 = 0.5C, 0x00 = 0.0C
 * For 10 bit: 1/4 C resolution : 0xc0 = 0.75C, 0x80 = 0.5C, 0x40 = 0.25C, 0x00 = 0.0C
 * For 11 bit: 1/8th C resolution
 * For 12 bit: 1/16th C resolution 
 * 
 */
void readI2CTemp(void)
{

	unsigned char data[4];

	data[0] = 0;
	data[1] = 0;
					
	MicoEFB_I2CWrite( 
							1,   // Number of bytes to be transfered (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_START, // Master: Insert Start (or repeated Start) prior to data transfer  
							0,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							TMP101_I2C_ADDR);		// Slave address
		
							
	MicoEFB_I2CRead( 
							2,   // Number of bytes to be read (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_RESTART, // Master: Insert Start (or repeated Start) prior to data transfer  
							1,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							TMP101_I2C_ADDR);		// Slave address

									
	RawTempValHi = data[0]; 
	RawTempValLo = data[1];		
}


/**
 * The TMP101 has the ability to report the temperature in 9,10,11 or 12 bit
 * precision.  This is controlled by the R1R0 bit field in the Control Register.
 * To write to the Control Register, the address 0x01 must be sent followed by
 * the byte value to write into the Control Register.
 * After proramming, the Register Pointer value must be reset to 0x00 so that
 * subsequent reads will be from the Temperature Register.
 * The Temperature Register is selected by default at power-up.
 * The default power-up precision is 9 bit.
 */ 
void  setPrecision(void)
{
	unsigned char data[4];

	data[0] = 1;   // set Pointer Regsiter to Configuration Register
	data[1] = Precision;  // set the precision, all other bits are 0, like power on default
				
	MicoEFB_I2CWrite( 
							2,   // Number of bytes to be transfered (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_START, // Master: Insert Start (or repeated Start) prior to data transfer  
							1,  // Master: Insert Stop at end of data transfer.
							TMP101_I2C_ADDR);		// Slave address
		
	data[0] = 0;   // set Pointer Register back to Temp. Reg.
					
	MicoEFB_I2CWrite( 
							1,   // Number of bytes to be transfered (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_START, // Master: Insert Start (or repeated Start) prior to data transfer  
							1,  // Master: Insert Stop at end of data transfer.
							TMP101_I2C_ADDR);		// Slave address
}


/*
 * Basic math to convert hex digit to decimal for display.
 * Luckily the TMP101 module returns a binary  temperature reading by default.
 * This value is an 8 bit whole part (+127 DegC to -127 DegC) + fraction bits.
 * Conversion to Celcius is real easy.
 */
void showTemp()
{
#ifdef DISPLAY_RAW_HEX_DATA

	unsigned char d;

	// Raw Format - just display the 2 bytes directly read from sensor 

 	d = RawTempValHi>>4;
 	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, d);
 	DisplayBuf[0] = Hex2Char(d);

 	
	d = RawTempValHi & 0x0f;
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, d);
	DisplayBuf[1] = Hex2Char(d);	

	
 	d = RawTempValLo>>4;
 	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, d);
 	DisplayBuf[2] = Hex2Char(d);

 	
	d = RawTempValLo & 0x0f;
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, d);
	DisplayBuf[3] = Hex2Char(d);	
	DisplayBuf[4] = 'h';
	DisplayBuf[5] = '\0';
		
	SendString(DisplayBuf);
		
	if (Logging)
	{
		SendString("->Log\r\n");
	}
	else
	{
		SendString("\r\n");
	}			


#else  // Display in Celsius, base 10 readable format

	unsigned char hundreds, tens, ones;
	unsigned char C;
    char *s1;
    unsigned char i;
    unsigned char neg;
	unsigned char d = 0;
	
	// Upper byte is direct temp in C (+/-) in 1's complement format
	// The following conversion is used for positive:
	// 0x00 = 0, 0x01 = 1, 0x02 = 2, 0x7f = 127C 
	// For negative, we also have to look at low byte:
	// 0xff_f0 = -1/16th, 0xff_80 = -0.5, 0xff_00 = -1.0, 0xfe_f0 = -1 1/16th 
	
	// Determine if the temperature reading is negative (MSb set).
	if (RawTempValHi & 0x80)
	{
		DisplayBuf[0] = '-';
		C = ~RawTempValHi;  // Convert to 1's complement positive number
		neg = 1;
		i = 1;
		if (RawTempValLo == 0)
			++C;   //  0xff_00 = -1.0, 0xfe_00 = -2.0
	}
	else
	{
		DisplayBuf[0] = '+';
		C = RawTempValHi;  // already positive number
		neg = 0;
		i = 0;
		d = 0x04;   // turn on deimal point
	}
	
	// This converts the hex number into base 10 digits 	
	if (C >= 100)
	{
		hundreds = 1;
		C = C - 100;
	}
	else
	{
		hundreds = 0;
	}
	DisplayBuf[1]= hundreds + '0';
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + i, hundreds);
	
	tens = 0;
	while (C >= 10)
	{
		C = C - 10;
		++tens;
	}
	DisplayBuf[2]= tens + '0';
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + i + 1, tens);
	
	ones = 0;
	while (C > 0)
	{
		C = C - 1;
		++ones;
	}
	DisplayBuf[3]= ones + '0';
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + i + 2, ones);
	DisplayBuf[4] = '\0';		

	i = RawTempValLo>>4;
		
	if (!neg)
	{
		if (RawTempValLo & 0x80)
			LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, 5);
		else
			LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, 0);	
	}
	else
	{		
		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, 0x3D);   // Negative number sign
		i = i | 0x10;  // if negative then we need to index in to list at upper 16 entries
	}
	
	
	SendString(DisplayBuf);
	
	s1 = CFractional[i];

	SendString(s1);			
	
	if (Logging)
	{
		SendString("->Log\r\n");
		d = d |  0x08;
	}
	else
	{
		SendString("\r\n");
	}			

	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 4, d);

#endif

}


/***************************************************************
 * Print the main menu on the hyperterminal	
 * 
 *
 ***************************************************************/
void showMainMenu()
{
	// Print Main menu
	SendString("\r\n\t-- MAIN MENU: Temp Log --\r\n");
	
	if (Precision == TEMP9BIT)
		SendString("\tP - Precision(9bit)\r\n");
	else if (Precision == TEMP10BIT)
		SendString("\tP - Precision(10bit)\r\n");
	else if (Precision == TEMP11BIT)	
		SendString("\tP - Precision(11bit)\r\n");
	else
		SendString("\tP - Precision(12bit)\r\n");

	SendString("\tT - Get Temperature\r\n\tL - Log Temperatures\r\n\tR - Recall Temperatures\r\n> ");
}



/*************************
 * USER-MAIN ENTRY POINT *
 * 
 *************************/
int main (void)
{
	char	selection;
	char	done;
	
	
	// Initialize Globals
	TempConv = 'C';
	Precision = TEMP9BIT;
	Logging = 0;


	SendString("\033[2JMachXO2 I2C/SPI Master Demo\r\n");
	
	MicoEFB_SPIInit();   // setup SPI Master controller for operation
	SPI_UnProtectSector0();

			
	while (1) 
	{
		// Start out with reading and displaying temperature
		while(!keyPress())
		{
			readI2CTemp();
			showTemp();
			if (Logging)
				SPI_StoreTemp(RawTempValHi, RawTempValLo);
			MicoSleepMilliSecs(500);
		}
		
		// Read and discard this key press becasue it was used to exit
		// the temperature read/display and not a real menu choice.
		MicoUart_getC(&uart_core_uart, &selection);
		
		done = 0;
		while (!done)
		{
			// Print Main menu and wait for user input
			showMainMenu();
			
			MicoUart_getC(&uart_core_uart, &selection);
			MicoUart_putC(&uart_core_uart, selection);
			
	
			// Select operation based on user input
			switch (selection)
			{
				case 't':   // Read TI temp sensor over I2C bus and display
				case 'T':   // current temperature
					done = 1;
					break;
					
				case 'l':   // Turn on Logging the Temperature readings to SPI flash
				case 'L':   //
					Logging = ~Logging;
					if (Logging)
					{

						SPI_EraseSector0();
						SPI_Addr_hi = 0;
						SPI_Addr_lo = 0;
						done = 1;
					}
					break;
					
				case 'r':   // Recall  and display Temperatures from SPI flash
				case 'R':   //
					SPI_Addr_hi = 0;
					SPI_Addr_lo = 0;
					Logging = 0;   // terminates the logging since we corrupted the global SPI_ADDR
					while(1)
					{
						SPI_RecallTemp();
						if ((RawTempValHi == 0xff) && (RawTempValLo == 0xff))
							break;
						showTemp();
					} 
					break;
					
				case 'p':   // Set precision of TI Temp Sensor
				case 'P':
					Precision = (Precision + 0x20) & 0x60;
					setPrecision();
					break;
					 
					
				default: 
					break;
			}
		
		}
		
	}
	
	return(0);
}


