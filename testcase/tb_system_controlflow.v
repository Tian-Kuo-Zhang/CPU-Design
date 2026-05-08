`timescale 1ns / 1ps
`include "paths.vh"

// 系统：beq / bne / jump + 后续边界片段（与 system_control.mem 一致）
module tb_system_controlflow;

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

        #1 $readmemh(`MEM_SYSTEM_CONTROL, UUT.U_ROM.mem);

        repeat (4) @(posedge clk);
        reset = 1'b0;

        repeat (120) @(posedge clk);

        if (UUT.U_RF.registers[0] !== 16'h0000)
            $fatal(1, "R0 must stay 0");
        if (UUT.U_RF.registers[1] !== 16'h00AB)
            $fatal(1, "R1 marker");
        if (UUT.U_RF.registers[2] !== 16'h0101)
            $fatal(1, "R2 wrap 255+2");
        if (UUT.U_RF.registers[3] !== 16'h0002)
            $fatal(1, "R3 after bne path");

        $display("PASS tb_system_controlflow");
        $finish;
    end

endmodule
