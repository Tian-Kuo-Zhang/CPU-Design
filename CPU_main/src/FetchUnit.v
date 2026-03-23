module FetchUnit (
    input  wire       clk,        // 时钟信号
    input  wire       reset,      // 复位信号 (Reset)
    input  wire [1:0] pc_sel,     // MUX 选择信号: 00=PC+1, 01=Branch, 10=Jump/other
    input  wire [7:0] imm_8,      // 符号扩展后的 8 位立即数
    output reg  [7:0] PC_out      // 当前程序地址 (输出至 ROM)
);

    wire [7:0] PC_plus_1;
    wire [7:0] PC_branch;
    reg  [7:0] PC_Next;

    // 1. 顺序执行路径: PC + 1
    assign PC_plus_1 = PC_out + 8'd1;

    // 2. 分支执行路径: PC + 立即数 (根据图 3: PC + imm_8)
    assign PC_branch = PC_out + imm_8;

    // 3. MUX: 决定打入 PC 的下一个地址 (PC_Next)
    always @(*) begin
        case (pc_sel)
            2'b00:   PC_Next = PC_plus_1; // PC+1 (顺序)
            2'b01:   PC_Next = PC_branch; // bne/beq (分支)
            2'b10:   PC_Next = imm_8;     // Jump (绝对跳转，假设立即数即地址)
            default: PC_Next = PC_plus_1;
        endcase
    end

    // 4. PC 寄存器逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_out <= 8'b0;               // 复位时 PC 清零
        end else begin
            PC_out <= PC_Next;            // 每个时钟周期更新 PC
        end
    end

endmodule