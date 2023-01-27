`include "riscv_defs.v"

// Implements long division
// source: https://projectf.io/posts/division-in-verilog/
module divider(
    // Inputs
    input clk_i,
    input [2:0] state_i,
    input [31:0] op1_i,
    input [31:0] op2_i,
    input is_div_i,
    input is_divu_i,
    input is_rem_i,
    input is_remu_i,

    // Outputs
    output [31:0] writeback_val_o,  
    output should_stall_ex_o
);

reg [31:0] dividend_q;
reg [31:0] divisor_q;
reg [31:0] quotient_q;
reg [31:0] remainder_q;

reg [31:0] divisor_cpy_r;
reg [31:0] tmp_quotient_r, tmp_quotient_next_r;
reg [32:0] ac_r, ac_next_r;
reg [4:0] i;

reg start_q = 0;
reg busy_q = 0;
reg valid_q = 0;
reg dbz_q = 0;

always@* begin
    if (ac_r >= {1'b0, divisor_cpy_r}) begin
        ac_next_r = ac_r - divisor_cpy_r;
        { ac_next_r, tmp_quotient_next_r } = { ac_next_r[31:0], tmp_quotient_r, 1'b1 };
    end else begin
        { ac_next_r, tmp_quotient_next_r } = { ac_r, tmp_quotient_r } << 1;
    end
end

always@(posedge clk_i) begin
    if (start_q) begin
        valid_q <= 0;
        i <= 0;
        if (divisor_q == 0) begin
            busy_q <= 0;
            dbz_q <= 1;
        end else begin
            busy_q <= 1;
            dbz_q <= 0;
            divisor_cpy_r <= divisor_q;
            { ac_r, tmp_quotient_r } <= { {32{1'b0}}, dividend_q, 1'b0 };
        end
    end else if (busy_q) begin
        if (i == 31) begin
            busy_q <= 0;
            valid_q <= 1;
            quotient_q <= tmp_quotient_next_r;
            remainder_q <= ac_next_r[32:1];
        end else begin
            i <= i + 1;
            ac_r <= ac_next_r;
            tmp_quotient_r <= tmp_quotient_next_r;
        end
    end
end

always@* begin
    if (is_div_i || is_rem_i) begin
        dividend_q = (op1_i[31]) ? -op1_i : op1_i;
    end else begin
        dividend_q = op1_i;
    end  
end

always@* begin
    if (is_div_i || is_rem_i) begin
        divisor_q  = (op2_i[31]) ? -op2_i : op2_i;
    end else begin
        divisor_q = op2_i;
    end  
end

reg div_triggered_q = 0;
reg [31:0] result_q = 0;
wire div_enabled_w = is_div_i || is_divu_i || is_rem_i || is_remu_i;
reg should_stall_q = 0;

always @(posedge clk_i) begin
    if (state_i == `EXECUTE_2 && div_enabled_w) begin
        if (~div_triggered_q) begin
            start_q <= 1;
            div_triggered_q <= 1;
            should_stall_q <= 1;
        end else if (start_q) begin
            start_q <= 0;
        end else if (valid_q) begin
            result_q <= (is_div_i || is_divu_i) ? quotient_q : remainder_q;
            should_stall_q <= 0;
        end
    end else if (state_i == `WRITE_BACK && div_enabled_w) begin
        div_triggered_q <= 0;
    end
end

assign writeback_val_o   = (op1_i[31] ^ op2_i[31]) ? -result_q : result_q;
assign should_stall_ex_o = should_stall_q;

endmodule
