module OC (
    input  [3:0] Opcode,
    input  [5:0] Funct,
    input        Branch_flag,

    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg [1:0] PCSrc,
    output reg [1:0] ALUOp,
    output reg       MemRead,
    output reg       MemWrite
);

always @(*) begin
    // default values
    RegWrite = 1'b0;
    ALUSrc   = 1'b0;
    MemtoReg = 1'b0;
    PCSrc    = 2'b00;
    ALUOp    = 2'b00;
    MemRead  = 1'b0;
    MemWrite = 1'b0;

    // mov imm   opcode = 0001
    if (Opcode == 4'b0001) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
    end

    // load      opcode = 0010
    else if (Opcode == 4'b0010) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        MemRead  = 1'b1;
        MemtoReg = 1'b1;
        ALUOp    = 2'b00;
    end

    // store     opcode = 0011
    else if (Opcode == 4'b0011) begin
        ALUSrc   = 1'b1;
        MemWrite = 1'b1;
        ALUOp    = 2'b00;
    end

    // addi      opcode = 0100
    else if (Opcode == 4'b0100) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
    end

    // subi      opcode = 0101
    else if (Opcode == 4'b0101) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b01;
    end

    // R-type    opcode = 0000
    else if (Opcode == 4'b0000) begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;

        case (Funct)
            6'b000000: ALUOp = 2'b00; // mov reg
            6'b000001: ALUOp = 2'b00; // add reg
            6'b000010: ALUOp = 2'b01; // sub reg
            6'b000011: ALUOp = 2'b10; // and reg
            6'b000100: ALUOp = 2'b11; // or reg
            default: begin
                RegWrite = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end

    // jump      opcode = 0110
    else if (Opcode == 4'b0110) begin
        PCSrc = 2'b10;
    end

    // beq       opcode = 0111
    else if (Opcode == 4'b0111) begin
        ALUSrc = 1'b0;
        ALUOp  = 2'b01;
        if (Branch_flag)
            PCSrc = 2'b01;
    end

    // bne       opcode = 1000
    else if (Opcode == 4'b1000) begin
        ALUSrc = 1'b0;
        ALUOp  = 2'b01;
        if (!Branch_flag)
            PCSrc = 2'b01;
    end
end

endmodule
