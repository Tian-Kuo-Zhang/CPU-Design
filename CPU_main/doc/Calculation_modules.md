
# Datapath Module Interface Specification

This document describes the I/O interfaces of key datapath modules:

- ALU
- ALUSrc_MUX
- Sign Extender

---

## 1. ALU

Performs arithmetic and logic operations based on control signal `ALU_Op`.  
Outputs computation result and branch flag (Zero detection).

| Signal Name  | I/O | Width (bits) | Description |
|--------------|-----|--------------|-------------|
| ALU_Op       | I   | 2            | Control signal; determines the operation type of ALU |
| ALU_A        | I   | 16           | Data path; operand A from Register File |
| ALU_B        | I   | 16           | Data path; operand B from MUX (Register or Immediate) |
| ALU_Out      | O   | 16           | Data path; output result of ALU computation |
| Branch_Flag  | O   | 1            | Control flag; 1 if result is zero, otherwise 0 |

---

## 2. ALUSrc_MUX

2-to-1 multiplexer used to select the second operand of the ALU.

| Signal Name | I/O | Width (bits) | Description |
|-------------|-----|--------------|-------------|
| ALU_Src     | I   | 1            | Control signal; selects ALU operand source |
| Imm_In      | I   | 16           | Data path; input from Sign Extender |
| Reg_In      | I   | 16           | Data path; input from Register File |
| Src_Out     | O   | 16           | Data path; selected output to ALU |

---

## 3. Sign Extender

Extends 8-bit immediate value to 16-bit using sign extension.

| Signal Name | I/O | Width (bits) | Description |
|-------------|-----|--------------|-------------|
| Imm_In      | I   | 8            | Data path; immediate input from instruction |
| Imm_Out     | O   | 16           | Data path; sign-extended output |

---
---

## 4. Control Signal Table (ALU + MUX)

This table defines the control signals for ALU operation and operand selection based on instruction opcode.

| Instruction | Opcode | ALU_Src | ALU_Op |
|------------|--------|--------|--------|
| mov imm    | 0001   | 1      | 00     |
| load       | 0010   | 1      | 00     |
| store      | 0011   | 1      | 00     |
| addi       | 0100   | 1      | 00     |
| subi       | 0101   | 1      | 01     |
| mov reg    | 0000   | 0      | 00     |
| add reg    | 0000   | 0      | 00     |
| sub reg    | 0000   | 0      | 01     |
| and reg    | 0000   | 0      | 10     |
| or reg     | 0000   | 0      | 11     |
| jump       | 0110   | X      | XX     |
| beq        | 0111   | 0      | 01     |
| bne        | 1000   | 0      | 01     |

---

### Notes

- `ALU_Src`:
  - `0` → Register input (Reg_In)
  - `1` → Immediate input (Imm_In)

- `ALU_Op`:
  - `00` → ADD
  - `01` → SUB
  - `10` → AND
  - `11` → OR

- `X` / `XX`:
  - Don't care (signal not used)

- For branch instructions (`beq`, `bne`):
  - ALU performs subtraction (`SUB`)
  - Branch decision is made in Control Unit using `Branch_Flag`:
    - `beq`: branch if `Branch_Flag == 1`
    - `bne`: branch if `Branch_Flag == 0`
