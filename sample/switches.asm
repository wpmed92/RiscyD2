li x1, 0x1000 ;led base
li x2, 0x1006 ;switch base
lbu x3, 0(x2) ;sw[0]
lbu x4, 1(x2) ;sw[1]
lbu x5, 2(x2) ;sw[2]
lbu x6, 3(x2) ;sw[3]
sb x3, 0(x1)  ;led[0]
sb x4, 1(x1)  ;led[1]
sb x5, 2(x1)  ;led[2]
sb x6, 3(x1)  ;led[3]
jal x0, -32   ;jump to start of polling logic