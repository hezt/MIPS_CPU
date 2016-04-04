`ifndef _instruction_mem
`define _instruction_mem

`include "definitions.vh"
`timescale 1ns / 1ps


module instruction_mem(
	input wire [31 : 0] pc_if,
	output wire [31 : 0] instruction_if
    );
	wire [7 : 0] num;
	reg [31 : 0] data [255 : 0];
	initial begin
		$readmemh("hztbm_d.txt", data);
	end
	
	assign num = pc_if[7 : 0];
	assign instruction_if = data[num];

endmodule

`endif