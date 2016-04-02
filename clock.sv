`ifndef _clock
`define _clock
`timescale 1ns / 1ps
`include "definitions.vh"

module clock(
	input wire clk_board,
	output reg clk_cpu = 1'b0,
	output reg clk_led = 1'b0
    );
	
	integer i = 0;
	always_ff @(posedge clk_board) begin
		i <= i + 1'd1;
		if(i == 32'd5000000 - 32'd1) begin
			i <= 1'd0;
			clk_cpu = ~clk_cpu;
		end
	end

	integer j = 0;
	always_ff @(posedge clk_board) begin
		j <= j + 1'd1;
		if(j >= 32'd50000 - 32'd1) begin
			j <= 1'd0;
			clk_led = ~clk_led;
		end
	end
	// parameter CLK_DIV_N = 5000000;

	// parameter CLK_LED_N = 100000;
	// reg [31 : 0] counter_cpu = 0;
	// reg [31 : 0] counter_led = 0;
	// always_ff @(posedge clk_board) begin
	// 	if(counter_cpu < CLK_DIV_N) begin
	// 		if(counter_cpu == (CLK_DIV_N >> 1)) begin
	// 			clk_cpu <= ~clk_cpu;
	// 		end
	// 		counter_cpu <= counter_cpu + 1;
	// 	end
	// 	else begin 
	// 		counter_cpu <= 0;
	// 	end
	// end

	// always_ff @(posedge clk_board) begin
	// 	if(counter_led < CLK_LED_N) begin
	// 		if(counter_led == (CLK_LED_N >> 1)) begin
	// 			clk_led <= ~clk_led;
	// 		end
	// 		counter_led <= counter_led + 1;
	// 	end
	// 	else begin 
	// 		counter_led <= 0;
	// 	end
	// end

endmodule

`endif