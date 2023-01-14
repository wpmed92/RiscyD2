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

    reg [3:0] led = 4'b0000;
    reg [31:0] data;
    wire [7:0] rx_byte;
    wire rx_byte_ready;
    wire tx_ready;
    reg tx_en = 0;
    reg [7:0] tx_byte = 0;

    uart_rx uart0(
        .clk_i(clk_i),
        .uart_txd_i(uart_txd_i),
        .byte_o(rx_byte),
        .byte_ready_o(rx_byte_ready)
    );

    uart_tx uart1(
        .clk_i(clk_i),
        .byte_i(tx_byte),
        .enable_i(tx_en),
        .ready_o(tx_ready),
        .uart_rxd_o(uart_rxd_o)
    );

    /*
     * 0x32000-0x32003:  led[0:3]               W
     * 0x32004:          uart_tx tx_en          W
     * 0x32005:          uart_tx tx_byte        W
     * 0x32006:          uart_tx tx_ready       R
     * 0x32007:          uart_rx rx_byte        R 
     * 0x32008:          uart_rx rx_byte_ready  R 
     * 0x32009-0x3200C:  sw[0:3]                R        
     */
    always @(posedge clk_i) begin
        if (enable_i && state_i == `LOAD_STORE) begin
            if (store_enable_i) begin
                case (address_i)
                    4'b0000   : led[0]   = data_i > 0;
                    4'b0001   : led[1]   = data_i > 0;
                    4'b0010   : led[2]   = data_i > 0;
                    4'b0011   : led[3]   = data_i > 0;
                    4'b0100   : tx_en    = data_i > 0;
                    4'b0101   : tx_byte  = data_i[7:0];
                endcase
            end else if (load_enable_i) begin
                case (address_i)
                    4'b0110   : data  = { 30'b0, tx_ready };
                    4'b0111   : data  = { 24'b0, rx_byte };
                    4'b1000   : data  = { 31'b0, rx_byte_ready };
                    4'b1001   : data  = { 31'b0, sw_i[0] };
                    4'b1010   : data  = { 31'b0, sw_i[1] };
                    4'b1011   : data  = { 31'b0, sw_i[2] };
                    4'b1100   : data  = { 31'b0, sw_i[3] };
                    default   : data = 0;
                endcase
            end
        end
    end

    assign led_o = led;
    assign data_o = data;
endmodule
