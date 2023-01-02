`include "constant_defs.v"

module mmio(
    input clk,
    input  [2:0]state,
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
    wire en_gpio = (address >= 'h32000);
    wire [31:0] _bram_out;
    wire [31:0] _gpio_out;

    // Dual-port RAM template expects write enable in the following format
    // 4'bxxxx -> x should be 1 for the bytes we want to write, and 0 otherwise
    // the position of the byte is determined by address bits 1:0 for bytes (values: 0-3), 
    // and bit 1 for half words (values: 0, 2)
    wire [3:0] weB_calc = is_sb && address[1:0] == 0 ? 4'b0001 :
                          is_sb && address[1:0] == 1 ? 4'b0010 :
                          is_sb && address[1:0] == 2 ? 4'b0100 :
                          is_sb && address[1:0] == 3 ? 4'b1000 :
                          is_sh && address[1] == 0   ? 4'b0011 :
                          is_sh && address[1] == 1   ? 4'b1100 :
                          is_sw                      ? 4'b1111 :
                          4'b0;
    
    // Dual-port RAM template expacts bytes and half-words in the same position as where we write them
    // for example: with weB 4'b0010 for a store byte, the template expects the byte we want to write at
    // position: 00f0. So we repeat the byte we want to write for each byte of the word, and we duplicate
    // the half-words to be present in the lower and higher half words of the word.
    wire [31:0] data_in_calc = is_sb  ? { data_in[7:0], data_in[7:0], data_in[7:0], data_in[7:0] }  :
                               is_sh  ? { data_in[15:0], data_in[15:0] }                            :
                               is_sw  ? data_in                                                     :
                                4'b0;

    // This logic selects the required bytes from the word coming out of dual-port RAM
    wire [31:0] _port_b_out = is_lb  && address[1:0] == 0  ?  { {24{_bram_out[7]}}, _bram_out[7:0]     } :
                              is_lb  && address[1:0] == 1  ?  { {24{_bram_out[15]}}, _bram_out[15:8]   } :
                              is_lb  && address[1:0] == 2  ?  { {24{_bram_out[23]}}, _bram_out[23:16]  } :
                              is_lb  && address[1:0] == 3  ?  { {24{_bram_out[31]}}, _bram_out[31:24]  } :
                              is_lbu && address[1:0] == 0  ?  {  24'b0, _bram_out[7:0]                 } :
                              is_lbu && address[1:0] == 1  ?  {  24'b0, _bram_out[15:8]                } :
                              is_lbu && address[1:0] == 2  ?  {  24'b0, _bram_out[23:16]               } :
                              is_lbu && address[1:0] == 3  ?  {  24'b0, _bram_out[31:24]               } :
                              is_lh  && address[1] == 0    ?  { {16{_bram_out[15]}}, _bram_out[15:0]   } :
                              is_lh  && address[1] == 1    ?  { {16{_bram_out[31]}}, _bram_out[31:16]  } :
                              is_lhu && address[1] == 0    ?  { 16'b0, _bram_out[15:0]                 } :
                              is_lhu && address[1] == 1    ?  { 16'b0, _bram_out[31:16]                } :
                              is_lw                        ?   _bram_out                                 :
                              32'b0;
    
    mem bram(
        //Port A is for instructions
        .state(state),
        .clkA(clk),
        .enaA(1'd1),
        .weA(4'd0),
        .addrA(pc[15:2]),
        .dinA(32'd0),
        .doutA(instr_out),
        //Port B is for memory
        .clkB(clk),
        .enaB(en_bram),
        .weB(weB_calc),
        .addrB(address[15:2]),
        .dinB(data_in_calc),
        .doutB(_bram_out)
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
