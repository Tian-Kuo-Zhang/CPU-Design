# 04 Integration Test - Basic Datapath

## 目标

验证从取指到写回的基础链路：

- `mov imm` -> `addi/subi` -> R-type 运算
- 控制单元对 ALU/写回路径的切换

## 测试程序（16-bit HEX）

按顺序写入 IM ROM：

1. `1405`  ; mov R1, #5
2. `1803`  ; mov R2, #3
3. `4602`  ; addi R1, R2, #2   -> R1=5
4. `5501`  ; subi R1, R1, #1   -> R1=4
5. `0651`  ; add  R1, R1, R2   -> R1=7
6. `0A43`  ; and  R2, R2, R1   -> R2=3
7. `0F04`  ; or   R3, R3, R0   -> R3 保持 0（初值为 0）

编码说明（核对用）：

- I-type: `[opcode(4)][rd(2)][rs(2)][imm8]`
- R-type: `[0000][rd][rs][rt][funct6]`

## 预期结果

- `R1 = 16'h0007`
- `R2 = 16'h0003`
- `R3 = 16'h0000`

## 能抓到的 bug

- OC 对 R-type funct 映射错误。
- ALUSrc 选择错误（立即数/寄存器源混淆）。
- 写回地址选择错误（`rd` 线网错接）。
