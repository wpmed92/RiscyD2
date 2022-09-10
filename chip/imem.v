module imem(
    input [2:0] state, 
    input [31:0] pc, 
    output [31:0] instr_out
);
    reg [7:0] mem [0:1048575];
    reg [31:0] _instr_out;

    integer i;

    initial begin
        $readmemh("code.mem", mem);
    end

    always @(state) begin
        if (state == 3'd1) begin
            _instr_out = { mem[pc + 3], mem[pc + 2], mem[pc + 1], mem[pc] };
        end
    end

    assign instr_out = _instr_out;
endmodule
