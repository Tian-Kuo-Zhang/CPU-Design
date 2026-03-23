# Control Unit Module Interface Specification

This document describes the I/O interfaces of key control unit modules in the CPU design.  
These modules are responsible for instruction storage, instruction decoding, and generation of internal control signals for the datapath, register file, ALU, memory, and fetch unit.

- IR (Instruction Register)
- Decoder
- OC (Output Control)

## 1. IR (Instruction Register)

Stores the 16-bit instruction fetched from ROM and provides instruction fields to the control unit and datapath.

| Signal Name | I/O | Width (bits) | Description |
|---|---|---:|---|
| instruction_in | I | 16 | Data path; 16-bit instruction input from ROM |
| instr | O | 16 | Data path; full instruction output bus |
| Opcode | O | 4 | Control path; opcode field output to Decoder / CU |
| Funct | O | 6 | Control path; function field output to OC |

## 2. Decoder

Decodes the 4-bit `Opcode` from the instruction into a 16-bit decoded control signal for the Output Control module.

| Signal Name | I/O | Width (bits) | Description |
|---|---|---:|---|
| Opcode | I | 4 | Control path; opcode input from IR / instruction |
| Decode_Out | O | 16 | Control path; decoded instruction output to OC |

## 3. OC (Output Control)

Generates control signals for the datapath and fetch unit based on the decoded instruction, function field, and branch result.

| Signal Name | I/O | Width (bits) | Description |
|---|---|---:|---|
| Decode_Out | I | 16 | Control path; decoded instruction input from Decoder |
| Funct | I | 6 | Control path; function field input from IR |
| Branch_flag | I | 1 | Control path; branch condition flag from ALU |
| RegWrite | O | 1 | Control path; enables register file write operation |
| ALUSrc | O | 1 | Control path; selects ALU B input source: register or immediate |
| MemtoReg | O | 1 | Control path; selects RF write-back source: ALU result or memory data |
| PCSrc | O | 2 | Control path; selects next PC source: sequential, branch, or jump |
| Op_in | O | 4 | Control path; specifies ALU execution operation |
| MemRead | O | 1 | Control path; enables RAM read operation |
| MemWrite | O | 1 | Control path; enables RAM write operation |
