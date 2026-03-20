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