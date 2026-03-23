`timescale 1ns / 1ps

module SignExtender_tb;

reg  [7:0] Imm_In;
wire [15:0] Imm_Out;

SignExtender uut (
    .Imm_In(Imm_In),
    .Imm_Out(Imm_Out)
);

initial begin

//------------------------------
// Positive values
//------------------------------
Imm_In = 8'd5;      // 00000101
#10;

Imm_In = 8'd12;     // 00001100
#10;

Imm_In = 8'd25;     // 00011001
#10;

//------------------------------
// Negative values
//------------------------------
Imm_In = 8'b11111011; // -5
#10;

Imm_In = 8'b11110110; // -10
#10;

Imm_In = 8'b11111100; // -4
#10;

$finish;

end

endmodule