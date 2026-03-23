`timescale 1ns / 1ps

module ALUSrc_MUX_tb;

reg         ALU_Src;
reg  [15:0] Imm_In;
reg  [15:0] Reg_In;

wire [15:0] Src_Out;

ALUSrc_MUX uut (
    .ALU_Src(ALU_Src),
    .Imm_In(Imm_In),
    .Reg_In(Reg_In),
    .Src_Out(Src_Out)
);

initial begin

//------------------------------
// Select Register input
//------------------------------
Reg_In = 16'd15;
Imm_In = 16'd9;
ALU_Src = 0;
#10;

//------------------------------
// Select Immediate input
//------------------------------
Reg_In = 16'd21;
Imm_In = 16'd6;
ALU_Src = 1;
#10;

//------------------------------
// Change values dynamically
//------------------------------
Reg_In = 16'd33;
Imm_In = 16'd12;
ALU_Src = 0;
#10;

ALU_Src = 1;
#10;

$finish;

end

endmodule