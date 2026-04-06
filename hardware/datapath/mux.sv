`timescale 1ns / 1ps

module mux #(
    parameter WIDTH = 32  // 默认宽度是 32 位
)(
    input  [WIDTH-1:0] d0, // 输入 0
    input  [WIDTH-1:0] d1, // 输入 1
    input              sel, // 选择信号
    output [WIDTH-1:0] y   // 输出
);

    assign y = sel ? d1 : d0;

endmodule