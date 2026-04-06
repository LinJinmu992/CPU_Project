`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 06:03:54 PM
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

    // -------------------------------------------------------------------
// 模块名：alu.v
// 功能：支持 RV32I 指令集的完整 ALU（基础版）
// -------------------------------------------------------------------

module alu(
    input  [31:0] a,           // 操作数 rs1
    input  [31:0] b,           // 操作数 rs2 或 立即数 imm
    input  [3:0]  alu_ctrl,      // ALU 控制信号 (由 defines.v 定义)
    output reg [31:0] res,     // 计算结果
    output        zero         // 零标志位 (用于 beq/bne 等分支)
);

    // 1. 中间结果定义
    wire [31:0] add_sub_res;
    wire [31:0] logic_res;
    wire [31:0] shift_res;
    wire [31:0] cmp_res;
    wire [31:0] b_real;
    wire        cla_cin;
    wire        cla_cout;

    // 2. 算术单元 (将来你可以把这一行换成你的 CLA 实例化)
    // 技巧：减法 A-B 在硬件上通过 A + (~B) + 1 实现
    assign b_real  = (alu_ctrl == `ALU_SUB) ? ~b : b;
    assign cla_cin = (alu_ctrl == `ALU_SUB);
    
    cla_32bit u_my_adder (
        .a    (a),            // 连到 ALU 的输入 a
        .b    (b_real),       // 连到处理后的 b_real
        .cin  (cla_cin),      // 连到减法判断逻辑出的 cin
        .sum  (add_sub_res),  // 计算结果直接传给 add_sub_res 线
        .cout (cla_cout)      // 进位输出可以悬空
    );

    // 3. 逻辑单元
    assign logic_res = (alu_ctrl == `ALU_AND) ? (a & b) :
                       (alu_ctrl == `ALU_OR)  ? (a | b) :
                       (alu_ctrl == `ALU_XOR) ? (a ^ b) : 32'b0;

    // 4. 移位单元 (注意：b[4:0] 限制移位范围 0-31)
    assign shift_res = (alu_ctrl == `ALU_SLL) ? (a << b[4:0]) :             // 逻辑左移
                       (alu_ctrl == `ALU_SRL) ? (a >> b[4:0]) :             // 逻辑右移
                       (alu_ctrl == `ALU_SRA) ? ($signed(a) >>> b[4:0]) : 32'b0; // 算术右移

    // 5. 比较单元 (用于 SLT/SLTU 指令)
    assign cmp_res = (alu_ctrl == `ALU_SLT)  ? {31'b0, ($signed(a) < $signed(b))} :
                     (alu_ctrl == `ALU_SLTU) ? {31'b0, (a < b)} : 32'b0;

    // 6. 总调度：结果多路选择器 (Mux)
    always @(*) begin
        case (alu_ctrl)
            `ALU_ADD, `ALU_SUB: res = add_sub_res;
            `ALU_AND, `ALU_OR, 
            `ALU_XOR:           res = logic_res;
            `ALU_SLL, `ALU_SRL, 
            `ALU_SRA:           res = $signed(a) >>> b[4:0];
            `ALU_SLT, `ALU_SLTU:res = cmp_res;
            default:            res = 32'b0;
        endcase
    end

    // 7. 零标志位：如果结果为 0，则 zero 为高电平
    assign zero = (res == 32'b0);

endmodule



