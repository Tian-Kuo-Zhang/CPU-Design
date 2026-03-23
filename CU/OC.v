module OC (
    input  [15:0] Decode_Out,
    input  [5:0]  Funct,
    input         Branch_flag,

    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg [1:0] PCSrc,
    output reg [1:0] Op_in,
    output reg       MemRead,
    output reg       MemWrite
);

always @(*) begin
    // default values
    RegWrite = 1'b0;
    ALUSrc   = 1'b0;
    MemtoReg = 1'b0;
    PCSrc    = 2'b00;
    Op_in    = 2'b00;
    MemRead  = 1'b0;
    MemWrite = 1'b0;

    // mov imm   opcode = 0001
    if (Decode_Out[1]) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        Op_in    = 2'b00;
    end

    // load      opcode = 0010
    else if (Decode_Out[2]) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        MemRead  = 1'b1;
        MemtoReg = 1'b1;
        Op_in    = 2'b00;
    end

    // store     opcode = 0011
    else if (Decode_Out[3]) begin
        ALUSrc   = 1'b1;
        MemWrite = 1'b1;
        Op_in    = 2'b00;
    end

    // addi      opcode = 0100
    else if (Decode_Out[4]) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        Op_in    = 2'b00;
    end

    // subi      opcode = 0101
    else if (Decode_Out[5]) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        Op_in    = 2'b01;
    end

    // R-type    opcode = 0000
    else if (Decode_Out[0]) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;

        case (Funct)
            6'b000000: Op_in = 2'b00; // mov reg
            6'b000001: Op_in = 2'b00; // add reg
            6'b000010: Op_in = 2'b01; // sub reg
            6'b000011: Op_in = 2'b10; // and reg
            6'b000100: Op_in = 2'b11; // or reg
            default: begin
                RegWrite = 1'b0;
                Op_in    = 2'b00;
            end
        endcase
    end

    // jump      opcode = 0110
    else if (Decode_Out[6]) begin
        PCSrc = 2'b10;
        // ALUSrc / Op_in don't care here, keep default
    end

    // beq       opcode = 0111
    else if (Decode_Out[7]) begin
        ALUSrc = 1'b0;
        Op_in  = 2'b01;   // compare by subtraction
        if (Branch_flag)
            PCSrc = 2'b01;
    end

    // bne       opcode = 1000
    else if (Decode_Out[8]) begin
        ALUSrc = 1'b0;
        Op_in  = 2'b01;   // compare by subtraction
        if (!Branch_flag)
            PCSrc = 2'b01;
    end
end

endmodule
