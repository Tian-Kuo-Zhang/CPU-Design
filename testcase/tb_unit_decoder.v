`timescale 1ns / 1ps
// 单元：Decoder 单热点译码
module tb_unit_decoder;

    reg  [3:0] Opcode;
    wire [15:0] Decode_Out;

    Decoder uut (
        .Opcode     (Opcode),
        .Decode_Out (Decode_Out)
    );

    integer k;
    initial begin
        for (k = 0; k < 16; k = k + 1) begin
            Opcode = k[3:0];
            #1;
            if (Decode_Out !== (16'h1 << k)) begin
                $display("FAIL decoder op=%0d exp one-hot bit %0d got %04h", k, k, Decode_Out);
                $fatal(1);
            end
        end
        $display("PASS tb_unit_decoder");
        $finish;
    end

endmodule
