module pc #(
    parameter WIDTH = 32,
    parameter RESET_ADDR = 32'h0000_0000
)(
    input               clk,
    input               rst,
    input               en,       // 🆕 新增：使能信号（通行证）
    input  [WIDTH-1:0]  next_pc,
    output reg [WIDTH-1:0] pc_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= RESET_ADDR;
        end else if (en) begin    // 🆕 只有收到“准行证”才更新
            pc_out <= next_pc;
        end
        // 如果 en 为 0，不写 else，它会自动保持原值（锁死当前 PC）
    end

endmodule