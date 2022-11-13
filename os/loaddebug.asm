li x1, 0xFF
li x2, 0xFFFF
li x3, 0xFFFFFFFF
li x4, 200
li x11, 0x32007
li x12, 0x32008
li x20, 0x32000
sb x1, 0(x4)
sh x2, 2(x4)
sw x3, 4(x4)
lb x5, 0(x4)
bne x5, x3, 40
lbu x6, 0(x4)
bne x6, x1, 32
lh x7, 2(x4)
bne x7, x3, 24
lhu x8, 2(x4)
bne x8, x2, 16
lw x9, 4(x4)
bne x9, x3, 8
jal x0, 12
sb x4, 0(x20)
sb x4, 1(x20)
lbu x13, 0(x11)
lbu x14, 0(x12)
sb x13, 2(x20)
sb x14, 3(x20)
jal x0, 0
