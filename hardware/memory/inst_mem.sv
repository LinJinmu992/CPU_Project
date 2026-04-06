`timescale 1ns / 1ps

module inst_mem (
    input  logic [31:0] addr,    // 来自 PC 的地址
    output logic [31:0] instr    // 输出给解码器的 32 位指令
);

    // 定义存储矩阵：假设深度为 64（你可以根据需求加大，比如 1024）
    // 每个单元宽 32 位
    logic [31:0] rom [0:63];

    // --- 核心逻辑：异步读 ---
    // 注意：RISC-V 地址是按字节编址的，但指令是 4 字节对齐
    // 所以我们需要把地址右移 2 位（即除以 4），来索引我们的字数组
    assign instr = rom[addr[31:2]];

    // --- 初始化：从外部文件加载机器码 ---
    initial begin
        // "inst.hex" 是你要运行的程序编译后的十六进制文件
        $readmemh("inst.hex", rom);
    end

endmodule