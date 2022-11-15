li x1, 0x48 ;H
li x2, 0x65 ;e
li x3, 0x6C ;l
li x4, 0x6C ;l
li x5, 0x6F ;o
li x21, 0x32000
li x6, 0x32004 ;tx_en
li x7, 0x32005 ;tx_byte
li x8, 0x32006 ;tx_ready
li x9, 1 ;enable flag
li x10, 0x200 ;char *hello_str = "Hello"
sb x9, 0(x21)
sb x1, 0(x10)
sb x2, 1(x10)
sb x3, 2(x10)
sb x4, 3(x10)
sb x5, 4(x10)
sb x0, 5(x10) ;null termination
lbu x20, 0(x10) ;load current char
lbu x11, 0(x8) ;wait until ready is off again
bne x11, x0, -4
sb x20, 0(x7)
sb x9, 0(x6) ;enable transmission
lbu x11, 0(x8) ;are we ready?
beq x11, x0, -4
addi x10, x10, 1
beq x20, x0, 8
jal x0, -36
jal x0, 0

