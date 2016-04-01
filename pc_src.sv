`ifndef _pc_src
`define _pc_src

`include "definitions.vh"
`timescale 1ns / 1ps

module pc_src(
	input wire [1 : 0] Branch, Jump,
	input wire Equal,
	input wire [`WORD_SIZE - 1 : 0] in_pc, in_branch,
	input wire [25 : 0] in_j,
	input wire [`WORD_SIZE - 1 : 0] in_jr,
	output reg [`WORD_SIZE - 1 : 0] out
    );
	//in_j is used for j and jal
`define PC_NORMAL 5'b00000
`define PC_BEQ 5'b01100
`define PC_BNE 5'b10000

	wire [2 : 0] op;
	wire [31 : 0] j, jr, jal;
	assign op = {Branch, Equal};
	assign j = {in_pc[31 : 26], in_j};
	assign jr = in_jr;
	always_comb begin
		case(Jump)
			2'b11: out = j; // j
			2'b10: out = j; // jal
			2'b01: out = jr; // jr
			default: begin 
				case (op)
					3'b000: out = in_pc + 1; // normal
					3'b011: out = in_pc + in_branch + 1;// beq
					3'b100: out = in_pc + in_branch + 1;// bne
					default : out = in_pc + 1;
				endcase
			end
		endcase
	end
endmodule

`endif