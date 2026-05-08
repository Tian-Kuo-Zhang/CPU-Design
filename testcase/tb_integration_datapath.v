`timescale 1ns / 1ps
`include "paths.vh"

// 集成：算术 + R-type + or（README 集成基本通路）
module tb_integration_datapath;

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

        #1 $readmemh(`MEM_INTEGRATION_BASIC, UUT.U_ROM.mem);

        repeat (4) @(posedge clk);
        reset = 1'b0;

        repeat (100) @(posedge clk);

        if (UUT.U_RF.registers[1] !== 16'h0007)
            $fatal(1, "integration_basic R1 exp 7");
        if (UUT.U_RF.registers[2] !== 16'h0003)
            $fatal(1, "integration_basic R2 exp 3");
        if (UUT.U_RF.registers[3] !== 16'h0000)
            $fatal(1, "integration_basic R3 exp 0");

        $display("PASS tb_integration_datapath");
        $finish;
    end

endmodule
