`include "constant_defs.v"

module gpio(
    // Inputs
    input clk_i,
    input [2:0] state_i,
    input enable_i,
    input load_enable_i,
    input store_enable_i,
    input [3:0] address_i,
    input [31:0] data_i,
    input uart_txd_i,
    input [3:0] sw_i,

    // Outputs
    output [31:0] data_o,
    output [3:0] led_o,
    output uart_rxd_o
);

    reg [3:0] led_r = 4'b0000;
    reg [31:0] data_r;
    reg [7:0] tx_byte_r = 0;
    reg tx_en_r = 0;

    wire [7:0] rx_byte_w;
    wire rx_byte_ready_w;
    wire tx_ready_w;

    uart_rx uart0(
        .clk_i(clk_i),
        .uart_txd_i(uart_txd_i),
        .byte_o(rx_byte_w),
        .byte_ready_o(rx_byte_ready_w)
    );

    uart_tx uart1(
        .clk_i(clk_i),
        .byte_i(tx_byte_r),
        .enable_i(tx_en_r),
        .ready_o(tx_ready_w),
        .uart_rxd_o(uart_rxd_o)
    );

    /*
     * 0x32000-0x32003:  led_r[0:3]               W
     * 0x32004:          uart_tx tx_en_r          W
     * 0x32005:          uart_tx tx_byte_r        W
     * 0x32006:          uart_tx tx_ready_w       R
     * 0x32007:          uart_rx rx_byte_w        R 
     * 0x32008:          uart_rx rx_byte_ready_w  R 
     * 0x32009-0x3200C:  sw[0:3]                R        
     */
    always @(posedge clk_i) begin
        if (enable_i && state_i == `LOAD_STORE) begin
            if (store_enable_i) begin
                case (address_i)
                    4'b0000   : led_r[0]   = data_i > 0;
                    4'b0001   : led_r[1]   = data_i > 0;
                    4'b0010   : led_r[2]   = data_i > 0;
                    4'b0011   : led_r[3]   = data_i > 0;
                    4'b0100   : tx_en_r    = data_i > 0;
                    4'b0101   : tx_byte_r  = data_i[7:0];
                endcase
            end else if (load_enable_i) begin
                case (address_i)
                    4'b0110   : data_r  = { 30'b0, tx_ready_w };
                    4'b0111   : data_r  = { 24'b0, rx_byte_w };
                    4'b1000   : data_r  = { 31'b0, rx_byte_ready_w };
                    4'b1001   : data_r  = { 31'b0, sw_i[0] };
                    4'b1010   : data_r  = { 31'b0, sw_i[1] };
                    4'b1011   : data_r  = { 31'b0, sw_i[2] };
                    4'b1100   : data_r  = { 31'b0, sw_i[3] };
                    default   : data_r = 0;
                endcase
            end
        end
    end

    assign led_o = led_r;
    assign data_o = data_r;
endmodule
