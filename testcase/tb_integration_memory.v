`timescale 1ns / 1ps
`include "paths.vh"

// 集成：load 通路（TB 预填 RAM[16]，指令 load R1 <- mem[R2+0x10]）
module tb_integration_memory;

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

        UUT.U_RAM.data_mem[16] = 16'hCAFE;

        #1 $readmemh(`MEM_INTEGRATION_MEM, UUT.U_ROM.mem);

        repeat (4) @(posedge clk);
        reset = 1'b0;

        repeat (60) @(posedge clk);

        if (UUT.U_RF.registers[1] !== 16'hCAFE)
            $fatal(1, "integration_memory R1 exp CAFE");

        $display("PASS tb_integration_memory");
        $finish;
    end

endmodule
