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

// Duty, PWM => (00, 000=0V), (11,111=3V), (01,100=1V), (10,110=2V)
module PWM(clk, rstn, Voltage, PWMVoltage);

	input clk, rstn;
	input [1:0] Voltage;

	output PWMVoltage;

	reg PWMVoltage;
	reg [2:0] state;

	parameter PWM0=0, PWM1=1, PWM2=2 ;

	always @(state) 
	begin
		case (state)
			PWM0:
			begin
				if (Voltage == 2'b00)
					PWMVoltage = 1'b0;
				else if (Voltage == 2'b11)
					PWMVoltage = 1'b1;
				else if (Voltage == 2'b01)
					PWMVoltage = 1'b1;
				else if (Voltage == 2'b10)
					PWMVoltage = 1'b1;
			end
			PWM1:
			begin
				if (Voltage == 2'b00)
					PWMVoltage = 1'b0;
				else if (Voltage == 2'b11)
					PWMVoltage = 1'b1;
				else if (Voltage == 2'b01)
					PWMVoltage = 1'b0;
				else if (Voltage == 2'b10)
					PWMVoltage = 1'b1;
			end
			PWM2:
			begin
				if (Voltage == 2'b00)
					PWMVoltage = 1'b0;
				else if (Voltage == 2'b11)
					PWMVoltage = 1'b1;
				else if (Voltage == 2'b01)
					PWMVoltage = 1'b0;
				else if (Voltage == 2'b10)
					PWMVoltage = 1'b0;
			end

			default:
			begin
				PWMVoltage = 1'b0;
			end
		endcase
	end

	always @(posedge clk or negedge rstn)
	begin
		if (rstn == 0)
			begin
			state = PWM0;
			end
		else
			begin

			case (state)
				PWM0:
					state = PWM1;
				PWM1:
					state = PWM2;
				PWM2:
					state = PWM0;

			endcase
			end
	end

endmodule

