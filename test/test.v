`include "cpu.v"

module test;
    reg reset = 0;
    reg clk = 0;

    wire [31:0] out1;
    wire [31:0] out2;

    initial begin
        # 10 reset = 1;
        # 20 reset = 0;
        # 100000 $finish;
    end

    always #5 clk = !clk;

    cpu core (clk, reset, out1, out2);
endmodule
