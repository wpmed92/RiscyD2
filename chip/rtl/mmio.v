`include "constant_defs.v"

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
    wire is_instr_fetch = (state == `FETCH_DECODE);
    wire en_bram = (address >= 0) && (address < 'h2404);
    wire en_gpio = (address >= 'h32000);
    wire [31:0] _bram_out;
    wire [31:0] _gpio_out;
    wire [3:0] weB_calc = is_sb ? 4'b1 << address[1:0]  :
                          is_sh ? 4'b11 << address[1:0] :
                          is_sw ? 4'b1111               :
                          4'b0;

    wire [31:0] _port_b_out = is_lb  ?  { {24{_bram_out[7]}}, _bram_out[7:0]   } :
                              is_lbu ?  { 24'b0, _bram_out[7:0]                } :
                              is_lh  ?  { {16{_bram_out[15]}}, _bram_out[15:0] } :
                              is_lhu ?  { 16'b0, _bram_out[15:0]               } :
                              is_lw  ?   _bram_out                               :
                              32'b0;
    
    mem bram(
        //Port A is for instructions
        .clkA(clk),
        .enaA(is_instr_fetch),
        .weA(4'd0),
        .addrA(pc[9:2]),
        .dinA(32'd0),
        .doutA(instr_out),
        //Port B is for memory
        .clkB(clk),
        .enaB(en_bram),
        .weB(weB_calc),
        .addrB(address[9:0]),
        .dinB(data_in),
        .doutB(_bram_out)
    );

    gpio io(
        clk,
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
        address[3:0],
        data_in,
        _gpio_out,
        led,
        uart_txd_in,
        uart_rxd_out,
        sw
    );

    assign data_out = en_bram ? _port_b_out : _gpio_out;
endmodule
