`ifndef _data_dependence
`define _data_dependence
`timescale 1ns / 1ps

module data_dependence(
	input wire [4 : 0] regfile_read_num1_syscall_id, regfile_read_num2_syscall_id, regfile_write_num_id_ex, regfile_write_num_ex_mem, 
	input wire [1 : 0] Jump_id,
	output reg nop_lock_id = 1'b0
    );
	
	always_comb begin
		if(Jump_id == 2'b00 || Jump_id == 2'b01) begin
			// non-j non-jal or jr
			if(regfile_write_num_id_ex != 1'b0 || regfile_write_num_ex_mem != 1'b0) begin
				if(regfile_read_num1_syscall_id == regfile_write_num_id_ex || regfile_read_num1_syscall_id == regfile_write_num_ex_mem || regfile_read_num2_syscall_id == regfile_write_num_id_ex || regfile_read_num2_syscall_id == regfile_write_num_ex_mem) nop_lock_id = 1'b1;
			end
			else nop_lock_id = 1'b0;
		end
		else nop_lock_id = 1'b0;
	end
endmodule

`endif
