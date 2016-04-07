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
	
	// reg [31 : 0] cycles_counter = 32'd0;
	// wire [2 : 0] op = {rst, halt, pc_bj, nop_lock_id};

	// always_ff @(posedge clk) begin
		// if(halt == 1'b0) cycles_counter = cycles_counter + 32'd1;
	// end

	// always_ff @(posedge clk) begin
	// 	case (op)
	// 		4'b0000: out <= out + 32'b1;
	// 		4'b0001: out <= out;
	// 		4'b0010: out <= in;
	// 		4'b0011: out <= out;
	// 		4'b0100: out <= out;
	// 		4'b0101: out <= out;
	// 		4'b0110: out <= out;
	// 		4'b0111: out <= out;
	// 		4'b1000: out <= 32'b0;
	// 		4'b1001: out <= 32'b0;
	// 		4'b1010: out <= 32'b0;
	// 		4'b1011: out <= 32'b0;
	// 		4'b1100: out <= 32'b0;
	// 		4'b1101: out <= 32'b0;
	// 		4'b1110: out <= 32'b0;
	// 		4'b1111: out <= 32'b0;
	// 		default : out <= 32'bz;
	// 	endcase
	// 	end

	always_comb begin
		if(rst == 1'b1) out <= 32'h0; 
		else if(halt == 1'b1) out <= out;
		else if(pc_bj == 1'b1) out <= pc_src_in;
		else if(nop_lock_id == 1'b1) out <= out;
		else out <= pc_if_id + 1;;
	end
endmodule

`endif





