`ifndef _bypass
`define _bypass
`timescale 1ns / 1ps


module bypass(
	input clk,
	input wire [4 : 0] regfile_write_num_ex_mem, regfile_write_num_mem_wb, regfile_read_num1_syscall_id_ex, regfile_read_num2_syscall_id_ex,
	input wire [31 : 0] instruction_id_ex,
	input wire [1 : 0] Jump_id_ex,
	output reg [2 : 0] bypass_ex = 3'b000  
    );
	wire [5 : 0] opcode;
	// reg [2 : 0] bypass_ex_temp = 3'b000;
	assign opcode = instruction_id_ex[31 : 26];
	always_comb begin
		if(opcode != 5'b100011 && (Jump_id_ex == 2'b00 || Jump_id_ex == 2'b01)) begin
			// not lw 
			// not jal j
			if((regfile_read_num1_syscall_id_ex == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0) bypass_ex = 3'b010;
			else if((regfile_read_num1_syscall_id_ex == regfile_write_num_mem_wb) && regfile_write_num_mem_wb != 0) bypass_ex = 3'b110;
			else if((regfile_read_num2_syscall_id_ex == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0) bypass_ex = 3'b001;
			else if((regfile_read_num2_syscall_id_ex == regfile_write_num_mem_wb) && regfile_write_num_mem_wb != 0) bypass_ex = 3'b101;
			else bypass_ex = 3'b000;
		end
		else bypass_ex = 3'b000;
	end

// always_ff @(posedge clk) begin
	// 	bypass_ex <= bypass_ex_temp;
	// end
endmodule

`endif