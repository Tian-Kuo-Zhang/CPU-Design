module IR (
    input  wire        clk,             // 依然保留 clk 引脚，防止顶层连线报错，但内部不再使用
    input  wire        reset,
    input  wire [15:0] instruction_in,

    output wire [15:0] instr,           // 【修改】：将 reg 改为了 wire
    output wire [3:0]  opcode,
    output wire [1:0]  rd,
    output wire [1:0]  rs,
    output wire [1:0]  rt,
    output wire [7:0]  imm,
    output wire [5:0]  funct
);

    // ==========================================
    // 核心修改：取消 always 时钟块，改为纯组合逻辑！
    // 如果复位，输出全0空指令；如果不复位，瞬间透传外部指令
    // ==========================================
    assign instr = (reset) ? 16'b0 : instruction_in;

    // ==========================================
    // 下面的切片解码代码完全不需要改！
    // 因为 assign 本身就是绝对并行的组合逻辑，
    // 只要 instr 一变，下面的部分会瞬间跟着改变。
    // ==========================================
    assign opcode = instr[15:12];
    assign rd     = instr[11:10];
    assign rs     = instr[9:8];
    assign rt     = instr[7:6];
    assign imm    = instr[7:0];
    assign funct  = instr[5:0];

endmodule
