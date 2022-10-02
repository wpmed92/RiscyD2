;load an exe from UART
li x1, 0x1004
li x2, 0x1005
li x3, 0x200
mv x6, x3
li x9, 0
li x10, 4
li x11, 0
lbu x4, 0(x2)
beq x4, x0, -4
bne x9, x10, 12
lw x11, 0(x3)
addi x11, x11, 4
lbu x5, 0(x1)
add x6, x3, x9
sb x5, 0(x6)
addi x9, x9, 1
beq x11, x9, 16
lbu x4, 0(x2)
bne x4, x0, -4
jal x0, -48
jalr x0, 4(x3)
