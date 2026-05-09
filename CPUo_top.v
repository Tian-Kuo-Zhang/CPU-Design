module CPUo_top (
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

    wire        Branch_flag;
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire [3:0]  ALUOp;
    wire [1:0]  PCSrc;
    wire [1:0]  real_raddr2;

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
    // Original comparison version:
    // - no BRAM attribute
    // - no interlock / no extra wait cycle
    // - asynchronous RAM read
    // ============================================================
    reg [15:0] data_ram [0:255];
    reg [7:0]  led_reg = 8'h00;

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
        end
    end

    always @(*) begin
        if (ram_addr == IO_SW_ADDR) begin
            ram_rdata = {8'h00, sw};
        end else if (ram_addr == IO_LED_ADDR) begin
            ram_rdata = {8'h00, led_reg};
        end else if (ram_addr == IO_MODE_ADDR) begin
            ram_rdata = {15'h0000, mode_reg};
        end else begin
            ram_rdata = data_ram[ram_addr[7:0]];
        end
    end

    // ============================================================
    // CPU datapath
    // ============================================================
    Fetch fetch_unit (
        .clk(clk_100m),
        .rst(rst),
        .stall(1'b0),
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
        .RegWrite(RegWrite),
        .raddr1(instr[9:8]),
        .raddr2(real_raddr2),
        .waddr(instr[11:10]),
        .wdata(write_back_data),
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
    assign ram_addr  = alu_result;
    assign ram_wdata = rdata2;

    // ============================================================
    // Seven-segment mode display
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

    wire [7:0] seg0_raw = mode_reg ? CHAR_E : CHAR_n;
    wire [7:0] seg1_raw = mode_reg ? CHAR_d : CHAR_E;
    wire [7:0] dig_raw  = 8'b00110000;

    assign seg0 = seg_apply_polarity(seg0_raw);
    assign seg1 = seg_apply_polarity(seg1_raw);
    assign dig_sel = dig_apply_polarity(dig_raw);

endmodule
