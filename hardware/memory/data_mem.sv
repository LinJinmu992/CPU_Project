`timescale 1ns / 1ps

module data_mem (
    input  logic        clk,
    input  logic        we,            // Write Enable，来自控制器的 mem_write
    input  logic [31:0] addr,          // 内存地址，通常来自 ALU 的计算结果
    input  logic [31:0] write_data,    // 要存入的数据，来自寄存器堆的 rs2_data
    output logic [31:0] read_data      // 输出的数据，送往写回寄存器堆的 MUX
);

    // 定义存储空间：64 个 32 位字（共 256 字节）
    // 实际项目中可以根据需要加大，如 [0:1023]
    logic [31:0] ram [0:63];

    // --- 1. 读逻辑：组合逻辑（异步读） ---
    // 在单周期 CPU 中，为了保证数据在当前周期内能写回寄存器，通常采用异步读
    assign read_data = ram[addr[31:2]];

    // --- 2. 写逻辑：时序逻辑（同步写） ---
    // 只有在时钟上升沿且写使能有效时，才改变内存内容
    always_ff @(posedge clk) begin
        if (we) begin
            ram[addr[31:2]] <= write_data;
        end
    end

    // --- 3. 初始化（可选）：方便仿真调试 ---
    initial begin
        // 如果你想预设一些初始数据，可以像 IROM 一样读一个 hex 文件
        // $readmemh("data.hex", ram);
        
        // 或者手动清零
        for (int i = 0; i < 64; i++) ram[i] = 32'b0;
    end

endmodule