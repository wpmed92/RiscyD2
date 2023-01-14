module div_int_tb();

    parameter CLK_PERIOD = 10;  // 10 ns == 100 MHz

    reg clk;
    reg start;            // start signal
    wire busy;             // calculation in progress
    wire valid;            // quotient and remainder are valid
    wire dbz;              // divide by zero flag
    reg [31:0] x;    // dividend
    reg [31:0] y;    // divisor
    wire [31:0] q;    // quotient
    wire [31:0] r;    // remainder

    divider div_int_inst (.*);

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $monitor("\t%d:\t%d /%d =%d (r =%d) (V=%b) (DBZ=%b)",
            $time, x, y, q, r, valid, dbz);
    end

    initial begin
        clk = 1;

        #100    x = 32'd0;  // 0
                y = 32'd2;  // 2
                start = 1;
        #10     start = 0;

        #330     x = 32'd2;  // 2
                y = 32'd0;  // 0
                start = 1;
        #10     start = 0;

        #330     x = 32'd7;  // 7
                y = 32'd2;  // 2
                start = 1;
        #10     start = 0;

        #330     x = 32'd15;  // 15
                y = 32'd5;  //  5
                start = 1;
        #10     start = 0;

        #330     x = 32'd1;  // 1
                y = 32'd1;  // 1
                start = 1;
        #10     start = 0;

        #330     x = 32'd8;  // 8
                y = 32'd9;  // 9
                start = 1;
        #10     start = 0;

        #330     $finish;
    end
endmodule
