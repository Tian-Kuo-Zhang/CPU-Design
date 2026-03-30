`timescale 1ns/1ps

module OC_tb;

    reg  [3:0] Opcode;
    reg  [5:0] Funct;
    reg        Branch_flag;

    wire       RegWrite;
    wire       ALUSrc;
    wire       MemtoReg;
    wire [1:0] PCSrc;
    wire [1:0] ALUOp;
    wire       MemRead;
    wire       MemWrite;

    // 实例化 OC
    OC uut (
        .Opcode(Opcode),
        .Funct(Funct),
        .Branch_flag(Branch_flag),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite)
    );

    initial begin
        // 初始化
        Opcode = 4'b0000;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 1. mov imm
        #10;
        Opcode = 4'b0001;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 2. load
        #10;
        Opcode = 4'b0010;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 3. store
        #10;
        Opcode = 4'b0011;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 4. addi
        #10;
        Opcode = 4'b0100;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 5. subi
        #10;
        Opcode = 4'b0101;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 6. R-type mov reg
        #10;
        Opcode = 4'b0000;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 7. R-type add reg
        #10;
        Opcode = 4'b0000;
        Funct = 6'b000001;
        Branch_flag = 1'b0;

        // 8. R-type sub reg
        #10;
        Opcode = 4'b0000;
        Funct = 6'b000010;
        Branch_flag = 1'b0;

        // 9. R-type and reg
        #10;
        Opcode = 4'b0000;
        Funct = 6'b000011;
        Branch_flag = 1'b0;

        // 10. R-type or reg
        #10;
        Opcode = 4'b0000;
        Funct = 6'b000100;
        Branch_flag = 1'b0;

        // 11. R-type invalid funct
        #10;
        Opcode = 4'b0000;
        Funct = 6'b111111;
        Branch_flag = 1'b0;

        // 12. jump
        #10;
        Opcode = 4'b0110;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 13. beq, branch taken
        #10;
        Opcode = 4'b0111;
        Funct = 6'b000000;
        Branch_flag = 1'b1;

        // 14. beq, branch not taken
        #10;
        Opcode = 4'b0111;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 15. bne, branch taken
        #10;
        Opcode = 4'b1000;
        Funct = 6'b000000;
        Branch_flag = 1'b0;

        // 16. bne, branch not taken
        #10;
        Opcode = 4'b1000;
        Funct = 6'b000000;
        Branch_flag = 1'b1;

        #10;
        $stop;
    end

endmodule
