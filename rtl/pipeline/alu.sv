`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2025 07:38:52 PM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


import rv32_pipeline_pkg::*;

module ALU(
    operand_a,
    operand_b,
    opcode,
    result,
    zero,
    clk, 
    rst_n
    );
    
    input wire logic[31:0] operand_a;
    input wire logic[31:0] operand_b;
    input wire ALU_OPCODE opcode;
    output logic[31:0] result;
    output logic zero;
    input wire logic clk;
    input wire logic rst_n;

    assign zero = ~(|result);

    always_comb begin
        case(opcode)
            ALU_ADD:
                result = operand_a + operand_b;
            ALU_SUB:
                result = operand_a - operand_b;
            ALU_SLL:
                result = operand_a << operand_b[4:0];
            ALU_SRL:
                result = operand_a >> operand_b[4:0];
            ALU_SRA:
                result = $unsigned($signed(operand_a) >>> operand_b[4:0]);
            ALU_XOR:
                result = operand_a ^ operand_b;
            ALU_OR:
                result = operand_a | operand_b;
            ALU_AND:
                result = operand_a & operand_b;
            ALU_SLT:
                result = $signed(operand_a) < $signed(operand_b);
            ALU_SLTU:
                result = $unsigned(operand_a) < $unsigned(operand_b);
            ALU_PASS_B:
                result = operand_b;
            default:
                result = 0;
        endcase
    end

endmodule
