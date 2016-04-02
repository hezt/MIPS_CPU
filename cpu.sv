`ifndef _cpu
`define _cpu
`timescale 1ns / 1ps

`include "definitions.vh"
`include "alu.sv"
`include "alu_control.sv"
`include "control.sv"
`include "instruction_mem.sv"
`include "jal_src.sv"
`include "pc.sv"
`include "pc_src.sv"
`include "ram.sv"
`include "regfile.sv"
`include "sign_ext.sv"
`include "alu_src.sv"

module cpu(
	input wire clk,
	output reg [31 : 0] display_syscall,
	output wire [14 : 0] display_pc
);
	reg rst = 1'b1;
 	wire RegDst, RegWrite, MemRead, MemWrite, MemtoReg, JalSrc, SyscallSrc, halt;
	wire Equal, regfile_write_en; 
	wire [1 : 0] Branch, Jump, AluSrc;
	wire [5 : 0] opcode, funct;
	wire [2 : 0] AluOp;
	wire [4 : 0] rs, rt, rd, shamt, regfile_write_num, rs_syscall, rt_syscall;
	wire [31 : 0] pc_out, read;
	wire [3 : 0] alu_control_op_out;
	wire [31 : 0] pc_src_out, ext_immidiate, alu_out, mem_out, regfile_write_data;
    wire [31 : 0] regfile_read_data1, regfile_read_data2, alu_src_out1, alu_src_out2;
    wire [15 : 0 ] immediate;
    wire [25 : 0 ] j_address;
    assign display_pc = pc_out[14 : 0];
	assign rs_syscall = SyscallSrc == 1'b1 ? 5'd2 : rs;
	assign rt_syscall = SyscallSrc == 1'b1 ? 5'd4 : rt; 
	assign halt = SyscallSrc == 1'b1 ? (regfile_read_data1 == 32'd10 ? 1'b1 : 1'b0) : 1'b0;

  	always_ff @(posedge clk) begin 
		rst <= 1'b0;
		if(SyscallSrc == 1'b1) begin
			if(regfile_read_data1 == 32'd10) display_syscall <= display_syscall;
			else display_syscall <= regfile_read_data2;
		end
		else display_syscall <= display_syscall;	
  	end
  	
	pc PC_MOD(
		.clk (clk),
		.rst (rst),
		.halt(halt),
		.in  (pc_src_out),
		.out (pc_out)
		);

	// pc_src PC_SRC_MOD(Branch, Jump, Equal, pc_out, ext_immidiate, j_address, regfile_read_data1, pc_src_out);
	pc_src PC_SRC_MOD(
		.Branch   (Branch),
		.Jump     (Jump),
		.Equal    (Equal),
		.in_pc    (pc_out),
		.in_branch(ext_immidiate),
		.in_j     (j_address),
		.in_jr    (regfile_read_data1),
		.out      (pc_src_out)
		);

	// sign_ext SIGN_EXT_MOD(immediate, ONEBIT_true, ext_immidiate);
	sign_ext SIGN_EXT_MOD(
		.in  (immediate),
		.out (ext_immidiate)
		);

	// jal_src JAL_SRC_MOD(JalSrc, RegDst, MemtoReg, pc_out, alu_out, mem_out,  rt, rd, regfile_write_en, regfile_write_num, regfile_write_data);
	jal_src JAL_SRC_MOD(
		.Jump      (Jump),
		.RegDst    (RegDst),
		.MemtoReg  (MemtoReg),
		.pc_in     (pc_out),
		.alu_in    (alu_out),
		.mem_in    (mem_out),
		.rt_num    (rt),
		.rd_num    (rd),
		.write_num (regfile_write_num),
		.write_data(regfile_write_data)
		);
	// control CONTROL_MOD(opcode, funct, RegDst, RegWrite, MemRead, MemWrite, MemtoReg, AluSrc, JalSrc, AluOp, Branch, Jump, SyscallSrc);
	control CONTROL_MOD(
		.opcode    (opcode),
		.funct     (funct),
		.RegDst    (RegDst),
		.RegWrite  (RegWrite),
		.MemRead   (MemRead),
		.MemWrite  (MemWrite),
		.MemtoReg  (MemtoReg),
		.AluSrc    (AluSrc),
		.JalSrc    (JalSrc),
		.AluOp     (AluOp),
		.Branch    (Branch),
		.Jump      (Jump),
		.SyscallSrc(SyscallSrc)
		);
	// regfile REGFILE_MOD(clk, rs_syscall, rt_syscall, regfile_write_num, regfile_write_en, regfile_write_data, regfile_read_data1, regfile_read_data2);
	regfile REGFILE_MOD(
		.clk       (clk),
		.read_num1 (rs_syscall),
		.read_num2 (rt_syscall),
		.write_num (regfile_write_num),
		.write_en  (RegWrite),
		.write_data(regfile_write_data),
		.read_data1(regfile_read_data1),
		.read_data2(regfile_read_data2)
		);

	// alu ALU_MOD(alu_control_op_out, regfile_read_data1, alu_src_out, alu_out, of, cf, Equal);
	alu ALU_MOD(
		.op   (alu_control_op_out),
		.in1  (alu_src_out1),
	 	.in2  (alu_src_out2),
	 	.out  (alu_out),
	 	.equal(Equal)
	 	);
	// alu_control ALU_CONTROL_MOD(AluOp, funct, alu_control_op_out);
	alu_control ALU_CONTROL_MOD(
		.AluOp(AluOp),
		.funct(funct),
	 	.out  (alu_control_op_out)
	 	);
	// instruction_mem INSTRUCTION_MEM_MOD(pc_out, opcode, rs, rt, rd, shamt, funct, immediate, j_address, read);
	instruction_mem INSTRUCTION_MEM_MOD(
		.pc       (pc_out),
		.opcode   (opcode),
		.rs       (rs),
		.rt       (rt),
		.rd       (rd),
		.shamt    (shamt),
		.funct    (funct),
		.immediate(immediate),
		.address  (j_address),
		.read     (read)
		);

	alu_src ALU_SRC_MOD(
		.AluSrc            (AluSrc),
		.regfile_read_data1(regfile_read_data1),
		.regfile_read_data2(regfile_read_data2),
		.ext_immidiate     (ext_immidiate),
		.shamt             (shamt),
		.alu_src_out1      (alu_src_out1),
		.alu_src_out2      (alu_src_out2)
		);
	// ram RAM_MOD(alu_out, regfile_read_data2, MemRead, MemWrite, clk, mem_out);
	ram RAM_MOD(
		.addr_in   (alu_out),
		.write_data(regfile_read_data2),
		.MemRead   (MemRead),
		.MemWrite  (MemWrite),
		.clk       (clk),
		.out       (mem_out)
		);

endmodule

`endif