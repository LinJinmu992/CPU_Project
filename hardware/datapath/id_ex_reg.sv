`timescale 1ns / 1ps

module id_ex_reg (
    input               clk,
    input               rst,
    input               en,
    input               clear,
    input               reg_write_in,
    input               mem_to_reg_in,
    input               mem_read_in,
    input               mem_write_in,
    input               alu_src_in,
    input               branch_in,
    input       [1:0]   alu_op_in,
    input       [31:0]  pc_in,
    input       [31:0]  pc_plus_4_in,
    input       [31:0]  rs1_data_in,
    input       [31:0]  rs2_data_in,
    input       [31:0]  imm_in,
    input       [4:0]   rs1_addr_in,
    input       [4:0]   rs2_addr_in,
    input       [4:0]   rd_addr_in,
    input       [2:0]   funct3_in,
    input       [6:0]   funct7_in,
    input       [6:0]   opcode_in,
    output reg          reg_write_out,
    output reg          mem_to_reg_out,
    output reg          mem_read_out,
    output reg          mem_write_out,
    output reg          alu_src_out,
    output reg          branch_out,
    output reg  [1:0]   alu_op_out,
    output reg  [31:0]  pc_out,
    output reg  [31:0]  pc_plus_4_out,
    output reg  [31:0]  rs1_data_out,
    output reg  [31:0]  rs2_data_out,
    output reg  [31:0]  imm_out,
    output reg  [4:0]   rs1_addr_out,
    output reg  [4:0]   rs2_addr_out,
    output reg  [4:0]   rd_addr_out,
    output reg  [2:0]   funct3_out,
    output reg  [6:0]   funct7_out,
    output reg  [6:0]   opcode_out
);

    always @(posedge clk) begin
        if (rst || clear) begin
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            alu_src_out <= 1'b0;
            branch_out <= 1'b0;
            alu_op_out <= 2'b0;
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_addr_out <= 5'b0;
            rs2_addr_out <= 5'b0;
            rd_addr_out <= 5'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            opcode_out <= 7'b0;
        end else if (en) begin
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            alu_src_out <= alu_src_in;
            branch_out <= branch_in;
            alu_op_out <= alu_op_in;
            pc_out <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out <= imm_in;
            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;
            opcode_out <= opcode_in;
        end
    end
endmodule
