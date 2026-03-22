`timescale 1ns / 1ps

module RAM_tb();
    // 1. 定义连接到 RAM 模块的信号
    reg [15:0] ram_addr_out;
    reg [15:0] ram_wdata_out;
    reg MemWrite;
    reg MemRead;
    reg clk;
    wire [15:0] ram_rdata_in;

    // 2. 实例化你写的 RAM 模块
    RAM uut (
        .ram_addr_out(ram_addr_out), 
        .ram_wdata_out(ram_wdata_out), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .clk(clk), 
        .ram_rdata_in(ram_rdata_in)
    );

    // 3. 生成时钟信号：每 5ns 翻转一次，周期就是 10ns
    always #5 clk = ~clk;

    // 4. 测试流程
    initial begin
        // 初始化信号
        clk = 0;
        ram_addr_out = 0;
        ram_wdata_out = 0;
        MemWrite = 0;
        MemRead = 0;

        #10; // 等待 10ns

        // --- 动作 1：向地址 05 写入数据 ABCD ---
        ram_addr_out = 16'h0005;
        ram_wdata_out = 16'hABCD;
        MemWrite = 1;      // 开启写使能
        #10;               // 等待一个时钟周期
        MemWrite = 0;      // 关闭写使能

        #10;

        // --- 动作 2：从地址 05 读取数据 ---
        ram_addr_out = 16'h0005;
        MemRead = 1;       // 开启读使能
        #10;               // 在下一个上升沿，ram_rdata_in 应该变为 ABCD
        MemRead = 0;

        #20;
        $stop;             // 停止仿真
    end
endmodule