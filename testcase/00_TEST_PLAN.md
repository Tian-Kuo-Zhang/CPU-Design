# Testcase 总览（单元 / 集成 / 系统 / 回归）

## 指令镜像（`sim_mem/*.mem`）

| 文件 | 用途 |
|------|------|
| `sanity.mem` | 冒烟（原 COE） |
| `integration_basic.mem` | 集成：mov / addi / subi / add / and / or |
| `integration_memory.mem` | 集成：load（TB 预填 RAM[16]=CAFE） |
| `system_control.mem` | 系统：beq / bne / jump + R0/溢出片段 |
| `regression_algorithm.mem` | 回归：`(0x2A+0x15)&0x0F` |
| `regression_boundary.mem` | 回归：短边界（R0、255+2） |

路径宏：**`paths.vh`**（运行前按本机修改绝对路径）。

## Testbench 一览

### 单元

| 文件 | 被测模块 |
|------|-----------|
| `tb_unit_decoder.v` | `Decoder` |
| `tb_unit_alu.v` | `ALU` |
| `tb_unit_signext.v` | `SignExtender` |
| `tb_fetch_branch_offset.v` | `FetchUnit` |
| `tb_rf_sync_write_async_read.v` | `RF` |
| `tb_ram_sync_write_async_read.v` | `RAM` |

### 集成

| 文件 | ROM |
|------|-----|
| `tb_integration_datapath.v` | `integration_basic.mem` |
| `tb_integration_memory.v` | `integration_memory.mem` |

### 系统

| 文件 | ROM |
|------|-----|
| `tb_system_controlflow.v` | `system_control.mem` |

### 回归

| 文件 | ROM |
|------|-----|
| `tb_regression_algorithm.v` | `regression_algorithm.mem` |
| `tb_regression_boundary.v` | `regression_boundary.mem` |
| `tb_regression_suite.v` | 顺序装载以上多份 mem |

详细步骤见 **`HOW_TO_RUN.md`**。
