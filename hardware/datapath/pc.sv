`timescale 1ns / 1ps

module pc #(
    parameter WIDTH = 32,
    parameter RESET_ADDR = 32'h0000_0000 // 默认复位到 0 地址
)(
    input              clk,      // 时钟信号
    input              rst_n,    // 异步复位信号（低电平有效）
    input  [WIDTH-1:0] next_pc,  // 输入：来自 MUX 的下一个 PC 值
    output reg [WIDTH-1:0] pc_out // 输出：当前的 PC 值
);

    // 时序逻辑：只在时钟上升沿或复位下降沿动作
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时，PC 回到起始地址
            pc_out <= RESET_ADDR;
        end else begin
            // 正常运行时，每一拍更新一次地址
            pc_out <= next_pc;
        end
    end

endmodule