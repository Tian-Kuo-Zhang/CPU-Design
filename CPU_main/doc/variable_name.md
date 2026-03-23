# CPU 团队开发变量统一命名对照表 (Standardized Variable Naming Convention)

## 1. 全局与外部接口信号 (Global & External Pins)
这些是 `CPU_Top` 模块的物理引脚，负责与外部 ROM、RAM 及系统环境交互。

| 变量名 | 位宽 | 方向 | 连接模块 | 功能描述 |
| :--- | :--- | :--- | :--- | :--- |
| **clk** | 1 bit | Input | 全局 | 系统全局时钟。PC、IR、RF 的写操作均在上升沿触发。 |
| **reset** | 1 bit | Input | Fetch | 全局复位信号。高电平时将 PC 清零至 `8'h00`。 |
| **rom_addr_out** | 8 bits | Output | Fetch → ROM | 输出给 ROM 的指令地址。 |
| **instruction_in** | 16 bits | Input | ROM → IR | 从外部 ROM 读取的 16 位机器码。 |
| **ram_addr_out** | 16 bits | Output | ALU → RAM | 输出给 RAM 的 16 位读写地址。 |
| **ram_wdata_out** | 16 bits | Output | RF → RAM | 准备存入 RAM 的数据（源自 `rdata2`）。 |
| **ram_rdata_in** | 16 bits | Input | RAM → MUX | 从 RAM 读取回来的 16 位数据。 |
| **MemRead** | 1 bit | Output | CU → RAM | 内存读使能。仅在 `load` 指令时为 1。 |
| **MemWrite** | 1 bit | Output | CU → RAM | 内存写使能。仅在 `store` 指令时为 1。 |

---

## 2. 指令切割与控制信号 (Instruction & Control Signals)
由控制单元 (CU) 产生的内部信号，指挥全场电路运行。

| 变量名 | 位宽 | 属性 | 来源 → 去向 | 功能描述 |
| :--- | :--- | :--- | :--- | :--- |
| **instr** | 16 bits | Wire | IR → 全局 | 完整的指令总线，用于后续切片（如 `instr[15:12]`）。 |
| **Opcode** | 4 bits | Input | IR → CU | 指令操作码，决定 CU 的核心状态。 |
| **Funct** | 6 bits | Input | IR → CU | R 型指令的功能码。 |
| **RegWrite** | 1 bit | Output | CU → RF | 寄存器堆写使能。为 1 时允许写入 `waddr`。 |
| **ALUSrc** | 1 bit | Output | CU → MUX | ALU B口来源选择。`0`: 选寄存器; `1`: 选立即数。 |
| **MemtoReg** | 1 bit | Output | CU → MUX | 写回来源选择。`0`: 选 ALU 结果; `1`: 选内存数据。 |
| **PCSrc** | 2 bits | Output | CU → Fetch | PC 路径选择。`00`: 顺序; `01`: 分支; `10`: 跳转。 |
| **Op_in** | 4 bits | Output | CU → ALU | 下发给 ALU 的具体执行命令（如加、减等）。 |
| **Branch_flag** | 1 bit | Wire | ALU → CU | 比较结果。相等则为 1，用于判断分支条件。 |

---

## 3. 数据通路核心信号 (Datapath Internal Wires)
在运算单元与寄存器之间流转的数据信号。

| 变量名 | 位宽 | 属性 | 来源/连接 | 功能描述 |
| :--- | :--- | :--- | :--- | :--- |
| **raddr1** | 2 bits | Input | instr[9:8] | 寄存器读地址 1 (Rs)。 |
| **raddr2** | 2 bits | Input | instr[7:6] | 寄存器读地址 2 (Rt)。 |
| **waddr** | 2 bits | Input | instr[11:10] | 寄存器写地址 (Rd)。 |
| **rdata1** | 16 bits | Output | RF → ALU | 读出的寄存器数据 1。 |
| **rdata2** | 16 bits | Output | RF → MUX | 读出的寄存器数据 2。 |
| **wdata_in** | 16 bits | Wire | MUX → RF | 最终写回 RF 的数据总线。 |
| **imm_8** | 8 bits | Input | instr[7:0] | 指令中的 8 位立即数。 |
| **sign_ext_imm** | 16 bits | Output | SE → MUX | 经过符号扩展后的 16 位立即数。 |
| **A_in** | 16 bits | Input | 顶层 A 口 | ALU 的上方输入。 |
| **B_in** | 16 bits | Input | 顶层 B 口 | ALU 的下方输入（MUX 选择后）。 |
| **alu_out** | 16 bits | Output | ALU → 顶层 | ALU 算出的 16 位结果。 |

---

## 4. 取指与寻址信号 (Fetch Unit Internal)
控制程序流向的内部 8 位信号。

| 变量名 | 位宽 | 属性 | 来源 | 功能描述 |
| :--- | :--- | :--- | :--- | :--- |
| **PC_out** | 8 bits | Reg | Fetch 输出 | 当前程序地址。 |
| **PC_plus_1** | 8 bits | Wire | PC + 1 | 顺序执行路径。 |
| **PC_branch** | 8 bits | Wire | PC + imm_8 | 分支执行路径。 |
| **PC_Next** | 8 bits | Reg | MUX 输出 | 最终决定打入 PC 的下一个地址。 |