addi x2, x0, 0
lui x1, 0x6AE
addi x1, x1, 0xFC0
addi x1, x1, -1
bne x1, x0, -4
xori x2, x2, 1
jal x0, -20
