# Fetch Unit Module Interface Specification (MIS)

**Module Name:** `FetchUnit`  

**Description:**  
The Fetch Unit is the instruction address generation module of the CPU. It produces the next instruction address (PC, Program Counter) and selects the correct address based on sequential execution, branch, or jump instructions. The module outputs the PC to the instruction memory (ROM/IM) for decoding and execution in later stages.

---

## 1. Ports

| Port Name | Direction | Width | Description |
|-----------|-----------|-------|-------------|
| `clk`     | input     | 1     | Clock signal (rising edge) |
| `reset`   | input     | 1     | Asynchronous reset, active high, resets PC to 0 |
| `pc_sel`  | input     | 2     | MUX control signal:<br>00 = sequential execution (PC+1)<br>01 = branch execution (PC + imm_8)<br>10 = absolute jump (imm_8) |
| `imm_8`   | input     | 8     | Immediate value from branch/jump instructions, sign-extended to 8 bits, used to compute the next instruction address |
| `PC_out`  | output    | 8     | Current program counter value, output to ROM (IM) as instruction fetch address |

---

## 2. Internal Signals

| Signal Name | Width | Description |
|-------------|-------|-------------|
| `PC_plus_1` | 8     | Result of sequential execution path (PC+1) |
| `PC_branch` | 8     | Result of branch path (PC + imm_8) |
| `PC_Next`   | 8     | MUX output, determines the next PC value |

---

## 3. Functional Description

1. **Sequential Execution (PC+1):**  
   By default, after executing an instruction, PC increments by 1 to point to the next sequential instruction.

2. **Branch Execution (PC + imm_8):**  
   For conditional branch instructions (e.g., `beq`, `bne`) when the condition is met, the target address is computed using the immediate offset.

3. **Jump Execution (imm_8):**  
   For unconditional jump instructions (e.g., `jump`), PC is updated directly to the immediate value (absolute address).

4. **MUX Control Logic (`pc_sel`):**  
   Determines the source of PC based on `pc_sel`:
   - `00` → Sequential path (`PC+1`)  
   - `01` → Branch path (`PC + imm_8`)  
   - `10` → Absolute jump (`imm_8`)  

5. **PC Register Update:**  
   PC is updated on the rising edge of `clk`. When `reset` is high, PC is cleared to zero.

---

## 4. Notes / Remarks

- `imm_8` is assumed to be sign-extended, supporting both positive and negative offsets.  
- PC output width is 8 bits, matching the ROM address bus width.  
- If `pc_sel` receives an invalid value, the default behavior is sequential increment.  
- The module can be directly integrated into the CPU datapath, interacting with the Decoder, ALU, and RAM modules.
