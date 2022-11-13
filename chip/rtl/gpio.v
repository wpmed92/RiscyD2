module gpio(
    input clk,
    input [1:0] state,
    input enabled,
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
    input [31:0] address,
    input [31:0] data_in,
    output [31:0] data_out,
    output [3:0] led_out,
    input uart_txd_in,
    output uart_rxd_out,
    input [3:0] sw
);

    reg [3:0] led = 4'b0000;
    reg [31:0] data;
    wire [7:0] rx_byte;
    wire rx_byte_ready;
    wire tx_ready;
    reg tx_en = 0;
    reg [7:0] tx_byte = 0;

    uart_rx uart0(
        clk,
        uart_txd_in,
        rx_byte,
        rx_byte_ready
    );

    uart_tx uart1(
        clk,
        tx_byte,
        tx_en,
        tx_ready,
        uart_rxd_out
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
    always @(posedge clk) begin
        if (state == 3'd2 && enabled) begin
            if (store_enable) begin
                case (address[3:0])
                    4'b0000   : led[0]   = data_in > 0;
                    4'b0001   : led[1]   = data_in > 0;
                    4'b0010   : led[2]   = data_in > 0;
                    4'b0011   : led[3]   = data_in > 0;
                    4'b0100   : tx_en    = data_in > 0;
                    4'b0101   : tx_byte  = data_in[7:0];
                endcase
            end else if (load_enable) begin
                case (address[3:0])
                    4'b0110   : data  = { 30'b0, tx_ready };
                    4'b0111   : data  = { 24'b0, rx_byte };
                    4'b1000   : data  = { 31'b0, rx_byte_ready };
                    4'b1001   : data  = { 31'b0, sw[0] };
                    4'b1010   : data  = { 31'b0, sw[1] };
                    4'b1011   : data  = { 31'b0, sw[2] };
                    4'b1100   : data  = { 31'b0, sw[3] };
                    default   : data = 0;
                endcase
            end
        end
    end

    assign led_out = led;
    assign data_out = data;
endmodule
