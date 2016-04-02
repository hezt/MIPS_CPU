`ifndef _alu
`define _alu

`timescale 1ns / 1ps
`include "definitions.vh"
// only for 32 bit
module alu(
	input wire [3 : 0] op,
    input wire [31 : 0] in1, in2,
    output reg [31 : 0] out,
    output reg equal
	);
	// wire [31 : 0] add_r; // the add operation's result
	// wire [31 : 0] sub_r; // the sub operation's result
	// wire [31 : 0] add_ur; // the without sign data add reuslut
	// wire [31 : 0] sub_ur; // the without sign data sub reuslut
	// wire [31 : 0] in1_u; // the in1's data without sign
	// wire [31 : 0] in2_u; // the in2's data without sign
	// wire add_cd;
	// wire sub_cd;
	// wire add_cf;
	// wire sub_cf;
	// wire add_of;
	// wire sub_of;
	// wire [1 : 0] add_cfr; // two sign and a cf's result
	// wire [1 : 0] sub_cfr; // two sign and a cf's result
	// assign in1_u = {1'b0, in1[30 : 0]};
	// assign in2_u = {1'b0, in2[30 : 0]};
	// assign add_ur = in1_u + in2_u;
	// assign sub_ur = in1_u - in2_u;
	// assign add_cd = add_ur[31];
	// assign sub_cd = sub_ur[31];
	// assign add_cfr = {1'b0, in1[31]} + {1'b0, in2[31]} + {1'b0, add_cd};
	// assign sub_cfr = {1'b0, in1[31]} - {1'b0, in2[31]} - {1'b0, sub_cd};
	// assign add_cf = add_cfr[1];
	// assign sub_cf = sub_cfr[1];
	// assign add_of = add_cd ^ add_cf;
	// assign sub_of = sub_cd ^ sub_cf;
    
    always_comb begin
        if(in1 == in2) begin
            equal = 1'b1;
        end
        else begin 
            equal = 1'b0;
        end
    
    end
    always_comb begin
        case (op)
        	`ALU_SLL: begin
        	   out = in1 << in2[4 : 0];
        	end
        	`ALU_SRA: begin
        		out = $signed(in1) >>> in2[4 : 0];
        	end
        	`ALU_SRL: begin
        		out = in1 >> in2[4 : 0];
        	end
        	`ALU_ADD: begin 
                out = in1 + in2;
        	end
        	`ALU_SUB: begin 
                out = in1 - in2;
        	end
        	`ALU_AND: begin
        		out = in1 & in2;
        	end
        	`ALU_OR: begin
        		out = in1 | in2;
        	end
        	`ALU_XOR: begin
        		out = in1 ^ in2;
        	end
        	`ALU_NOR: begin
        		out = ~(in1 | in2);
        	end
        	`ALU_CMP: begin
        		out = ($signed(in1) < $signed(in2)) ? 1 : 0;
        	end
        	`ALU_CMPU: begin
        		out = (in1 < in2) ? 1 : 0;
        	end
            default: begin
            	out = 32'bz;
        	end
        endcase
    end

endmodule

`endif
