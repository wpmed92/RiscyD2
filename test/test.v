`timescale 1us/1us
`include "cpu.v"

module test;
    reg clk = 0; 

    wire tx;
    reg rx = 1;
    wire [3:0] leds;

    initial begin
       # 100000 $finish;
    end

    always #5 clk = !clk;

    cpu core (clk, leds, rx, tx);
endmodule
