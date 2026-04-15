`timescale 1ns / 1ps

module mem_wb_reg (
    input               clk,
    input               rst,      // 同步复位信号（高电平有效）
    input               en,        // 流水线使能
    input               clear,     // 清除流水线（通常不需要，但保留）
    // 控制信号
    input               reg_write_in,
    input               mem_to_reg_in,
    // 数据信号
    input       [31:0]  alu_result_in,
    input       [31:0]  mem_read_data_in,
    input       [4:0]   rd_addr_in,
    // 输出
    output reg          reg_write_out,
    output reg          mem_to_reg_out,
    output reg  [31:0]  alu_result_out,
    output reg  [31:0]  mem_read_data_out,
    output reg  [4:0]   rd_addr_out
);

    always @(posedge clk) begin
        if (rst) begin
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_result_out <= 32'b0;
            mem_read_data_out <= 32'b0;
            rd_addr_out <= 5'b0;
        end else if (clear) begin
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_result_out <= 32'b0;
            mem_read_data_out <= 32'b0;
            rd_addr_out <= 5'b0;
        end else if (en) begin
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_result_out <= alu_result_in;
            mem_read_data_out <= mem_read_data_in;
            rd_addr_out <= rd_addr_in;
        end
        // 否则保持原值
    end

endmodule