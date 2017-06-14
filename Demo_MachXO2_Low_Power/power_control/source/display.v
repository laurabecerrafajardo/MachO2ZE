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

//`include "timescale.v"
module display (
	input clk_i,
	input rst_n,
	input [7:0] data_in,
	output reg [7:0] LCD1,
	output reg [7:0] LCD2,
	output reg [7:0] LCD3,
	output reg [7:0] LCD4,
	output reg LCDDP1,   
	output reg LCDDP2,   
	output reg LCDDP3,   
	output reg LCDCol,   
	output reg LCDEnWB   
	);
  
  reg [25:0] count;
  always@ (posedge clk_i)
    count <= count + 1 ;
  
  
	always@( * ) begin
			LCD1 <= {4'h0, data_in[7:4]} ; //8'h0A ;//8'h19; //P count[25] ; //
			LCD2 <= {4'h0, data_in[3:0]} ; //8'h0A ;//8'h12; //I count[24] ; //
			LCD3 <= 8'h00                ; //8'h0A ;//8'h0C; //C count[23] ; //
			LCD4 <= 8'h0A                ; //8'h0A ;//8'h18; //O count[22] ; //
			LCDDP1 <= 0;
			LCDDP2 <= 1;
			LCDDP3 <= 0;
			LCDCol <= 0;
			LCDEnWB <= 1;

	end
    
endmodule