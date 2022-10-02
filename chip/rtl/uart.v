module uart(
    input clk,
    input uart_txd_in,
    output [7:0] byte,
    output byte_read
);

reg [4:0] counter = 0;
reg [1:0] state = 0; //idle, reading, finished
reg [10:0] uart_tick = 0;
reg [7:0] _byte = 0;
reg _byte_read = 0;
reg [3:0] bit_counter = 0;

//9600 baud rate
//sample 16 times 9600 -> 153600 -> 100MHz clock -> 651 clock tick produces 1 uart sample tick
always @(posedge clk) begin
    if (uart_tick == 651) begin
        uart_tick <= 0;

        if (uart_txd_in == 0 && state == 2'b00) begin
            if (counter == 7) begin
                _byte_read <= 0;
                _byte <= 0;
                state <= 2'b01;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end else if (state == 2'b01) begin
            if (bit_counter == 8) begin
                bit_counter <= 0;
                state <= 2'b10;
            end else if (counter == 15) begin
                _byte <= _byte | (uart_txd_in << bit_counter);
                counter <= 0;
                bit_counter <= bit_counter + 1;
            end else begin
                counter <= counter + 1;
            end
        end else if (state == 2'b10) begin
            if (counter == 15) begin
                if (uart_txd_in == 1) begin
                    _byte_read <= 1;
                    counter <= 0;
                    state <= 2'b00; //idle
                end
            end else begin
                counter <= counter + 1;
            end
        end else begin
            _byte_read <= 0;
            _byte <= 0;
        end
    end else begin
        uart_tick <= uart_tick + 1;
    end
end

assign byte = _byte;
assign byte_read = _byte_read;

endmodule