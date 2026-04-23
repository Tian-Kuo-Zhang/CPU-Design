`timescale 1ns / 1ps

module tb_rf_sync_write_async_read;

    reg         clk;
    reg         RegWrite;
    reg  [1:0]  raddr1;
    reg  [1:0]  raddr2;
    reg  [1:0]  waddr;
    reg  [15:0] wdata;
    wire [15:0] rdata1;
    wire [15:0] rdata2;

    RF dut (
        .clk      (clk),
        .RegWrite (RegWrite),
        .raddr1   (raddr1),
        .raddr2   (raddr2),
        .waddr    (waddr),
        .wdata    (wdata),
        .rdata1   (rdata1),
        .rdata2   (rdata2)
    );

    always #5 clk = ~clk;

    task check16;
        input [15:0] got;
        input [15:0] exp;
        input [255:0] tag;
        begin
            if (got !== exp) begin
                $display("[FAIL] %s exp=0x%04h got=0x%04h @%0t", tag, exp, got, $time);
                $fatal(1);
            end else begin
                $display("[PASS] %s value=0x%04h @%0t", tag, got, $time);
            end
        end
    endtask

    initial begin
        clk      = 1'b0;
        RegWrite = 1'b0;
        raddr1   = 2'b00;
        raddr2   = 2'b00;
        waddr    = 2'b00;
        wdata    = 16'h0000;

        // Initial read: R0 must always be 0
        #1;
        check16(rdata1, 16'h0000, "R0 hard-wired zero");

        // Prepare write R1 = 0x1234, read R1 before edge (should still old value 0)
        raddr1   = 2'b01;
        waddr    = 2'b01;
        wdata    = 16'h1234;
        RegWrite = 1'b1;
        #1;
        check16(rdata1, 16'h0000, "Before posedge, R1 old value");

        // After posedge write should commit, async read should reflect immediately
        @(posedge clk);
        #1;
        check16(rdata1, 16'h1234, "After posedge, R1 new value visible");

        // Turn off write, change read address asynchronously
        RegWrite = 1'b0;
        raddr2   = 2'b01;
        #1;
        check16(rdata2, 16'h1234, "Async read on raddr2");

        // Try to write R0, must remain zero
        waddr    = 2'b00;
        wdata    = 16'hFFFF;
        RegWrite = 1'b1;
        @(posedge clk);
        #1;
        raddr1   = 2'b00;
        #1;
        check16(rdata1, 16'h0000, "R0 write-protection");

        // Same-cycle read/write same register behavior check:
        // before edge read old value, after edge read new value
        raddr1   = 2'b10;
        waddr    = 2'b10;
        wdata    = 16'h00AA;
        RegWrite = 1'b1;
        #1;
        check16(rdata1, 16'h0000, "Same-cycle before edge read old R2");
        @(posedge clk);
        #1;
        check16(rdata1, 16'h00AA, "Same-cycle after edge read new R2");

        $display("tb_rf_sync_write_async_read finished.");
        $finish;
    end

endmodule
