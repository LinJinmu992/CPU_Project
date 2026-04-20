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
    logic [6:0]  opcode_ex;
    
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
    logic [2:0]  funct3_mem;
    logic [6:0]  opcode_mem;
    
    // MEM 阶段
    logic [31:0] mem_read_data_mem;
    // logic [7:0]  lb_data;
    // logic [15:0] lh_data;
    
    // MEM/WB 寄存器
    logic        reg_write_wb, mem_to_reg_wb;
    logic [31:0] alu_result_wb;
    logic [31:0] mem_read_data_wb;
    logic [4:0]  rd_addr_wb;
    logic [31:0] pc_plus_4_wb;
    logic [2:0]  funct3_wb; // 💡 专门用来接收从寄存器里传出来的 funct3 说明书
    logic [6:0]  opcode_wb;
    
    // WB 阶段
    logic [31:0] rd_data_wb;
    
    // 流水线控制信号
    logic        stall_if, stall_id, stall_ex;
    logic        flush_ex;
    
    // 转发信号
    logic [1:0]  forward_a, forward_b;
    logic [31:0] rs1_data_forwarded, rs2_data_forwarded;
    
    // ---------------------------------------------------------
    // 流水线寄存器实例化
    // ---------------------------------------------------------
    
    if_id_reg u_if_id_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (!stall_if),
        .clear          (branch_taken_ex),
        .pc_in          (pc_if),
        .pc_plus_4_in   (pc_plus_4_if),
        .instr_in       (instr_if),
        .pc_out         (pc_id),
        .pc_plus_4_out  (pc_plus_4_id),
        .instr_out      (instr_id)
    );
    
    id_ex_reg u_id_ex_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (!stall_id),
        .clear          (flush_ex || branch_taken_ex),
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
        .opcode_in      (instr_id[6:0]),
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
        .funct7_out     (funct7_ex),
        .opcode_out     (opcode_ex)
    );
    
    ex_mem_reg u_ex_mem_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (1'b1),
        .clear          (1'b0),
        .reg_write_in   (reg_write_ex),
        .mem_to_reg_in  (mem_to_reg_ex),
        .mem_read_in    (mem_read_ex),
        .mem_write_in   (mem_write_ex),
        .alu_result_in  (alu_result_ex),
        .rs2_data_in    (rs2_data_forwarded),
        .rd_addr_in     (rd_addr_ex),
        .pc_plus_4_in   (pc_plus_4_ex),
        .funct3_in      (funct3_ex),
        .opcode_in      (opcode_ex),
        .reg_write_out  (reg_write_mem),
        .mem_to_reg_out (mem_to_reg_mem),
        .mem_read_out   (mem_read_mem),
        .mem_write_out  (mem_write_mem),
        .alu_result_out (alu_result_mem),
        .rs2_data_out   (rs2_data_mem),
        .rd_addr_out    (rd_addr_mem),
        .pc_plus_4_out  (pc_plus_4_mem),
        .funct3_out     (funct3_mem),
        .opcode_out     (opcode_mem)
    );
    
    mem_wb_reg u_mem_wb_reg (
        .clk            (clk),
        .rst           (rst),
        .en             (1'b1),
        .clear          (1'b0),
        .reg_write_in   (reg_write_mem),
        .mem_to_reg_in  (mem_to_reg_mem),
        .alu_result_in  (alu_result_mem),
        .mem_read_data_in (perip_rdata),
        .rd_addr_in     (rd_addr_mem),
        .pc_plus_4_in   (pc_plus_4_mem),
        .opcode_in      (opcode_mem),
        .reg_write_out  (reg_write_wb),
        .mem_to_reg_out (mem_to_reg_wb),
        .alu_result_out (alu_result_wb),
        .mem_read_data_out (mem_read_data_wb),
        .rd_addr_out    (rd_addr_wb),
        .pc_plus_4_out  (pc_plus_4_wb),
        .opcode_out     (opcode_wb),
        .funct3_in(funct3_mem),
        .funct3_out(funct3_wb)
    );
    
    // ---------------------------------------------------------
    // 阶段逻辑
    // ---------------------------------------------------------
    
    // --- IF 阶段 ---
    pc #(.RESET_ADDR(`IROM_BASE)) u_pc (
        .clk      (clk),
        .rst      (rst),
        .next_pc  (branch_taken_ex ? pc_target_ex : (!stall_if ? pc_plus_4_if : pc_if)),
        .pc_out   (pc_if)
    );
    
    assign irom_addr = pc_if;
    assign instr_if = irom_data;
    assign pc_plus_4_if = pc_if + 4;
    
    // --- ID 阶段 ---
    assign rs1_addr_id = instr_id[19:15];
    assign rs2_addr_id = instr_id[24:20];
    assign rd_addr_id  = instr_id[11:7];
    assign funct3_id   = instr_id[14:12];
    assign funct7_id   = instr_id[31:25];
    
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
    
    imm_gen u_immgen (
        .instr   (instr_id),
        .imm_sel (imm_sel_id),
        .imm     (imm_id)
    );
    
    // --- EX 阶段 ---
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
    
    alu_control u_alu_ctrl (
        .alu_op     (alu_op_ex),
        .funct3     (funct3_ex),
        .funct7     (funct7_ex),
        .alu_ctrl   (alu_ctrl_ex)
    );
    
    logic [31:0] alu_in1_ex, alu_in2_ex;
    assign alu_in1_ex = (opcode_ex == `OP_LUI) ? 32'b0 :
                        (opcode_ex == `OP_AUIPC) ? pc_ex : rs1_data_forwarded; // AUIPC/LUI 处理
    assign alu_in2_ex = alu_src_ex ? imm_ex : rs2_data_forwarded;
    
    alu u_alu (
        .a        (alu_in1_ex),
        .b        (alu_in2_ex),
        .alu_ctrl (alu_ctrl_ex),
        .res      (alu_result_ex),
        .zero     (alu_zero_ex)
    );
    
    // 修改后：增加 & ~32'h1 逻辑
    assign pc_target_ex = (opcode_ex == `OP_JALR) ? ((rs1_data_forwarded + imm_ex) & ~32'h1) : (pc_ex + imm_ex);
    
    always @(*) begin
        case (opcode_ex)
            `OP_BRANCH: begin
                case (funct3_ex)
                    3'b000: branch_taken_ex = alu_zero_ex;  // BEQ
                    3'b001: branch_taken_ex = !alu_zero_ex; // BNE
                    3'b100: branch_taken_ex = alu_result_ex[0]; // BLT (ALU SLT)
                    3'b101: branch_taken_ex = !alu_result_ex[0]; // BGE
                    3'b110: branch_taken_ex = alu_result_ex[0]; // BLTU
                    3'b111: branch_taken_ex = !alu_result_ex[0]; // BGEU
                    default: branch_taken_ex = 1'b0;
                endcase
            end
            `OP_JAL, `OP_JALR: branch_taken_ex = 1'b1;
            default: branch_taken_ex = 1'b0;
        endcase
    end
    
    // --- MEM 阶段 ---
    assign perip_addr = alu_result_mem;
    //assign perip_addr = {alu_result_mem[31:2], 2'b00};
    assign perip_wen = mem_write_mem;
    always @(*) begin
        case (funct3_mem)
            3'b000: perip_mask = 2'b00; // SB - 1字节
            3'b001: perip_mask = 2'b01; // SH - 2字节
            3'b010: perip_mask = 2'b10; // SW - 4字节
            default: perip_mask = 2'b10; // 默认4字节
        endcase
    end
    assign perip_wdata = rs2_data_mem << (8 * alu_result_mem[1:0]);

    // 根据地址低两位选择字节 (符合小端序)
    // always @(*) begin
    //     case (alu_result_mem[1:0])
    //         2'b00: lb_data = perip_rdata[7:0];
    //         2'b01: lb_data = perip_rdata[15:8];
    //         2'b10: lb_data = perip_rdata[23:16];
    //         2'b11: lb_data = perip_rdata[31:24];
    //         default: lb_data = 8'b0;
    //     endcase
    // end

    // // 选择半字
    // //assign lh_data = alu_result_mem[1] ? perip_rdata[31:16] : perip_rdata[15:0];
    // always @(*) begin
    //     case (alu_result_mem[1:0])
    //         2'b00:   lh_data = perip_rdata[15:0];  // 对应字节 [1, 0]
    //         2'b01:   lh_data = perip_rdata[23:8];  // 🎯 解决地址 13 的关键！对应字节 [2, 1]
    //         2'b10:   lh_data = perip_rdata[31:16]; // 对应字节 [3, 2]
    //         default: lh_data = perip_rdata[15:0];
    //     endcase
    // end

    // // 根据 funct3 进行最终的写回数据扩展
    // always @(*) begin
    //     case (funct3_mem)
    //         3'b000: mem_read_data_mem = { {24{lb_data[7]}}, lb_data };  // LB (符号扩展)
    //         3'b001: mem_read_data_mem = { {16{lh_data[15]}}, lh_data }; // LH (符号扩展)
    //         3'b010: mem_read_data_mem = perip_rdata;                   // LW
    //         3'b100: mem_read_data_mem = { 24'b0, lb_data };            // LBU (零扩展)
    //         3'b101: mem_read_data_mem = { 16'b0, lh_data };            // LHU (零扩展)
    //         default: mem_read_data_mem = perip_rdata;
    //     endcase
    // end
    
    // --- WB 阶段 ---

// 1. 【新增】定义内部中间信号，用于存放处理后的数据
logic [7:0]  lb_data_wb;
logic [15:0] lh_data_wb;
logic [31:0] final_mem_read_data_wb;

// 2. 【新增】从 WB 阶段的原始内存数据中抠出字节 (LB/LBU)
always @(*) begin
    case (alu_result_wb[1:0]) // 使用传到 WB 的地址低两位
        2'b00: lb_data_wb = mem_read_data_wb[7:0];
        2'b01: lb_data_wb = mem_read_data_wb[15:8];
        2'b10: lb_data_wb = mem_read_data_wb[23:16];
        2'b11: lb_data_wb = mem_read_data_wb[31:24];
        default: lb_data_wb = 8'b0;
    endcase
end

// 3. 【新增】从 WB 阶段的原始内存数据中抠出半字 (LH/LHU) —— 🎯 核心修复点
always @(*) begin
    case (alu_result_wb[1:0])
        2'b00:   lh_data_wb = mem_read_data_wb[15:0];
        2'b01:   lh_data_wb = mem_read_data_wb[23:8];  // 解决地址 13 非对齐读取
        2'b10:   lh_data_wb = mem_read_data_wb[31:16];
        default: lh_data_wb = mem_read_data_wb[15:0];
    endcase
end

// 4. 【新增】根据指令码进行符号扩展或零扩展
always @(*) begin
    case (funct3_wb) // ⚠️ 确保 funct3 已经通过寄存器传到了 WB
        3'b000: final_mem_read_data_wb = { {24{lb_data_wb[7]}}, lb_data_wb };  // LB
        3'b001: final_mem_read_data_wb = { {16{lh_data_wb[15]}}, lh_data_wb }; // LH
        3'b010: final_mem_read_data_wb = mem_read_data_wb;                    // LW
        3'b100: final_mem_read_data_wb = { 24'b0, lb_data_wb };               // LBU
        3'b101: final_mem_read_data_wb = { 16'b0, lh_data_wb };               // LHU
        default: final_mem_read_data_wb = mem_read_data_wb;
    endcase
end

// 5. 【修改】这是你原有的 always 块，但里面的 mem_read_data_wb 换成了加工后的 final_mem_read_data_wb
always @(*) begin
    if (opcode_wb == `OP_JAL || opcode_wb == `OP_JALR)
        rd_data_wb = pc_plus_4_wb;
    else
        // 关键改动：原本直接连 mem_read_data_wb，现在连 final_mem_read_data_wb
        rd_data_wb = mem_to_reg_wb ? final_mem_read_data_wb : alu_result_wb;
end

    // ---------------------------------------------------------
    // 冒险控制单元
    // ---------------------------------------------------------
    hazard_detection_unit u_hazard_detection (
        .rs1_addr_id   (rs1_addr_id),
        .rs2_addr_id   (rs2_addr_id),
        .mem_read_ex   (mem_read_ex),
        .rd_addr_ex    (rd_addr_ex),
        .mem_read_mem  (mem_read_mem), // 🆕 确保接上了
        .rd_addr_mem   (rd_addr_mem),  // 🆕 确保接上了
        .stall_if      (stall_if),
        .stall_id      (stall_id),
        .stall_ex      (stall_ex),
        .flush_ex      (flush_ex)
    );

endmodule
