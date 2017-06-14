//////////////////////////////////////////////////////////////////////
//
// 8 bit WISHBONE SLAVE REGISTER MEMORY MAPPED MODULE
//
// Common template for memory-mapped interface to a module's
// control and status registers.  
// Intended for control plane type access, not high-thruput
// data access since it does not support bursts.
// This only supports Classic, registered cycle access.
// None-block mode.  One Rd/Wr per cycle.
//
// Big Endian bus orientation
// Byte lane selects are supported.
/////////////////////////////////////////////////////////////////////

// 
//



module wb2lcd
(
	// Wishbone bus interface signals
	input         wb_clk_i,
	input         wb_rst_i,

	input  [7:0] wb_dat_i,
	input  [3:0] wb_adr_i,
	input         wb_cyc_i,
	input         wb_stb_i,
	input         wb_we_i,  
	output [7:0] wb_dat_o,
	output        wb_ack_o,
	output  wire      wb_int_o,

	//////////// Module Specific Signals ///////////
	input  wire		LCD_clk,
	output reg [7:0]	LCD_digit0,
	output reg [7:0]	LCD_digit1,
	output reg [7:0]	LCD_digit2,
	output reg [7:0]	LCD_digit3,
	output wire 		LCD_decPt0,
	output wire 		LCD_decPt1,
	output wire 		LCD_decPt2,
	output wire 		LCD_colon
);


localparam	DIGIT0=			4'd0;
localparam	DIGIT1=			4'd1;
localparam	DIGIT2=			4'd2;
localparam	DIGIT3=			4'd3;
localparam	EXTRAS=			4'd4;


	//////////// Common Wishbone Bus Control/Response Signals ///////////
	reg 		wb_stb_d1;
	reg 		wb_stb_d2;
	reg [7:0]	wb_dat_local;

	wire rd, wr;


	assign rd = ~wb_we_i && wb_cyc_i && wb_stb_i;    
	assign wr = wb_we_i && wb_cyc_i && wb_stb_i;

	assign wb_dat_o = wb_dat_local;
	assign wb_ack_o = wb_stb_d1 & ~wb_stb_d2;

	assign wb_int_o = 1'b0;
 

	//////////// Module Specific Registers and Signals ///////////
	/////////////////////////////////////////////////////////////////
	//               LCD CLOCK DOMAIN REGSITERS
	/////////////////////////////////////////////////////////////////
	reg		colon; 
	reg [2:0]	dot; 

	reg [7:0]	lcd_LCD_digit0;
	reg [7:0]	lcd_LCD_digit1;
	reg [7:0]	lcd_LCD_digit2;
	reg [7:0]	lcd_LCD_digit3;
	reg 		lcd_colon; 
	reg [2:0] 	lcd_dot; 

	/////////////////////////////////////////////////////////////////
	//             WISHBONE CLOCK DOMAIN REGSITERS
	/////////////////////////////////////////////////////////////////
	reg [7:0]	wb_LCD_digit0;
	reg [7:0]	wb_LCD_digit1;
	reg [7:0]	wb_LCD_digit2;
	reg [7:0]	wb_LCD_digit3;
	reg 		wb_colon; 
	reg [2:0] 	wb_dot; 


	assign 	LCD_decPt0 = dot[0];
	assign 	LCD_decPt1 = dot[1];
	assign 	LCD_decPt2 = dot[2];
	assign  LCD_colon  = colon;


	// Pipeline STB for ACK so its generated on next clock
	// so there is time to register in wb_dat_local for response back.
	// Need to pipeline the write side to allow the read side time to read data
	always @(posedge wb_clk_i or posedge wb_rst_i )
	begin
		if (wb_rst_i)
    			wb_stb_d1 <= 1'b0;    
		else
			wb_stb_d1 <= wb_stb_i;
	end

	always @(posedge wb_clk_i or posedge wb_rst_i )
	begin
		if (wb_rst_i)
    			wb_stb_d2 <= 1'b0;    
		else
			wb_stb_d2 <= wb_stb_d1 & wb_cyc_i;
	end


	//////////// Access Module Specific Registers and Signals ///////////
	always @(posedge wb_clk_i or posedge wb_rst_i )
	begin
  		if (wb_rst_i)
  		begin
			// Reset all Module Registers Here
        		wb_dat_local <= 8'h00;    

			wb_LCD_digit0 <= 8'h00;
			wb_LCD_digit1 <= 8'h00;
			wb_LCD_digit2 <= 8'h00;
			wb_LCD_digit3 <= 8'h00;
			wb_colon <= 1'b0; 
			wb_dot <= 3'b000; 
		end
  
  		else if (wb_cyc_i && wb_stb_i)
		begin
			// Read/Write all Module Registers Here

			case (wb_adr_i)

				DIGIT0:
				begin
					if (wr)
						wb_LCD_digit0<= wb_dat_i;
					else
					  	wb_dat_local <= wb_LCD_digit0;
				end
				
				DIGIT1:
				begin
					if (wr)
						wb_LCD_digit1<= wb_dat_i;
					else
					  	wb_dat_local <= wb_LCD_digit1;
				end
				
				DIGIT2:
				begin
					if (wr)
						wb_LCD_digit2<= wb_dat_i;
					else
					  	wb_dat_local <= wb_LCD_digit2;
				end
				
				DIGIT3:
				begin
					if (wr)
						wb_LCD_digit3<= wb_dat_i;
					else
					  	wb_dat_local <= wb_LCD_digit3;
				end
				

				EXTRAS: //
				begin
					if (wr)
					begin
						wb_colon <= wb_dat_i[3];
						wb_dot <= wb_dat_i[2:0];
					end
					else
					begin
					  	wb_dat_local <= {4'b0000,wb_colon,wb_dot};
					end
				end

			endcase
		end  // valid cycle

  		else  // Default things to do when not being accessed
  		begin
        		wb_dat_local <= 8'h00;    
		end

	end // always


	//
	// clock Domain Crossing between wishbone (CPU) clock and the lower
	// speed (2 MHz) LCD driver clock
	//
	always @(posedge LCD_clk or posedge wb_rst_i )
	begin
		if (wb_rst_i)
		begin
			LCD_digit0 <= 8'h00;
			LCD_digit1 <= 8'h00;
			LCD_digit2 <= 8'h00;
			LCD_digit3 <= 8'h00;
			colon <= 1'b0;
			dot <= 3'b000;
			lcd_LCD_digit0 <= 8'h00;
			lcd_LCD_digit1 <= 8'h00;
			lcd_LCD_digit2 <= 8'h00;
			lcd_LCD_digit3 <= 8'h00;
			lcd_colon <= 1'b0; 
			lcd_dot <= 3'b000; 
		end
		else
		begin
			// Double clock to transfer domains
			lcd_LCD_digit0 <= wb_LCD_digit0;
			lcd_LCD_digit1 <= wb_LCD_digit1;
			lcd_LCD_digit2 <= wb_LCD_digit2;
			lcd_LCD_digit3 <= wb_LCD_digit3;
			lcd_colon <= wb_colon; 
			lcd_dot <= wb_dot; 

			LCD_digit0 <= lcd_LCD_digit0;
			LCD_digit1 <= lcd_LCD_digit1;
			LCD_digit2 <= lcd_LCD_digit2;
			LCD_digit3 <= lcd_LCD_digit3;
			colon <= lcd_colon; 
			dot <= lcd_dot; 
		end
	end



endmodule

