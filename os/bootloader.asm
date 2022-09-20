;load an exe from UART
li x1, 0x1004    ; uart_byte port
li x2, 0x1005    ; uart_ready port
li x3, 0x200     ; address of executable (first 4 bytes will be exe size)
mv x6, x3        
li x9, 0         ; iterator, or address of 
li x10, 4        ; size of exe is stored in 4 bytes
li x11, 0        ; size of executable stored here
lbu x4, 0(x2)    ; while (!(*(uart_ready))) ;
beq x4, x0, -4
bne x9, x10, 12  ; if (i == 4) {
lw x11, 0(x3)    ;  size_of_exe = *((uint32_t*) exe));
addi x11, x11, 4 ;  size_of_exe += 4; }
lbu x5, 0(x1)    ; cur_byte = *uart_byte;
add x6, x3, x9   ; exe += i;
sb x5, 0(x6)     ; *exe = cur_byte
addi x9, x9, 1   ; i += 1
beq x11, x9, 16  ; if (i == size_of_exe) goto load program
lbu x4, 0(x2)    ; while (*uart_ready) ;
bne x4, x0, -4
jal x0, -48      ; goto start of routine
jalr x0, 4(x3)   ; execute loaded program, 4 byte offset is needed because
