
module lcd_display (
	input	       rst       , // 
	input	       clk_in    , // clk  // clk_USB

	// LCD               
	input [7:0]  LCD1      ,
  input [7:0]  LCD2      ,
  input [7:0]  LCD3      ,
  input [7:0]  LCD4      ,
  input        LCDDP1    ,
  input        LCDDP2    ,
  input        LCDDP3    ,
  input        LCDCol    ,

	output 	     LCD_COM0  ,       
	output 	     LCD_COM1  ,       
	output 	     LCD_COM2  ,       
	output 	     LCD_COM3  ,       
	output 	     LCD_5     ,          
	output 	     LCD_6     ,          
	output 	     LCD_7     ,          
	output 	     LCD_8     ,          
	output 	     LCD_9     ,          
	output 	     LCD_10    ,         
	output 	     LCD_11    ,         
	output 	     LCD_12         

);

	// LCD interface
	wire 			LCDEnb;   
	reg 			LCDEnb1;   
	wire 			LCDEnWB;
	
	wire 			LCDDP1;   
	wire 			LCDDP2;   
	wire 			LCDDP3;   
	wire 			LCDCol;   

	wire [7:0]			LCD1;
	wire [7:0]			LCD2;
	wire [7:0]			LCD3;
	wire [7:0]			LCD4;

	reg [6:0]			LCD1Seg;
	reg [6:0]			LCD2Seg;
	reg [6:0]			LCD3Seg;
	reg [6:0]			LCD4Seg;

	reg [15:0]			lcdcounter;
	
  reg [1:0] count ;	

  // clock generation
  always @(posedge clk_in)
    count <= count + 1 ;
    
  assign clk = count[1] ;
    
  wire STDBY ;
  wire rst_n ;
  
  assign STDBY = 1'b0 ; // used to switch between power saving and normal modes
  assign rst_n = rst ;
	

