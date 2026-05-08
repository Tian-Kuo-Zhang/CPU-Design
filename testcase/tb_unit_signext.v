`timescale 1ns / 1ps
// 单元：符号扩展 8->16
module tb_unit_signext;

    reg  [7:0] Imm_In;
    wire [15:0] Imm_Out;

    SignExtender uut (
        .Imm_In  (Imm_In),
        .Imm_Out (Imm_Out)
    );

    initial begin
        Imm_In = 8'h7F; #1;
        if (Imm_Out !== 16'h007F) $fatal(1, "pos");
        Imm_In = 8'h80; #1;
        if (Imm_Out !== 16'hFF80) $fatal(1, "neg80");
        Imm_In = 8'hF9; #1;
        if (Imm_Out !== 16'hFFF9) $fatal(1, "negF9");
        $display("PASS tb_unit_signext");
        $finish;
    end

endmodule
