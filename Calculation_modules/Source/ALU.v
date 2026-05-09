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
    input  wire [3:0]  ALUOp,

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
     case (ALUOp)
            4'b0000: ALU_out = A + B;
            4'b0001: ALU_out = A - B;
            4'b0010: ALU_out = A & B;
            4'b0011: ALU_out = A | B;
            4'b0100: ALU_out = B;
            4'b0101: ALU_out = A;
            4'b0110: ALU_out = A ^ B;
            4'b0111: ALU_out = {A[14:0], A[15]};
            4'b1000: ALU_out = {A[0], A[15:1]};
            default: ALU_out = 16'b0;

    endcase
end


//--------------------------------------------------------------
// Zero Detection (Branch Flag)
//--------------------------------------------------------------

assign Branch_Flag = (ALU_Out == 16'b0);


endmodule
