`include "riscv_defs.v"

module multiplier_tb();
    parameter CLK_PERIOD = 10;

    reg clk;

     // Inputs
    reg [31:0] rs1_val;
    reg [31:0] rs2_val;
    reg is_mul;
    reg is_mulh;
    reg is_mulhsu;
    reg is_mulhu;

    // Outputs
    wire [31:0] product;

    multiplier multiplier_inst(
        .op1_i(rs1_val),
        .op2_i(rs2_val),
        .is_mul_i(is_mul),
        .is_mulh_i(is_mulh),
        .is_mulhsu_i(is_mulhsu),
        .is_mulhu_i(is_mulhu),
        .product_o(product)
    );

    integer out_data;

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $monitor("\t%d:\t%d * %d = %d",
            $time, rs1_val, rs2_val, product);
    end

    initial begin
        clk = 1;

        #10 rs1_val = 32'd2;
            rs2_val = 32'd8;
            is_mul = 1;
            is_mulh = 0;
            is_mulhsu = 0;
            is_mulhu = 0;

        #10 rs1_val = 32'hFFFFFFFF;
            rs2_val = 32'hFFFFFFFF;
            is_mul = 1;
            is_mulh = 0;
            is_mulhsu = 0;
            is_mulhu = 0;

        #10 rs1_val = 32'hFFFFFFFF;
            rs2_val = 32'hFFFFFFFF;
            is_mul = 0;
            is_mulh = 1;
            is_mulhsu = 0;
            is_mulhu = 0;

        #10 rs1_val = 32'hFFFFFFFF;
            rs2_val = 32'hFFFFFFFF;
            is_mul = 0;
            is_mulh = 0;
            is_mulhsu = 1;
            is_mulhu = 0;

        #10 rs1_val = 32'hFFFFFFFF;
            rs2_val = 32'hFFFFFFFF;
            is_mul = 0;
            is_mulh = 0;
            is_mulhsu = 0;
            is_mulhu = 1;

        # 10 $finish;
    
    end
endmodule