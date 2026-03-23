`timescale 1ns / 1ps

module Top(
    input  wire clk,
    input  wire reset,
    
    // --- 调试探针 (Debug Probes) ---
    // 把核心信号引到外部，方便在仿真波形图里直接观察
    output wire [7:0]  probe_PC,
    output wire [15:0] probe_Instruction,
    output wire [15:0] probe_ALU_Result
);

    // ==========================================
    // 1. 内部线网声明 (Wire Declarations)
    // ==========================================
    
    // 取指与指令总线
    wire [7:0]  pc_to_rom;
    wire [15:0] rom_to_ir;
    wire [15:0] instr_bus;
    
    // IR 解析出的各个字段
    wire [3:0]  opcode_bus;
    wire [1:0]  rd_bus, rs_bus, rt_bus;
    wire [7:0]  imm_bus;
    wire [5:0]  funct_bus;
    wire [15:0] decode_to_oc; 

    // Datapath 数据总线
    wire [15:0] rdata1, rdata2;
    wire [15:0] extended_imm;
    wire [15:0] alu_b_in;
    wire [15:0] alu_result;
    wire [15:0] ram_rdata;
    wire [15:0] writeback_data;

    // CU (OC) 发出的控制信号
    wire [1:0] pc_sel;
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
    wire [1:0] alu_op; 
    wire branch_flag;  

    // 探针连线
    assign probe_PC          = pc_to_rom;
    assign probe_Instruction = instr_bus;
    assign probe_ALU_Result  = alu_result;

    // ==========================================
    // 2. 模块实例化 (搭积木)
    // ==========================================

    // [1] 取指单元
    FetchUnit U_FetchUnit (
        .clk    (clk), 
        .reset  (reset), 
        .pc_sel (pc_sel),   // 连到 OC 的 PCSrc
        .imm_8  (imm_bus), 
        .PC_out (pc_to_rom)
    );

    // [2] 指令存储器 (IP核)
    IM_ROM U_ROM (
        .a      (pc_to_rom), 
        .spo    (rom_to_ir)
    );

    // [3] 指令寄存器
    IR U_IR (
        .clk            (clk), 
        .reset          (reset), 
        .instruction_in (rom_to_ir),
        .instr          (instr_bus), 
        .opcode         (opcode_bus), 
        .rd             (rd_bus),
        .rs             (rs_bus), 
        .rt             (rt_bus), 
        .imm            (imm_bus), 
        .funct          (funct_bus)
    );

    // [4] 译码器
    Decoder U_Decoder (
        .Opcode     (opcode_bus), 
        .Decode_Out (decode_to_oc)
    );

    // [5] 寄存器堆
    RF U_RF (
        .clk        (clk), 
        .RegWrite   (RegWrite),
        .raddr1     (rs_bus), 
        .raddr2     (rt_bus), 
        .waddr      (rd_bus),
        .wdata      (writeback_data),
        .rdata1     (rdata1), 
        .rdata2     (rdata2)
    );

    // [6] 符号扩展器
    SignExtender U_SignExtender (
        .Imm_In     (imm_bus), 
        .Imm_Out    (extended_imm)
    );

    // [7] ALU 来源选择器
    ALUSrc_MUX U_ALUSrc_MUX (
        .ALU_Src    (ALUSrc), 
        .Imm_In     (extended_imm),
        .Reg_In     (rdata2), 
        .Src_Out    (alu_b_in)
    );

    // [8] 算术逻辑单元
    ALU U_ALU (
        .ALU_Op      (alu_op), 
        .ALU_A       (rdata1), 
        .ALU_B       (alu_b_in),
        .ALU_Out     (alu_result), 
        .Branch_Flag (branch_flag)
    );

    // [9] 数据存储器
    // 🚨 提醒：必须确保 RAM.v 里的读取逻辑已经改成了异步读 (always @*)
    RAM U_RAM (
        .clk           (clk), 
        .ram_addr_out  (alu_result), 
        .ram_wdata_out (rdata2),
        .MemWrite      (MemWrite), 
        .MemRead       (MemRead), 
        .ram_rdata_in  (ram_rdata)
    );

    // [10] 写回选择器 (一个简单的 assign 代替 MUX)
    assign writeback_data = (MemtoReg) ? ram_rdata : alu_result;

    // [11] 操作控制器 (大脑)
    OC U_OC (
        .Decode_Out  (decode_to_oc), 
        .Funct       (funct_bus), 
        .Branch_flag (branch_flag),
        .RegWrite    (RegWrite), 
        .ALUSrc      (ALUSrc), 
        .MemtoReg    (MemtoReg),
        .PCSrc       (pc_sel), 
        .Op_in       (alu_op), 
        .MemRead     (MemRead), 
        .MemWrite    (MemWrite)
    );

endmodule