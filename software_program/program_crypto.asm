; program_crypto.asm (collision-free lookup version)
; Function:
;   mode=0 (En): encryption
;   mode=1 (dE): decryption
;
; Design goals:
; - Guarantee a one-to-one mapping (permutation) over the 8-bit domain,
;   so that no two different plaintext values map to the same ciphertext.
; - Implement the lookup-table path using load/store instructions.
;
; Algorithm definition (effective on the low 8 bits only):
;   Enc(x):
;     x = x + 0x3D
;     x = LUT[x]
;     x = x xor 0x6B
;     x = x + 0x27
;     x = LUT[x]
;
;   Dec(y):
;     y = LUT[y]
;     y = y - 0x27
;     y = y xor 0x6B
;     y = LUT[y]
;     y = y - 0x3D
;
; The LUT satisfies the involution property: LUT[LUT[v]] = v.
; Therefore, the same lookup table can be reused in both the
; encryption path and the inverse steps of the decryption path.
;
; I/O mapping:
;   [0x0010] -> SW[7:0]
;   [0x0011] -> LED[7:0]
;   [0x0012] -> mode(bit0), 0=En, 1=dE
;
; Register usage:
;   R0: constant zero
;   R1: data state
;   R2: mode
;   R3: temporary register for key constants
;
; Address  Machine Code  Instruction
; 0x00 2410  load R1, #0x10         ; R1 <- SW
; 0x01 2812  load R2, #0x12         ; R2 <- mode
; 0x02 7208  beq  R2, R0, #0x08     ; mode==0 -> branch to encryption path (0x0A)
;
; -------- Decryption path --------
; 0x03 2500  load R1, #0x00         ; R1 <- LUT[R1]
; 0x04 5527  subi R1, R1, #0x27
; 0x05 1C6B  mov  R3, #0x6B
; 0x06 05C5  xor  R1, R3
; 0x07 2500  load R1, #0x00         ; R1 <- LUT[R1]
; 0x08 553D  subi R1, R1, #0x3D
; 0x09 6010  jump #0x10
;
; -------- Encryption path --------
; 0x0A 453D  addi R1, R1, #0x3D
; 0x0B 2500  load R1, #0x00         ; R1 <- LUT[R1]
; 0x0C 1C6B  mov  R3, #0x6B
; 0x0D 05C5  xor  R1, R3
; 0x0E 4527  addi R1, R1, #0x27
; 0x0F 2500  load R1, #0x00         ; R1 <- LUT[R1]
;
; -------- Output and loop --------
; 0x10 3411  store R1, #0x11        ; LED <- R1
; 0x11 6000  jump #0x00
