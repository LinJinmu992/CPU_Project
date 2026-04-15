`timescale 1ns / 1ps

module if_id_reg (
    input               clk,
    input               rst,      // 同步复位信号（高电平有效）
    input               en,        // 流水线使能（1 = 正常流动，0 = 保持）
    input               clear,     // 清除流水线（用于分支冲刷）
    input       [31:0]  pc_in,
    input       [31:0]  pc_plus_4_in,
    input       [31:0]  instr_in,
    output reg  [31:0]  pc_out,
    output reg  [31:0]  pc_plus_4_out,
    output reg  [31:0]  instr_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc_out         <= 32'b0;
            pc_plus_4_out  <= 32'b0;
            instr_out      <= 32'b0;
        end else if (clear) begin
            pc_out         <= 32'b0;
            pc_plus_4_out  <= 32'b0;
            instr_out      <= 32'b0;   // 冲刷时插入空指令（相当于 NOP）
        end else if (en) begin
            pc_out         <= pc_in;
            pc_plus_4_out  <= pc_plus_4_in;
            instr_out      <= instr_in;
        end
        // 否则保持原值
    end

endmodule