//***********************************************************************
//
//  LCD
//
//***********************************************************************

	assign LCDEnb = 1 ;

	// Used to create LCD clocks
	always @(posedge clk, negedge rst_n)
	begin
		if(rst_n == 0) begin
			lcdcounter <= 0;
		end else if (LCDEnb) begin
			lcdcounter <= lcdcounter + 1;
		end
	end

	wire			LCDFrameclk;
	wire			LCDPWMclk;

	assign LCDFrameclk = lcdcounter[12]; // LCD Frame clock ~60-90Hz * 4 = 240Hz - 360Hz
	assign LCDPWMclk = lcdcounter[2]; // LCD PWM clock used to create 0V, 1V, 2V, 3V


	// 4 Digit LCD with encoding
	LCD4Digit LCD4Digit_inst(
		.LCDFrameclk(LCDFrameclk),
		.LCDPWMclk(LCDPWMclk),
		.rstn(rst_n),
		.LCDDP1(LCDDP1),
		.LCDDP2(LCDDP2),
		.LCDDP3(LCDDP3),
		.LCDCol(LCDCol),
		.LCD1(LCD1Seg),
		.LCD2(LCD2Seg),
		.LCD3(LCD3Seg),
		.LCD4(LCD4Seg),

		.LCD_COM0_sig(LCD_COM0_sig),
		.LCD_COM1_sig(LCD_COM1_sig),
		.LCD_COM2_sig(LCD_COM2_sig),
		.LCD_COM3_sig(LCD_COM3_sig),

		.LCD_5_sig(LCD_5_sig),
		.LCD_6_sig(LCD_6_sig),
		.LCD_7_sig(LCD_7_sig),
		.LCD_8_sig(LCD_8_sig),
		.LCD_9_sig(LCD_9_sig),
		.LCD_10_sig(LCD_10_sig),
		.LCD_11_sig(LCD_11_sig),
		.LCD_12_sig(LCD_12_sig)
		);

	assign LCD_COM0 = (LCDEnb & ~STDBY) ? LCD_COM0_sig : 1'bZ;  
	assign LCD_COM1 = (LCDEnb & ~STDBY) ? LCD_COM1_sig : 1'bZ;  
	assign LCD_COM2 = (LCDEnb & ~STDBY) ? LCD_COM2_sig : 1'bZ;  
	assign LCD_COM3 = (LCDEnb & ~STDBY) ? LCD_COM3_sig : 1'bZ;  
	assign LCD_5 = (LCDEnb & ~STDBY) ? LCD_5_sig : 1'bZ;  
	assign LCD_6 = (LCDEnb & ~STDBY) ? LCD_6_sig : 1'bZ;  
	assign LCD_7 = (LCDEnb & ~STDBY) ? LCD_7_sig : 1'bZ;  
	assign LCD_8 = (LCDEnb & ~STDBY) ? LCD_8_sig : 1'bZ;  
	assign LCD_9 = (LCDEnb & ~STDBY) ? LCD_9_sig : 1'bZ;  
	assign LCD_10 = (LCDEnb & ~STDBY) ? LCD_10_sig : 1'bZ;  
	assign LCD_11 = (LCDEnb & ~STDBY) ? LCD_11_sig : 1'bZ;  
	assign LCD_12 = (LCDEnb & ~STDBY) ? LCD_12_sig : 1'bZ;  

	reg [7:0] CharAddress;
	wire [6:0] CharSegments;
	reg [1:0] lcdstate;

	parameter lcd1state=0, lcd2state=1, lcd3state=2, lcd4state=3 ;

	always @(posedge clk, negedge rst_n ) 
	if (rst_n ==0) begin
	  		CharAddress <= 0; 
				LCD1Seg <= 0 ;
				LCD2Seg <= 0 ;
				LCD3Seg <= 0 ;
				LCD4Seg <= 0 ;

	end
	else begin
		case (lcdstate)
			lcd1state: begin
				CharAddress <= LCD1; 
				LCD1Seg <= CharSegments;
				LCD2Seg <= LCD2Seg ;
				LCD3Seg <= LCD3Seg ;
				LCD4Seg <= LCD4Seg ;
			end
			lcd2state: begin
				CharAddress <= LCD2; 
				LCD1Seg <= LCD1Seg ;
				LCD2Seg <= CharSegments;
				LCD3Seg <= LCD3Seg ;
				LCD4Seg <= LCD4Seg ;

			end
			lcd3state: begin
				CharAddress <= LCD3; 
				LCD1Seg <= LCD1Seg ;
				LCD2Seg <= LCD2Seg ;				
				LCD3Seg <= CharSegments;
				LCD4Seg <= LCD4Seg ;				
			end
			lcd4state: begin
				CharAddress <= LCD4; 
				LCD1Seg <= LCD1Seg ;
				LCD2Seg <= LCD2Seg ;					
				LCD3Seg <= LCD3Seg ;							
				LCD4Seg <= CharSegments;
			end

			default:begin
			end
		endcase
	end

	LCDCharMap LCDCharMap_inst (
		.Address(CharAddress), 
		.OutClock(clk), 
		.OutClockEn(1), 
		.Reset(!rst), 
		.Q(CharSegments));

	reg [2:0] lcdnextstate;

	always @(posedge clk, negedge rst_n)
	begin
		if (rst_n == 0) begin
			lcdstate <= lcd1state;
			lcdnextstate <= lcdnextstate;
		end else begin
			lcdnextstate <= lcdnextstate + 1;
			
			case (lcdstate)
				lcd1state: begin
					if (&lcdnextstate == 1) begin
						lcdstate <= lcd2state;
					end
				end
				lcd2state: begin
					if (&lcdnextstate == 1) begin
						lcdstate <= lcd3state;
					end
				end
				lcd3state: begin
					if (&lcdnextstate == 1) begin
						lcdstate <= lcd4state;
					end
				end
				lcd4state: begin
					if (&lcdnextstate == 1) begin
						lcdstate <= lcd1state;
					end
				end
			endcase
		end
	end


endmodule