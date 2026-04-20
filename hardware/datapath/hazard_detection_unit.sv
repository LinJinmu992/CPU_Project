module hazard_detection_unit (
    input [4:0] rs1_addr_id, rs2_addr_id,
    input       mem_read_ex, mem_read_mem, // 🆕 增加 MEM 阶段检测
    input [4:0] rd_addr_ex, rd_addr_mem,   // 🆕 增加 MEM 阶段地址
    output      stall_if, stall_id, stall_ex, flush_ex
);
    // 如果 EX 或 MEM 阶段有 Load 且目标寄存器被 ID 阶段需要，则阻塞
    wire hazard = (mem_read_ex  && (rd_addr_ex  != 5'b0) && ((rd_addr_ex  == rs1_addr_id) || (rd_addr_ex  == rs2_addr_id))) ||
                  (mem_read_mem && (rd_addr_mem != 5'b0) && ((rd_addr_mem == rs1_addr_id) || (rd_addr_mem == rs2_addr_id)));

    assign stall_if = hazard;
    assign stall_id = hazard;
    assign stall_ex = 1'b0;
    assign flush_ex = hazard; 
endmodule