// ----------------------------------------------------------------
// RISC-V CPU 全局宏定义文�?
// 建议�? Vivado 中右键点击该文件，�?�择 "Set Global Include"
// ----------------------------------------------------------------

// --- 1. ALU 操作�? (ALU Control Signals) ---
// 这些�? ALU 控制单元输出�? ALU �? 4 位控制信�?
`define ALU_AND  4'b0000
// 按位与操作，用于 AND/ANDI 指令
`define ALU_OR   4'b0001
// 按位或操作，用于 OR/ORI 指令
`define ALU_ADD  4'b0010
// 加法操作，用�? ADD/ADDI 指令
`define ALU_SUB  4'b0110
// 减法操作，用�? SUB 指令
`define ALU_SLT  4'b0111  // 有符号比�? (Set Less Than)
// 有符号小于置位，用于 SLT/SLTI 指令
`define ALU_SLTU 4'b1001  // 无符号比�? (Set Less Than Unsigned)
// 无符号小于置位，用于 SLTU/SLTIU 指令
`define ALU_XOR  4'b0100
// 按位异或操作，用�? XOR/XORI 指令
`define ALU_SLL  4'b0011  // 逻辑左移
// 逻辑左移操作，用�? SLL/SLLI 指令
`define ALU_SRL  4'b0101  // 逻辑右移
// 逻辑右移操作，用�? SRL/SRLI 指令
`define ALU_SRA  4'b1000  // 算术右移
// 算术右移操作，用�? SRA/SRAI 指令

// --- 2. 指令大类操作�? (Major Opcodes) ---
// 指令�? [6:0] �?
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
// 加载高位立即�? (LUI)
`define OP_JAL    7'b1101111
// 跳转并链�? (JAL)
`define OP_JALR   7'b1100111
// 跳转并链接寄存器 (JALR)
`define OP_AUIPC  7'b0010111
// 加载高位立即数并加PC (AUIPC)

// --- 3. 2�? ALUOp 控制信号 ---
// 来自主控制器 (Main Control) 输出�? ALU 控制�? (ALU Control)
`define ALUOP_LOAD_STORE 2'b00
// 用于加载/存储地址计算（加法）
`define ALUOP_BRANCH     2'b01
// 用于分支比较（减法）
`define ALUOP_RTYPE      2'b10
// 用于 R-type 指令（根�? funct3/funct7 选择 ALU 操作�?
`define ALUOP_ITYPE      2'b11
// 用于 I-type 指令（根�? funct3 选择 ALU 操作�?

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

// --- 5. Funct7 关键位定�? ---
`define F7_NORMAL  7'b0000000
// 大多数指令（ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND�?
`define F7_MODIFY  7'b0100000 // 用于区分 add/sub, srl/sra
 // 用于区分 SUB �? SRA（当 funct7[5]=1 时）

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

// --- 8. Load/Store 功能�? (Funct3 for Load/Store) ---
`define F3_LB       3'b000  // 有符号字节加�?
`define F3_LH       3'b001  // 有符号半字加�?
`define F3_LW       3'b010  // 字加�?
`define F3_LBU      3'b100  // 无符号字节加�?
`define F3_LHU      3'b101  // 无符号半字加�?
`define F3_SB       3'b000  // 字节存储
`define F3_SH       3'b001  // 半字存储
`define F3_SW       3'b010  // 字存�?

//`define RUN_TRACE

// 指令类型定义（与上面的OP_*定义相同，保留用于兼容性）
`define R_TYPE   `OP_RTYPE
`define I_TYPE   `OP_ITYPE
`define IL_TYPE  `OP_LOAD
`define IJ_TYPE  `OP_JALR
`define S_TYPE   `OP_STORE
`define B_TYPE   `OP_BRANCH
`define U_TYPE   `OP_LUI
`define UA_TYPE  `OP_AUIPC // U auipc
`define J_TYPE   `OP_JAL
`define CSR_TYPE 7'b111_0011 // CSR

`define OPCODE_LEN 7