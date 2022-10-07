module vga(
    input CLK100MHZ,
    output VGA_HS_O,
    output VGA_VS_O,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output [31:0] row,
    output [31:0] col,
    output [31:0] h_counter,
    output [31:0] v_counter
);

reg [31:0] _h_counter = 0;
reg [31:0] _v_counter = 0;
reg [1:0] clock_divide_counter = 0;
reg [31:0] _row = 0;
reg [31:0] _col = 0;

reg [11:0] pixel_buffer[0:239][0:319];
reg [11:0] cur_pixel = 12'd0;
reg [3:0] cur_red = 4'd0;
reg [3:0] cur_blue = 4'd0;
reg [3:0] cur_green = 4'd0;
reg pixel_tick = 0;

initial begin
    $readmemh("vga_hex.mem", pixel_buffer);
end

always @(posedge CLK100MHZ) begin
    if (clock_divide_counter == 2'd3) begin
        clock_divide_counter <= 0;
        pixel_tick <= 1;
    end else begin
        pixel_tick <= 0;
        clock_divide_counter <= clock_divide_counter + 1;
    end
end

always @(posedge CLK100MHZ) begin
    if (pixel_tick) begin
        //Visible vertical range
        if (_v_counter >= 35 && _v_counter < 515) begin
            //Visible horizontal range
            if (_h_counter > 142 && _h_counter < 783) begin
                cur_pixel = pixel_buffer[_row >> 1][_col >> 1];
                cur_red = cur_pixel[0 +: 4];
                cur_green = cur_pixel[4 +: 4];
                cur_blue = cur_pixel[8 +: 4];
                _col <= _col + 1;
            end else if (_h_counter == 799) begin
                _col <= 0;
                _row <= _row + 1;
            end
        end else if (_v_counter >= 0 && _v_counter < 2) begin
            _row <= 0;
            _col <= 0;
        end
        
        if (_h_counter == 799) begin
            _v_counter <= (_v_counter + 1) % 525;
        end

        _h_counter <= (_h_counter + 1) % 800;
    end
end

assign VGA_HS_O = _h_counter >= 0 && _h_counter < 96;
assign VGA_VS_O = _v_counter >= 0 && _v_counter < 2;
assign VGA_R = cur_red;
assign VGA_G = cur_green;
assign VGA_B = cur_blue;
assign row = _row;
assign col = _col;
assign h_counter = _h_counter;
assign v_counter = _v_counter;

endmodule
