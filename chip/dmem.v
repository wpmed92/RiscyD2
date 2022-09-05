module dmem(
    input [2:0] state,
    input load_enable,
    input store_enable,
    input is_lb,
    input is_lbu,
    input is_lh,
    input is_lhu,
    input is_lw,
    input is_sb,
    input is_sh,
    input is_sw,
    input [31:0] data_in,
    input [31:0] address, 
    output [31:0] data_out
);
    // 1Mb dmem
    reg [7:0] mem [0:1048575];
    reg [31:0] data;
    
    integer i;

    always @(state) begin
        if (state == 3'd6) begin
            if (load_enable) begin
                if (is_lb) begin
                    data <= { {24{mem[address][7]}}, mem[address] };
                end else if (is_lh) begin
                    data <= { {16{mem[address][15]}}, mem[address + 1], mem[address] };
                end else if (is_lbu) begin
                    data <= { 24'b0, mem[address] };
                end else if (is_lhu) begin
                    data <= { 16'b0, mem[address + 1], mem[address] };
                end else begin
                    data <= { mem[address + 3], mem[address + 2], mem[address + 1], mem[address] };  
                end
            end else if (store_enable) begin
                if (is_sb) begin
                    mem[address] = data_in[7:0];
                end else if (is_sh) begin
                    mem[address] = data_in[7:0];
                    mem[address + 1] = data_in[15:8];
                end else begin
                    mem[address] = data_in[7:0];
                    mem[address + 1] = data_in[15:8];
                    mem[address + 2] = data_in[23:16];
                    mem[address + 3] = data_in[31:24];
                end

                //for (i = 0; i < 22; i = i + 1)
                //   $display("%d:%h", i, mem[i]);
            end
        end
    end

    assign data_out = data;
endmodule
