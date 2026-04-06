`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 05:42:16 PM
// Design Name: 
// Module Name: cla_32bits
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


module cla_32bit(
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);
    wire [8:0] c;
    assign c[0] = cin;

    // 实例化 8 个 4 位 CLA 块，像乐高一样拼起来
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : cla_gen
            cla_4bit u_cla (
                .a(a[4*i+3 : 4*i]),
                .b(b[4*i+3 : 4*i]),
                .cin(c[i]),
                .sum(sum[4*i+3 : 4*i]),
                .cout(c[i+1])
            );
        end
    endgenerate

    assign cout = c[8];
endmodule