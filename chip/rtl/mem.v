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
    reg [7:0] mem [0:'hfff];
    reg [31:0] data;
    reg [31:0] _instr_out;

    initial begin
        $readmemh("code.mem", mem);
    end

    always @(posedge clk) begin
        if (state == 3'd1) begin
            _instr_out <= { mem[pc + 3], mem[pc + 2], mem[pc + 1], mem[pc] };
        end else if (state == 3'd6 && enabled) begin
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
                    mem[address] <= data_in[7:0];
                end else if (is_sh) begin
                    mem[address] <= data_in[7:0];
                    mem[address + 1] <= data_in[15:8];
                end else begin
                    mem[address] <= data_in[7:0];
                    mem[address + 1] <= data_in[15:8];
                    mem[address + 2] <= data_in[23:16];
                    mem[address + 3] <= data_in[31:24];
                end
            end
        end
    end

    assign data_out = data;
    assign instr_out = _instr_out;
endmodule
