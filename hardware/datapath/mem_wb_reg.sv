`timescale 1ns / 1ps

module mem_wb_reg (
    input               clk,
    input               rst,
    input               en,
    input               clear,
    input               reg_write_in,
    input               mem_to_reg_in,
    input       [31:0]  alu_result_in,
    input       [31:0]  mem_read_data_in,
    input       [4:0]   rd_addr_in,
    input       [31:0]  pc_plus_4_in,
    input       [6:0]   opcode_in,
    input       [2:0]   funct3_in,        // 💡 新增：接收 MEM 阶段的 funct3
    
    output reg          reg_write_out,
    output reg          mem_to_reg_out,
    output reg  [31:0]  alu_result_out,
    output reg  [31:0]  mem_read_data_out,
    output reg  [4:0]   rd_addr_out,
    output reg  [31:0]  pc_plus_4_out,
    output reg  [6:0]   opcode_out,
    output reg  [2:0]   funct3_out        // 💡 新增：传给 WB 阶段的 funct3
);

    always @(posedge clk) begin
        if (rst || clear) begin
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_result_out <= 32'b0;
            mem_read_data_out <= 32'b0;
            rd_addr_out <= 5'b0;
            pc_plus_4_out <= 32'b0;
            opcode_out <= 7'b0;
            funct3_out <= 3'b0;          // 💡 新增：复位信号
        end else if (en) begin
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_result_out <= alu_result_in;
            mem_read_data_out <= mem_read_data_in;
            rd_addr_out <= rd_addr_in;
            pc_plus_4_out <= pc_plus_4_in;
            opcode_out <= opcode_in;
            funct3_out <= funct3_in;     // 💡 新增：信号传递
        end
    end
endmodule