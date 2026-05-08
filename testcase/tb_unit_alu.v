`timescale 1ns / 1ps
// 单元：ALU + Branch_Flag（判零）
module tb_unit_alu;

    reg  [1:0]  ALU_Op;
    reg  [15:0] ALU_A;
    reg  [15:0] ALU_B;
    wire [15:0] ALU_Out;
    wire        Branch_Flag;

    ALU uut (
        .ALU_Op      (ALU_Op),
        .ALU_A       (ALU_A),
        .ALU_B       (ALU_B),
        .ALU_Out     (ALU_Out),
        .Branch_Flag (Branch_Flag)
    );

    task check;
        input [15:0] exp_out;
        input        exp_z;
        begin
            #1;
            if (ALU_Out !== exp_out || Branch_Flag !== exp_z) begin
                $display("FAIL ALU out=%04h z=%0b exp_out=%04h exp_z=%0b", ALU_Out, Branch_Flag, exp_out, exp_z);
                $fatal(1);
            end
        end
    endtask

    initial begin
        ALU_Op = 2'b00;
        ALU_A  = 16'd13;
        ALU_B  = 16'd7;
        check(16'd20, 1'b0);

        ALU_Op = 2'b01;
        ALU_A  = 16'd25;
        ALU_B  = 16'd9;
        check(16'd16, 1'b0);

        ALU_Op = 2'b01;
        ALU_A  = 16'd22;
        ALU_B  = 16'd22;
        check(16'd0, 1'b1);

        ALU_Op = 2'b01;
        ALU_A  = 16'hFFFF;
        ALU_B  = 16'hFFFE;
        check(16'd1, 1'b0);

        $display("PASS tb_unit_alu");
        $finish;
    end

endmodule
