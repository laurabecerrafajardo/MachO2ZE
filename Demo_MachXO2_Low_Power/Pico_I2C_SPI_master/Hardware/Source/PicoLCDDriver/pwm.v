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

