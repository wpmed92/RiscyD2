li x1, 1
li x2, 0x32001 ;base led pointer
sb x1, 0(x2) ;led[0]
jal x0, -4
