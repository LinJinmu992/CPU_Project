`include "defines.sv"

`timescale 1ns / 1ps

module alu_control (
    input  [1:0] alu_op,    // 来自 Main Control
    input  [2:0] funct3,    // 来自指令 [14:12]
    input  [6:0] funct7,    // 来自指令 [31:25]
    output reg [3:0] alu_ctrl // 输出给 ALU 的 4 位控制码
);

    always @(*) begin
        case (alu_op)
            `ALUOP_LOAD_STORE: alu_ctrl = `ALU_ADD;
            `ALUOP_BRANCH:     alu_ctrl = `ALU_SUB;
            `ALUOP_RTYPE: begin
                case (funct3)
                    `F3_ADD_SUB: alu_ctrl = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
                    `F3_SLL:     alu_ctrl = `ALU_SLL;
                    `F3_SLT:     alu_ctrl = `ALU_SLT;
                    `F3_SLTU:    alu_ctrl = `ALU_SLTU;
                    `F3_XOR:     alu_ctrl = `ALU_XOR;
                    `F3_SRL_SRA: alu_ctrl = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    `F3_OR:      alu_ctrl = `ALU_OR;
                    `F3_AND:     alu_ctrl = `ALU_AND;
                    default:     alu_ctrl = `ALU_ADD;
                endcase
            end
            `ALUOP_ITYPE: begin
                case (funct3)
                    `F3_ADD_SUB: alu_ctrl = `ALU_ADD;
                    `F3_SLT:     alu_ctrl = `ALU_SLT;
                    `F3_SLTU:    alu_ctrl = `ALU_SLTU;
                    `F3_XOR:     alu_ctrl = `ALU_XOR;
                    `F3_OR:      alu_ctrl = `ALU_OR;
                    `F3_AND:     alu_ctrl = `ALU_AND;
                    `F3_SLL:     alu_ctrl = `ALU_SLL;
                    `F3_SRL_SRA: alu_ctrl = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
                    default:     alu_ctrl = `ALU_ADD;
                endcase
            end
            default: alu_ctrl = `ALU_ADD;
        endcase
    end
endmodule
