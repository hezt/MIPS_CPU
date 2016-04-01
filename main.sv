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

	reg RegDst, RegWrite, MemRead, MemWrite, MemtoReg, JalSrc, SyscallSrc;
	reg Equal, regfile_write_en, of, cf, halt;
	reg [2 : 0] AluOp;
	reg [1 : 0] Branch, Jump;
	reg [5 : 0] opcode, funct;
	reg [1 : 0] AluSrc;
	reg [4 : 0] rs, rt, rd, shamt, regfile_write_num, rt_syscall, rs_syscall;
	reg [31 : 0] alu_src_out1, alu_src_out2, regfile_read_data1, regfile_read_data2;
	reg [31 : 0] pc_src_out, ext_immidiate, alu_out, mem_out, regfile_write_data;
    reg [15 : 0 ] immediate;
    reg [25 : 0 ] j_address;
	reg [3 : 0] alu_control_op_out;
	reg [31 : 0] pc_out, read;

  	cpu CPU_MOD(
  		.clk               (clk_cpu),
  		.display_syscall   (display_syscall),
  		.display_pc        (display_pc),
  		.RegDst            (RegDst),
  		.RegWrite          (RegWrite),
  		.MemRead           (MemRead),
  		.MemWrite          (MemWrite),
  		.MemtoReg          (MemtoReg),
  		.JalSrc            (JalSrc),
  		.SyscallSrc        (SyscallSrc),
  		.halt              (halt),
  		.Equal             (Equal),
  		.regfile_write_en  (regfile_write_en),
  		.of                (of),
  		.cf                (cf),
  		.Branch            (Branch),
  		.Jump              (Jump),
  		.AluSrc            (AluSrc),
  		.opcode            (opcode),
  		.funct             (funct),
  		.AluOp             (AluOp),
  		.rs                (rs),
  		.rt                (rt),
  		.rd                (rd),
  		.shamt             (shamt),
  		.regfile_write_num (regfile_write_num),
  		.rs_syscall        (rs_syscall),
  		.rt_syscall        (rt_syscall),
  		.pc_out            (pc_out),
  		.read              (read),
  		.alu_control_op_out(alu_control_op_out),
  		.pc_src_out        (pc_src_out),
  		.ext_immidiate     (ext_immidiate),
  		.alu_out           (alu_out),
  		.mem_out           (mem_out),
  		.regfile_write_data(regfile_write_data),
  		.regfile_read_data1(regfile_read_data1),
  		.regfile_read_data2(regfile_read_data2),
  		.alu_src_out1      (alu_src_out1),
  		.alu_src_out2      (alu_src_out2),
  		.immediate         (immediate),
  		.j_address         (j_address)
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