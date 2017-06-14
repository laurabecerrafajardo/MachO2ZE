`include "system_conf.v"

`timescale 1ps / 1ps

// testbench - do not synthesize



module tb();

	parameter sys_clk_period = 83_000;  // 83ns = 12 MHz


	reg clk;
	reg refclk;
	reg rst_n;    // active low 

	tri1 scl, sda;

	wire [11:0] LCD;

	wire oscclkout;
	wire rstout;
	wire cntout;
	wire uart_out;
	reg uart_in;
	  
	tri1 spi_clk;
	tri1 spi_out;
	tri1 spi_in;
	wire spi_cs0;
  
	tri1 SPI_WrProt;
	
	
	PUR PUR_INST(1'b1);
	GSR GSR_INST(1'b1);
	//TSALL TSALL_INST(1'b1);


	top_XO2 dut
	(
	  .brd_clk(clk),              // 12 MHz (clk from FTDI circuit)
	  .rstn(rst_n),         // active low

	  .EnI2CSPI(),     // NC - only used for board hdw
	  .EnAMP(),     // NC


	  .oscclkout(oscclkout),
	  .rstout(rstout),
	  .cntout(cntout),

	  // LCD digits and mux controls
	  .LCD_COM0(LCD[0]),
	  .LCD_COM1(LCD[1]),
	  .LCD_COM2(LCD[2]),
	  .LCD_COM3(LCD[3]),
	  .LCD_5(LCD[4]),
	  .LCD_6(LCD[5]),
	  .LCD_7(LCD[6]),
	  .LCD_8(LCD[7]),
	  .LCD_9(LCD[8]),
	  .LCD_10(LCD[9]),
	  .LCD_11(LCD[10]),
	  .LCD_12(LCD[11]),

	// UART interface (note signals are in reference to FTDI)
	  .FTDI_txd(uart_in),  // <=== from FTDI chip
	  .FTDI_rxd(uart_out),  // ===> to FTDI chip
	
	// I2C Interface
	  .scl(scl),
	  .sda(sda),

	// SPI Flash Interface
	  .spi_clk(spi_clk),  // OUT:
	  .spi_cs0(spi_cs0),  // OUT:
	  .spi_out(spi_out),  // OUT:
	  .spi_in(spi_in)  // IN:

	);


	AT25DQ041 spi_flash
	(
		.CSB(spi_cs0),  // IN:  chip Select
		.SCK(spi_clk),  // IN:  Serial Clock
		.SI(spi_out),   // BiDi:  Serial Data in
		.WPB(SPI_WrProt),  // BiDi: Write Protect (active low)
          	.SO(spi_in),   // BiDi:  Serial Data out
          	.HOLDB(1'b1),   // BiDi: Hold (active low)
          	.VCC(1'b1),   // IN:
          	.GND(1'b0)   // IN:
	);



 	M24FC128 i2c_slave
	(
		.A0(1'b0), 
		.A1(1'b0), 
		.A2(1'b0), 
		.WP(1'b0), 
		.SDA(sda), 
		.SCL(scl), 
		.RESET(1'b0)    // inactive.  Not actually present as a pin on physical device
	);

	//====================================================
	// Simulation control and dump
	//====================================================
	initial
	begin

	    	uart_in <= 1'b1;    // inactive

	    	$display("LM8 in XO2 Pico Test Bench Simulation Start"); 
  		$timeformat(-9,0,"ns",0);   	    

	end

	// System Clock 12Mhz =  83nsec = 83,000 psec per clk tick
	initial 
	begin
	    clk = 0;
	    #(sys_clk_period/2);
	    forever #(sys_clk_period/2) clk = ~clk;
	end


	// Assert reset signal for 1 clock at start of simulation
	initial
	begin
	    rst_n = 1'b1;
	    @( posedge clk)  rst_n = 1'b0;   // assert reset
	    #(sys_clk_period * 16)  // hold asserted for 16 clocks
	    @( posedge clk)  rst_n = 1'b1;
	end



	initial
	begin
	    // $dumpfile("dump.vcd");
	    // $dumpvars;
	end

endmodule

