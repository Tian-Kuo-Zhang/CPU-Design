`timescale 1ns / 1ps

module RAM_tb();

    // --- 信号定义 ---
    reg [15:0] ram_addr_out;
    reg [15:0] ram_wdata_out;
    reg MemWrite;
    reg MemRead;
    reg clk;
    wire [15:0] ram_rdata_in;

    // --- 实例化被测模块 (UUT) ---
    RAM uut (
        .ram_addr_out(ram_addr_out), 
        .ram_wdata_out(ram_wdata_out), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .clk(clk), 
        .ram_rdata_in(ram_rdata_in)
    );

    // --- 时钟生成: 周期为 10ns (100MHz) ---
    always #5 clk = ~clk;

    // --- 测试逻辑 ---
    initial begin
        // 1. 初始化信号
        clk = 0;
        MemWrite = 0;
        MemRead = 0;
        ram_addr_out = 0;
        ram_wdata_out = 0;

        #10; // 等待稳定

        // 2. 写入操作测试
        // 向地址 0x05 写入 0xABCD
        write_mem(16'h0005, 16'hABCD);
        
        // 向地址 0x0A 写入 0x1234
        write_mem(16'h000A, 16'h1234);

        #10;

        // 3. 读取操作测试
        // 读取地址 0x05
        read_mem(16'h0005);
        
        // 读取地址 0x0A
        read_mem(16'h000A);
        
        // 4. 测试非读取状态 (应输出 0)
        #10;
        MemRead = 0;
        ram_addr_out = 16'h0005; 
        #10;

        // 结束仿真
        $display("Simulation Finished.");
        $finish;
    end

    // --- 辅助任务 (Tasks) ---
    
    // 模拟写入过程
    task write_mem(input [15:0] addr, input [15:0] data);
        begin
            @(posedge clk);
            MemWrite = 1;
            ram_addr_out = addr;
            ram_wdata_out = data;
            @(posedge clk);
            MemWrite = 0;
            $display("[WRITE] Addr: %h, Data: %h", addr, data);
        end
    endtask

    // 模拟读取过程
    task read_mem(input [15:0] addr);
        begin
            MemRead = 1;
            ram_addr_out = addr;
            #5; // 等待组合逻辑读取
            $display("[READ]  Addr: %h, Data: %h", addr, ram_rdata_in);
            #5;
            MemRead = 0;
        end
    endtask

endmodule
