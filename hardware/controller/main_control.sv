`timescale 1ns / 1ps

module main_control (
    input  [6:0] opcode,
    output reg   reg_write, // 是否写回寄存器
    output reg   alu_src,   // ALU 的 B 端选寄存器还是立即数
    output reg   mem_to_reg,// 写回寄存器的是 ALU 还是内存
    output reg   mem_read,  // 是否读内存
    output reg   mem_write, // 是否写内存
    output reg   branch,    // 是否是分支指令
    output reg [1:0] alu_op,// 传给 ALU Control 的分类信号
    output reg [2:0] imm_sel// 传给 Imm Gen 的类型选择
);

    always @(*) begin
        // 默认值：关闭所有写使能，防止误操作
        {reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch, alu_op, imm_sel} = 11'b0;

        case (opcode)
            `OP_RTYPE: begin
                reg_write = 1'b1; alu_op = `ALUOP_RTYPE;
            end
            `OP_ITYPE: begin
                reg_write = 1'b1; alu_src = 1'b1; alu_op = `ALUOP_ITYPE; imm_sel = 3'b000;
            end
            `OP_LOAD: begin
                reg_write = 1'b1; alu_src = 1'b1; mem_to_reg = 1'b1; mem_read = 1'b1; imm_sel = 3'b000;
            end
            `OP_STORE: begin
                alu_src = 1'b1; mem_write = 1'b1; imm_sel = 3'b001;
            end
            `OP_BRANCH: begin
                branch = 1'b1; alu_op = `ALUOP_BRANCH; imm_sel = 3'b010;
            end
            // 这里可以继续添加 LUI, JAL 等
            default: ;
        endcase
    end
endmodule