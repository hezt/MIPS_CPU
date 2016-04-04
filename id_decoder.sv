`ifndef _id_decoder
`define _id_decoder

`timescale 1ns / 1ps

module id_decoder(
	input wire [31 : 0] instruction_if_id,
	output wire [5 : 0] opcode,
	output wire [4 : 0] rs,
	output wire [4 : 0] rt,
	output wire [4 : 0] rd,
	output wire [4 : 0] shamt,
	output wire [5 : 0] funct,
	output wire [15 : 0 ] immediate,
	output wire [25 : 0 ] address
    );
	
	assign opcode = instruction_reg[31 : 26];
	assign rs = instruction_reg[25 : 21];
	assign rt  = instruction_reg[20 : 16];
	assign rd  = instruction_reg[15 : 11];
	assign shamt  = instruction_reg[10 : 6];
	assign funct = instruction_reg[5 : 0];
	assign immediate = instruction_reg[15 : 0];
	assign address = instruction_reg[25 : 0];
endmodule

`endif