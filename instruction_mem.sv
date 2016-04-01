`ifndef _instruction_mem
`define _instruction_mem

`include "definitions.vh"
`timescale 1ns / 1ps
`define LENGTH 7

module instruction_mem(


	input wire [`WORD_SIZE - 1 : 0] pc,
	output wire [5 : 0] opcode,
	output wire [4 : 0] rs,
	output wire [4 : 0] rt,
	output wire [4 : 0] rd,
	output wire [4 : 0] shamt,
	output wire [5 : 0] funct,
	output wire [15 : 0 ] immediate,
	output wire [25 : 0 ] address,
	output wire [31 : 0] read
    );
	wire [`LENGTH : 0] num;
	reg [31 : 0] data [256 : 0];
	
	initial begin 
		$readmemh("benchmark.txt", data, 0, 256);
	end
	
//	always_ff @(pc) beging
//	   $display
//	end
	assign num = pc[`LENGTH : 0];
	assign read = data[num];
	assign opcode = read[31 : 26];
	assign rs = read[25 : 21];
	assign rt  = read[20 : 16];
	assign rd  = read[15 : 11];
	assign shamt  = read[10 : 6];
	assign funct = read[5 : 0];
	assign immediate = read[15 : 0];
	assign address = read[25 : 0];
endmodule

`endif