module uart_rx(
    // Inputs
    input clk_i,
    input uart_txd_i,

    // Outputs
    output [7:0] byte_o,
    output byte_ready_o
);

reg [ 4:0] counter_q = 0;

// idle, reading, finished
reg [ 1:0] state_q = 0;

reg [10:0] uart_tick_q = 0;
reg        byte_read_q = 0;
reg [ 3:0] bit_counter_q = 0;
reg [ 7:0] byte_q = 0;

// 9600 baud rate
// sample 16 times 9600 -> 153600 -> 100MHz clock -> 651 clock tick produces 1 uart sample tick
always @(posedge clk_i) begin
    if (uart_tick_q == 651) begin
        uart_tick_q <= 0;

        if (uart_txd_i == 0 && state_q == 2'b00) begin
            if (counter_q == 7) begin
                byte_read_q <= 0;
                byte_q <= 0;
                state_q <= 2'b01;
                counter_q <= 0;
            end else begin
                counter_q <= counter_q + 1;
            end
        end else if (state_q == 2'b01) begin
            if (bit_counter_q == 8) begin
                bit_counter_q <= 0;
                state_q <= 2'b10;
            end else if (counter_q == 15) begin
                byte_q <= byte_q | (uart_txd_i << bit_counter_q);
                counter_q <= 0;
                bit_counter_q <= bit_counter_q + 1;
            end else begin
                counter_q <= counter_q + 1;
            end
        end else if (state_q == 2'b10) begin
            if (counter_q == 15) begin
                if (uart_txd_i == 1) begin
                    byte_read_q <= 1;
                    counter_q <= 0;
                    state_q <= 2'b00; //idle
                end
            end else begin
                counter_q <= counter_q + 1;
            end
        end else begin
            byte_read_q <= 0;
            byte_q <= 0;
        end
    end else begin
        uart_tick_q <= uart_tick_q + 1;
    end
end

assign byte_o = byte_q;
assign byte_ready_o = byte_read_q;

endmodule
