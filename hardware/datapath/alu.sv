`include "defines.sv"

`timescale 1ns / 1ps

module alu(
    input  [31:0] a,           // rs1
    input  [31:0] b,           // rs2 or imm
    input  [3:0]  alu_ctrl,    // ALU control signals
    output reg [31:0] res,     // result
    output        zero         // zero flag
);

    // 1. Internal signals
    wire [31:0] add_sub_res;
    wire [31:0] logic_res;
    reg  [31:0] shift_res;
    wire [31:0] cmp_res;
    wire [31:0] b_real;
    wire        cla_cin;
    wire        cla_cout;

    // 2. Arithmetic Unit
    assign b_real  = (alu_ctrl == `ALU_SUB) ? ~b : b;
    assign cla_cin = (alu_ctrl == `ALU_SUB);
    
    //cla_32bit u_my_adder (
    //    .a    (a),
    //    .b    (b_real),
    //    .cin  (cla_cin),
    //    .sum  (add_sub_res),
    //    .cout (cla_cout)
    //);
    // 临时测试：看看是不是加法器模块的问题
    assign add_sub_res = (alu_ctrl == `ALU_SUB) ? (a - b) : (a + b);

    // 3. Logic Unit
    assign logic_res = (alu_ctrl == `ALU_AND) ? (a & b) :
                       (alu_ctrl == `ALU_OR)  ? (a | b) :
                       (alu_ctrl == `ALU_XOR) ? (a ^ b) : 32'b0;

    // 4. Shift Unit (修复 Verilog 无符号传染 Bug)
    always @(*) begin
        case (alu_ctrl)
            `ALU_SLL: shift_res = a << b[4:0];
            `ALU_SRL: shift_res = a >> b[4:0];
            `ALU_SRA: shift_res = $signed(a) >>> b[4:0]; // 独立的分支，$signed 绝对生效
            default:  shift_res = 32'b0;
        endcase
    end

    // 5. Comparison Unit
    assign cmp_res = (alu_ctrl == `ALU_SLT)  ? {31'b0, ($signed(a) < $signed(b))} :
                     (alu_ctrl == `ALU_SLTU) ? {31'b0, (a < b)} : 32'b0;

    // 6. Final Result MUX
    always @(*) begin
        case (alu_ctrl)
            `ALU_ADD, `ALU_SUB: res = add_sub_res;
            `ALU_AND, `ALU_OR, 
            `ALU_XOR:           res = logic_res;
            `ALU_SLL, `ALU_SRL, 
            `ALU_SRA:           res = shift_res;
            `ALU_SLT, `ALU_SLTU:res = cmp_res;
            default:            res = 32'b0;
        endcase
    end

    // 7. Zero Flag
    assign zero = (res == 32'b0);

endmodule
