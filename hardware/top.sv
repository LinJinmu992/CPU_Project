`timescale 1ns / 1ps

module cpu_top (
    input  logic clk,
    input  logic rst_n
);

    // ---------------------------------------------------------
    // 1. 内部信号（导线）定义
    // ---------------------------------------------------------
    // PC 相关
    logic [31:0] pc, pc_next, pc_plus_4, pc_target;
    
    // 指令与立即数
    logic [31:0] instr;
    logic [31:0] imm;
    logic [2:0]  imm_sel;
    
    // 寄存器堆信号
    logic [31:0] rs1_data, rs2_data, rd_data;
    
    // ALU 信号
    logic [31:0] alu_in2, alu_result;
    logic        alu_zero;
    
    // 存储器信号
    logic [31:0] mem_read_data;

    // 控制总线（来自 Controller）
    logic [3:0] alu_ctrl;
    logic       reg_write, mem_write, alu_src, mem_to_reg, pc_src, branch_en;
    logic [1:0] alu_op; 

    // ---------------------------------------------------------
    // 2. 核心模块实例化（接线）
    // ---------------------------------------------------------

    // --- 【取指阶段 IF】 ---
    pc u_pc (
        .clk    (clk),
        .rst_n  (rst_n),
        .next_pc  (pc_next),
        .pc_out (pc)
    );

    inst_mem u_irom (
        .addr   (pc),       // 别忘了 inst_mem 内部要做 [31:2] 映射
        .instr  (instr)
    );

    assign pc_plus_4 = pc + 4;

    // --- 【译码阶段 ID】 ---
    // 这里把控制指令发给 Controller，换取控制信号
    main_control u_main_ctrl (
        .opcode     (instr[6:0]),
        .reg_write  (reg_write),
        .mem_write  (mem_write),
        .alu_src    (alu_src),
        .mem_to_reg (mem_to_reg),
        .branch     (branch_en),
        .alu_op     (alu_op),   // 输出中间信号
        .imm_sel    (imm_sel)
    );

    alu_control u_alu_ctrl (
        .alu_op     (alu_op),       // 接收暗号
        .funct3     (instr[14:12]), // 辅助判断
        .funct7     (instr[31:25]),    // 通常只需要第 30 位来区分 add/sub 或 srl/sra
        .alu_ctrl   (alu_ctrl)      // 输出最终的 4 位 ALU 操作码
    );

    reg_file u_regfile (
        .clk        (clk),
        .rst_n      (rst_n),
        .we         (reg_write),
        .r_addr1    (instr[19:15]),
        .r_addr2    (instr[24:20]),
        .w_addr     (instr[11:7]),
        .w_data     (rd_data),      // 来自 WB 阶段的 MUX
        .r_data1    (rs1_data),
        .r_data2    (rs2_data)
    );

    imm_gen u_immgen (
        .instr   (instr),
        .imm_sel (imm_sel),
        .imm     (imm)
    );

    // --- 【执行阶段 EX】 ---
    // MUX: ALU 的第二个操作数是选寄存器还是立即数？
    assign alu_in2 = alu_src ? imm : rs2_data;

    alu u_alu (
        .a      (rs1_data),
        .b      (alu_in2),
        .alu_ctrl   (alu_ctrl),
        .res (alu_result),
        .zero   (alu_zero)
    );

    // --- 【访存阶段 MEM】 ---
    data_mem u_dram (
        .clk        (clk),
        .we         (mem_write),
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    // --- 【写回阶段 WB】 ---
    // MUX: 写回寄存器的是 ALU 算出来的，还是内存读出来的？
    assign rd_data = mem_to_reg ? mem_read_data : alu_result;

    // --- 【下一条指令计算】 ---
    assign pc_target = pc + imm;
    assign pc_src    = branch_en && alu_zero; // 如果是分支指令且 ALU 说条件成立
    assign pc_next   = pc_src ? pc_target : pc_plus_4;

endmodule