
module multiplier(
    // Inputs
    input [31:0] op1_i,
    input [31:0] op2_i,
    input is_mul_i,
    input is_mulh_i,
    input is_mulhsu_i,
    input is_mulhu_i,

    // Outputs
    output [31:0] product_o
);

reg  [32:0] multiplicand_r;
reg  [32:0] multiplier_r;
wire [64:0] product_w;


always@* begin
    if (is_mulhsu_i || is_mulh_i) begin
        multiplicand_r = { op1_i[31], op1_i[31:0] };
    end else begin
        multiplicand_r = { 1'b0, op1_i[31:0]  };
    end
end

always@* begin
    if (is_mulh_i) begin
        multiplier_r = { op2_i[31], op2_i[31:0] };
    end else begin
        multiplier_r = { 1'b0, op2_i[31:0]  };
    end
end

assign product_w = { {32{multiplicand_r[32]}},  multiplicand_r } * { {32{multiplier_r[32]}},  multiplier_r };

assign product_o = is_mul_i ? product_w[31:0] : product_w[63:32];

endmodule
