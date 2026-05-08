# 只跑「系统测试 + 回归/边界」仿真

工程已内置 **`tb_system_regression.v`** + **`IM_ROM.v`** 中的配套指令序列，无需再手动跑 `testcase` 里那些单元 TB。

## Vivado 操作

1. 打开 `final_CPU.xpr`。
2. **Flow Navigator → Simulation Sources**，展开 `sim_1`。
3. 右键 **`tb_system_regression`** → **Set as Top**。
4. **Run Simulation → Run Behavioral Simulation**。
5. 结束时应看到 Tcl/console 输出：`PASS: system + regression checks OK.`  
   若出现 `FAIL:`，根据提示对照波形。

（若要恢复冒烟仿真，把顶层改回 **`tb_Top`**。）

## 波形建议（汇报用）

拖到波形窗口的信号示例：

| 信号 | 含义 |
|------|------|
| `clk` | 对齐每一拍（单周期一条指令） |
| `reset` | 复位释放后开始取指 |
| `probe_PC` | 当前取指地址 |
| `probe_Instruction` | IR 输出的指令字 |
| `probe_ALU_Result` | ALU 结果（分支时在判零） |

展开 **`UUT` → `U_RF`**，若工具允许观察内部数组，可看 **`registers[0]`～`registers[3]`** 终值是否与 TB 预期一致。

## 当前 ROM 程序覆盖了什么

- **系统**：`beq` 跳过陷阱、`bne` 跳过陷阱、`jump` 到固定地址。
- **回归/边界**：`mov R0,#255` 尝试写 R0（应仍恒 0）；`255+2` 的 **16 位加法回绕**（`R2=16'h0101`）。

更细的 RAM 别名 / PC=0xFE / 随机回归需继续在 **`IM_ROM.v`** 里加长程序或另写 TB（见 `07_regression_boundary_and_bughunt.md`）。
