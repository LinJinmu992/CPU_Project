// ----------------------------------------------------------------
// RISC-V CPU 全局宏定义文件
// 建议在 Vivado 中右键点击该文件，选择 "Set Global Include"
// ----------------------------------------------------------------

// --- 1. ALU 操作码 (ALU Control Signals) ---
// 这些是 ALU 控制单元输出给 ALU 的 4 位控制信号
`define ALU_AND  4'b0000
// 按位与操作，用于 AND/ANDI 指令
`define ALU_OR   4'b0001
// 按位或操作，用于 OR/ORI 指令
`define ALU_ADD  4'b0010
// 加法操作，用于 ADD/ADDI 指令
`define ALU_SUB  4'b0110
// 减法操作，用于 SUB 指令
`define ALU_SLT  4'b0111  // 有符号比较 (Set Less Than)
// 有符号小于置位，用于 SLT/SLTI 指令
`define ALU_SLTU 4'b1001  // 无符号比较 (Set Less Than Unsigned)
// 无符号小于置位，用于 SLTU/SLTIU 指令
`define ALU_XOR  4'b0100
// 按位异或操作，用于 XOR/XORI 指令
`define ALU_SLL  4'b0011  // 逻辑左移
// 逻辑左移操作，用于 SLL/SLLI 指令
`define ALU_SRL  4'b0101  // 逻辑右移
// 逻辑右移操作，用于 SRL/SRLI 指令
`define ALU_SRA  4'b1000  // 算术右移
// 算术右移操作，用于 SRA/SRAI 指令

// --- 2. 指令大类操作码 (Major Opcodes) ---
// 指令的 [6:0] 位
`define OP_RTYPE  7'b0110011
// R-type 指令：ADD, SUB, AND, OR, SLT, SLTU, XOR, SLL, SRL, SRA
`define OP_ITYPE  7'b0010011
// I-type 算术指令：ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
`define OP_LOAD   7'b0000011
// 加载指令：LB, LH, LW, LBU, LHU
`define OP_STORE  7'b0100011
// 存储指令：SB, SH, SW
`define OP_BRANCH 7'b1100011
// 分支指令：BEQ, BNE, BLT, BGE, BLTU, BGEU
`define OP_LUI    7'b0110111
// 加载高位立即数 (LUI)
`define OP_JAL    7'b1101111
// 跳转并链接 (JAL)
`define OP_JALR   7'b1100111
// 跳转并链接寄存器 (JALR)

// --- 3. 2位 ALUOp 控制信号 ---
// 来自主控制器 (Main Control) 输出给 ALU 控制器 (ALU Control)
`define ALUOP_LOAD_STORE 2'b00
// 用于加载/存储地址计算（加法）
`define ALUOP_BRANCH     2'b01
// 用于分支比较（减法）
`define ALUOP_RTYPE      2'b10
// 用于 R-type 指令（根据 funct3/funct7 选择 ALU 操作）
`define ALUOP_ITYPE      2'b11
// 用于 I-type 指令（根据 funct3 选择 ALU 操作）

// --- 4. Funct3 字段定义 ---
`define F3_ADD_SUB 3'b000
// ADD/SUB, ADDI 指令
`define F3_SLL     3'b001
// SLL, SLLI 指令
`define F3_SLT     3'b010
// SLT, SLTI 指令
`define F3_SLTU    3'b011
// SLTU, SLTIU 指令
`define F3_XOR     3'b100
// XOR, XORI 指令
`define F3_SRL_SRA 3'b101
// SRL, SRLI, SRA, SRAI 指令
`define F3_OR      3'b110
// OR, ORI 指令
`define F3_AND     3'b111
// AND, ANDI 指令

// --- 5. Funct7 关键位定义 ---
`define F7_NORMAL  7'b0000000
// 大多数指令（ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND）
`define F7_MODIFY  7'b0100000 // 用于区分 add/sub, srl/sra
 // 用于区分 SUB 和 SRA（当 funct7[5]=1 时）

// --- 6. 内存映射地址范围 (Memory Map) ---
`define IROM_BASE   32'h8000_0000
`define IROM_END    32'h8000_3FFF
`define DRAM_BASE   32'h8010_0000
`define DRAM_END    32'h8013_FFFF
`define PERIP_BASE  32'h8020_0000
`define PERIP_END   32'h8020_FFFF  // 根据规范，外设区域到 0x8020_0053，但预留空间

// --- 7. 读写掩码编码 (Perip Mask Encoding) ---
`define MASK_BYTE   2'b00   // 1字节
`define MASK_HALF   2'b01   // 2字节
`define MASK_WORD   2'b10   // 4字节

// --- 8. Load/Store 功能码 (Funct3 for Load/Store) ---
`define F3_LB       3'b000  // 有符号字节加载
`define F3_LH       3'b001  // 有符号半字加载
`define F3_LW       3'b010  // 字加载
`define F3_LBU      3'b100  // 无符号字节加载
`define F3_LHU      3'b101  // 无符号半字加载
`define F3_SB       3'b000  // 字节存储
`define F3_SH       3'b001  // 半字存储
`define F3_SW       3'b010  // 字存储
