`ifndef _mem_wb
`define _mem_wb

`timescale 1ns / 1ps

module mem_wb(
	input wire clk,
	input wire [31 : 0] pc_ex_mem,
	input wire [31 : 0] instruction_ex_mem,
	input wire MemtoReg_ex_mem,
	input wire [4 : 0] rt_ex_mem, rd_ex_mem,
	input wire [1 : 0] Jump_ex_mem,
	input wire [31 : 0] alu_out_ex_mem,
	input wire [31 : 0] ram_read_data_mem,
	input wire  RegDst_ex_mem,
	input wire RegWrite_ex_mem,
	input wire halt_ex_mem,
	output reg [31 : 0] pc_mem_wb,
	output reg [31 : 0] instruction_mem_wb,
	output reg MemtoReg_mem_wb,
	output reg [1 : 0] Jump_mem_wb,
	output reg [4 : 0] rt_mem_wb, rd_mem_wb,
	output reg [31 : 0] alu_out_mem_wb,
	output reg [31 : 0] ram_read_data_mem_wb,
	output reg RegDst_mem_wb,
	output reg RegWrite_mem_wb,
	output reg halt_mem_wb
    );
	
	always_ff @(posedge clk) begin
		pc_mem_wb <= pc_ex_mem;
		instruction_mem_wb <= instruction_ex_mem;
		MemtoReg_mem_wb <= MemtoReg_ex_mem;
		Jump_mem_wb <= Jump_ex_mem;
		alu_out_mem_wb <= alu_out_ex_mem;
		ram_read_data_mem_wb <= ram_read_data_mem;
		rt_mem_wb <= rt_ex_mem;
		rd_mem_wb <= rd_ex_mem;
		RegDst_mem_wb <= RegDst_ex_mem;
		RegWrite_mem_wb <= RegWrite_ex_mem;
		halt_mem_wb <= halt_ex_mem;
	end
endmodule

`endif