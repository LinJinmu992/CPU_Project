`timescale 1ns / 1ps

module reg_file (
    input             clk,
    input             rst,      // 同步复位信号（高电平有效）
    // 写端口
    input             we,       // 写使能 (Write Enable)
    input      [4:0]  w_addr,   // 写地址 (rd)
    input      [31:0] w_data,   // 写数据
    // 读端口 1
    input      [4:0]  r_addr1,  // 读地址 1 (rs1)
    output     [31:0] r_data1,  // 读数据 1
    // 读端口 2
    input      [4:0]  r_addr2,  // 读地址 2 (rs2)
    output     [31:0] r_data2   // 读数据 2
);

    // 定义 32 个 32 位寄存器
    reg [31:0] regs [31:0];

    // --- 写逻辑 (时序逻辑) ---
    always @(posedge clk) begin
        if (rst) begin
            // 复位清零所有寄存器 (虽然实际芯片中可能不全清，但仿真建议清零)
            integer i;
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
        end else if (we && (w_addr != 5'b0)) begin
            // 只有当写使能开启 且 写地址不是 x0 时才写入
            regs[w_addr] <= w_data;
        end
    end

    // --- 读逻辑 (组合逻辑) ---
    // 如果读地址是 0，强制输出 0；否则输出对应寄存器值
    assign r_data1 = (r_addr1 == 5'b0) ? 32'b0 : regs[r_addr1];
    assign r_data2 = (r_addr2 == 5'b0) ? 32'b0 : regs[r_addr2];

endmodule