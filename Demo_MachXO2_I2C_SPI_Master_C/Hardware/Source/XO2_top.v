////////////////////////////////////////////////////////////////////////////////
// Lattice MachXO2-1200 Pico Board Temperature Logging Demo.
//
// This design provides access to the XO2 Pico board's I2C temperature
// sensor and SPI flash using the EFB hard I2C and SPI master controllers.
// An LM8 runs software to provide the demo control and user interface.
// The demo reads the I2C temperature, displays it, logs it to SPI flash,
// and recalls stored temperature data.
//
// The main purpose of the demo is to show how the EFB I2C and SPI controllers
// can be accessed by drivers to read/write to external devices.
//
// A 4 digit LCD is also used to display the temperature.  A UART is used
// for user I/O and menu control of the demo features.
//
// For a more complete description of the demo, see the Users Guide or the
// software project which will show the flow of execution.
//
// NOTE: The EFB is generated separately in IPexpress and instantiated
// here, outside the MSB platform, to avoid extra software driver routines
// and modules that come along with the EFB component added directly into
// the MSB project.  This will not effect performance or LUT usage, but is
// just a little extra work to wire up the module the the MSB slave
// passthru port.
//
///////////////////////////////////////////////////////////////////////////////
// 
// General I/O
//----------------
//  N3 - reset
//  A7 - 12MHz BrdClk
//
// 3.3V Power Supply Control
//--------------------------
//  N2 = EnI2CSPI
//  P2 = EnAMP
//
// I2C pins are:
//----------------
//  C8 - SCL
//  B8 - SDA
//
//
// SPI pins are:
//----------------
//  P3 - SPI_CS0
//  M4 - SPI_CLK
//  N4 - SPI_OUT
//  P13 - SPI_IN
//
//
//
// 4 Char LCD Display
//----------------
//  B14 - LCD_COM0
//  C13 - LCD_COM1
//  C14 - LCD_COM2
//  D12 - LCD_COM3
//  J12 - LCD_5
//  J14 - LCD_6
//  J13 - LCD_7
//  K12 - LCD_8
//  K13 - LCD_9
//  K14 - LCD_10
//  L14 - LCD_11
//  M13 - LCD_12
// 
//
// LM8 UART
//----------
// E1 - TXD_UART   (tx from FTDI to XO2)
// E2 - RXD_UART   (rx at FTDI, from XO2)
// E3 - UART_ACT   (just indicates tx/rx activity, usually goes to an LED)
//
//
//
//
module top_XO2 
(
	// General Inputs
	input rstn,
	input wire brd_clk,

	output EnI2CSPI,
	output EnAMP,

	// Outputs
	output oscclkout, // debug testpoint
	output rstout,    // debug testpoint
	output cntout,    // debug testpoint

	// LCD Outputs
	output LCD_COM0,
	output LCD_COM1,
	output LCD_COM2,
	output LCD_COM3,

	output LCD_5,
	output LCD_6,
	output LCD_7,
	output LCD_8,
	output LCD_9,
	output LCD_10,
	output LCD_11,
	output LCD_12,

	// UART interface
	input  FTDI_txd,
	output FTDI_rxd,
	
	// I2C Interface
	inout  scl,
	inout  sda,

	// SPI Flash Interface
	inout spi_clk,
	inout spi_out,
	inout  spi_in,
	output spi_cs0
);

	localparam COUNT_WIDTH = 3;   // used to generate 2 MHz LCD clock from 12 MHz board clock

	reg [COUNT_WIDTH-1:0]		lcdcounter;
	reg				lcd_clk;
	wire				oscclk;
	wire				sys_clk /* synthesis syn_keep=1 */;

	// Wishbone connections between LM8 and EFB and LCD register control module
	//
	wire [3:0] 		LCD_wb_adr;
	wire [7:0]		LCD_wb_wr_data;
	wire [7:0]		LCD_wb_rd_data;
	wire			LCD_wb_stb;
	wire			LCD_wb_cyc;
	wire			LCD_wb_we;
	wire			LCD_wb_ack;

	wire [7:0] 		EFB_wb_adr;
	wire [7:0]		EFB_wb_wr_data;
	wire [7:0]		EFB_wb_rd_data;
	wire			EFB_wb_stb;
	wire			EFB_wb_cyc;
	wire			EFB_wb_we;
	wire			EFB_wb_ack;
	wire			EFB_i2c_irq;

	wire [7:0] 		LCD_digit0;
	wire [7:0] 		LCD_digit1;
	wire [7:0] 		LCD_digit2;
	wire [7:0] 		LCD_digit3;
	wire 			LCD_dp1;
	wire 			LCD_dp2;
	wire 			LCD_dp3;
	wire 			LCD_cln;


	assign rstout = ~rstn;
	assign cntout = lcd_clk;


	assign EnI2CSPI = 1'b1;   // set to 1 to turn on 3.3v to I2C and SPI chips
	assign EnAMP    = 1'b1;   // set to 1 for voltage measuring circuit (if used)

	//***********************************************************************
	//
	//  Internal Oscillator
	//
	//***********************************************************************
	defparam OSCH_inst.NOM_FREQ = "24.18" ;
	OSCH OSCH_inst(
		.STDBY(1'b0),
		.OSC(oscclk),
		.SEDSTDBY());

	assign oscclkout    = oscclk;


	//***********************************************************************
	//
	//   Select System Clock
	//
	//***********************************************************************
	//assign sys_clk = oscclk;
	assign sys_clk = brd_clk;



	//***********************************************************************
	//
	//  LCD Clock Generator
	//  The LCD module needs to be driven with a 2 MHz clock in order to
	//  generate the correct PWM drive to the segments for contrast and
	//  update.  Supplying a clock not = 2 MHz will result in character
	//  smeering, poor contrast and/or not proper updates.
	//
	//  This generates 2 MHz from the 12 MHz system clock.
	//
	//***********************************************************************
	always @(posedge sys_clk or negedge rstn)
	begin
		if(rstn == 0) begin
			lcdcounter <= 0;
			lcd_clk <= 0;
		end
	       	else
	       	begin
			lcdcounter <= lcdcounter + 1;

			if (lcdcounter == 3)
			begin
				lcdcounter <= 0;
				lcd_clk <= ~lcd_clk;
			end

		end
	end


	
	//***********************************************************************
	//
	//  LCD Display Driver
	//
	//***********************************************************************
	PicoLCDdriver PicoLCDdriver_u
	(
		.rst_n(rstn), // IN: Async Reset
		.clk(lcd_clk),   // IN: 2.08 MHz
		.LCD_enb(1'b1),   // IN: Enable LCD display, else float the outputs
		
		// 4 input digits
		.LCD1(LCD_digit0),		        // IN[7:0]: Left charactor to display
		.LCD2(LCD_digit1),                 // IN[7:0]:
		.LCD3(LCD_digit2),                 // IN[7:0]:
		.LCD4(LCD_digit3),		        // IN[7:0]: Right charactor to display
		.LCDDP1(LCD_dp1),   	// IN: display Decimal Point after LCD1
		.LCDDP2(LCD_dp2),   	// IN: display Decimal Point after LCD2   
		.LCDDP3(LCD_dp3),   	// IN: display Decimal Point after LCD3   
		.LCDCol(LCD_cln),   	// IN: display Colon after LCD2   
		
		// to LCD display panel
		.LCD_COM0(LCD_COM0),   // OUT:
		.LCD_COM1(LCD_COM1),   // OUT:
		.LCD_COM2(LCD_COM2),   // OUT:
		.LCD_COM3(LCD_COM3),   // OUT:
		.LCD_5(LCD_5),         // OUT:
		.LCD_6(LCD_6),         // OUT:
		.LCD_7(LCD_7),         // OUT:
		.LCD_8(LCD_8),         // OUT:
		.LCD_9(LCD_9),         // OUT:
		.LCD_10(LCD_10),       // OUT:
		.LCD_11(LCD_11),       // OUT:
		.LCD_12(LCD_12)        // OUT:
	);



	//***********************************************************************
	//
	//  MICO8 Instantiation
	//
	//***********************************************************************

	mico8 mico8_u 
	( 
		.clk_i(sys_clk),
		.reset_n(rstn)
		, .uartSIN(FTDI_txd) // IN: to Mico UART rx from FTDI
		, .uartSOUT(FTDI_rxd) // OUT: from Mico UART tx to FTDI

		, .slave_LCDclk() //  OUT: Not Used
		, .slave_LCDrst() //  OUT: Not Used
		, .slave_LCDslv_adr(LCD_wb_adr) // OUT[32-1:0]: 
		, .slave_LCDslv_master_data(LCD_wb_wr_data) // OUT[8-1:0]: writing to slave
		, .slave_LCDslv_slave_data(LCD_wb_rd_data) // IN[8-1:0]: reading from slave
		, .slave_LCDslv_cyc(LCD_wb_cyc) // OUT:
		, .slave_LCDslv_strb(LCD_wb_stb) // OUT:
		, .slave_LCDslv_we(LCD_wb_we) // OUT:
		, .slave_LCDslv_ack(LCD_wb_ack) // 
		, .slave_LCDslv_err(1'b0) //  IN: Not used
		, .slave_LCDslv_rty(1'b0) //  IN: Not used
		, .slave_LCDslv_sel() // OUT[3:0] : not used cause 8 bits
		, .slave_LCDslv_bte() // OUT[1:0]: Not Used
		, .slave_LCDslv_cti() // OUT[2:0]: Not Used
		, .slave_LCDslv_lock() //  OUT: Not Used
		, .slave_LCDintr_active_high(1'b0) //  IN: Not Used, no interrupts

		, .slave_EFBclk() //   OUT: Not Used
		, .slave_EFBrst() //   OUT: Not Used
		, .slave_EFBslv_adr(EFB_wb_adr) // OUT[32-1:0]: 
		, .slave_EFBslv_master_data(EFB_wb_wr_data) // OUT[8-1:0]: writing to slave
		, .slave_EFBslv_slave_data(EFB_wb_rd_data) // IN[8-1:0]: reading from slave
		, .slave_EFBslv_cyc(EFB_wb_cyc) // OUT:
		, .slave_EFBslv_strb(EFB_wb_stb) // OUT:
		, .slave_EFBslv_we(EFB_wb_we) // OUT:
		, .slave_EFBslv_ack(EFB_wb_ack) // 
		, .slave_EFBslv_err(1'b0) //  IN: Not used
		, .slave_EFBslv_rty(1'b0) //  IN: Not used
		, .slave_EFBslv_sel() // OUT[3:0] : not used cause 8 bits
		, .slave_EFBslv_bte() // OUT[1:0]: Not Used
		, .slave_EFBslv_cti() // OUT[2:0]: Not Used
		, .slave_EFBslv_lock() //  OUT: Not Used
		, .slave_EFBintr_active_high(EFB_i2c_irq) // 
		
		
	);


	
	//***********************************************************************
	//
	//  Instantiate EFB from IPexpress to avoid drivers and other files
	//  that get pulled in when done inside MSB.
	//  Hopefully this will be more optimized and smaller executable
	//  software.
	//
	//***********************************************************************
	
	myEFB myEFB_u
	(
		.wb_clk_i(sys_clk ), 
		.wb_rst_i(~rstn ), 

		.wb_cyc_i(EFB_wb_cyc ), 
		.wb_stb_i(EFB_wb_stb ), 
    		.wb_we_i(EFB_wb_we ), 
		.wb_adr_i(EFB_wb_adr ), 
		.wb_dat_i(EFB_wb_wr_data ), 
		.wb_dat_o(EFB_wb_rd_data ), 
		.wb_ack_o(EFB_wb_ack ), 

    		.i2c1_scl(scl), 
		.i2c1_sda(sda), 
		.i2c1_irqo(EFB_i2c_irq ),

 		.spi_clk( spi_clk), // BiDi: (out) clock
		.spi_miso( spi_in), // BiDi
    		.spi_mosi( spi_out), // BiDi
		.spi_scsn( 1'b1), //  in:  (slave chip select)
		.spi_csn( spi_cs0) // out: chip select to a slave
	);

	
	//***********************************************************************
	//
	//  Wishbone Registers to LCD Display
	//
	//  Wishbone slave to accept register writes from LM8 software into
	//  5 registers that are then used to drive the LCD module with the
	//  4 digits to display and any decimal points or other special
	//  displays.
	//
	//***********************************************************************
	wb2lcd wb2lcd_u
	(
		// Wishbone bus interface signals
		.wb_clk_i(sys_clk),
		.wb_rst_i(~rstn),

		.wb_dat_i(LCD_wb_wr_data),
		.wb_adr_i(LCD_wb_adr),
		.wb_cyc_i(LCD_wb_cyc),
		.wb_stb_i(LCD_wb_stb),
		.wb_we_i(LCD_wb_we),  
		.wb_dat_o(LCD_wb_rd_data),
		.wb_ack_o(LCD_wb_ack),
		.wb_int_o(),

		//////////// Module Specific Signals ///////////
		.LCD_clk(lcd_clk),       // clock domain for the LCD display module
		.LCD_digit0(LCD_digit0),
		.LCD_digit1(LCD_digit1),
		.LCD_digit2(LCD_digit2),
		.LCD_digit3(LCD_digit3),
		.LCD_decPt0(LCD_dp1),
		.LCD_decPt1(LCD_dp2),
		.LCD_decPt2(LCD_dp3),
		.LCD_colon(LCD_cln)
	);






endmodule

