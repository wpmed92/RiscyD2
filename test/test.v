`timescale 1us/1us

module test;
    reg clk = 0; 

    wire tx;
    wire rx;
    wire [3:0] leds;
    reg [3:0] sw = 4'b0000;

    initial begin
       # 100000 $finish;
    end

    always #5 clk = !clk;

    cpu core (clk, leds, tx, rx, sw);
endmodule
