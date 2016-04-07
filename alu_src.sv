`ifndef _alu_src
`define _alu_src

`include "definitions.vh"
`timescale 1ns / 1ps
module alu_src(
	input wire [1 : 0] AluSrc,
	input wire [`WORD_SIZE - 1 : 0] regfile_read_data1, regfile_read_data2, ext_immidiate,
	input wire [4 : 0] shamt, 
	input wire [2 : 0] bypass_ex,
	input wire [31 : 0] regfile_write_data_wb, alu_out_ex_mem,
	output reg [`WORD_SIZE - 1 : 0] alu_src_out1, alu_src_out2
    );
// if((regfile_read_num1_syscall_id_ex == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0) bypass_ex = 3'b010;
// 			else if((regfile_read_num1_syscall_id_ex == regfile_write_num_mem_wb) && regfile_write_num_mem_wb != 0) bypass_ex = 3'b110;
// 			else if((regfile_read_num2_syscall_id_ex == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0) bypass_ex = 3'b001;
// 			else if((regfile_read_num2_syscall_id_ex == regfile_write_num_mem_wb) && regfile_write_num_mem_wb != 0) bypass_ex = 3'b101;
// 			else bypass_ex = 3'b000;
	always_comb begin
		case (AluSrc)
			2'b00: begin
				// r
				case (bypass_ex)
					3'b010: begin
						alu_src_out1 = alu_out_ex_mem;
						alu_src_out2 = regfile_read_data2;
					end
					3'b110: begin
						alu_src_out1 = regfile_write_data_wb;
						alu_src_out2 = regfile_read_data2;
					end
					3'b001: begin
						alu_src_out1 = regfile_read_data1;
						alu_src_out2 = alu_out_ex_mem;
					end
					3'b101: begin
						alu_src_out1 = regfile_read_data1;
						alu_src_out2 = regfile_write_data_wb;
					end
					default : begin
						alu_src_out1 = regfile_read_data1;
						alu_src_out2 = regfile_read_data2;
					end
				endcase
			end
			2'b01: begin
				// i
				case (bypass_ex)
					3'b010: begin
						alu_src_out1 = alu_out_ex_mem;
						alu_src_out2 = ext_immidiate;
					end
					3'b110: begin
						alu_src_out1 = regfile_write_data_wb;
						alu_src_out2 = ext_immidiate;
					end
					default : begin
						alu_src_out1 = regfile_read_data1;
						alu_src_out2 = ext_immidiate;
					end
				endcase
				// alu_src_out1 = regfile_read_data1;
				// alu_src_out2 = ext_immidiate;
			end
			2'b11: begin
				// shift
				// alu_src_out1 = regfile_read_data2;
				// alu_src_out2 = {26'h0, shamt};
				case (bypass_ex)
					3'b001: begin
						alu_src_out1 = alu_out_ex_mem;
						alu_src_out2 = {26'h0, shamt};
					end
					3'b101: begin
						alu_src_out1 = regfile_write_data_wb;
						alu_src_out2 = {26'h0, shamt};
					end
					default : begin
						alu_src_out1 = regfile_read_data1;
						alu_src_out2 = {26'h0, shamt};
					end
				endcase
			end
			default : begin
				alu_src_out1 = 32'bz;
				alu_src_out2 = 32'bz;
			end
		endcase
	end
endmodule

`endif