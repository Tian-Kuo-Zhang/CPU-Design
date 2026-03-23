//==============================================================
// Module Name : ALU
//
// Description :
// 16-bit combinational Arithmetic Logic Unit.
//
// Performs arithmetic and logic operations based on ALU_Op.
// Outputs result and branch flag (Zero detection).
//
//==============================================================

module ALU (

    // Control signal
    // Determines ALU operation type
    input  [1:0] ALU_Op,

    // Operand A (from Register File)
    input  [15:0] ALU_A,

    // Operand B (from MUX: Register or Immediate)
    input  [15:0] ALU_B,

    // ALU result
    output reg [15:0] ALU_Out,

    // Branch flag (Zero flag)
    // 1 when result == 0
    output Branch_Flag
);


//--------------------------------------------------------------
// ALU Core Logic
//--------------------------------------------------------------

always @(*) begin
    case (ALU_Op)

        2'b00: ALU_Out = ALU_A + ALU_B;   // ADD
        2'b01: ALU_Out = ALU_A - ALU_B;   // SUB
        2'b10: ALU_Out = ALU_A & ALU_B;   // AND
        2'b11: ALU_Out = ALU_A | ALU_B;   // OR

        default: ALU_Out = 16'b0;

    endcase
end


//--------------------------------------------------------------
// Zero Detection (Branch Flag)
//--------------------------------------------------------------

assign Branch_Flag = (ALU_Out == 16'b0);


endmodule