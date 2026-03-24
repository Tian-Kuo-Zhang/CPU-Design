`timescale 1ns / 1ps

module tb_Top();

    // 1. 声明给 CPU 的输入信号 (用 reg)
    reg clk;
    reg reset;

    // 2. 声明从 CPU 接出来的探针信号 (用 wire)
    wire [7:0]  probe_PC;
    wire [15:0] probe_Instruction;
    wire [15:0] probe_ALU_Result;

    // 3. 把你的 CPU (Top) 实例化到测试台上
    Top UUT (
        .clk              (clk),
        .reset            (reset),
        .probe_PC         (probe_PC),
        .probe_Instruction(probe_Instruction),
        .probe_ALU_Result (probe_ALU_Result)
    );

    // 4. 制造心脏跳动：生成 100MHz 的时钟 (周期 10ns)
    always #5 clk = ~clk;

    // 5. 编写测试动作
    initial begin
        // 刚上电，初始化信号
        clk = 0;
        reset = 1;  // 按下复位键，强制 PC 归零
        
        // 维持复位状态 15ns，确保 CPU 彻底清醒
        #15;        
        
        // 松开复位键，CPU 开始全速执行 ROM 里的指令！
        reset = 0;  
        
        // 让 CPU 跑 100 纳秒 (相当于跑 10 条指令)
        #100;
        
        // 停止仿真
        $display("Test Finished!");
        $stop;
    end

endmodule