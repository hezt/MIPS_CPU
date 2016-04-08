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
`include "ex_mem.sv"
`include "mem_wb.sv"
`include "data_dependence.sv"
`include "bypass.sv"
module cpu(
	input wire clk,
	output reg [31 : 0] display_syscall,
	output wire [11 : 0] cycles_counter
);
	reg rst = 1'b1;
	// pc signal
	wire [31 : 0] pc_if, pc_if_id, pc_id_ex, pc_ex_mem, pc_mem_wb;

	// instruction and decode signal
	wire [31 : 0] instruction_if, instruction_if_id, instruction_id_ex, instruction_ex_mem, instruction_mem_wb;
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
	wire [1 : 0] Jump_id, Jump_id_ex, Jump_ex_mem, Jump_mem_wb;
	wire [1 : 0] AluSrc_id, AluSrc_id_ex;
	wire [2 : 0] AluOp_id, AluOp_id_ex;
	wire RegDst_id, RegDst_id_ex, RegDst_ex_mem, RegDst_mem_wb;
	wire RegWrite_id, RegWrite_id_ex, RegWrite_ex_mem, RegWrite_mem_wb;
	wire MemRead_id, MemRead_id_ex, MemRead_ex_mem;
	wire MemWrite_id, MemWrite_id_ex, MemWrite_ex_mem;
	wire MemtoReg_id, MemtoReg_id_ex, MemtoReg_ex_mem, MemtoReg_mem_wb;
	wire JalSrc_id, JalSrc_id_ex;
	wire SyscallSrc_id, SyscallSrc_id_ex;

	// sign extention
	wire [31 : 0]ext_immediate_id, ext_immediate_id_ex;

	// regfile
	reg [4 : 0] regfile_read_num1_syscall_id = 1'b0;
	reg [4 : 0] regfile_read_num2_syscall_id = 1'b0;
	wire [4 : 0] regfile_read_num1_syscall_id_ex;
	wire [4 : 0] regfile_read_num2_syscall_id_ex;
	reg [4 : 0] regfile_write_num_id;
	wire [4 : 0] regfile_write_num_id_ex, regfile_write_num_ex_mem, regfile_write_num_mem_wb;
	wire [31 : 0] regfile_write_data_wb;
	wire [31 : 0] regfile_read_data1_id, regfile_read_data1_id_ex; 
	wire [31 : 0] regfile_read_data2_id, regfile_read_data2_id_ex;

	// alu_src
	wire [31 : 0] alu_src_out1_ex;
	wire [31 : 0] alu_src_out2_ex;
	// alu ctrl
	wire [3 : 0] alu_control_out_ex;
	// alu
	wire alu_equal_ex;
	wire [31 : 0] alu_out_ex, alu_out_ex_mem, alu_out_mem_wb;
	// pc src
	wire [31 : 0] pc_src_out_ex;
	wire pc_src_bj_ex;
	wire halt_ex, halt_ex_mem, halt_mem_wb;
	// ram
	wire [31 : 0] ram_write_data_ex_mem;
	wire [31 : 0] ram_read_data_mem, ram_read_data_mem_wb;	

	// data denpendence
	wire nop_lock_id;
	// bypass
	wire [31 : 0] bypass_data1_ex, bypass_data2_ex;
	// cycles counter
	always_comb begin
		if(SyscallSrc_id == 1'b1) begin
			regfile_read_num1_syscall_id = 5'd2;
		end
		else begin
			regfile_read_num1_syscall_id = rs_id;
		end
	end
	always_comb begin
		if(SyscallSrc_id == 1'b1) begin
			regfile_read_num2_syscall_id = 5'd4;
		end
		else begin
			regfile_read_num2_syscall_id = rt_id;
		end
	end
	// EX syscall's execution
	assign halt_ex = SyscallSrc_id_ex == 1'b1 ? (bypass_data1_ex == 32'd10 ? 1'b1 : 1'b0) : 1'b0;
	always_ff @(posedge clk) begin 
		rst <= 1'b0;
		if(SyscallSrc_id_ex == 1'b1) begin
			if(bypass_data1_ex == 32'd10) display_syscall <= display_syscall;
			else display_syscall <= bypass_data2_ex;
		end
		else display_syscall <= bypass_data2_ex;	
  	end

  	// judge which is wrote
  	always_comb begin
  		if(Jump_id == 2'b10) regfile_write_num_id = 5'd31;
  		else if(RegDst_id == 1'b1) regfile_write_num_id = rd_id;
  		else if(RegDst_id == 1'b0) regfile_write_num_id = rt_id;
  		else regfile_write_num_id = 5'dz;
  	end

	// IF
	pc PC_MOD(
		.rst  (rst),
		.halt (halt_ex),
		.pc_src_in   (pc_src_out_ex),
		.out  (pc_if),
		.pc_bj(pc_src_bj_ex),
		.pc_if_id   (pc_if_id),
		.nop_lock_id(nop_lock_id)
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
		.pc_if_id         (pc_if_id),
		.nop_lock_id      (nop_lock_id),
		.pc_bj         (pc_src_bj_ex)
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
		.AluOp     (AluOp_id)
		);
	regfile REGFILE_MOD(
		.clk       (clk),
		.read_num1 (regfile_read_num1_syscall_id),
		.read_num2 (regfile_read_num2_syscall_id),
		.write_num (regfile_write_num_mem_wb),
		.write_en  (RegWrite_mem_wb),
		.write_data(regfile_write_data_wb),
		.read_data1(regfile_read_data1_id),
		.read_data2(regfile_read_data2_id)
		);
	sign_ext SIGN_EXT_MOD(
		.in (immediate_id),
		.out(ext_immediate_id)
		);
	data_dependence DATA_DEPENDENCE_MOD(
		.regfile_read_num1_syscall_id(regfile_read_num1_syscall_id),
		.regfile_read_num2_syscall_id(regfile_read_num2_syscall_id),
		.regfile_write_num_id_ex     (regfile_write_num_id_ex),
		.regfile_write_num_ex_mem    (regfile_write_num_ex_mem),
		.nop_lock_id                 (nop_lock_id),
		.clk                         (clk),
		.MemRead_id_ex               (MemRead_id_ex),
		.RegWrite_id_ex              (RegWrite_id_ex)
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
		.RegWrite_id        (RegWrite_id),
		.MemRead_id         (MemRead_id),
		.MemWrite_id        (MemWrite_id),
		.MemtoReg_id        (MemtoReg_id),
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
		.RegWrite_id_ex     (RegWrite_id_ex),
		.MemRead_id_ex      (MemRead_id_ex),
		.MemWrite_id_ex     (MemWrite_id_ex),
		.MemtoReg_id_ex     (MemtoReg_id_ex),
		.SyscallSrc_id_ex   (SyscallSrc_id_ex),
		.read_data1_id_ex   (regfile_read_data1_id_ex),
		.read_data2_id_ex   (regfile_read_data2_id_ex),
		.instruction_if_id  (instruction_if_id),
		.instruction_id_ex  (instruction_id_ex),
		.halt_ex            (halt_ex),
		.regfile_write_num_id(regfile_write_num_id),
		.regfile_write_num_id_ex(regfile_write_num_id_ex),
		.nop_lock_id         (nop_lock_id),
		.pc_bj               (pc_src_bj_ex),
		.regfile_read_num1_syscall_id(regfile_read_num1_syscall_id),
		.regfile_read_num2_syscall_id(regfile_read_num2_syscall_id),
		.regfile_read_num1_syscall_id_ex(regfile_read_num1_syscall_id_ex),
		.regfile_read_num2_syscall_id_ex(regfile_read_num2_syscall_id_ex)
		);

	// EX
	bypass BYPASS_MOD(
		.regfile_write_num_ex_mem       (regfile_write_num_ex_mem),
		.regfile_write_num_mem_wb       (regfile_write_num_mem_wb),
		.regfile_read_num1_syscall_id_ex(regfile_read_num1_syscall_id_ex),
		.regfile_read_num2_syscall_id_ex(regfile_read_num2_syscall_id_ex),
		.RegWrite_ex_mem                (RegWrite_ex_mem),
		.RegWrite_mem_wb                (RegWrite_mem_wb),
		.clk                            (clk),
		.regfile_write_data_wb          (regfile_write_data_wb),
		.alu_out_ex_mem                 (alu_out_ex_mem),
		.regfile_read_data1_id_ex       (regfile_read_data1_id_ex),
		.regfile_read_data2_id_ex       (regfile_read_data2_id_ex),
		.bypass_data1_ex                (bypass_data1_ex),
		.bypass_data2_ex                (bypass_data2_ex)
		);
	alu_src ALU_SRC_MOD(
		.AluSrc            (AluSrc_id_ex),
		.regfile_read_data1(bypass_data1_ex),
		.regfile_read_data2(bypass_data2_ex),
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
		.in2  (alu_src_out2_ex),
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

	// EX/MEM
	ex_mem EX_MEM_MOD(
		.clk                     (clk),
		.pc_id_ex                (pc_id_ex),
		.instruction_id_ex       (instruction_id_ex),
		.RegWrite_id_ex          (RegWrite_id_ex),
		.MemRead_id_ex           (MemRead_id_ex),
		.MemWrite_id_ex          (MemWrite_id_ex),
		.MemtoReg_id_ex          (MemtoReg_id_ex),
		.alu_out_ex              (alu_out_ex),
		.regfile_read_data2_id_ex(bypass_data2_ex),
		.Jump_id_ex              (Jump_id_ex),
		.pc_ex_mem               (pc_ex_mem),
		.instruction_ex_mem      (instruction_ex_mem),
		.RegWrite_ex_mem         (RegWrite_ex_mem),
		.RegDst_ex_mem           (RegDst_ex_mem),
		.MemRead_ex_mem          (MemRead_ex_mem),
		.MemWrite_ex_mem         (MemWrite_ex_mem),
		.MemtoReg_ex_mem         (MemtoReg_ex_mem),
		.Jump_ex_mem             (Jump_ex_mem),
		.alu_out_ex_mem          (alu_out_ex_mem),
		.ram_write_data_ex_mem   (ram_write_data_ex_mem),
		.halt_ex                 (halt_ex),
		.halt_ex_mem             (halt_ex_mem),
		.regfile_write_num_id_ex (regfile_write_num_id_ex),
		.regfile_write_num_ex_mem(regfile_write_num_ex_mem)
		);
  	
	// MEM
	ram RAM_MOD(
		.addr_in   (alu_out_ex_mem),
		.write_data(ram_write_data_ex_mem),
		.MemRead   (MemRead_ex_mem),
		.MemWrite  (MemWrite_ex_mem),
		.clk       (clk),
		.out       (ram_read_data_mem)	
		);
	// MEM/WB
	mem_wb MEM_WB_MOD(
		.clk                 (clk),
		.pc_ex_mem           (pc_ex_mem),
		.instruction_ex_mem  (instruction_ex_mem),
		.MemtoReg_ex_mem     (MemtoReg_ex_mem),
		.Jump_ex_mem         (Jump_ex_mem),
		.alu_out_ex_mem      (alu_out_ex_mem),
		.ram_read_data_mem   (ram_read_data_mem),
		.RegWrite_ex_mem     (RegWrite_ex_mem),
		.pc_mem_wb           (pc_mem_wb),
		.instruction_mem_wb  (instruction_mem_wb),
		.MemtoReg_mem_wb     (MemtoReg_mem_wb),
		.Jump_mem_wb         (Jump_mem_wb),
		.alu_out_mem_wb      (alu_out_mem_wb),
		.ram_read_data_mem_wb(ram_read_data_mem_wb),
		.RegWrite_mem_wb     (RegWrite_mem_wb),
		.halt_ex_mem         (halt_ex_mem),
		.halt_mem_wb         (halt_mem_wb),
		.regfile_write_num_ex_mem(regfile_write_num_ex_mem),
		.regfile_write_num_mem_wb(regfile_write_num_mem_wb),
		.cycles_counter          (cycles_counter)
		);

	jal_src JAL_SRC_MOD(
		.Jump      (Jump_mem_wb),
		.MemtoReg  (MemtoReg_mem_wb),
		.pc_in     (pc_mem_wb),
		.alu_in    (alu_out_mem_wb),
		.mem_in    (ram_read_data_mem_wb),
		.write_data(regfile_write_data_wb)
		);
endmodule

`endif