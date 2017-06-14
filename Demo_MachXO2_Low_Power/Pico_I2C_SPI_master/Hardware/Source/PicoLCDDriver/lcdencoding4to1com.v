// Uses Machester Encoding to encode the LCD data, 4 segments in a frame
module LCDEncoding4to1com(clk, rstn, LCDcom, LCDcomEncoded);

	input clk, rstn;
	input [3:0] LCDcom;

	output [1:0] LCDcomEncoded; // {Full Drive, Pull Up, Pull Down}

	reg [1:0] LCDcomEncoded;
	reg [2:0] state;

	parameter seg1a=0, seg1b=1, seg2a=2, seg2b=3, seg3a=4, seg3b=5, seg4a=6, seg4b=7 ;

	always @(state) 
	begin
		case (state)
			seg1a:
			begin
				LCDcomEncoded = LCDcom[3] ? 2'b00 : 2'b10; // (0V or 2V)
			end
			seg1b:
			begin
				LCDcomEncoded = LCDcom[3] ? 2'b11 : 2'b01; // (3V or 1V)
			end
			seg2a:
			begin
				LCDcomEncoded = LCDcom[2] ? 2'b00 : 2'b10; // (0V or 2V)
			end
			seg2b:
			begin
				LCDcomEncoded = LCDcom[2] ? 2'b11 : 2'b01; // (3V or 1V)
			end
			seg3a:
			begin
				LCDcomEncoded = LCDcom[1] ? 2'b00 : 2'b10; // (0V or 2V)
			end
			seg3b:
			begin
				LCDcomEncoded = LCDcom[1] ? 2'b11 : 2'b01; // (3V or 1V)
			end
			seg4a:
			begin
				LCDcomEncoded = LCDcom[0] ? 2'b00 : 2'b10; // (0V or 2V)
			end
			seg4b:
			begin
				LCDcomEncoded = LCDcom[0] ? 2'b11 : 2'b01; // (3V or 1V)
			end

			default:
			begin
				LCDcomEncoded = 21'b00;
			end
		endcase
	end

	always @(posedge clk or negedge rstn)
	begin
		if (rstn == 0)
		begin
			state = seg1a;
		end
		else
		begin

			case (state)
				seg1a:
					state = seg1b;
				seg1b:
					state = seg2a;
				seg2a:
					state = seg2b;
				seg2b:
					state = seg3a;
				seg3a:
					state = seg3b;
				seg3b:
					state = seg4a;
				seg4a:
					state = seg4b;
				seg4b:
					state = seg1a;

			endcase
		end
	end

endmodule
