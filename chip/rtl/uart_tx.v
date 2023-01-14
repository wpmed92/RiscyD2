module uart_tx(
    // Inputs
    input clk_i,
    input [7:0] byte_i,
    input enable_i,

    // Outputs
    output ready_o,
    output uart_rxd_o
);

reg [14:0] uart_tick = 0;
reg [4:0] tx_counter = 0;
reg _tx_ready = 0;
reg _uart_rxd_out = 1;

//9600 baud rate
//100MHz clock / 9600 -> 10416 clock tick produces 1 uart transmission tick
always @(posedge clk_i) begin
    if (uart_tick == 10416) begin
        uart_tick <= 0;

        if (enable_i) begin
            tx_counter <= tx_counter + 1;
            
            if (tx_counter == 0) begin //start bit
                _tx_ready <= 0;
                _uart_rxd_out <= 0;
            end else if (tx_counter < 9 && tx_counter > 0) begin
                _uart_rxd_out <= byte_i[tx_counter - 1];
            end else begin //stop bit
                _uart_rxd_out <= 1;
                tx_counter <= 0;
                _tx_ready <= 1;
            end
        end else begin
            _uart_rxd_out <= 1;
            tx_counter <= 0;
            _tx_ready <= 0;
        end
    end else begin
        uart_tick <= uart_tick + 1;
    end
end

assign ready_o = _tx_ready;
assign uart_rxd_o = _uart_rxd_out;

endmodule