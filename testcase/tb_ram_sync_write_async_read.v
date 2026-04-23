`timescale 1ns / 1ps

module tb_ram_sync_write_async_read;

    reg  [15:0] ram_addr_out;
    reg  [15:0] ram_wdata_out;
    reg         MemWrite;
    reg         MemRead;
    reg         clk;
    wire [15:0] ram_rdata_in;

    RAM dut (
        .ram_addr_out  (ram_addr_out),
        .ram_wdata_out (ram_wdata_out),
        .MemWrite      (MemWrite),
        .MemRead       (MemRead),
        .clk           (clk),
        .ram_rdata_in  (ram_rdata_in)
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
        clk           = 1'b0;
        ram_addr_out  = 16'h0000;
        ram_wdata_out = 16'h0000;
        MemWrite      = 1'b0;
        MemRead       = 1'b0;

        // When MemRead=0, output should be 0 by design.
        #1;
        check16(ram_rdata_in, 16'h0000, "MemRead=0 output forced zero");

        // Write addr 0x0010 = 0xABCD (sync write at posedge)
        ram_addr_out  = 16'h0010;
        ram_wdata_out = 16'hABCD;
        MemWrite      = 1'b1;
        MemRead       = 1'b1;

        // Before posedge write not committed yet; read may be X/old (do not assert exact).
        #1;
        $display("[INFO] Before posedge read=0x%04h (may be old/X)", ram_rdata_in);

        @(posedge clk);
        #1;
        check16(ram_rdata_in, 16'hABCD, "After posedge write, async read gets new data");

        // Address alias test: only low 8 bits are used in RAM module.
        // 0x0010 and 0x0110 index the same entry [0x10].
        ram_addr_out = 16'h0110;
        #1;
        check16(ram_rdata_in, 16'hABCD, "Address alias by low 8-bit index");

        // Turn off MemRead; output should return to 0.
        MemWrite = 1'b0;
        MemRead  = 1'b0;
        #1;
        check16(ram_rdata_in, 16'h0000, "Read disabled output zero");

        $display("tb_ram_sync_write_async_read finished.");
        $finish;
    end

endmodule
