`ifndef _ram
`define _ram

`include "definitions.vh"
`timescale 1ns / 1ps

module ram(
	input wire [31 : 0] addr_in, write_data,
	input wire MemRead, MemWrite, clk,
	output reg [31 : 0] out 
    );
	reg [31 : 0] data [255 : 0];
    wire [31 : 0] addr; 
    assign addr = addr_in[31 : 0];
	assign out = MemRead ? data[addr] : 32'bz;

	always_ff @(negedge clk iff MemWrite) begin
		data[addr] <= write_data;
	end

endmodule

`endif