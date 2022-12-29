li x1, 0x32000 ;led base
li x2, 10
li x3, 2
mul x4, x2, x3
andi x5, x4, 1
sb x5, 0(x1)
srli x5, x4, 1
andi x5, x5, 1
sb x5, 1(x1)
srli x5, x4, 2
andi x5, x5, 1
sb x5, 2(x1)
srli x5, x4, 3
andi x5, x5, 1
sb x5, 3(x1)
jal x0, 0
