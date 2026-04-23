`timescale 1ns / 1ps

module tb_fetch_branch_offset;

    reg        clk;
    reg        reset;
    reg  [1:0] pc_sel;
    reg  [7:0] imm_8;
    wire [7:0] PC_out;

    FetchUnit dut (
        .clk    (clk),
        .reset  (reset),
        .pc_sel (pc_sel),
        .imm_8  (imm_8),
        .PC_out (PC_out)
    );

    always #5 clk = ~clk;

    task check_pc;
        input [7:0] exp;
        input [255:0] tag;
        begin
            if (PC_out !== exp) begin
                $display("[FAIL] %s exp=%0d(0x%02h) got=%0d(0x%02h) @%0t",
                         tag, exp, exp, PC_out, PC_out, $time);
                $fatal(1);
            end else begin
                $display("[PASS] %s pc=%0d(0x%02h) @%0t", tag, PC_out, PC_out, $time);
            end
        end
    endtask

    initial begin
        clk   = 1'b0;
        reset = 1'b1;
        pc_sel = 2'b00;
        imm_8  = 8'h00;

        #12;
        reset = 1'b0;

        // Sequential: PC should move 0->1->2->3
        @(posedge clk); check_pc(8'd1, "SEQ +1 #1");
        @(posedge clk); check_pc(8'd2, "SEQ +1 #2");
        @(posedge clk); check_pc(8'd3, "SEQ +1 #3");

        // Absolute jump to 20
        imm_8  = 8'd20;
        pc_sel = 2'b10;
        @(posedge clk); check_pc(8'd20, "JUMP abs to 20");
        pc_sel = 2'b00;

        // Let it run one cycle: 21
        @(posedge clk); check_pc(8'd21, "SEQ after jump");

        // Branch with positive offset +5: 21 -> 26
        imm_8  = 8'd5;
        pc_sel = 2'b01;
        @(posedge clk); check_pc(8'd26, "BRANCH +5");

        // Branch with "negative offset" FEh (two's complement -2): 26 -> 24
        imm_8  = 8'hFE;
        pc_sel = 2'b01;
        @(posedge clk); check_pc(8'd24, "BRANCH -2 (imm=0xFE)");

        // Keep branch for one more cycle: 24 -> 22
        @(posedge clk); check_pc(8'd22, "BRANCH -2 again");

        pc_sel = 2'b00;
        @(posedge clk); check_pc(8'd23, "SEQ resumes");

        $display("tb_fetch_branch_offset finished.");
        $finish;
    end

endmodule
