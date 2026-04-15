`timescale 1ns / 1ps
`include "defines.sv"

module myCPU (
    input  logic cpu_clk,
    input  logic cpu_rst,
    output logic [31:0] irom_addr,
    input  logic [31:0] irom_data,
    output logic [31:0] perip_addr,
    output logic perip_wen,
    output logic [1:0] perip_mask,
    output logic [31:0] perip_wdata,
    input  logic [31:0] perip_rdata
);

    // 内部时钟与复位
    logic clk, rst;
    assign clk = cpu_clk;
    assign rst = cpu_rst; // 同步高电平复位

    // ---------------------------------------------------------
    // 流水线寄存器信号定义
    // ---------------------------------------------------------
    // IF 阶段
    logic [31:0] pc_if, pc_plus_4_if;
    logic [31:0] instr_if;
    
    // IF/ID 寄存器
    logic [31:0] pc_id, pc_plus_4_id;
    logic [31:0] instr_id;
    
    // ID 阶段
    logic [31:0] rs1_data_id, rs2_data_id;
    logic [31:0] imm_id;
    logic [4:0]  rs1_addr_id, rs2_addr_id, rd_addr_id;
    logic [2:0]  funct3_id;
    logic [6:0]  funct7_id;
    // 控制信号
    logic        reg_write_id, mem_to_reg_id, mem_read_id, mem_write_id;
    logic        alu_src_id, branch_id;
    logic [1:0]  alu_op_id;
    logic [2:0]  imm_sel_id;
    
    // ID/EX 寄存器
    logic        reg_write_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex;
    logic        alu_src_ex, branch_ex;
    logic [1:0]  alu_op_ex;
    logic [31:0] pc_ex, pc_plus_4_ex;
    logic [31:0] rs1_data_ex, rs2_data_ex;
    logic [31:0] imm_ex;
    logic [4:0]  rs1_addr_ex, rs2_addr_ex, rd_addr_ex;
    logic [2:0]  funct3_ex;
    logic [6:0]  funct7_ex;
    
    // EX 阶段
    logic [3:0]  alu_ctrl_ex;
    logic [31:0] alu_result_ex;
    logic        alu_zero_ex;
    logic [31:0] pc_target_ex;
    logic        branch_taken_ex;
    
    // EX/MEM 寄存器
    logic        reg_write_mem, mem_to_reg_mem, mem_read_mem, mem_write_mem;
    logic [31:0] alu_result_mem;
    logic [31:0] rs2_data_mem;
    logic [4:0]  rd_addr_mem;
    logic [31:0] pc_plus_4_mem;
    
    // MEM 阶段
    logic [31:0] mem_read_data_mem;
    
    // MEM/WB 寄存器
    logic        reg_write_wb, mem_to_reg_wb;
    logic [31:0] alu_result_wb;
    logic [31:0] mem_read_data_wb;
    logic [4:0]  rd_addr_wb;
    
    // WB 阶段
    logic [31:0] rd_data_wb;
    
    // 流水线控制信号
    logic        stall_if, stall_id, stall_ex, stall_mem, stall_wb; // 阻塞信号
    logic        flush_if, flush_id, flush_ex, flush_mem, flush_wb; // 冲刷信号
    
    // 转发信号
    logic [1:0]  forward_a, forward_b;
    logic [31:0] rs1_data_forwarded, rs2_data_forwarded;
    
    // ---------------------------------------------------------
    // 流水线寄存器实例化
    // ---------------------------------------------------------
    
    // --- IF/ID 寄存器 ---
    if_id_reg u_if_id_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (!stall_if),       // 阻塞时停止流动
        .clear          (flush_id),        // 冲刷时清空
        .pc_in          (pc_if),
        .pc_plus_4_in   (pc_plus_4_if),
        .instr_in       (instr_if),
        .pc_out         (pc_id),
        .pc_plus_4_out  (pc_plus_4_id),
        .instr_out      (instr_id)
    );
    
    // --- ID/EX 寄存器 ---
    id_ex_reg u_id_ex_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (!stall_id),
        .clear          (flush_ex),
        .reg_write_in   (reg_write_id),
        .mem_to_reg_in  (mem_to_reg_id),
        .mem_read_in    (mem_read_id),
        .mem_write_in   (mem_write_id),
        .alu_src_in     (alu_src_id),
        .branch_in      (branch_id),
        .alu_op_in      (alu_op_id),
        .pc_in          (pc_id),
        .pc_plus_4_in   (pc_plus_4_id),
        .rs1_data_in    (rs1_data_id),
        .rs2_data_in    (rs2_data_id),
        .imm_in         (imm_id),
        .rs1_addr_in    (rs1_addr_id),
        .rs2_addr_in    (rs2_addr_id),
        .rd_addr_in     (rd_addr_id),
        .funct3_in      (funct3_id),
        .funct7_in      (funct7_id),
        .reg_write_out  (reg_write_ex),
        .mem_to_reg_out (mem_to_reg_ex),
        .mem_read_out   (mem_read_ex),
        .mem_write_out  (mem_write_ex),
        .alu_src_out    (alu_src_ex),
        .branch_out     (branch_ex),
        .alu_op_out     (alu_op_ex),
        .pc_out         (pc_ex),
        .pc_plus_4_out  (pc_plus_4_ex),
        .rs1_data_out   (rs1_data_ex),
        .rs2_data_out   (rs2_data_ex),
        .imm_out        (imm_ex),
        .rs1_addr_out   (rs1_addr_ex),
        .rs2_addr_out   (rs2_addr_ex),
        .rd_addr_out    (rd_addr_ex),
        .funct3_out     (funct3_ex),
        .funct7_out     (funct7_ex)
    );
    
    // --- EX/MEM 寄存器 ---
    ex_mem_reg u_ex_mem_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (!stall_ex),
        .clear          (flush_mem),
        .reg_write_in   (reg_write_ex),
        .mem_to_reg_in  (mem_to_reg_ex),
        .mem_read_in    (mem_read_ex),
        .mem_write_in   (mem_write_ex),
        .alu_result_in  (alu_result_ex),
        .rs2_data_in    (rs2_data_forwarded), // 使用转发后的数据
        .rd_addr_in     (rd_addr_ex),
        .pc_plus_4_in   (pc_plus_4_ex),
        .reg_write_out  (reg_write_mem),
        .mem_to_reg_out (mem_to_reg_mem),
        .mem_read_out   (mem_read_mem),
        .mem_write_out  (mem_write_mem),
        .alu_result_out (alu_result_mem),
        .rs2_data_out   (rs2_data_mem),
        .rd_addr_out    (rd_addr_mem),
        .pc_plus_4_out  (pc_plus_4_mem)
    );
    
    // --- MEM/WB 寄存器 ---
    mem_wb_reg u_mem_wb_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (!stall_mem),
        .clear          (flush_wb),
        .reg_write_in   (reg_write_mem),
        .mem_to_reg_in  (mem_to_reg_mem),
        .alu_result_in  (alu_result_mem),
        .mem_read_data_in (mem_read_data_mem),
        .rd_addr_in     (rd_addr_mem),
        .reg_write_out  (reg_write_wb),
        .mem_to_reg_out (mem_to_reg_wb),
        .alu_result_out (alu_result_wb),
        .mem_read_data_out (mem_read_data_wb),
        .rd_addr_out    (rd_addr_wb)
    );
    
    // ---------------------------------------------------------
    // 阶段逻辑
    // ---------------------------------------------------------
    
    // --- IF 阶段 ---
    pc #(.RESET_ADDR(`IROM_BASE)) u_pc (
        .clk      (clk),
        .rst      (rst),
        .next_pc  (branch_taken_ex ? pc_target_ex : pc_plus_4_if), // 分支跳转
        .pc_out   (pc_if)
    );
    
    // 指令存储器接口
    assign irom_addr = pc_if;
    assign instr_if = irom_data;
    
    assign pc_plus_4_if = pc_if + 4;
    
    // --- ID 阶段 ---
    // 提取指令字段
    assign rs1_addr_id = instr_id[19:15];
    assign rs2_addr_id = instr_id[24:20];
    assign rd_addr_id  = instr_id[11:7];
    assign funct3_id   = instr_id[14:12];
    assign funct7_id   = instr_id[31:25];
    
    // 主控制器
    main_control u_main_ctrl (
        .opcode     (instr_id[6:0]),
        .reg_write  (reg_write_id),
        .mem_write  (mem_write_id),
        .alu_src    (alu_src_id),
        .mem_to_reg (mem_to_reg_id),
        .branch     (branch_id),
        .alu_op     (alu_op_id),
        .imm_sel    (imm_sel_id),
        .mem_read   (mem_read_id)
    );
    
    // 寄存器堆
    reg_file u_regfile (
        .clk        (clk),
        .rst        (rst),
        .we         (reg_write_wb),
        .r_addr1    (rs1_addr_id),
        .r_addr2    (rs2_addr_id),
        .w_addr     (rd_addr_wb),
        .w_data     (rd_data_wb),
        .r_data1    (rs1_data_id),
        .r_data2    (rs2_data_id)
    );
    
    // 立即数生成
    imm_gen u_immgen (
        .instr   (instr_id),
        .imm_sel (imm_sel_id),
        .imm     (imm_id)
    );
    
    // --- EX 阶段 ---
    // 转发单元
    forwarding_unit u_forwarding_unit (
        .rs1_addr_ex   (rs1_addr_ex),
        .rs2_addr_ex   (rs2_addr_ex),
        .rd_addr_mem   (rd_addr_mem),
        .reg_write_mem (reg_write_mem),
        .rd_addr_wb    (rd_addr_wb),
        .reg_write_wb  (reg_write_wb),
        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );

    // 转发多路选择器
    always @(*) begin
        case (forward_a)
            2'b00: rs1_data_forwarded = rs1_data_ex;
            2'b01: rs1_data_forwarded = alu_result_mem;
            2'b10: rs1_data_forwarded = rd_data_wb;
            default: rs1_data_forwarded = rs1_data_ex;
        endcase
        case (forward_b)
            2'b00: rs2_data_forwarded = rs2_data_ex;
            2'b01: rs2_data_forwarded = alu_result_mem;
            2'b10: rs2_data_forwarded = rd_data_wb;
            default: rs2_data_forwarded = rs2_data_ex;
        endcase
    end
    
    // ALU 控制
    alu_control u_alu_ctrl (
        .alu_op     (alu_op_ex),
        .funct3     (funct3_ex),
        .funct7     (funct7_ex),
        .alu_ctrl   (alu_ctrl_ex)
    );
    
    // ALU 输入选择
    logic [31:0] alu_in2_ex;
    assign alu_in2_ex = alu_src_ex ? imm_ex : rs2_data_forwarded;
    
    // ALU 实例
    alu u_alu (
        .a        (rs1_data_forwarded),
        .b        (alu_in2_ex),
        .alu_ctrl (alu_ctrl_ex),
        .res      (alu_result_ex),
        .zero     (alu_zero_ex)
    );
    
    // 分支目标计算
    assign pc_target_ex = pc_ex + imm_ex;
    assign branch_taken_ex = branch_ex && alu_zero_ex;
    
    // --- MEM 阶段 ---
    // 外设接口信号生成
    assign perip_addr = alu_result_mem;
    assign perip_wen = mem_write_mem;
    assign perip_mask = 2'b10; // 暂时固定为字访问
    assign perip_wdata = rs2_data_mem;
    assign mem_read_data_mem = perip_rdata;
    
    // --- WB 阶段 ---
    assign rd_data_wb = mem_to_reg_wb ? mem_read_data_wb : alu_result_wb;
    
    // ---------------------------------------------------------
    // 冒险控制单元
    // ---------------------------------------------------------
    // 冒险检测单元
    wire hazard_flush_ex;
    hazard_detection_unit u_hazard_detection (
        .rs1_addr_id   (rs1_addr_id),
        .rs2_addr_id   (rs2_addr_id),
        .mem_read_ex   (mem_read_ex),
        .rd_addr_ex    (rd_addr_ex),
        .stall_if      (stall_if),
        .stall_id      (stall_id),
        .stall_ex      (stall_ex),
        .flush_ex      (hazard_flush_ex)
    );

    // 冲刷信号（分支 + 冒险）
    assign flush_id = branch_taken_ex; // 分支发生时冲刷 ID 阶段
    assign flush_ex = hazard_flush_ex || branch_taken_ex; // 冒险或分支时冲刷 EX 阶段
    assign flush_if = 1'b0;            // IF 阶段一般不冲刷，因为分支目标由 EX 阶段决定
    assign flush_mem = 1'b0;
    assign flush_wb = 1'b0;
    
    // 其他阶段的阻塞信号（目前仅冒险检测单元控制）
    assign stall_mem = 1'b0;
    assign stall_wb = 1'b0;
    
    // 转发控制已由 forwarding_unit 实现，无需额外赋值

endmodule