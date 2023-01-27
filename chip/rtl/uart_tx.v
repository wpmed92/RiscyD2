module uart_tx(
    // Inputs
    input clk_i,
    input [7:0] byte_i,
    input enable_i,

    // Outputs
    output ready_o,
    output uart_rxd_o
);

reg [14:0] uart_tick_q = 0;
reg [4:0] tx_counter_q = 0;
reg tx_ready_q = 0;
reg uart_rxd_out_q = 1;

//9600 baud rate
//100MHz clock / 9600 -> 10416 clock tick produces 1 uart transmission tick
always @(posedge clk_i) begin
    if (uart_tick_q == 10416) begin
        uart_tick_q <= 0;

        if (enable_i) begin
            tx_counter_q <= tx_counter_q + 1;
            
            if (tx_counter_q == 0) begin //start bit
                tx_ready_q <= 0;
                uart_rxd_out_q <= 0;
            end else if (tx_counter_q < 9 && tx_counter_q > 0) begin
                uart_rxd_out_q <= byte_i[tx_counter_q - 1];
            end else begin //stop bit
                uart_rxd_out_q <= 1;
                tx_counter_q <= 0;
                tx_ready_q <= 1;
            end
        end else begin
            uart_rxd_out_q <= 1;
            tx_counter_q <= 0;
            tx_ready_q <= 0;
        end
    end else begin
        uart_tick_q <= uart_tick_q + 1;
    end
end

assign ready_o = tx_ready_q;
assign uart_rxd_o = uart_rxd_out_q;

endmodule
