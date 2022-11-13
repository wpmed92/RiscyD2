;load an exe from UART
li x1, 0x32007 ;rx_byte
li x2, 0x32008 ;rx_byte_ready
li x12, 0x32000
li x13, 0 ;led select for debug
li x14, 0 ;copy of the current byte being read
li x15, 0 ;bit to write out to led for debugging purposes
li x16, 0 ;led debug counter
li x17, 4 ;we have 4 leds
li x18, 1
li x3, 0x200
mv x6, x3
li x9, 0
li x10, 4
li x11, 0
sb x18, 0(x12)
lbu x4, 0(x2)
sb x18, 1(x12)
beq x4, x0, -8
sb x0, 1(x12)
bne x9, x10, 12
lw x11, 0(x3)
addi x11, x11, 4
lbu x5, 0(x1)
add x6, x3, x9
sb x5, 0(x6)
mv x14, x5
andi x15, x14, 1 ;mask lsb
srli x14, x14, 1
add x13, x12, x16 ;led select
addi x16, x16, 1
sb x15, 0(x13) ;store the lsb 
bne x16, x17, -20
addi x16, x0, 0
addi x13, x0, 0
addi x9, x9, 1
beq x11, x9, 16
lbu x4, 0(x2)
bne x4, x0, -4
jal x0, -88
jalr x0, 4(x3)
