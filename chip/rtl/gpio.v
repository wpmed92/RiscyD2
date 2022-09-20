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
    output uart_rxd_out
);

    reg [3:0] led;
    reg [31:0] data;
    reg [2:0] port_select;
    wire [7:0] byte;
    wire  byte_read;

    uart uart0(
        clk,
        uart_txd_in,
        uart_rxd_out,
        byte, //out
        byte_read //out
    );

    always @(*) begin
        port_select = address % 8;

        if (state == 3'd6 && enabled) begin
            if (store_enable) begin
                case (port_select)
                    3'b000   : led[0] = data_in > 0;
                    3'b001   : led[1] = data_in > 0;
                    3'b010   : led[2] = data_in > 0;
                    3'b011   : led[3] = data_in > 0;
                endcase
            end else if (load_enable) begin
                case (port_select)
                    3'b100   : data  = { 24'b0, byte };
                    3'b101   : data  = { 30'b0, byte_read };
                endcase
            end
        end
    end

    assign led_out = led;
    assign data_out = data;
endmodule
