`timescale 1ns / 1ps
`include "paths.vh"

// 回归套件：同一仿真内串行跑多份 ROM（依赖 RF reset 清零）
module tb_regression_suite;

    reg         clk = 1'b0;
    reg         reset = 1'b1;
    wire [7:0]  probe_PC;
    wire [15:0] probe_Instruction;
    wire [15:0] probe_ALU_Result;

    Top UUT (
        .clk               (clk),
        .reset             (reset),
        .probe_PC          (probe_PC),
        .probe_Instruction (probe_Instruction),
        .probe_ALU_Result  (probe_ALU_Result)
    );

    always #5 clk = ~clk;

    integer i;

    task clr_ram;
        begin
            for (i = 0; i < 256; i = i + 1)
                UUT.U_RAM.data_mem[i] = 16'h0000;
        end
    endtask

    task pulse_reset;
        begin
            reset = 1'b1;
            repeat (4) @(posedge clk);
            reset = 1'b0;
        end
    endtask

    initial begin
        // --- 1 sanity（仅冒烟，不强制 Golden）---
        clr_ram();
        #1 $readmemh(`MEM_SANITY, UUT.U_ROM.mem);
        pulse_reset();
        repeat (30) @(posedge clk);
        $display(".. sanity smoke done");

        // --- 2 integration_basic ---
        clr_ram();
        #1 $readmemh(`MEM_INTEGRATION_BASIC, UUT.U_ROM.mem);
        pulse_reset();
        repeat (100) @(posedge clk);
        if (UUT.U_RF.registers[1] !== 16'h0007 || UUT.U_RF.registers[2] !== 16'h0003)
            $fatal(1, "suite integration_basic");

        // --- 3 integration_memory ---
        clr_ram();
        UUT.U_RAM.data_mem[16] = 16'hCAFE;
        #1 $readmemh(`MEM_INTEGRATION_MEM, UUT.U_ROM.mem);
        pulse_reset();
        repeat (60) @(posedge clk);
        if (UUT.U_RF.registers[1] !== 16'hCAFE)
            $fatal(1, "suite integration_memory");

        // --- 4 system_control ---
        clr_ram();
        #1 $readmemh(`MEM_SYSTEM_CONTROL, UUT.U_ROM.mem);
        pulse_reset();
        repeat (130) @(posedge clk);
        if (UUT.U_RF.registers[0] !== 16'h0000 || UUT.U_RF.registers[1] !== 16'h00AB
                || UUT.U_RF.registers[2] !== 16'h0101 || UUT.U_RF.registers[3] !== 16'h0002)
            $fatal(1, "suite system_control");

        // --- 5 regression_algorithm ---
        clr_ram();
        #1 $readmemh(`MEM_REGRESSION_ALG, UUT.U_ROM.mem);
        pulse_reset();
        repeat (80) @(posedge clk);
        if (UUT.U_RF.registers[1] !== 16'h000F)
            $fatal(1, "suite regression_algorithm");

        // --- 6 regression_boundary ---
        clr_ram();
        #1 $readmemh(`MEM_REGRESSION_BOUND, UUT.U_ROM.mem);
        pulse_reset();
        repeat (80) @(posedge clk);
        if (UUT.U_RF.registers[0] !== 16'h0000 || UUT.U_RF.registers[1] !== 16'h00AB
                || UUT.U_RF.registers[2] !== 16'h0101)
            $fatal(1, "suite regression_boundary");

        $display("PASS tb_regression_suite (all segments)");
        $finish;
    end

endmodule
