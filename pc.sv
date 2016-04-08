`ifndef _pc
`define _pc

`include "definitions.vh"
`timescale 1ns / 1ps

module pc(
	input wire rst, halt, pc_bj, nop_lock_id,
	input wire [31 : 0] pc_if_id,
	input wire [31 : 0] pc_src_in,
	output reg [31 : 0] out = 32'h0
    );
	
	always_comb begin
		if(rst == 1'b1) out <= 32'h0; 
		else if(halt == 1'b1) out <= out;
		else if(pc_bj == 1'b1) out <= pc_src_in;
		else if(nop_lock_id == 1'b1) out <= out;
		else out <= pc_if_id + 1;
	end
endmodule

`endif





