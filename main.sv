`ifndef _main
`define _main

`timescale 1ns / 1ps
`include "definitions.vh"
`include "led_display.sv"
`include "clock.sv"
`include "cpu.sv"

module main(
    input wire clk_board,
    output wire clk_cpu,
    output wire [7 : 0] display_data, display_en,
    output reg [14 : 0] display_pc
    );
    wire clk_led;
    wire [31 : 0] display_syscall;
    cpu cpu(
        .clk            (clk_cpu),
        .display_syscall(display_syscall),
        .display_pc     (display_pc)
        );
    clock CLOCK_MOD(
        .clk_board(clk_board),
        .clk_cpu  (clk_cpu),
        .clk_led  (clk_led)
        );	
      	
    led_display LED_DISPLAY_MOD(
        .clk         (clk_led),
        .in_data     (display_syscall),
        .display_data(display_data),
        .display_en  (display_en)
        );

endmodule

`endif