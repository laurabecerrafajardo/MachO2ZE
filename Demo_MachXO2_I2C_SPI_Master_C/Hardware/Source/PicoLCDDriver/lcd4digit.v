// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2001 - 2008 by Lattice Semiconductor Corporation  
// --------------------------------------------------------------------  
//  
// Permission:                    
//
// Lattice Semiconductor grants permission to use this code for use
// in synthesis for any Lattice programmable logic product. Other
// use of this code, including the selling or duplication of any
// portion is strictly prohibited.
//
// Disclaimer:
//
// This VHDL or Verilog source code is intended as a design reference
// which illustrates how these types of functions can be implemented.
// It is the user's responsibility to verify their design for
// consistency and functionality through the use of formal
// verification methods. Lattice Semiconductor provides no warranty
// regarding the use or functionality of this code.
//
// --------------------------------------------------------------------
//
// Lattice Semiconductor Corporation
// 5555 NE Moore Court
// Hillsboro, OR 97214
// U.S.A
//
// TEL: 1-800-Lattice (USA and Canada)
// 503-268-8001 (other locations)
//
// web: http://www.latticesemi.com/
// email: techsupport@latticesemi.com
//  
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Ver: | Author |Mod. Date |Changes Made:
// V1.0 | C.W.   |3/31/11    |Initial ver
//  
// --------------------------------------------------------------------
module LCD4Digit(
	input 			LCDFrameclk,
	input 			LCDPWMclk,
	input 			rstn,

	input			LCDDP1,
	input			LCDDP2,
	input			LCDDP3,
	input			LCDCol,

	input [6:0] 	LCD1,
	input [6:0] 	LCD2,
	input [6:0] 	LCD3,
	input [6:0] 	LCD4,

	output			LCD_COM0_sig,
	output			LCD_COM1_sig,
	output			LCD_COM2_sig,
	output			LCD_COM3_sig,

	output 			LCD_5_sig,
	output 			LCD_6_sig,
	output 			LCD_7_sig,
	output 			LCD_8_sig,
	output 			LCD_9_sig,
	output 			LCD_10_sig,
	output 			LCD_11_sig,
	output 			LCD_12_sig
	);

	wire [1:0]		LCD_COM0enc;
	wire [1:0]		LCD_COM1enc;
	wire [1:0]		LCD_COM2enc;
	wire [1:0]		LCD_COM3enc;
	wire [1:0]		LCD_5enc;
	wire [1:0]		LCD_6enc;
	wire [1:0]		LCD_7enc;
	wire [1:0]		LCD_8enc;
	wire [1:0]		LCD_9enc;
	wire [1:0]		LCD_10enc;
	wire [1:0]		LCD_11enc;
	wire [1:0]		LCD_12enc;


	// LCD Com signals
	LCDEncoding4to1com LCD_COM0enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDcom({1'b1, 1'b0, 1'b0, 1'b0}), .LCDcomEncoded(LCD_COM0enc));
	PWM LCD_COM0_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_COM0enc), .PWMVoltage(LCD_COM0_sig));

	LCDEncoding4to1com LCD_COM1enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDcom({1'b0, 1'b1, 1'b0, 1'b0}), .LCDcomEncoded(LCD_COM1enc));
	PWM LCD_COM1_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_COM1enc), .PWMVoltage(LCD_COM1_sig));

	LCDEncoding4to1com LCD_COM2enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDcom({1'b0, 1'b0, 1'b1, 1'b0}), .LCDcomEncoded(LCD_COM2enc));
	PWM LCD_COM2_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_COM2enc), .PWMVoltage(LCD_COM2_sig));

	LCDEncoding4to1com LCD_COM3enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDcom({1'b0, 1'b0, 1'b0, 1'b1}), .LCDcomEncoded(LCD_COM3enc));
	PWM LCD_COM3_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_COM3enc), .PWMVoltage(LCD_COM3_sig));

	// LCD Segment Signals
	LCDEncoding4to1 LCD_5enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({!LCD1[3], !LCD1[4], !LCD1[6], !LCD1[5]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_5enc));
	PWM LCD_5_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_5enc), .PWMVoltage(LCD_5_sig));

	LCDEncoding4to1 LCD_6enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({LCDDP1, !LCD1[2], !LCD1[1], !LCD1[0]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_6enc));
	PWM LCD_6_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_6enc), .PWMVoltage(LCD_6_sig));

	LCDEncoding4to1 LCD_7enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({!LCD2[3], !LCD2[4], !LCD2[6], !LCD2[5]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_7enc));
	PWM LCD_7_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_7enc), .PWMVoltage(LCD_7_sig));

	LCDEncoding4to1 LCD_8enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({LCDDP2, !LCD2[2], !LCD2[1], !LCD2[0]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_8enc));
	PWM LCD_8_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_8enc), .PWMVoltage(LCD_8_sig));

	LCDEncoding4to1 LCD_9enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({!LCD3[3], !LCD3[4], !LCD3[6], !LCD3[5]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_9enc));
	PWM LCD_9_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_9enc), .PWMVoltage(LCD_9_sig));

	LCDEncoding4to1 LCD_10enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({LCDDP3, !LCD3[2], !LCD3[1], !LCD3[0]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_10enc));
	PWM LCD_10_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_10enc), .PWMVoltage(LCD_10_sig));

	LCDEncoding4to1 LCD_11enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({!LCD4[3], !LCD4[4], !LCD4[6], !LCD4[5]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_11enc));
	PWM LCD_11_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_11enc), .PWMVoltage(LCD_11_sig));

	LCDEncoding4to1 LCD_12enc_inst (.clk(LCDFrameclk), .rstn(rstn), .LCDSegments({LCDCol, !LCD4[2], !LCD4[1], !LCD4[0]}), .LCDcom(LCDcom), .LCDSegEncoded(LCD_12enc));
	PWM LCD_12_inst (.clk(LCDPWMclk), .rstn(rstn), .Voltage(LCD_12enc), .PWMVoltage(LCD_12_sig));

endmodule

