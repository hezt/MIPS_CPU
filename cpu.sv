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
`include "if_id.sv"
`include "instruction_decoder.sv"
`include "id_ex.sv"

module cpu(
	input wire clk,
	output reg [31 : 0] display_syscall,
	output wire [14 : 0] display_pc
);
	reg rst = 1'b1;
	// pc signal
	wire [31 : 0] pc_if, pc_if_id, pc_id_ex;

	// instruction and decode signal
	wire [31 : 0] instruction_if, instruction_if_id, instruction_id_ex;
	wire [5 : 0] opcode_id;
	wire [5 : 0] funct_id, funct_id_ex;
	wire [4 : 0] rs_id;
	wire [4 : 0] rt_id;
	wire [4 : 0] rd_id;
	wire [4 : 0] shamt_id, shamt_id_ex;
	wire [15 : 0] immediate_id;
	wire [25 : 0] address_id, address_id_ex;

	// control signal
	wire [1 : 0] Branch_id, Branch_id_ex;
	wire [1 : 0] Jump_id, Jump_id_ex;
	wire [1 : 0] AluSrc_id, AluSrc_id_ex;
	wire [2 : 0] AluOp_id, AluOp_id_ex;
	wire RegDst_id, RegDst_id_ex;
	wire RegWrite_id, RegDst_id_ex;
	wire MemRead_id, MemRead_id_ex;
	wire MemWrite_id, MemWrite_id_ex;
	wire MemtoReg_id, MemtoReg_id_ex;
	wire JalSrc_id, JalSrc_id_ex;
	wire SyscallSrc_id, SyscallSrc_id_ex;

	// sign extention
	wire [31 : 0]ext_immediate_id, ext_immediate_id_ex;

	// regfile
	wire [4 : 0] regfile_read_num1_id, regfile_read_num1_syscall_id;
	wire [4 : 0] regfile_read_num2_id, regfile_read_num2_syscall_id;
	wire [4 : 0] regfile_write_num_id; // cun yi
	wire regfile_write_en_id; // cun yi
	wire [31 : 0] regfile_write_data_id; // cun yi
	wire [31 : 0] regfile_read_data1_id, regfile_read_data1_id_ex; 
	wire [31 : 0] regfile_read_data2_id, regfile_read_data2_id_ex;

	// alu_src
	wire [31 : 0] alu_src_out1_ex;
	wire [31 : 0] alu_src_out1_ex;
	// alu ctrl
	wire [3 : 0] alu_control_out_ex;
	// alu
	wire alu_equal_ex;
	wire [31 : 0] alu_out_ex;
	// pc src
	wire [31 : 0] pc_src_out_ex;
	wire pc_src_bj_ex;
	wire halt_ex;

	// ID syscall's getting data
	assign regfile_read_num1_syscall_id = SyscallSrc_id == 1'b1 ? 5'd2 : regfile_read_num1_id;
	assign regfile_read_num2_syscall_id = SyscallSrc_id == 1'b1 ? 5'd4 : regfile_read_num2_id;
	// EX syscall's execution
	assign halt_ex = SyscallSrc_id_ex == 1'b1 ? (regfile_read_data1_id_ex == 32'd10 ? 1'b1 : 1'b0) : 1'b0;
	always_ff @(posedge clk) begin 
		rst <= 1'b0;
		if(SyscallSrc_id_ex == 1'b1) begin
			if(regfile_read_data1_id_ex == 32'd10) display_syscall <= display_syscall;
			else display_syscall <= regfile_read_data2_id_ex;
		end
		else display_syscall <= display_syscall;	
  	end
  	// EX display pc
  	assign display_pc = pc_if[14 : 0];



	// IF
	pc PC_MOD(
		.clk  (clk),
		.rst  (rst),
		.halt (halt_ex),
		.in   (pc_src_out_ex),
		.out  (pc_if),
		.pc_bj(pc_src_bj_ex)	
		);
	instruction_mem INSTRUCTION_MEM_MOD(
		.pc_if         (pc_if),
		.instruction_if(instruction_if)
		);
	// IF/ID
	if_id IF_ID_MOD(
		.clk              (clk),
		.instruction_if   (instruction_if),
		.pc_if            (pc_if),
		.instruction_if_id(instruction_if_id),
		.pc_if_id         (pc_if_id)
		);
	// ID
	instruction_decoder INSTRUCTION_DECODER_MOD(
		.instruction_if_id(instruction_if_id),
		.opcode           (opcode_id),
		.rs               (rs_id),
		.rt               (rt_id),
		.rd               (rd_id),
		.shamt            (shamt_id),
		.funct            (funct_id),
		.immediate        (immediate_id),
		.address          (address_id)
		);
	control CONTROL_MOD(
		.opcode    (opcode_id),
		.funct     (funct_id),
		.RegDst    (RegDst_id),
		.RegWrite  (RegWrite_id),
		.MemRead   (MemRead_id),
		.MemWrite  (MemWrite_id),
		.MemtoReg  (MemtoReg_id),
		.JalSrc    (JalSrc_id),
		.Branch    (Branch_id),
		.Jump      (Jump_id),
		.AluSrc    (AluSrc_id),
		.SyscallSrc(SyscallSrc_id),
		.AluOp     (AluOp_id),
		);
	regfile REGFILE_MOD(
		.clk       (clk),
		.read_num1 (regfile_read_num1_syscall_id),
		.read_num2 (regfile_read_num2_syscall_id),
		.write_num (regfile_write_num_id),
		.write_en  (regfile_write_en_id),
		.write_data(regfile_write_data_id),
		.read_data1(regfile_read_data1_id),
		.read_data2(regfile_read_data2_id)
		);
	sign_ext SIGN_EXT_MOD(
		.in (immediate_id),
		.out(ext_immediate_id)
		);

	// ID/EX
	id_ex ID_EX_MOD(
		.clk                (clk),
		.pc_if_id           (pc_if_id),
		.funct_id           (funct_id),
		.shamt_id           (shamt_id),
		.ext_immediate_id   (ext_immediate_id),
		.address_id         (address_id),
		.Branch_id          (Branch_id),
		.Jump_id            (Jump_id),
		.AluSrc_id          (AluSrc_id),
		.AluOp_id           (AluOp_id),
		.RegDst_id          (RegDst_id),
		.RegWrite_id        (RegWrite_id),
		.MemRead_id         (MemRead_id),
		.MemWrite_id        (MemWrite_id),
		.MemtoReg_id        (MemtoReg_id),
		.JalSrc_id          (JalSrc_id),
		.SyscallSrc_id      (SyscallSrc_id),
		.read_data1_id      (regfile_read_data1_id),
		.read_data2_id      (regfile_read_data2_id),
		.pc_id_ex           (pc_id_ex),
		.funct_id_ex        (funct_id_ex),
		.shamt_id_ex        (shamt_id_ex),
		.ext_immediate_id_ex(ext_immediate_id_ex),
		.address_id_ex      (address_id_ex),
		.Branch_id_ex       (Branch_id_ex),
		.Jump_id_ex         (Jump_id_ex),
		.AluSrc_id_ex       (AluSrc_id_ex),
		.AluOp_id_ex        (AluOp_id_ex),
		.RegDst_id_ex       (RegDst_id_ex),
		.RegWrite_id_ex     (RegWrite_id_ex),
		.MemRead_id_ex      (MemRead_id_ex),
		.MemWrite_id_ex     (MemWrite_id_ex),
		.MemtoReg_id_ex     (MemtoReg_id_ex),
		.JalSrc_id_ex       (JalSrc_id_ex),
		.SyscallSrc_id_ex   (SyscallSrc_id_ex),
		.read_data1_id_ex   (regfile_read_data1_id_ex),
		.read_data2_id_ex   (regfile_read_data2_id_ex),
		.instruction_if_id  (instruction_if_id),
		.instruction_id_ex  (instruction_id_ex)
		);

	// EX
	alu_src ALU_SRC_MOD(
		.AluSrc            (AluSrc_id_ex),
		.regfile_read_data1(regfile_read_data1_id_ex),
		.regfile_read_data2(regfile_read_data2_id_ex),
		.ext_immidiate     (ext_immediate_id_ex),
		.shamt             (shamt_id_ex),
		.alu_src_out1      (alu_src_out1_ex),
		.alu_src_out2      (alu_src_out2_ex)
		);

	alu_control ALU_CONTROL_MOD(
		.AluOp(AluOp_id_ex),
		.funct(funct_id_ex),
		.out  (alu_control_out_ex)
		);
	alu ALU_MOD(
		.op   (alu_control_out_ex),
		.in1  (alu_src_out1_ex),
		.in2  (alu_src_out2),
		.out  (alu_out_ex),
		.equal(alu_equal_ex)
		);
	pc_src PC_SRC_MOD(
		.Branch   (Branch_id_ex),
		.Jump     (Jump_id_ex),
		.Equal    (alu_equal_ex),
		.in_pc    (pc_id_ex),
		.in_branch(ext_immediate_id_ex),
		.in_j     (address_id_ex),
		.in_jr    (regfile_read_data1_id_ex),
		.out      (pc_src_out_ex),
		.pc_bj    (pc_src_bj_ex)
		);	
  	


	// // jal_src JAL_SRC_MOD(JalSrc, RegDst, MemtoReg, pc_out, alu_out, mem_out,  rt, rd, regfile_write_en, regfile_write_num, regfile_write_data);
	// jal_src JAL_SRC_MOD(
	// 	.Jump      (Jump),
	// 	.RegDst    (RegDst),
	// 	.MemtoReg  (MemtoReg),
	// 	.pc_in     (pc_out),
	// 	.alu_in    (alu_out),
	// 	.mem_in    (mem_out),
	// 	.rt_num    (rt),
	// 	.rd_num    (rd),
	// 	.write_num (regfile_write_num),
	// 	.write_data(regfile_write_data)
	// 	);

	// // ram RAM_MOD(alu_out, regfile_read_data2, MemRead, MemWrite, clk, mem_out);
	// ram RAM_MOD(
	// 	.addr_in   (alu_out),
	// 	.write_data(regfile_read_data2),
	// 	.MemRead   (MemRead),
	// 	.MemWrite  (MemWrite),
	// 	.clk       (clk),
	// 	.out       (mem_out)
	// 	);

endmodule

`endif