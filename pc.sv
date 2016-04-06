`ifndef _pc
`define _pc

`include "definitions.vh"
`timescale 1ns / 1ps

module pc(
	input wire clk,
	input wire rst, halt, pc_bj,
	input wire nop_lock_id,
	input wire [`WORD_SIZE - 1 : 0] in,
	output reg [`WORD_SIZE - 1 : 0] out = 32'h0
    );

	reg [31 : 0] cycles_counter = 32'd0;
	always_ff @(posedge clk) begin
		if(halt == 1'b0) cycles_counter = cycles_counter + 32'd1;
	end

	always_ff @(posedge clk) begin
		if(rst == 1'b1) begin
			out <= 32'h0; 
		end
		else if(halt == 1'b1) begin
			// halt is 1
			out <= out;
		end
		else if(nop_lock_id == 1'b0) begin
			if(pc_bj == 1'b1) begin
				out <= in;
			end
			else begin
				out <= out + 1'b1;
			end
		end 
		else out <= out;
	end
endmodule

`endif