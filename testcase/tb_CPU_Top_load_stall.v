`timescale 1ns/1ps
`default_nettype none

module tb_CPU_Top_load_stall;

    reg         clk_100m;
    reg  [7:0]  sw;
    reg         btn_mode;
    wire [7:0]  led;
    wire [7:0]  seg0;
    wire [7:0]  seg1;
    wire [7:0]  dig_sel;

    CPU_Top dut (
        .clk_100m(clk_100m),
        .sw(sw),
        .btn_mode(btn_mode),
        .led(led),
        .seg0(seg0),
        .seg1(seg1),
        .dig_sel(dig_sel)
    );

    // 100 MHz clock
    initial clk_100m = 1'b0;
    always #5 clk_100m = ~clk_100m;

    // Stimulus
    initial begin
        sw       = 8'h3C;
        btn_mode = 1'b1; // active-low button not pressed

        // Run long enough to pass internal power-on reset and execute several loops.
        #20000;
        $display("[TB] Timeout reached.");
        $finish;
    end

    // Optional waveform dump (works in simulators that support VCD dump)
    initial begin
        $dumpfile("tb_CPU_Top_load_stall.vcd");
        $dumpvars(0, tb_CPU_Top_load_stall);
    end

    integer err_count;
    integer stall_count;
    integer resume_count;
    integer normal_advance_count;
    integer ram_load_issue_count;

    reg [7:0] prev_pc;
    reg       prev_rst;
    reg       prev_mem_wait;
    reg       prev_mem_read;
    reg       had_valid_prev;

    initial begin
        err_count             = 0;
        stall_count           = 0;
        resume_count          = 0;
        normal_advance_count  = 0;
        ram_load_issue_count  = 0;
        prev_pc               = 8'h00;
        prev_rst              = 1'b1;
        prev_mem_wait         = 1'b0;
        prev_mem_read         = 1'b0;
        had_valid_prev        = 1'b0;
    end

    always @(posedge clk_100m) begin
        if (dut.rst) begin
            had_valid_prev <= 1'b0;
        end else begin
            if (!had_valid_prev) begin
                had_valid_prev <= 1'b1;
            end else begin
                // 1) RAM-load issue should enter wait state in next cycle
                if (prev_mem_read && !dut.mem_wait) begin
                    err_count = err_count + 1;
                    $display("[TB][ERR] mem_read did not enter mem_wait. t=%0t pc(prev)=0x%02h pc(now)=0x%02h",
                             $time, prev_pc, dut.rom_addr);
                end

                // 2) mem_wait should last exactly one cycle
                if (prev_mem_wait && dut.mem_wait) begin
                    err_count = err_count + 1;
                    $display("[TB][ERR] mem_wait lasted >1 cycle. t=%0t pc=0x%02h", $time, dut.rom_addr);
                end

                // 3) During mem_wait cycle, PC must hold
                if (prev_mem_wait) begin
                    if (dut.rom_addr !== prev_pc) begin
                        err_count = err_count + 1;
                        $display("[TB][ERR] PC changed during stall. t=%0t prev_pc=0x%02h now_pc=0x%02h",
                                 $time, prev_pc, dut.rom_addr);
                    end else begin
                        stall_count = stall_count + 1;
                    end
                end

                // 4) After a stall cycle ends, PC should resume changing next cycle
                if (prev_mem_wait && !dut.mem_wait) begin
                    // resume check deferred to next cycle by observing non-equal in normal flow below
                    resume_count = resume_count + 1;
                end

                // 5) Non-stall cycles should show normal forward activity over time
                if (!prev_mem_wait && !dut.mem_wait) begin
                    if (dut.rom_addr !== prev_pc) begin
                        normal_advance_count = normal_advance_count + 1;
                    end
                end
            end

            if (dut.mem_read) begin
                ram_load_issue_count = ram_load_issue_count + 1;
            end

            prev_pc             <= dut.rom_addr;
            prev_rst            <= dut.rst;
            prev_mem_wait       <= dut.mem_wait;
            prev_mem_read       <= dut.mem_read;

            // End condition: observed enough RAM-load stalls and no errors.
            if (ram_load_issue_count >= 4) begin
                if (err_count == 0 && stall_count >= 2 && normal_advance_count >= 10) begin
                    $display("[TB][PASS] load interlock verified.");
                    $display("[TB][PASS] ram_load_issue_count=%0d stall_count=%0d resume_count=%0d normal_advance_count=%0d",
                             ram_load_issue_count, stall_count, resume_count, normal_advance_count);
                    $finish;
                end else if (err_count > 0) begin
                    $display("[TB][FAIL] err_count=%0d", err_count);
                    $finish;
                end
            end
        end
    end

endmodule

`default_nettype wire
