`ifndef _definitions
`define _definitionsn
//posedge read
//negedge write
// `define _SIM_MODE

`define WORD_SIZE 32
`define REGF_SIZE 32
`define RAM_SIZE 1024
`define RAM_BIT 32 


`define ALU_SLL 4'd0
`define ALU_SRA 4'd1
`define ALU_SRL 4'd2
`define ALU_MUL 4'd3
`define ALU_DIV 4'd4
`define ALU_ADD 4'd5
`define ALU_SUB 4'd6
`define ALU_AND 4'd7
`define ALU_OR 4'd8
`define ALU_XOR 4'd9
`define ALU_NOR 4'd10
`define ALU_CMP 4'd11
`define ALU_CMPU 4'd12




`define CTRL_OPCODE_RTYPE 6'b000000

`define CTRL_OPCODE_ADD 6'b000000
`define CTRL_OPCODE_ADDU 6'b000000
`define CTRL_OPCODE_AND 6'b000000
`define CTRL_OPCODE_SLL 6'b000000
`define CTRL_OPCODE_SRA 6'b000000
`define CTRL_OPCODE_SRL 6'b000000
`define CTRL_OPCODE_SUB 6'b000000
`define CTRL_OPCODE_OR 6'b000000
`define CTRL_OPCODE_NOR 6'b000000
`define CTRL_OPCODE_SLT 6'b000000
`define CTRL_OPCODE_SLTU 6'b000000
`define CTRL_OPCODE_JR 6'b000000
`define CTRL_OPCODE_SYSCALL 6'b000000
`define CTRL_OPCODE_ADDI 6'b001000
`define CTRL_OPCODE_ADDIU 6'b001001
`define CTRL_OPCODE_ANDI 6'b001100
`define CTRL_OPCODE_ORI 6'b001101
`define CTRL_OPCODE_LW 6'b100011
`define CTRL_OPCODE_SW 6'b101011
`define CTRL_OPCODE_BEQ 6'b000100
`define CTRL_OPCODE_BNE 6'b000101
`define CTRL_OPCODE_SLTI 6'b001010
`define CTRL_OPCODE_J 6'b000010
`define CTRL_OPCODE_JAL 6'b000011


`define FUNCT_ADD 6'b100000
`define FUNCT_ADDU 6'b100001
`define FUNCT_AND 6'b100100
`define FUNCT_SLL 6'b000000
`define FUNCT_SRA 6'b000011
`define FUNCT_SRL 6'b000010
`define FUNCT_SUB 6'b100010
`define FUNCT_OR 6'b100101
`define FUNCT_NOR 6'b100111
`define FUNCT_SLT 6'b101010
`define FUNCT_SLTU 6'b101011
`define FUNCT_JR 6'b001000
`define FUNCT_SYSCALL 6'b001100

`define ALU_OP_ADD 3'b000
`define ALU_OP_SUB 3'b010
`define ALU_OP_AND 3'b110
`define ALU_OP_OR 3'b111
`define ALU_OP_FUNCT 3'b100

`endif