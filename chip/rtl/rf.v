`include "riscv_defs.v"

module rf(
    // Inputs
    input clk_i,
    input [2:0] state_i,
    input rs1_en_i, 
    input [4:0] rs1_i,
    input rs2_en_i, 
    input [4:0] rs2_i,
    input rd_en_i,
    input [4:0] rd_i,
    input [4:0] is_load_i,
    input is_csr_i,
    input [31:0] alu_result_i,
    input [31:0] load_result_i,
    input [31:0] csr_val_i,

    // Outputs
    output [31:0] rs1_val_o,
    output [31:0] rs2_val_o
);
    reg [31:0] registers_q[0:31];

    reg [31:0] rs1_val_q;
    reg [31:0] rs2_val_q;

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers_q[i] = 0;
    end

    always @(posedge clk_i) begin
        if (state_i == `EXECUTE_1) begin
            rs1_val_q <= rs1_en_i ? registers_q[rs1_i] : 0;
            rs2_val_q <= rs2_en_i ? registers_q[rs2_i] : 0;
        end else if (state_i == `WRITE_BACK && rd_en_i && rd_i != 0) begin
            registers_q[rd_i] = is_load_i ? load_result_i : 
                                is_csr_i  ? csr_val_i :
                                alu_result_i;
       `ifdef ISA_TEST
            for (i = 0; i < 32; i = i + 1)
               $display("%d:%h", i, registers_q[i]);
        `endif
        end
    end

    assign rs1_val_o = rs1_val_q;
    assign rs2_val_o = rs2_val_q;
endmodule