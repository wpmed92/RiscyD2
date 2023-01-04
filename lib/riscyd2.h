#ifndef __RISCYD2_H
#define __RISCYD2_H

/*
 * 0x32000-0x32003:  led[0:3]               W
 * 0x32004:          uart_tx tx_en          W
 * 0x32005:          uart_tx tx_byte        W
 * 0x32006:          uart_tx tx_ready       R
 * 0x32007:          uart_rx rx_byte        R 
 * 0x32008:          uart_rx rx_byte_ready  R 
 * 0x32009-0x3200C:  sw[0:3]                R        
 */

#define LED_0         0x32000
#define LED_1         0x32001
#define LED_2         0x32002
#define LED_3         0x32003
#define UART_TX_EN    0x32004
#define UART_TX_BYTE  0x32005
#define UART_TX_READY 0x32006
#define UART_RX_BYTE  0x32007
#define UART_RX_READY 0x32008
#define SW_0          0x32009
#define SW_1          0x3200A
#define SW_2          0x3200B
#define SW_3          0x3200C

#define CYCLES_PER_MS 100000

void riscy_print(unsigned char* buffer) {
    while(*buffer != 0) {
        while (*(volatile unsigned char *) UART_TX_READY) ;

        *(unsigned char*) UART_TX_BYTE = *buffer;
        *(unsigned char*) UART_TX_EN = 1;
        while (!(*(volatile unsigned char *) UART_TX_READY)) ;

        buffer++;
    }

    *(unsigned char*) UART_TX_EN = 0;
}

void riscy_led(int led_num, int is_on) {
    switch (led_num) {
        case 0:
            *(unsigned char*) LED_0 = is_on;
            break;
        case 1:
            *(unsigned char*) LED_1 = is_on;
            break;
        case 2:
            *(unsigned char*) LED_2 = is_on;
            break;
        case 3:
            *(unsigned char*) LED_3 = is_on;
            break;

    }
}

void riscy_led_pattern(int led_pattern) {
     *(unsigned char*) LED_0 = led_pattern & 1;
     *(unsigned char*) LED_1 = (led_pattern >> 1) & 1;
     *(unsigned char*) LED_2 = (led_pattern >> 2) & 1;
     *(unsigned char*) LED_3 = (led_pattern >> 3) & 1;
}

unsigned long start_cycles;

void riscy_start_timer(void) {
    asm volatile ("rdcycle %0" : "=r" (start_cycles));
}

unsigned long riscy_stop_timer() {
    unsigned long end_cycles;
    asm volatile ("rdcycle %0" : "=r" (end_cycles));
    return (end_cycles - start_cycles) / CYCLES_PER_MS;
}

#endif
