;Test code adapted from: https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv
addi x1, x0, 21
addi x2, x0, 7
addi x3, x0, 0xFFC
andi x5, x1, 92
xori x5, x5, 21
ori  x6, x1, 92
xori x6, x6, 92
addi x7, x1, 7
xori x7, x7, 29
slli x8, x1, 6
xori x8, x8, 0x541
srli x9, x1, 2
xori x9, x9, 4
and x10, x1, x2
xori x10, x10, 4
or x11, x1, x2
xori x11, x11, 22
xor x12, x1, x2
xori x12, x12, 19
add x13, x1, x2
xori x13, x13, 29
sub x14, x1, x2
xori x14, x14, 15
sll x15, x2, x2
xori x15, x15, 0x381
srl x16, x1, x2
xori x16, x16, 1
sltu x17, x2, x1
xori x17, x17, 0
sltiu x18, x2, 21
xori x18, x18, 0
lui x19, 0
xori x19, x19, 1
srai x20, x3, 1
xori x20, x20, 0xFFF
slt x21, x3, x1
xori x21, x21, 0
slti x22, x3, 1
xori x22, x22, 0
sra x23, x1, x2
xori x23, x23, 1
auipc x4, 4
srli x24, x4, 7
xori x24, x24, 0x80
jal x25, 2
auipc x4, 0
xor x25, x25, x4
xori x25, x25, 1
jalr x26, 16(x4)
sub x26, x26, x4
addi x26, x26, 0xFF1
sw x1, 1(x2)
lw x27, 1(x2)
xori x27, x27, 20
addi x28, x0, 1
addi x29, x0, 1
addi x30, x0, 1
jal x0, 0
