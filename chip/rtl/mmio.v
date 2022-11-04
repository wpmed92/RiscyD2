`include "mem.v"
`include "gpio.v"

module mmio(
    input clk,
    input [2:0] state,
    input load_enable,
    input store_enable,
    input is_lb,
    input is_lbu,
    input is_lh,
    input is_lhu,
    input is_lw,
    input is_sb,
    input is_sh,
    input is_sw,
    input [31:0] pc, 
    input [31:0] address,
    input [31:0] data_in,
    output [31:0] data_out,
    output [31:0] instr_out,
    output [3:0] led,
    input uart_txd_in,
    output uart_rxd_out,
    input [3:0] sw
);
    wire en_bram = (address >= 0) && (address < 'h32000);
    wire en_gpio = address >= 'h32000;
    wire [31:0] _bram_out;
    wire [31:0] _gpio_out;

    mem bram(
        clk,
        state,
        en_bram,
        load_enable,
        store_enable,
        is_lb,
        is_lbu,
        is_lh,
        is_lhu,
        is_lw,
        is_sb,
        is_sh,
        is_sw,
        pc, 
        address,
        data_in,
        _bram_out,
        instr_out
    );

    gpio io(
        clk,
        state,
        en_gpio,
        load_enable,
        store_enable,
        is_lb,
        is_lbu,
        is_lh,
        is_lhu,
        is_lw,
        is_sb,
        is_sh,
        is_sw,
        address,
        data_in,
        _gpio_out,
        led,
        uart_txd_in,
        uart_rxd_out,
        sw
    );

    assign data_out = en_bram ? _bram_out : _gpio_out;
endmodule
