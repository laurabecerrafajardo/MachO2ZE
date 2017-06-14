/****************************************************************
* 

*****************************************************************/
#include "MicoUtils.h"
#include "DDStructs.h"
#include "MicoUart.h"
#include "system_conf.h"
#include "MicoEFB_I2C.h"
#include "EFB_SPI.h"


#define SIMULATION 

#define I2C_READ  (1)
#define I2C_WRITE (0)

#ifdef SIMULATION 
// address to an I2C EEPROM used in sim 
#define I2C_ADDR (0x08<<1)   // 7 bit address:000_1000
#endif

#define TMP101_I2C_ADDR (0x4a<<1)   // 7 bit address:100_1010 shifted up to 8 bit

// Action of the Temperature A/D converter
// The define is the exact bit position in the Command Register
// so no upshifting is needed when writing to the register.
#define I2C_STANDBY  0x00
#define SPI_STANDBY  0x20 
#define I2C_WAKE     0x40
#define SPI_WAKE     0x60

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
unsigned char Action;

char HexChar[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
	                '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
	    
		    
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


/***************************************************************
 * Print the main menu on the hyperterminal	
 * 
 * METRIC: 56 assy inst				   *
 ***************************************************************/
void showMainMenu()
{
	// Clear screen
//	MicoUart_putC (pUart, 0xc);
	// Print Main menu
	SendString("\r\n\t-- MAIN MENU: Power Saving Demo --\r\n");
	
	
	if (Action == I2C_STANDBY)
		SendString("\t0 - Power saving through I2C \r\n");

		SendString("\t1 - Power saving through SPI \r\n");
		SendString("\t2 - Non Power saving through I2C \r\n");
		SendString("\t3 - Non Power saving through SPI \r\n");
		
		SendString("\tOthers - Non power saving\r\n");

}



/*************************
 * USER-MAIN ENTRY POINT *
 * 
 * METRIC: 151 assy inst
 *************************/
int main (void)
{
	char	selection;
	char	done;

	unsigned char data[4];
	char err;
	
	unsigned char tx_data[4];
	unsigned char rx_data[4];	
	
	// Initialize Globals
	TempConv = 'C';
	Action = I2C_STANDBY;
/*		
#ifdef SIMULATION 
	sim_test_i2c_eeprom();   // never returns
#else
*/			
	while (1) 
	{
		// Read and discard this key press becasue it was used to exit
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
				case '0':   // 0 - Power saving through I2C
      		  data[0] = 0x7D;
      		  data[1] = 0x02;
      		  data[2] = 0x00;
      		  
      		  err = MicoEFB_I2CWrite( 
      		  					3,                  // Number of bytes to be transfered (min 1 and max 256) 
      		  					data,               // Buffer containing the data to be transferred
      		  					MICO_EFB_I2C_START, // Master: Insert Start (or repeated Start) prior to data transfer  
      		  					1,                  // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
      		  					I2C_ADDR);		      // Slave address
      	        
					break;

				case '1':   // 1 - Power saving through SPI
	            tx_data[0] = 0x7D;          // 
	            tx_data[1] = 0x02;          // 
	            tx_data[2] = 0x00;          // 
	            	            
	            err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND,             // readMode
							tx_data,                    // *txBuffer,
							rx_data,                    // *rxBuffer,
							3                           // bufferSize
							);
      	        
					break;
					 
				case '2':   // 2 - Power saving through I2C
						data[0] = 0xFF;
        		data[1] = 0xFF;
        		data[2] = 0xFF;
        		
        		err = MicoEFB_I2CWrite( 
							3,                          // Number of bytes to be transfered (min 1 and max 256) 
							data,                       // Buffer containing the data to be transferred
							MICO_EFB_I2C_START,         // Master: Insert Start (or repeated Start) prior to data transfer  
							1,                          // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							I2C_ADDR);		              // Slave address

					break;

				case '3':   // 3 - Non Power saving through SPI
	            tx_data[0] = 0xFF;           // 
	            tx_data[1] = 0xFF;           // 
	            tx_data[2] = 0xFF;           // 
	            	            
	            err = MicoEFB_SPITransfer(
							SPI_WR_COMMAND,             // readMode
							tx_data,                    // *txBuffer,
							rx_data,                    // *rxBuffer,
							3                           // bufferSize
							);
      	        
					break;
					
				default: // Others - Non power saving
						data[0] = 0xFF;
        		data[1] = 0xFF;
        		data[2] = 0xFF;
        		
        		err = MicoEFB_I2CWrite( 
							3,                          // Number of bytes to be transfered (min 1 and max 256) 
							data,                       // Buffer containing the data to be transferred
							MICO_EFB_I2C_START,         // Master: Insert Start (or repeated Start) prior to data transfer  
							1,                          // Master: Insert Stop at end of data transfer. Slave: Stretch clock at end of transfer.
							I2C_ADDR);		              // Slave address

					break;
			}
		
		}
		
	}
	
//#endif	

	return(0);
}

