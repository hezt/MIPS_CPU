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
        		out = ($unsigned(in1) < $unsigned(in2)) ? 1 : 0;
        	end
            default: begin
            	out = 32'bz;
        	end
        endcase
    end

endmodule

`endif
