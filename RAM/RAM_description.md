# RAM Module Interface Specification

## 1. Overview
The `RAM` module is a **Synchronous Write, Asynchronous Read** memory block. It provides a storage capacity of 256 words, each 16 bits wide. It is designed to interface with a CPU or a system bus where data storage is synchronized to a clock edge, but data retrieval is needed immediately upon address assertion.

---

## 2. Signal Descriptions

| Signal Name     | Direction | Width | Description                                                                                                       |
| :-------------- | :-------: | :---: | :---------------------------------------------------------------------------------------------------------------- |
| `clk`           | Input     | 1     | **System Clock**: Driving edge for memory write operations (Active on Rising Edge).                               |
| `ram_addr_out`  | Input     | 16    | **Address Bus**: 16-bit input. Internal mapping uses only the lower 8 bits `[7:0]` to address 256 locations.       |
| `ram_wdata_out` | Input     | 16    | **Write Data**: The 16-bit data to be stored in the RAM during a write cycle.                                     |
| `MemWrite`      | Input     | 1     | **Write Enable**: When HIGH (1'b1), data on `ram_wdata_out` is saved to memory at the next `clk` rising edge.     |
| `MemRead`       | Input     | 1     | **Read Enable**: When HIGH (1'b1), memory content is output to `ram_rdata_in`. When LOW, output is forced to 0.   |
| `ram_rdata_in`  | Output    | 16    | **Read Data**: The 16-bit data retrieved from memory, sent back to the CPU or Bus.                                |

---

## 3. Functional Behavior

### 3.1 Write Cycle (Synchronous)
Writing to the memory is synchronized to the positive edge of the clock. 
* **Condition**: `MemWrite` must be asserted (1'b1) before or at the rising edge of `clk`.
* **Action**: `data_mem[addr[7:0]] <= ram_wdata_out;`
* **Latency**: The data is committed to the internal array at the clock edge.

### 3.2 Read Cycle (Asynchronous)
Reading is implemented as combinational logic. It does not require a clock edge.
* **Condition**: `MemRead` must be asserted (1'b1).
* **Action**: `ram_rdata_in = data_mem[ram_addr_out[7:0]];`
* **Bus Protection**: If `MemRead` is de-asserted (1'b0), the output `ram_rdata_in` is driven to `16'h0000`. This prevents "bus noise" or stale data from propagating when the memory is not being accessed.

---

## 4. Addressing Logic
The module uses an internal memory array `data_mem [0:255]`. 
* Although the input `ram_addr_out` is 16-bit, the module performs **Address Truncation**.
* Effective Address = `ram_addr_out[7:0]`.
* *Note: Ensure the system designer is aware that addresses `0x0001` and `0x0101` will access the same physical memory cell.*

---

## 5. Timing Characteristics

| Parameter           | Requirement | Description                                                                 |
| :------------------ | :---------- | :-------------------------------------------------------------------------- |
| **Write Setup** | $t_{su}$    | Address and Write Data must be stable before `clk` rising edge.             |
| **Read Access Time**| $t_{acc}$   | Combinational delay from `ram_addr_out` or `MemRead` change to valid output.|
| **Clock Frequency** | $f_{max}$   | Dependent on target FPGA/ASIC technology (standard 100MHz+ supported).      |

---

## 6. Example Instantiation (Verilog)

```verilog
RAM u_data_memory (
    .clk            (sys_clk),          // System clock
    .ram_addr_out   (cpu_addr),         // 16-bit address from CPU
    .ram_wdata_out  (cpu_write_data),   // 16-bit data from CPU
    .MemWrite       (control_mem_we),   // Write enable signal
    .MemRead        (control_mem_re),   // Read enable signal
    .ram_rdata_in   (mem_read_data)     // 16-bit data to CPU
);
