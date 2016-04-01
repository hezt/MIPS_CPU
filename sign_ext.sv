`ifndef _sign_ext
`define _sign_ext

//sign extention module from 16 bit to 32 bit
`timescale 1ns / 1ps
module sign_ext(
	input wire [15 : 0] in,
	input wire sign, 
	output reg [31 : 0] out
    );//sign: 0 is unsigned, 1 is signed
	always_comb begin
		//unsigned
		if(sign == 0)
			out = {16'h0, in};
		//signed
		else begin
			case (in[15])
				//sign is 1
				1 : out = {16'hFFFF, in};
				//sign is 0
				0 : out = {16'h0, in};
				default : out = {16'hz, in};
			endcase
		end
	end
endmodule

`endif