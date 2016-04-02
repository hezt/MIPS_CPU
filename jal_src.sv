`ifndef _jal_src
`define _jal_src

`include "definitions.vh"
`timescale 1ns / 1ps
module jal_src(
	input wire [1 : 0] Jump,
	input wire RegDst, 
	input wire MemtoReg,
	input wire [31 : 0] pc_in, alu_in, mem_in,
	input wire [4 : 0] rt_num, rd_num,
	output reg [4 : 0] write_num,
	output reg [31 : 0] write_data
    );
	
	wire [3 : 0] op = {Jump, RegDst, MemtoReg};
	// other situation is 0
	// Jump 10 is jal
	always_comb begin

		case (op)
			4'b1000: begin 
				write_num = 5'd31;
				write_data = pc_in + 1;
			end
			4'b0010: begin 
				write_num = rd_num;
				write_data = alu_in;
			end
			4'b0000: begin 
				write_num = rt_num;
				write_data = alu_in;
			end
			4'b0011: begin
				write_num = rd_num;
				write_data = mem_in;
			end
			4'b0001: begin
				write_num = rt_num;
				write_data = mem_in;
			end
			default : begin
			    write_num = rd_num;
			    write_data = mem_in;
			end
		endcase
	end
endmodule

`endif