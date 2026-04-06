`timescale 1ns / 1ps

module imm_gen (
    input  [31:0] instr,    // 输入：32位原始指令
    input  [2:0]  imm_sel,  // 输入：来自控制器的选择信号
    output reg [31:0] imm   // 输出：32位符号扩展后的立即数
);

    always @(*) begin
        case (imm_sel)
            // I 型：addi, lw, jalr (12位，直接取高12位)
            3'b000: imm = { {20{instr[31]}}, instr[31:20] };

            // S 型：sw, sh, sb (12位，由两部分拼成)
            3'b001: imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };

            // B 型：beq, bne (13位，末尾补0，位置最乱)
            3'b010: imm = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

            // U 型：lui, auipc (20位，放在高20位，低12位补0)
            3'b011: imm = { instr[31:12], 12'b0 };

            // J 型：jal (21位，末尾补0，乱序拼接)
            3'b100: imm = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };

            default: imm = 32'b0;
        endcase
    end

endmodule