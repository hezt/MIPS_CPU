`ifndef _pc
`define _pc

`include "definitions.vh"
`timescale 1ns / 1ps

module pc(
	input wire clk,
	input wire rst, halt,
	input wire [`WORD_SIZE - 1 : 0] in,
	output reg [`WORD_SIZE - 1 : 0] out = 32'h0
    );
	

	always_ff @(posedge clk) begin
		if(rst == 1'b1) begin
			out <= 32'h0; 
		end
		else if (halt == 1'b1) begin
			out <= out;
		end 
		else begin
			out <= in;
		end
	end
endmodule

`endif