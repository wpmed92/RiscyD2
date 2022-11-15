li x1, 0
li x2, 0x32000 ;base led pointer
li x3, 0x989680
addi x3, x3, -1
bne x3, x0, -4
xori x1, x1, 1
sb x1, 0(x2) ;led[0]
sb x1, 1(x2) ;led[2]
sb x1, 2(x2) ;led[2]
sb x1, 3(x2) ;led[2]
jal x0, -36
