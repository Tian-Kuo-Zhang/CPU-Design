# RAM Module Interface Specification (MIS)

**Module Name:** `RAM`  

**Description:**  
The RAM module serves as the data memory (DM) for the CPU. It supports synchronous read and write operations controlled by `MemRead` and `MemWrite` signals. Data is stored and retrieved on the rising edge of the clock. The module provides 16-bit wide data words and an 8-bit addressable memory space (256 locations).

---

## 1. Ports

| Port Name         | Direction | Width | Description |
|------------------|-----------|-------|-------------|
| `ram_addr_out`    | input     | 16    | Address input from CPU. Only lower 8 bits are used to access memory (0–255). |
| `ram_wdata_out`   | input     | 16    | Data to be written to memory when `MemWrite` is high. |
| `MemWrite`        | input     | 1     | Memory write enable. When high, data at `ram_wdata_out` is stored at `ram_addr_out[7:0]`. |
| `MemRead`         | input     | 1     | Memory read enable. When high, data at `ram_addr_out[7:0]` is output to `ram_rdata_in`. |
| `clk`             | input     | 1     | Clock signal. Memory operations are synchronous to rising edge. |
| `ram_rdata_in`    | output    | 16    | Data output to CPU. Provides the value stored at the selected address during read. |

---

## 2. Internal Signals

| Signal Name      | Width | Description |
|-----------------|-------|-------------|
| `data_mem`       | 16    | 16-bit wide memory array, 256 entries (addressed 0–255) |

---

## 3. Functional Description

1. **Synchronous Write:**  
   On the rising edge of `clk`, if `MemWrite` is high, the value on `ram_wdata_out` is written to `data_mem[ram_addr_out[7:0]]`.

2. **Synchronous Read:**  
   On the rising edge of `clk`, if `MemRead` is high, the data stored at `data_mem[ram_addr_out[7:0]]` is output to `ram_rdata_in`. If `MemRead` is low, `ram_rdata_in` outputs 0 to prevent bus contention.

3. **Memory Size and Addressing:**  
   The module provides 256 memory locations (8-bit addressing) with 16-bit width per location. Only `ram_addr_out[7:0]` is used for indexing; higher bits are ignored.

4. **Clock Synchronization:**  
   All memory operations are synchronous to the rising edge of `clk`.

---

## 4. Notes / Remarks

- Both read and write operations are synchronous; no asynchronous memory access is supported.  
- Unused memory locations are initialized to unknown (can be optionally initialized to 0 for simulation).  
- Designed to interface directly with the CPU datapath, including Load/Store instructions.  
- Writing and reading the same address in the same clock cycle will result in the read returning the new value if `MemWrite` and `MemRead` are both high (behavior may be tool-dependent).  
