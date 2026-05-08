# 01 Unit Test - Fetch/PC

## 目标

验证 `FetchUnit` 的 3 条路径是否正确：

- 顺序执行：`PC + 1`
- 分支执行：`PC + imm`
- 跳转执行：`PC = imm`

## 操作步骤

直接使用并扩展现有 `FetchUnit/tb_FetchUnit.v`：

1. reset 后保持 `pc_sel=00` 跑 4 个周期。
2. 设置 `pc_sel=01, imm_8=8'd5`，跑 1 周期后恢复 `pc_sel=00`。
3. 设置 `pc_sel=10, imm_8=8'd50`，跑 1 周期后恢复 `pc_sel=00`。

## 预期结果

- 顺序段：PC 单调 +1。
- 分支段：PC 从当前值增加 5。
- 跳转段：PC 直接变为 50。

## 能抓到的 bug

- `pc_sel` 译码错误（分支和跳转走错路径）。
- PC 更新时序错误（上升沿前后值不对）。
- 分支路径误连成 `PC+1+imm` 或其他形式。
