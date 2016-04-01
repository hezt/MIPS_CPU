`ifndef _regfile
`define _regfile

`timescale 1ns / 1ps
`include "definitions.vh"

//32 bit register file
module regfile(
	input wire clk,
	input wire [4 : 0] read_num1, read_num2,
	input wire [4 : 0] write_num,
	input wire write_en,
	input wire [`WORD_SIZE - 1 : 0] write_data,
	output wire [`WORD_SIZE - 1 : 0] read_data1, read_data2
    );
	
	reg [31 : 0] regs [31 : 0];

    assign read_data1 = (read_num1 == 5'd0) ? 32'd0 : regs[read_num1];
    assign read_data2 = (read_num2 == 5'd0) ? 32'd0 : regs[read_num2];
    
	always_ff @(negedge clk iff write_en) begin
		regs[write_num] <= write_data;	
	end
endmodule

`endif