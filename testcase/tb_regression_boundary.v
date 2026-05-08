`timescale 1ns / 1ps
`include "paths.vh"

// 回归：R0 写保护 + 255+2 回绕（短程序）
module tb_regression_boundary;

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
    initial begin
        for (i = 0; i < 256; i = i + 1)
            UUT.U_RAM.data_mem[i] = 16'h0000;

        #1 $readmemh(`MEM_REGRESSION_BOUND, UUT.U_ROM.mem);

        repeat (4) @(posedge clk);
        reset = 1'b0;

        repeat (80) @(posedge clk);

        if (UUT.U_RF.registers[0] !== 16'h0000)
            $fatal(1, "R0");
        if (UUT.U_RF.registers[1] !== 16'h00AB)
            $fatal(1, "R1");
        if (UUT.U_RF.registers[2] !== 16'h0101)
            $fatal(1, "R2");

        $display("PASS tb_regression_boundary");
        $finish;
    end

endmodule
