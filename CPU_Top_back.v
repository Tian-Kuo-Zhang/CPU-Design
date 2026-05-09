module CPU_Top (
    input  wire        clk_100m,
    input  wire [7:0]  sw,
    input  wire        btn_mode,
    output wire [7:0]  led,
    output wire [7:0]  seg0,
    output wire [7:0]  seg1,
    output wire [7:0]  dig_sel
);

    // ============================================================
    // Configuration
    // ============================================================
    localparam BTN_ACTIVE_LOW   = 1'b1;
    localparam SEG_ACTIVE_LOW   = 1'b0;
    localparam DIG_ACTIVE_LOW   = 1'b0;
    localparam [19:0] DB_MAX    = 20'd1_000_000; // ~10ms @100MHz

    // Memory-mapped IO addresses
    localparam [15:0] IO_SW_ADDR   = 16'h0010;
    localparam [15:0] IO_LED_ADDR  = 16'h0011;
    localparam [15:0] IO_MODE_ADDR = 16'h0012;

    // ============================================================
    // CPU core internal buses
    // ============================================================
    wire [7:0]  rom_addr;
    reg  [15:0] rom_data;

    wire [15:0] ram_addr;
    wire [15:0] ram_wdata;
    reg  [15:0] ram_rdata;
    wire        MemRead;
    wire        MemWrite;

    wire [15:0] instr;
    wire [15:0] rdata1;
    wire [15:0] rdata2;
    wire [15:0] imm_ext;
    wire [15:0] alu_b;
    wire [15:0] alu_result;
    wire [15:0] write_back_data;
    wire [15:0] rf_wdata;
    wire [1:0]  rf_waddr;
    wire        rf_regwrite;

    wire        Branch_flag;
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire [3:0]  ALUOp;
    wire [1:0]  PCSrc;
    wire [1:0]  real_raddr2;
    wire        is_ram_addr;
    wire        mem_read;
    wire        PC_Stall;

    reg         mem_wait = 1'b0;
    reg [1:0]   load_waddr = 2'b00;

    // ============================================================
    // Power-on reset generator
    // ============================================================
    reg [7:0] rst_cnt = 8'd0;
    reg       rst = 1'b1;

    always @(posedge clk_100m) begin
        if (rst) begin
            rst_cnt <= rst_cnt + 8'd1;
            if (&rst_cnt) begin
                rst <= 1'b0;
            end
        end
    end

    // ============================================================
    // Program ROM
    // ============================================================
    reg [15:0] program_rom [0:255];

    initial begin
        $readmemh("program_crypto.mem", program_rom);
    end

    always @(*) begin
        rom_data = program_rom[rom_addr];
    end

    // ============================================================
    // Button debounce + toggle mode register
    // mode_reg = 0: Encrypt, 1: Decrypt
    // ============================================================
    reg [1:0] btn_sync = 2'b11;
    reg       btn_stable = 1'b1;
    reg [19:0] db_cnt = 20'd0;

    wire btn_pressed_level = BTN_ACTIVE_LOW ? ~btn_stable : btn_stable;
    reg  btn_pressed_d = 1'b0;
    wire btn_pressed_pulse = btn_pressed_level & ~btn_pressed_d;

    reg mode_reg = 1'b0;

    always @(posedge clk_100m) begin
        btn_sync <= {btn_sync[0], btn_mode};

        if (btn_sync[1] != btn_stable) begin
            if (db_cnt >= DB_MAX) begin
                btn_stable <= btn_sync[1];
                db_cnt <= 20'd0;
            end else begin
                db_cnt <= db_cnt + 20'd1;
            end
        end else begin
            db_cnt <= 20'd0;
        end

        btn_pressed_d <= btn_pressed_level;

        if (rst) begin
            mode_reg <= 1'b0;
        end else if (btn_pressed_pulse) begin
            mode_reg <= ~mode_reg;
        end
    end

    // ============================================================
    // Data memory + memory-mapped IO
    // ============================================================
    (* ram_style = "block" *) reg [15:0] data_ram [0:255];
    reg [7:0]  led_reg = 8'h00;
    reg [15:0] ram_rdata_mem = 16'h0000;

    // Preload LUT table for load/store-based lookup crypto.
    initial begin
        $readmemh("crypto_lut.mem", data_ram);
    end

    assign led = led_reg;

    always @(posedge clk_100m) begin
        if (MemWrite) begin
            if (ram_addr == IO_LED_ADDR) begin
                led_reg <= ram_wdata[7:0];
            end else if ((ram_addr != IO_SW_ADDR) && (ram_addr != IO_MODE_ADDR)) begin
                data_ram[ram_addr[7:0]] <= ram_wdata;
            end
            // Synchronous RAM read style for BRAM inference
            ram_rdata_mem <= data_ram[ram_addr[7:0]];
        end else begin
            // Synchronous RAM read style for BRAM inference
            ram_rdata_mem <= data_ram[ram_addr[7:0]];
        end
    end

    // IO-mapped reads remain combinational; data RAM reads use registered output.
    always @(*) begin
        if (ram_addr == IO_SW_ADDR) begin
            ram_rdata = {8'h00, sw};
        end else if (ram_addr == IO_LED_ADDR) begin
            ram_rdata = {8'h00, led_reg};
        end else if (ram_addr == IO_MODE_ADDR) begin
            ram_rdata = {15'h0000, mode_reg};
        end else begin
            ram_rdata = ram_rdata_mem;
        end
    end

    // ============================================================
    // CPU datapath
    // ============================================================
    Fetch fetch_unit (
        .clk(clk_100m),
        .rst(rst),
        .stall(PC_Stall),
        .PCSrc(PCSrc),
        .imm_8(instr[7:0]),
        .PC_out(rom_addr)
    );

    assign instr = rom_data;

    Control_Unit cu (
        .Opcode(instr[15:12]),
        .Funct(instr[5:0]),
        .Branch_flag(Branch_flag),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .PCSrc(PCSrc)
    );

    assign real_raddr2 = (instr[15:12] == 4'b0011 ||
                          instr[15:12] == 4'b0111 ||
                          instr[15:12] == 4'b1000) ? instr[11:10] : instr[7:6];

    RF register_file (
        .clk(clk_100m),
        .rst(rst),
        .RegWrite(rf_regwrite),
        .raddr1(instr[9:8]),
        .raddr2(real_raddr2),
        .waddr(rf_waddr),
        .wdata(rf_wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    Sign_Extend se_unit (
        .imm_in(instr[7:0]),
        .imm_out(imm_ext)
    );

    assign alu_b = (ALUSrc) ? imm_ext : rdata2;

    ALU alu_unit (
        .A(rdata1),
        .B(alu_b),
        .ALUOp(ALUOp),
        .ALU_out(alu_result),
        .Branch_flag(Branch_flag)
    );

    assign write_back_data = (MemtoReg) ? ram_rdata : alu_result;
    assign rf_wdata = mem_wait ? ram_rdata_mem : write_back_data;
    assign rf_waddr = mem_wait ? load_waddr : instr[11:10];
    assign rf_regwrite = mem_wait ? 1'b1 : (RegWrite && !mem_read);

    assign ram_addr  = alu_result;
    assign ram_wdata = rdata2;
    assign is_ram_addr = (ram_addr != IO_SW_ADDR) &&
                         (ram_addr != IO_LED_ADDR) &&
                         (ram_addr != IO_MODE_ADDR);
    assign mem_read = MemRead && is_ram_addr && !mem_wait;
    // Stall only in the wait/commit cycle.
    // If we also stall in load issue cycle, PC will be stuck on the same load
    // and the core may repeatedly re-enter wait on RAM loads.
    assign PC_Stall = mem_wait;

    // Hardware interlock for BRAM synchronous read:
    // 1) load from RAM address enters wait state for one cycle
    // 2) during wait cycle PC is stalled
    // 3) wait cycle writes sampled BRAM data back to original destination reg
    always @(posedge clk_100m or posedge rst) begin
        if (rst) begin
            mem_wait <= 1'b0;
            load_waddr <= 2'b00;
        end else if (mem_wait) begin
            mem_wait <= 1'b0;
        end else if (mem_read) begin
            mem_wait <= 1'b1;
            load_waddr <= instr[11:10];
        end
    end

    // ============================================================
    // Seven-segment mode display
    // seg bit order follows XDC wiring:
    // seg[x][0]=A, [1]=B, [2]=C, [3]=D, [4]=E, [5]=F, [6]=G, [7]=DP
    // So binary literals below are written in [7:0]={DP,G,F,E,D,C,B,A}.
    // mode=0 -> "En", mode=1 -> "dE"
    // ============================================================
    function [7:0] seg_apply_polarity;
        input [7:0] raw;
        begin
            seg_apply_polarity = SEG_ACTIVE_LOW ? ~raw : raw;
        end
    endfunction

    function [7:0] dig_apply_polarity;
        input [7:0] raw;
        begin
            dig_apply_polarity = DIG_ACTIVE_LOW ? ~raw : raw;
        end
    endfunction

    localparam [7:0] CHAR_E = 8'b01111001; // A D E F G
    localparam [7:0] CHAR_n = 8'b01010100; // C E G
    localparam [7:0] CHAR_d = 8'b01011110; // B C D E G

    // Board wiring makes the two banks appear in opposite visual order.
    // Swap bank assignment so observed text reads "En" / "dE".
    wire [7:0] seg0_raw = mode_reg ? CHAR_E : CHAR_n;
    wire [7:0] seg1_raw = mode_reg ? CHAR_d : CHAR_E;

    // Enable two adjacent digits on the right-side 4-digit group (BIT5 and BIT6).
    wire [7:0] dig_raw = 8'b00110000;

    assign seg0 = seg_apply_polarity(seg0_raw);
    assign seg1 = seg_apply_polarity(seg1_raw);
    assign dig_sel = dig_apply_polarity(dig_raw);

endmodule
