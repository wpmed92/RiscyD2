;int prev = 0
;int cur = 1
;int elems = 6
;int i = 0;
;while (i < elems) {
;  cur = prev + cur;
;  prev = cur;
;  i = i + 1;
;}
addi x1, x0, 0  ;int prev = 0
addi x2, x0, 1  ;int cur = 1
addi x3, x0, 0  ;int i = 0;
addi x4, x0, 0  ;tmp = 0;
addi x5, x0, 8  ;elems = 10;
addi x6, x0, 0  ;int *array = 0;
sw x1, 0(x6)   ;store first element
sw x2, 4(x6)   ;store first element
addi x6, x6, 8
add x4, x1, x2  ;tmp = prev + cur
add x1, x2, x0  ;prev = cur
add x2, x4, x0  ;cur = tmp
addi x3, x3, 1  ;i = i + 1
sw x2, 0(x6)
addi x6, x6, 4
blt x3, x5, -24
lw x1, 0(x0)
lw x2, 4(x0)
lw x3, 8(x0)
lw x4, 12(x0)
lw x5, 16(x0)
lw x6, 20(x0)
lw x7, 24(x0)
lw x8, 28(x0)
lw x9, 32(x0)
lw x10, 36(x0)
jal x0, 0
