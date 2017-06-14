/****************************************************************
* 

*****************************************************************/
#include "MicoUtils.h"
#include "DDStructs.h"
#include "MicoUart.h"
#include "system_conf.h"
#include "MicoEFB_I2C.h"


#define I2C_READ  (1)
#define I2C_WRITE (0)

#ifdef SIMULATION 
// address to an I2C EEPROM used in sim 
#define EEPROM_I2C_ADDR (0x50<<1)   // 7 bit address:101_0000 shifted up to 8 bit
#endif

#define TMP101_I2C_ADDR (0x4a<<1)   // 7 bit address:100_1010 shifted up to 8 bit

// Precision of the Temperature A/D converter
// The define is the exact bit position in the Command Register
// so no upshifting is needed when writing to the register.
#define TEMP9BIT  0x00
#define TEMP10BIT 0x20 
#define TEMP11BIT 0x40
#define TEMP12BIT 0x60



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

char HexChar[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
	                '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
	    
#if 0		    
char *CFractional[16] =
{
	".0 C",      // 0x00
	".0625 C",   // 0x10
	".125 C",    // 0x20
	".1875 C",   // 0x30
	".25 C",     // 0x40
	".3125 C",   // 0x50
	".375 C",    // 0x60
	".4375 C",   // 0x70
	".5 C",      // 0x80
	".5625 C",   // 0x90
	".625 C",    // 0xA0
	".6875 C",   // 0xB0
	".75 C",     // 0xC0
	".8125 C",   // 0xD0
	".875 C",    // 0xE0
	".9375 C"    // 0xF0
};
#endif
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
	unsigned char hundreds, tens, ones;
	unsigned char C;
    char *s1;
    unsigned char i;
    unsigned char neg;
	unsigned char d = 0;
	
	
	if (TempConv == 'h')
	{
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
		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 4, 0);   // no decimal points or ':' 
		DisplayBuf[3] = Hex2Char(d);	
		DisplayBuf[4] = 'h';
		DisplayBuf[5] = '\0';
			
		SendString(DisplayBuf);
	}
	else
	{
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

		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 4, d);
	}
	
	SendString("\r\n");

}





/***************************************************************
 * Print the main menu on the hyperterminal	
 * 
  *
 ***************************************************************/
void showMainMenu()
{
	// Clear screen
//	MicoUart_putC (pUart, 0xc);
	// Print Main menu
	SendString("\r\n\t-- MAIN MENU: I2C Lite --\r\n");
	
	if (TempConv == 'C')
		SendString("\tU - Temp. in (C)\r\n");
	else 
		SendString("\tU - Temp. in (hex)\r\n");
	
	if (Precision == TEMP9BIT)
		SendString("\tP - Precision(9bit)\r\n");
	else if (Precision == TEMP10BIT)
		SendString("\tP - Precision(10bit)\r\n");
	else if (Precision == TEMP11BIT)	
		SendString("\tP - Precision(11bit)\r\n");
	else
		SendString("\tP - Precision(12bit)\r\n");

	SendString("\tT - Read Temperature\r\n> ");
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
		
#ifdef SIMULATION 
	sim_test_i2c_eeprom();   // never returns
#else
		
	SendString("\033[2JMachXO2 I2C Master Access Demo\r\n");	
		
	while (1) 
	{
		// Start out with reading and displaying temperature
		while(!keyPress())
		{
			readI2CTemp();
			showTemp();
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
				case 'u':   // Set conversion rate to Celcius or Raw Hex values
				case 'U':
					 if (TempConv == 'C')
					 	TempConv = 'h';
					 else
					 	TempConv = 'C';
					 break;
	
	
				case 't':   // Read TI temp sensor over I2C bus and display
				case 'T':   // current temperature
					done = 1;
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
	
#endif	

	return(0);
}



//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

#ifdef SIMULATION 
void	sim_test_i2c_eeprom(void)
{
	unsigned char data[6];
	char err;
	unsigned char i;


	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, 0);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, 1);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, 2);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, 3);
	i = 0;
	while (1)
	{
		data[0] = 0;  // hi addr
		data[1] = i;  // lo addr
		data[2] = i & 0x0f;
		data[3] = (i+1) & 0x0f;
		data[4] = (i+2) & 0x0f;
		data[5] = (i+3) & 0x0f;
		
		// WRITE CYCLE
		//-------------
		// <Start>[ADDR+W]_[ADDR_HI]_[ADDR_LO]_[DATA_0]_[DATA_1]..[DATA_n]_<Stop>
		//                ^         ^         ^        ^                  ^
		//               ACK       ACK       ACK      ACK                ACK      
		//
		// Do a Write into the EEPROM - 2 bytes address, 4 bytes sequential data
		err = MicoEFB_I2CWrite( 
							6,   // Number of bytes to be transfered (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_START, // Master: Insert Start (or repeated Start) prior to data transfer  
							1,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							EEPROM_I2C_ADDR);		// Slave address

		// Technically need to wait for byte writes to happen
		
		// READ CYCLE
		//-------------
		// <Start>[ADDR+W]_[ADDR_HI]_[ADDR_LO]_<Start>[ADDR+R]_[Read_0]_[Read_1]..[Read_n]_<Stop>
		//                ^         ^         ^               ^        ^                  ^
		//               ACK       ACK       ACK             ACK      ACK                NAK      
		// Do a Write into the EEPROM - 2 bytes address, 4 bytes sequential data
		// Now Write the address again
		err = MicoEFB_I2CWrite( 
							2,   // Number of bytes to be transfered (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_START, // Master: Insert Start (or repeated Start) prior to data transfer  
							0,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							EEPROM_I2C_ADDR);		// Slave address
							
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, i);		
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, i);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, i);
	LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, i);
	
		err = MicoEFB_I2CRead( 
							4,   // Number of bytes to be transfered (min 1 and max 256) 
							data,        // Buffer containing the data to be transferred
							MICO_EFB_I2C_RESTART, // Master: ReStart prior to data transfer  
							1,  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							EEPROM_I2C_ADDR);		// Slave address
	
		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 0, data[0]);
		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 1, data[1]);
		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 2, data[2]);
		LM8_WRITE_MEM_BYTE(SLAVE_LCD_BASE_ADDRESS + 3, data[3]);

		i = i + 4;
	}
}
#endif		
