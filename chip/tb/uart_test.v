`timescale 1ns/1ps
`include "uart.v"

module test_uart;
    reg rx_clk = 0;
    reg tx_clk = 0;

    wire tx; //ignores in this test
    reg rx = 1;

    reg [7:0] msg[0:3];
    reg [7:0] msg_back[0:3];
    integer i = -1;
    integer byte_counter = 0;
    reg [7:0] cur_byte;

    initial begin
        msg[0] <= 8'hAB;
        msg[1] <= 8'hFF;
        msg[2] <= 8'h00;
        msg[3] <= 8'h12;
    end

    initial begin
        # 4166670 
        if (msg[0] == msg_back[0] && 
            msg[1] == msg_back[1] && 
            msg[2] == msg_back[2] && 
            msg[3] == msg_back[3]
        ) begin
            $display("PASSED");
        end else begin
            $display("FAILED");
        end 

        $finish;
    end

    always #52083 tx_clk = !tx_clk;
    always #5 rx_clk = !rx_clk; //imitate 100MHz clock

    //Transmission side
    always @(posedge tx_clk) begin
        i = i + 1;
        
        if (i == 0) begin //start bit
            rx = 0;
            cur_byte = msg[byte_counter][7:0];
        end else if (i < 9 && i > 0) begin
            rx = (cur_byte >> (i-1)) & 1;
        end else begin //stop bit
            rx = 1;
            i = -1;
            byte_counter = byte_counter + 1;
        end
    end

    integer rec_byte_i = 0;
    reg byte_read_prev = 0;
    wire [7:0] byte;
    wire byte_read;

    //Receiver side
    always @(posedge rx_clk) begin
        if (byte_read && byte_read_prev == 0) begin
            byte_read_prev = 1;
            msg_back[rec_byte_i] = byte;
            rec_byte_i = rec_byte_i + 1;
        end else if (byte_read == 0 && byte_read_prev == 1) begin
            byte_read_prev = 0;
        end
    end

    uart uart0(
        rx_clk,
        rx,
        tx,
        byte,
        byte_read
    );

endmodule
