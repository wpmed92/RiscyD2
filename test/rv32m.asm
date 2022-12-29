li x1, 4
li x2, 2
mul x3, x1, x2
div x4, x1, x2
li x1, -4
mul x5, x1, x2
div x6, x1, x2
li x2, -2
div x20, x1, x2
li x7, 0xFFFFFFFF
li x8, 0xFFFFFFFF
mulh x9, x7, x8
mulhsu x10, x7, x8
mulhu x11, x7, x8
li x12, 17
li x13, 3
divu x14, x12, x13
div x15, x12, x13
remu x16, x12, x13
rem x17, x12, x13
li x12, -17
rem x18, x12, x13
li x13, -3
rem x19, x12, x13
jal x0, 0
