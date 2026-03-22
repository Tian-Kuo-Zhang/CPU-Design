`timescale 1ns / 1ps

module tb_FetchUnit();

    // 1. 声明信号
    reg        clk;
    reg        reset;
    reg  [1:0] pc_sel;
    reg  [7:0] imm_8;
    wire [7:0] PC_out;

    // 2. 例化被测模块 (UUT: Unit Under Test)
    FetchUnit uut (
        .clk(clk),
        .reset(reset),
        .pc_sel(pc_sel),
        .imm_8(imm_8),
        .PC_out(PC_out)
    );

    // 3. 生成时钟信号：周期为 10ns (100MHz)
    always #5 clk = ~clk;

    // 4. 测试激励过程
    initial begin
        // --- 初始化 ---
        clk = 0;
        reset = 1;
        pc_sel = 2'b00;
        imm_8 = 8'h00;

        // --- 1. 复位测试 ---
        #15 reset = 0; // 15ns 后撤销复位
        $display("Time: %t | Reset released, PC_out: %d", $time, PC_out);

        // --- 2. 顺序执行测试 (PC+1) ---
        // 让它跑 3 个周期，观察 PC 是否变为 1, 2, 3
        #30; 
        $display("Time: %t | Sequential check, PC_out: %d (Expected: 3)", $time, PC_out);

        // --- 3. 分支跳转测试 (beq/bne) ---
        // 假设当前 PC=3，我们要跳转 +5，目标应该是 8
        imm_8 = 8'd5;
        pc_sel = 2'b01; 
        #10; // 等待一个上升沿
        pc_sel = 2'b00; // 跳转完回到顺序模式
        $display("Time: %t | Branch check, PC_out: %d (Expected: 8)", $time, PC_out);

        // --- 4. 绝对跳转测试 (Jump) ---
        // 直接跳转到地址 50
        imm_8 = 8'd50;
        pc_sel = 2'b10;
        #10;
        pc_sel = 2'b00;
        $display("Time: %t | Jump check, PC_out: %d (Expected: 50)", $time, PC_out);

        // --- 5. 停止仿真 ---
        #50;
        $display("Simulation Finished!");
        $finish;
    end

endmodule