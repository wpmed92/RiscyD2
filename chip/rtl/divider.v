// Implements long division
// source: https://projectf.io/posts/division-in-verilog/
module divider(
    // Inputs
    input clk_i,
    input start_i,          // start signal
    output busy_i,      // calculation in progress
    output valid_i,     // quotient and remainder are valid
    output dbz_i,       // divide by zero flag
    input  [31:0] x_i,      // dividend
    input  [31:0] y_i,      // divisor

    // Outputs
    output reg [31:0] q_o,  // quotient
    output reg [31:0] r_o   // remainder
);

reg [31:0] y1;              // copy of divisor
reg [31:0] q1, q1_next;     // intermediate quotient
reg [32:0] ac, ac_next;     // accumulator (1 bit wider)
reg [4:0] i;                // iteration counter

reg _busy = 0;
reg _valid = 0;
reg _dbz = 0;

always@* begin
    if (ac >= {1'b0,y1}) begin
        ac_next = ac - y1;
        {ac_next, q1_next} = {ac_next[31:0], q1, 1'b1};
    end else begin
        {ac_next, q1_next} = {ac, q1} << 1;
    end
end

always@(posedge clk) begin
    if (start) begin
        _valid <= 0;
        i <= 0;
        if (y == 0) begin  // catch divide by zero
            _busy <= 0;
            _dbz <= 1;
        end else begin  // initialize values
            _busy <= 1;
            _dbz <= 0;
            y1 <= y;
            {ac, q1} <= {{32{1'b0}}, x, 1'b0};
        end
    end else if (_busy) begin
        if (i == 31) begin  // we're done
            _busy <= 0;
            _valid <= 1;
            q <= q1_next;
            r <= ac_next[32:1];  // undo final shift
        end else begin  // next iteration
            i <= i + 1;
            ac <= ac_next;
            q1 <= q1_next;
        end
    end
end

assign dbz = _dbz;
assign valid = _valid;
assign busy = _busy;

endmodule
