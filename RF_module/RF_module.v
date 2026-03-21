module RF (
    input  wire        clk,       // 系统时钟
    input  wire        RegWrite,  // 写使能信号 (来自 OC)
    input  wire [1:0]  raddr1,    // 读地址 1 (对应 Rs)
    input  wire [1:0]  raddr2,    // 读地址 2 (对应 Rt)
    input  wire [1:0]  waddr,     // 写地址 (对应 Rd)
    input  wire [15:0] wdata,     // 准备写入的 16 位数据
    
    output wire [15:0] rdata1,    // 读出的 16 位数据 1
    output wire [15:0] rdata2     // 读出的 16 位数据 2
);

    // 定义 4 个 16 位的寄存器阵列 (R0, R1, R2, R3)
    reg [15:0] registers [3:0];

    // 初始化：强烈建议仿真时加上，避免初始状态为不定态 (x)
    integer i;
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            registers[i] = 16'b0;
        end
    end

    // ==========================================
    // 1. 异步读逻辑 (Asynchronous Read)
    // 只要地址有变化，数据立刻输出。
    // 并且强行规定：如果读取 R0 (地址 2'b00)，永远输出 0。
    // 连续赋值语句,而不等待时钟边沿.
    // ==========================================
    assign rdata1 = (raddr1 == 2'b00) ? 16'b0 : registers[raddr1];
    assign rdata2 = (raddr2 == 2'b00) ? 16'b0 : registers[raddr2];

    // ==========================================
    // 2. 同步写逻辑 (Synchronous Write)
    // 只有在时钟上升沿，且 RegWrite 为 1 时才执行写入。
    // ==========================================
    always @(posedge clk) begin
        if (RegWrite) begin
            // 硬件级保护：绝对不允许改写 R0 寄存器
            if (waddr != 2'b00) begin
                registers[waddr] <= wdata;
            end
        end
    end

endmodule