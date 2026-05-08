# Testcase 四类测试 — 如何运行

## 1. 你需要包含的 RTL（同一仿真库）

将下列文件加入 Vivado **Design / Simulation Sources**（或与 iverilog 一起编译）：

| 文件 |
|------|
| `Top.v`（工程根目录） |
| `IM_ROM.v` |
| `FetchUnit/FetchUnit.v` |
| `CU/IR.v`、`CU/decoder.v`、`CU/OC.v` |
| `RF_module/RF_module.v` |
| `Calculation_modules/Source/ALU.v`、`ALUSrc_MUX.v`、`sign_extender.v` |
| `RAM/RAM.v` |

## 2. `paths.vh`（必改路径）

打开 **`testcase/paths.vh`**，把 `d:/PC_design/CPU-Design-main` 换成你的工程根路径（**正斜杠**），保证 `$readmemh` 能找到 **`testcase/sim_mem/*.mem`**。

Vivado：**Simulation Sources** 里把 `testcase` 目录加到 **Verilog Include Paths**（或把 `paths.vh` 所在目录设为 include search path）。

## 3. 四类测试与顶层模块

| 层级 | 仿真顶层 | 说明 |
|------|-----------|------|
| **单元** | `tb_unit_decoder`、`tb_unit_alu`、`tb_unit_signext` | 仅译码 / ALU / 符号扩展 |
| | `tb_fetch_branch_offset`、`tb_rf_sync_write_async_read`、`tb_ram_sync_write_async_read` | Fetch / RF / RAM（例化路径需含对应 `.v`） |
| **集成** | `tb_integration_datapath`、`tb_integration_memory` | 整机 + ROM mem |
| **系统** | `tb_system_controlflow` | 控制流 + 部分边界 |
| **回归** | `tb_regression_algorithm`、`tb_regression_boundary`、`tb_regression_suite` | 算法短程序；边界短程序；**套件一次性串行全跑** |

在 Vivado 中对准顶层：**右键 TB → Set as Top → Run Behavioral Simulation**。

## 4. 指令存储

各 TB 在 `#1` 后通过 **`$readmemh(..., UUT.U_ROM.mem)`** 装载 **`sim_mem/*.mem`**；默认 `IM_ROM` 内仍有一份 COE 冒烟数据，会被覆盖。

## 5. RF 复位

`RF` 已增加 **`reset` 同步清零**，便于 **`tb_regression_suite`** 多段程序串跑。`Top` 已将 **`reset`** 接到 **`RF`**。
