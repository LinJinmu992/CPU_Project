`timescale 1ns / 1ps

module forwarding_unit (
    // EX 阶段的源寄存器地址
    input [4:0] rs1_addr_ex,
    input [4:0] rs2_addr_ex,
    // 后续阶段的目标寄存器地址
    input [4:0] rd_addr_mem,
    input       reg_write_mem,
    input [4:0] rd_addr_wb,
    input       reg_write_wb,
    // 输出转发选择信号
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    // 转发逻辑
    always @(*) begin
        // 默认值：无转发
        forward_a = 2'b00;
        forward_b = 2'b00;

        // 来自 MEM 阶段的转发（优先级最高）
        if (reg_write_mem && rd_addr_mem != 5'b0) begin
            if (rd_addr_mem == rs1_addr_ex) forward_a = 2'b01;
            if (rd_addr_mem == rs2_addr_ex) forward_b = 2'b01;
        end

        // 来自 WB 阶段的转发（优先级次之）
        if (reg_write_wb && rd_addr_wb != 5'b0) begin
            // 如果 MEM 阶段没有转发到同一个寄存器，则覆盖
            if (rd_addr_wb == rs1_addr_ex && !(reg_write_mem && rd_addr_mem == rs1_addr_ex))
                forward_a = 2'b10;
            if (rd_addr_wb == rs2_addr_ex && !(reg_write_mem && rd_addr_mem == rs2_addr_ex))
                forward_b = 2'b10;
        end
    end

endmodule