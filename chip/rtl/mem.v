module mem(
    input clk,
    input [2:0] state,
    input enabled,
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
    input [31:0] pc, 
    input [31:0] address,
    input [31:0] data_in,
    output [31:0] data_out,
    output [31:0] instr_out
);
    reg [31:0] mem [0:'hfff];
    reg [31:0] data;
    reg [31:0] _instr_out;
    reg [7:0] byte;
    reg [15:0] hword;

    initial begin
        $readmemh("code.mem", mem);
    end

    always @(posedge clk) begin
        if (state == 3'd1) begin
            _instr_out = mem[pc[31:2]];
        end else if (state == 3'd6 && enabled) begin
            if (load_enable) begin
                if (is_lb) begin
                    byte = mem[address[31:2]][{address[1:0], 3'b0} +: 8];
                    data <= { {24{byte[7]}}, byte };
                end else if (is_lh) begin
                    hword = mem[address[31:2]][{address[1], 4'b0} +: 16];
                    data <= { {16{hword[15]}}, hword };
                end else if (is_lbu) begin
                    data <= { 24'b0, mem[address[31:2]][{address[1:0], 3'b0} +: 8] };
                end else if (is_lhu) begin
                    data <= { 16'b0, mem[address[31:2]][{address[1], 4'b0} +: 16] };
                end else begin
                    data <= mem[address[31:2]];
                end
            end else if (store_enable) begin
                if (is_sb) begin
                    mem[address[31:2]][{address[1:0], 3'b0} +: 8] <= data_in[7:0];
                end else if (is_sh) begin
                    mem[address[31:2]][{address[1], 4'b0} +: 16] <= data_in[15:0];
                end else begin
                    mem[address[31:2]] <= data_in;
                end
            end
        end
    end

    assign data_out = data;
    assign instr_out = _instr_out;
endmodule
