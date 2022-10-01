`include "uart.v"

module gpio(
    input clk,
    input [2:0] state,
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
    input [3:0] sw
);

    reg [3:0] led = 4'b0000;
    reg [31:0] data;
    reg [3:0] port_select;
    wire [7:0] byte;
    wire  byte_read;

    uart uart0(
        clk,
        uart_txd_in,
        uart_rxd_out,
        byte, //out
        byte_read //out
    );

    always @(posedge clk) begin
        port_select = address % 16;

        if (state == 3'd6 && enabled) begin
            if (store_enable) begin
                case (port_select)
                    4'b0000   : led[0] = data_in > 0;
                    4'b0001   : led[1] = data_in > 0;
                    4'b0010   : led[2] = data_in > 0;
                    4'b0011   : led[3] = data_in > 0;
                endcase
            end else if (load_enable) begin
                case (port_select)
                    4'b0100   : data  = { 24'b0, byte };
                    4'b0101   : data  = { 30'b0, byte_read };
                    4'b0110   : data  = { 30'b0, sw[0] };
                    4'b0111   : data  = { 30'b0, sw[1] };
                    4'b1000   : data  = { 30'b0, sw[2] };
                    4'b1001   : data  = { 30'b0, sw[3] };
                endcase
            end
        end
    end

    assign led_out = led;
    assign data_out = data;
endmodule
