`ifndef _data_dependence
`define _data_dependence
`timescale 1ns / 1ps

module data_dependence(
	input wire clk,
	input [5 : 0] opcode_id,
	input wire [4 : 0] regfile_read_num1_syscall_id, regfile_read_num2_syscall_id, regfile_write_num_id_ex, regfile_write_num_ex_mem, 
	output reg nop_lock_id = 1'b0
    );
	reg nop_lock_id_temp = 1'b0;
	always_comb begin
		if(opcode_id == 6'b100011) begin
			if((regfile_read_num1_syscall_id == regfile_write_num_id_ex) && regfile_write_num_id_ex != 0) nop_lock_id_temp = 1'b1;
			else if((regfile_read_num1_syscall_id == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0) nop_lock_id_temp = 1'b1;
			else if((regfile_read_num2_syscall_id == regfile_write_num_id_ex) && regfile_write_num_id_ex != 0) nop_lock_id_temp = 1'b1;
			else if((regfile_read_num2_syscall_id == regfile_write_num_ex_mem) && regfile_write_num_ex_mem != 0) nop_lock_id_temp = 1'b1;
			else nop_lock_id_temp = 1'b0;
		end
		else nop_lock_id_temp = 1'b0;
	end
	always_ff @(negedge clk) begin
		nop_lock_id <= nop_lock_id_temp;
	end
endmodule

`endif
