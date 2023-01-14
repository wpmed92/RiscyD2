`include "constant_defs.v"

module mmio(
    // Inputs
    input clk_i,
    input  [2:0] state_i,
    input is_lb_i,
    input is_lbu_i,
    input is_lh_i,
    input is_lhu_i,
    input is_lw_i,
    input is_sb_i,
    input is_sh_i,
    input is_sw_i,
    input [31:0] pc_i, 
    input [31:0] address_i,
    input [31:0] data_i,
    input uart_txd_i,
    input [3:0] sw_i,

    // Outputs
    output [31:0] data_o,
    output [31:0] instr_o,
    output [3:0] led_o,
    output uart_rxd_o
);
    wire en_bram = (address_i >= 0) && (address_i < 'h32000);
    wire en_gpio = (address_i >= 'h32000);
    wire load_enable  = is_lb_i || is_lbu_i || is_lh_i || is_lhu_i || is_lw_i;
    wire store_enable = is_sb_i || is_sh_i  || is_sw_i;
    wire [31:0] bram_out;
    wire [31:0] gpio_out;

    // Dual-port RAM template expects write enable in the following format
    // 4'bxxxx -> x should be 1 for the bytes we want to write, and 0 otherwise
    // the position of the byte is determined by address_i bits 1:0 for bytes (values: 0-3), 
    // and bit 1 for half words (values: 0, 2)
    wire [3:0] weB_calc = is_sb_i && address_i[1:0] == 0 ? 4'b0001 :
                          is_sb_i && address_i[1:0] == 1 ? 4'b0010 :
                          is_sb_i && address_i[1:0] == 2 ? 4'b0100 :
                          is_sb_i && address_i[1:0] == 3 ? 4'b1000 :
                          is_sh_i && address_i[1] == 0   ? 4'b0011 :
                          is_sh_i && address_i[1] == 1   ? 4'b1100 :
                          is_sw_i                      ? 4'b1111 :
                          4'b0;
    
    // Dual-port RAM template expacts bytes and half-words in the same position as where we write them
    // for example: with weB 4'b0010 for a store byte, the template expects the byte we want to write at
    // position: 00f0. So we repeat the byte we want to write for each byte of the word, and we duplicate
    // the half-words to be present in the lower and higher half words of the word.
    wire [31:0] data_in_calc = is_sb_i  ? { data_i[7:0], data_i[7:0], data_i[7:0], data_i[7:0] }  :
                               is_sh_i  ? { data_i[15:0], data_i[15:0]                         }  :
                               is_sw_i  ?   data_i                                                :
                               4'b0;

    // This logic selects the required bytes from the word coming out of dual-port RAM
    wire [31:0] port_b_out = is_lb_i  && address_i[1:0] == 0  ?  { {24{bram_out[7]}}, bram_out[7:0]      } :
                             is_lb_i  && address_i[1:0] == 1  ?  { {24{bram_out[15]}}, bram_out[15:8]    } :
                             is_lb_i  && address_i[1:0] == 2  ?  { {24{bram_out[23]}}, bram_out[23:16]   } :
                             is_lb_i  && address_i[1:0] == 3  ?  { {24{bram_out[31]}}, bram_out[31:24]   } :
                             is_lbu_i && address_i[1:0] == 0  ?  {  24'b0, bram_out[7:0]                 } :
                             is_lbu_i && address_i[1:0] == 1  ?  {  24'b0, bram_out[15:8]                } :
                             is_lbu_i && address_i[1:0] == 2  ?  {  24'b0, bram_out[23:16]               } :
                             is_lbu_i && address_i[1:0] == 3  ?  {  24'b0, bram_out[31:24]               } :
                             is_lh_i  && address_i[1] == 0    ?  { {16{bram_out[15]}}, bram_out[15:0]    } :
                             is_lh_i  && address_i[1] == 1    ?  { {16{bram_out[31]}}, bram_out[31:16]   } :
                             is_lhu_i && address_i[1] == 0    ?  { 16'b0, bram_out[15:0]                 } :
                             is_lhu_i && address_i[1] == 1    ?  { 16'b0, bram_out[31:16]                } :
                             is_lw_i                          ?   bram_out                                 :
                             32'b0;
    
    mem mem_inst(
        //Port A is for instructions
        .state_i(state_i),
        .clkA_i(clk_i),
        .enaA_i(1'd1),
        .weA_i(4'd0),
        .addrA_i(pc_i[15:2]),
        .dinA_i(32'd0),
        .doutA_o(instr_o),
        
        //Port B is for memory
        .clkB_i(clk_i),
        .enaB_i(en_bram),
        .weB_i(weB_calc),
        .addrB_i(address_i[15:2]),
        .dinB_i(data_in_calc),
        .doutB_o(bram_out)
    );

    gpio gpio_inst(
        .clk_i(clk_i),
        .state_i(state_i),
        .enable_i(en_gpio),
        .load_enable_i(load_enable),
        .store_enable_i(store_enable),
        .address_i(address_i[3:0]),
        .data_i(data_i),
        .uart_txd_i(uart_txd_i),
        .sw_i(sw_i),
        .data_o(gpio_out),
        .led_o(led_o),
        .uart_rxd_o(uart_rxd_o)
    );

    assign data_o = en_bram ? port_b_out : gpio_out;
endmodule
