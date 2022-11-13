`timescale 1ns/1ps
`include "cpu.v"

module test_uart_with_cpu;
    reg rx_clk = 0;
    reg tx_clk = 0;

    wire tx; //ignores in this test
    reg rx = 1;
    wire [3:0] leds;

    reg [31:0] exe[0:12];
    reg start_transmission = 0;

    initial begin
        $readmemh("exe.mem", exe);
        # 200000
        start_transmission = 1;
    end

    integer i = -1;
    integer byte_counter = 0;
    reg [7:0] cur_byte;

    always #52083 tx_clk = !tx_clk; //9600 baud rate
    always #5 rx_clk = !rx_clk; //emulate 100MHz clock

    //Transmission side
    always @(posedge tx_clk) begin
        if (start_transmission == 1 && byte_counter < 52) begin
            i = i + 1;
            
            if (i == 0) begin //start bit
                rx = 0;
                cur_byte = exe[byte_counter[31:2]][{byte_counter[1:0], 3'b0} +: 8];;
            end else if (i < 9 && i > 0) begin
                rx = cur_byte[i-1];
            end else begin //stop bit
                rx = 1;
                i = -1;
                //$display("leds=%b", leds);
                byte_counter = byte_counter + 1;
            end
        end
    end

    wire [3:0] sw;
    cpu core (rx_clk, leds, rx, tx, sw);

endmodule
