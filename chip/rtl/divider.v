// Implements long division
// source: https://projectf.io/posts/division-in-verilog/
module divider(
    input clk,
    input start,          // start signal
    output reg busy,      // calculation in progress
    output reg valid,     // quotient and remainder are valid
    output reg dbz,       // divide by zero flag
    input  [31:0] x,      // dividend
    input  [31:0] y,      // divisor
    output reg [31:0] q,  // quotient
    output reg [31:0] r   // remainder
);

reg [31:0] y1;              // copy of divisor
reg [31:0] q1, q1_next;     // intermediate quotient
reg [32:0] ac, ac_next;     // accumulator (1 bit wider)
reg [4:0] i;                // iteration counter

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
        valid <= 0;
        i <= 0;
        if (y == 0) begin  // catch divide by zero
            busy <= 0;
            dbz <= 1;
        end else begin  // initialize values
            busy <= 1;
            dbz <= 0;
            y1 <= y;
            {ac, q1} <= {{32{1'b0}}, x, 1'b0};
        end
    end else if (busy) begin
        if (i == 31) begin  // we're done
            busy <= 0;
            valid <= 1;
            q <= q1_next;
            r <= ac_next[32:1];  // undo final shift
        end else begin  // next iteration
            i <= i + 1;
            ac <= ac_next;
            q1 <= q1_next;
        end
    end
end

endmodule
