`timescale 1ns / 1ps

module CU_tb;

    // =====================================================
    // 1. Testbench inputs
    // =====================================================
    reg clk;
    reg reset;
    reg [15:0] instruction_in;
    reg Branch_flag;

    // =====================================================
    // 2. Wires from IR
    // =====================================================
    wire [15:0] instr;
    wire [3:0]  opcode;
    wire [1:0]  rd;
    wire [1:0]  rs;
    wire [1:0]  rt;
    wire [7:0]  imm;
    wire [5:0]  funct;

    // =====================================================
    // 3. Wires from Decoder
    // =====================================================
    wire [15:0] Decode_Out;

    // =====================================================
    // 4. Wires from OC
    // =====================================================
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire [1:0]  PCSrc;
    wire [1:0]  Op_in;
    wire        MemRead;
    wire        MemWrite;

    // =====================================================
    // 5. Instantiate IR
    // =====================================================
    IR uut_IR (
        .clk(clk),
        .reset(reset),
        .instruction_in(instruction_in),
        .instr(instr),
        .opcode(opcode),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .imm(imm),
        .funct(funct)
    );

    // =====================================================
    // 6. Instantiate Decoder
    // =====================================================
    Decoder uut_Decoder (
        .Opcode(opcode),
        .Decode_Out(Decode_Out)
    );

    // =====================================================
    // 7. Instantiate OC
    // =====================================================
    OC uut_OC (
        .Decode_Out(Decode_Out),
        .Funct(funct),
        .Branch_flag(Branch_flag),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .Op_in(Op_in),
        .MemRead(MemRead),
        .MemWrite(MemWrite)
    );

    // =====================================================
    // 8. Clock generation
    //    时钟周期 = 10ns
    // =====================================================
    always #5 clk = ~clk;

    // =====================================================
    // 9. Task: apply one instruction
    //    在时钟上升沿让 IR 锁存新指令
    // =====================================================
    task apply_instruction;
        input [15:0] inst;
        input bf;
        begin
            // 先在下一个上升沿到来前准备好输入
            instruction_in = inst;
            Branch_flag    = bf;

            // 等待 IR 真正采样
            @(posedge clk);
            #1;   // 给组合逻辑一点稳定时间

            // 调试输出，可在 Tcl/Console 里看到
            $display("time=%0t | instruction_in=%h | instr=%h | opcode=%b | funct=%b | Branch_flag=%b | Decode_Out=%b | RegWrite=%b ALUSrc=%b MemtoReg=%b MemRead=%b MemWrite=%b PCSrc=%b Op_in=%b",
                     $time, instruction_in, instr, opcode, funct, Branch_flag,
                     Decode_Out, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, PCSrc, Op_in);
        end
    endtask

    // =====================================================
    // 10. Stimulus
    // =====================================================
    initial begin
        // -------------------------
        // 初始化
        // -------------------------
        clk            = 1'b0;
        reset          = 1'b1;
        instruction_in = 16'h0000;
        Branch_flag    = 1'b0;

        // -------------------------
        // 复位
        // -------------------------
        #2;
        @(posedge clk);
        #1;
        reset = 1'b0;

        // =================================================
        // A. mov imm   opcode = 0001
        // 预期：
        // RegWrite=1, ALUSrc=1, Op_in=00
        // =================================================
        apply_instruction(16'b0001_01_00_00000011, 1'b0);

        // =================================================
        // B. load      opcode = 0010
        // 预期：
        // RegWrite=1, ALUSrc=1, MemRead=1, MemtoReg=1, Op_in=00
        // =================================================
        apply_instruction(16'b0010_01_00_00000100, 1'b0);

        // =================================================
        // C. store     opcode = 0011
        // 预期：
        // ALUSrc=1, MemWrite=1, Op_in=00
        // =================================================
        apply_instruction(16'b0011_01_00_00000101, 1'b0);

        // =================================================
        // D. addi      opcode = 0100
        // 预期：
        // RegWrite=1, ALUSrc=1, Op_in=00
        // =================================================
        apply_instruction(16'b0100_01_00_00000110, 1'b0);

        // =================================================
        // E. subi      opcode = 0101
        // 预期：
        // RegWrite=1, ALUSrc=1, Op_in=01
        // =================================================
        apply_instruction(16'b0101_01_00_00000111, 1'b0);

        // =================================================
        // F. R-type mov reg   opcode = 0000, funct = 000000
        // 预期：
        // RegWrite=1, ALUSrc=0, Op_in=00
        // =================================================
        apply_instruction(16'b0000_01_10_00_000000, 1'b0);

        // =================================================
        // G. R-type add reg   opcode = 0000, funct = 000001
        // 预期：
        // RegWrite=1, ALUSrc=0, Op_in=00
        // =================================================
        apply_instruction(16'b0000_01_10_00_000001, 1'b0);

        // =================================================
        // H. R-type sub reg   opcode = 0000, funct = 000010
        // 预期：
        // RegWrite=1, ALUSrc=0, Op_in=01
        // =================================================
        apply_instruction(16'b0000_01_10_00_000010, 1'b0);

        // =================================================
        // I. R-type and reg   opcode = 0000, funct = 000011
        // 预期：
        // RegWrite=1, ALUSrc=0, Op_in=10
        // =================================================
        apply_instruction(16'b0000_01_10_00_000011, 1'b0);

        // =================================================
        // J. R-type or reg    opcode = 0000, funct = 000100
        // 预期：
        // RegWrite=1, ALUSrc=0, Op_in=11
        // =================================================
        apply_instruction(16'b0000_01_10_00_000100, 1'b0);

        // =================================================
        // K. jump      opcode = 0110
        // 预期：
        // PCSrc = 10
        // =================================================
        apply_instruction(16'b0110_00_00_00000001, 1'b0);

        // =================================================
        // L. beq not taken   opcode = 0111, Branch_flag = 0
        // 预期：
        // ALUSrc=0, Op_in=01, PCSrc=00
        // =================================================
        apply_instruction(16'b0111_01_10_00000010, 1'b0);

        // =================================================
        // M. beq taken       opcode = 0111, Branch_flag = 1
        // 预期：
        // ALUSrc=0, Op_in=01, PCSrc=01
        // =================================================
        apply_instruction(16'b0111_01_10_00000010, 1'b1);

        // =================================================
        // N. bne not taken   opcode = 1000, Branch_flag = 1
        // 你的 OC 逻辑是 if (!Branch_flag) PCSrc=01
        // 所以 Branch_flag=1 时不跳
        // 预期：
        // ALUSrc=0, Op_in=01, PCSrc=00
        // =================================================
        apply_instruction(16'b1000_01_10_00000010, 1'b1);

        // =================================================
        // O. bne taken       opcode = 1000, Branch_flag = 0
        // 预期：
        // ALUSrc=0, Op_in=01, PCSrc=01
        // =================================================
        apply_instruction(16'b1000_01_10_00000010, 1'b0);

        // -------------------------
        // 留一点时间观察最后一条
        // -------------------------
        @(posedge clk);
        #5;

        $stop;
    end

endmodule