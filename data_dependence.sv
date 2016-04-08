`ifndef _data_dependence
`define _data_dependence
`timescale 1ns / 1ps

module data_dependence(
	input wire clk,
	input wire MemRead_id_ex,
	input wire [1 : 0] Jump_id,
	input wire [4 : 0] regfile_read_num1_syscall_id, regfile_read_num2_syscall_id, regfile_write_num_id_ex, regfile_write_num_ex_mem,
	input wire RegWrite_id_ex, RegWrite_ex_mem,
	input wire [31 : 0] regfile_read_data1_id, regfile_read_data2_id, alu_out_ex, ram_read_data_mem,
	output reg nop_lock_id = 1'b0,
	output reg [31 : 0] bypass_data1_id = 0, 
	output reg [31 : 0] bypass_data2_id = 0
    );
	reg nop_lock_id_temp = 1'b0;
	reg [31 : 0] temp1, temp2;
	// if ir is LW, then insert a bubble
	always_comb begin
		if(MemRead_id_ex == 1'b1) begin
			if((regfile_read_num1_syscall_id == regfile_write_num_id_ex) && regfile_write_num_id_ex != 0 && RegWrite_id_ex == 1'b1) nop_lock_id_temp = 1'b1;
			// else if((regfile_read_num1_syscall_id == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 1'b0 && RegWrite_ex_mem == 1'b1) nop_lock_id_temp = 1'b1;
			else if((regfile_read_num2_syscall_id == regfile_write_num_id_ex) && regfile_write_num_id_ex != 0 && RegWrite_id_ex == 1'b1) nop_lock_id_temp = 1'b1;
			// else if((regfile_read_num2_syscall_id == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 1'b0 && RegWrite_ex_mem == 1'b1) nop_lock_id_temp = 1'b1;
			else nop_lock_id_temp = 1'b0;
		end
		else nop_lock_id_temp = 1'b0;
	end

	always_ff @(negedge clk) begin
		nop_lock_id <= nop_lock_id_temp;
		bypass_data1_id <= temp1;
		bypass_data2_id <= temp2;
	end
	// if ir isn't LW, then judge about the bypass

	always_comb begin
		if(Jump_id == 2'b00 || Jump_id == 2'b01) begin
			// not lw 
			// not jal j
			if((regfile_read_num1_syscall_id == regfile_write_num_id_ex) && regfile_write_num_id_ex != 0 && RegWrite_id_ex == 1'b1) begin
				temp1 = alu_out_ex;
			end
			else if((regfile_read_num1_syscall_id == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0 && RegWrite_ex_mem == 1'b1) begin
				temp1 = ram_read_data_mem;
			end
			else begin
				temp1 = regfile_read_data1_id;
			end
		end
		else begin
			temp1 = regfile_read_data1_id;
		end
	end

	always_comb begin
		if(MemRead_id_ex == 1'b0 && (Jump_id == 2'b00 || Jump_id == 2'b01)) begin
			// not lw 
			// not jal j
			if((regfile_read_num2_syscall_id == regfile_write_num_id_ex) && regfile_write_num_id_ex != 0 && RegWrite_id_ex == 1'b1) begin
				temp2 = alu_out_ex;
			end
			else if((regfile_read_num2_syscall_id == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0 && RegWrite_ex_mem == 1'b1) begin
				temp2 = ram_read_data_mem;
			end
			else begin
				temp2 = regfile_read_data2_id;
			end
		end
		else begin
			temp2 = regfile_read_data2_id;
		end
	end
endmodule

`endif
