//==============================================================
// Module Name : ALUSrc_MUX
//
// Description :
// 2-to-1 multiplexer for ALU source selection.
//
// Selects between register input and immediate input based on
// ALU_Src control signal.
//
//==============================================================

module ALUSrc_MUX (

    // Control signal
    // 0 : select Reg_In
    // 1 : select Imm_In
    input         ALU_Src,

    // Immediate input (from Sign Extender)
    input  [15:0] Imm_In,

    // Register input (from Register File)
    input  [15:0] Reg_In,

    // Output to ALU
    output [15:0] Src_Out
);

//--------------------------------------------------------------
// MUX logic
//--------------------------------------------------------------

assign Src_Out = (ALU_Src) ? Imm_In : Reg_In;

endmodule
