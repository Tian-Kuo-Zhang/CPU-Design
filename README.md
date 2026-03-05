# CPU-Design


| Opcode (4bit) | Rd (2bit) | Rs (2bit) | Imme (8bit) | Assembly       | Function Description                     |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 0000          | 01        | xx        | 00000010    | mov r1 #02     | R1 <= 2                                  |
| 0001          | 10        | 01        | xxxxxxxx    | mov R2 R1      | R2 <= (R1)                               |
| 0010          | 01        | xx        | 00001000    | add r1 #08     | R1 <= (R1) + 8                           |
| 0011          | 01        | 10        | xxxxxxxx    | add R1 R2      | R1 <= (R1) + (R2)                        |
| 0101          | 01        | 10        | xxxxxxxx    | sub R1 R2      | R1 <= (R1) - (R2)                        |
| 0111          | 01        | 10        | xxxxxxxx    | and R1 R2      | R1 <= (R1) bit_and (R2)                  |
| 1001          | 01        | 10        | xxxxxxxx    | or R1 R2       | R1 <= (R1) bit_or (R2)                   |
| 1010          | xx        | xx        | 00000001    | jump #01       | PC <= 1                                  |
| 1100 | 01 | xx | 00001111| load R1 #15| R1 <= RAM[15] (Read from RAM to R1)  |
| 1011 | 01 | xx | 00001111| store R1 #15| RAM[15] <= R1 (Write R1 to RAM)      |
