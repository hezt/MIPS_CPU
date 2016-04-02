`ifndef _sign_ext
`define _sign_ext

//sign extention module from 16 bit to 32 bit
`timescale 1ns / 1ps
module sign_ext(
	input wire [15 : 0] in,
	output reg [31 : 0] out
    );
	always_comb begin
    	out[31 : 0] <= { {16{in[15]}}, in[15 : 0] };
	end
endmodule

`endif