`timescale 1ns / 1ps

module hazard_detection_unit (
    // ID 阶段的源寄存器地址
    input [4:0] rs1_addr_id,
    input [4:0] rs2_addr_id,
    // EX 阶段的指令信息
    input       mem_read_ex,
    input [4:0] rd_addr_ex,
    // 控制信号输出
    output      stall_if,   // 阻塞 IF 阶段
    output      stall_id,   // 阻塞 ID 阶段
    output      stall_ex,   // 阻塞 EX 阶段（通常为 0）
    output      flush_ex    // 冲刷 EX 阶段（插入空泡）
);

    // 检测加载‑使用型冒险
    wire load_use_hazard = mem_read_ex && (rd_addr_ex != 5'b0) &&
                          ((rd_addr_ex == rs1_addr_id) || (rd_addr_ex == rs2_addr_id));

    assign stall_if = load_use_hazard;
    assign stall_id = load_use_hazard;
    assign stall_ex = 1'b0;   // EX 阶段不需要阻塞
    assign flush_ex = load_use_hazard; // 清除 ID/EX 寄存器，插入空泡

endmodule