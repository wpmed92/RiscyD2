`timescale 1ns/1ps
`include "vga.v"

module test_vga;

    reg pxl_clk = 0;

    //100Mhz clock
    always #5 pxl_clk = ~pxl_clk;

    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;
    wire hsync;
    wire vsync;
    wire [31:0] row;
    wire [31:0] col;
    wire [31:0] h_counter;
    wire [31:0] v_counter;

    initial begin
	    $dumpfile("vga_timing.vcd");
        $dumpvars;
        $monitor("t=%d, hsync=%d, vsync=%d, red=%h, green=%h, blue=%h, row=%d, col=%d", $time, hsync, vsync, red, green, blue, row, col);
        #16480000 $finish;
    end

    vga vga(
        pxl_clk,
        hsync,
        vsync,
        red,
        green,
        blue,
        row,
        col,
        h_counter,
        v_counter
    );

endmodule
