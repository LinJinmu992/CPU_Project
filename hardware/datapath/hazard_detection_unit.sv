module hazard_detection_unit (
    input [6:0] opcode_id,      // 🆕 传入 opcode，判断指令类型
    input [4:0] rs1_addr_id, rs2_addr_id,
    input       mem_read_ex,    // 只需要检测 EX 阶段，MEM 阶段交给前递
    input [4:0] rd_addr_ex,
    output      stall_if, stall_id, flush_ex
);
    // 只有这些指令真正需要读取寄存器
    // 排除 LUI (0x37), AUIPC (0x17), JAL (0x6f)
    wire uses_rs1 = (opcode_id != 7'h37) && (opcode_id != 7'h17) && (opcode_id != 7'h6f);
    // 只有 R型、Branch、Store 需要用到 rs2
    wire uses_rs2 = (opcode_id == 7'h33) || (opcode_id == 7'h63) || (opcode_id == 7'h23);

    // 只有 Load-Use 冲突（Load 在 EX，Use 在 ID）才需要真正停顿
    wire hazard = mem_read_ex && (rd_addr_ex != 5'b0) && 
                  ((uses_rs1 && (rd_addr_ex == rs1_addr_id)) || 
                   (uses_rs2 && (rd_addr_ex == rs2_addr_id)));

    assign stall_if = hazard;
    assign stall_id = hazard;
    assign flush_ex = hazard; 
endmodule