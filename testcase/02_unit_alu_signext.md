# 02 Unit Test - ALU and SignExt

## 目标

验证 ALU 四类运算与立即数符号扩展：

- `ADD/SUB/AND/OR`
- 8 位立即数符号扩展到 16 位

## 最小输入向量（模块级）

1. `ALU_Op=00, A=16'h0003, B=16'h0004`，期望 `0007`
2. `ALU_Op=01, A=16'h0003, B=16'h0005`，期望 `FFFE`
3. `ALU_Op=10, A=16'h00F0, B=16'h0F0F`，期望 `0000`
4. `ALU_Op=11, A=16'h00F0, B=16'h0F0F`，期望 `0FFF`
5. SignExt: `Imm_In=8'h7F`，期望 `007F`
6. SignExt: `Imm_In=8'h80`，期望 `FF80`
7. SignExt: `Imm_In=8'hF9`，期望 `FFF9`

## 预期结果

- ALU 输出与上面数值一致。
- `Branch_Flag` 只在 ALU 输出为 0 时拉高。
- SignExt 对负数立即数应正确补 1。

## 能抓到的 bug

- `subi/addi` 在负数边界计算错误。
- `Branch_Flag` 判定时机/条件错误。
- 立即数被零扩展（常见错误）而非符号扩展。
