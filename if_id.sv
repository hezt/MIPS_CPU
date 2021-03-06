`ifndef _if_id
`define _if_id
`timescale 1ns / 1ps


module if_id(
	input wire clk,
	input wire [31 : 0] instruction_if,
	input wire [31 : 0] pc_if,
	input wire nop_lock_id,
	input wire pc_bj,
	output reg [31 : 0] instruction_if_id = 0,
	output reg [31 : 0] pc_if_id = 0
    );
	always_ff @(posedge clk) begin
		if(nop_lock_id == 1'b0) begin
			instruction_if_id <= instruction_if;
			pc_if_id <= pc_if;
		end
		else begin
			instruction_if_id <= instruction_if_id;
			pc_if_id <= pc_if_id;
		end

	end
endmodule

`endif