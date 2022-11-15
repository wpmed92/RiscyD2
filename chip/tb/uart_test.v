`timescale 1ns/1ps

module test_uart;
    reg clk = 0;

    wire tx;
    reg [7:0] tx_byte;
    reg tx_en = 1;
    wire tx_ready;

    reg [7:0] msg[0:3];
    reg [7:0] msg_back[0:3];
    integer i = -1;
    reg [1:0] byte_counter = 0;
    reg [7:0] cur_byte;

    initial begin
        msg[0] <= 8'hAB;
        msg[1] <= 8'hFF;
        msg[2] <= 8'h00;
        msg[3] <= 8'h12;
    end

    initial begin
        # 4270560
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

    always #5 clk = !clk; //imitate 100MHz clock

    //Transmission side
    reg already_counted = 0;

    always @(posedge clk) begin
        tx_byte <= msg[byte_counter][7:0];

        if (tx_ready && !already_counted) begin
            byte_counter <= byte_counter + 1;
            already_counted <= 1;
        end else if (!tx_ready) begin
            already_counted <= 0;
        end
    end

    integer rec_byte_i = 0;
    reg byte_read_prev = 0;
    wire [7:0] byte;
    wire byte_read;

    //Receiver side
    always @(posedge clk) begin
        if (byte_read && byte_read_prev == 0) begin
            byte_read_prev <= 1;
            msg_back[rec_byte_i] <= byte;
            rec_byte_i <= rec_byte_i + 1;
        end else if (byte_read == 0 && byte_read_prev == 1) begin
            byte_read_prev <= 0;
        end
    end

    uart_rx uart0(
        clk,
        tx,
        byte,
        byte_read
    );

    uart_tx uart1(
        clk,
        tx_byte,
        tx_en,
        tx_ready,
        tx
    );

endmodule
