`include "constant_defs.v"
`include "extension_defs.v"

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
    reg [31:0] registers_r[0:31];

    reg [31:0] rs1_val_r;
    reg [31:0] rs2_val_r;

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers_r[i] = 0;
    end

    always @(posedge clk_i) begin
        if (state_i == `REG_FILE_READ) begin
            rs1_val_r <= rs1_en_i ? registers_r[rs1_i] : 0;
            rs2_val_r <= rs2_en_i ? registers_r[rs2_i] : 0;
        end else if (state_i == `WRITE_BACK && rd_en_i && rd_i != 0) begin
            registers_r[rd_i] = is_load_i ? load_result_i : 
                                is_csr_i  ? csr_val_i :
                                alu_result_i;
       `ifdef ISA_TEST
            for (i = 0; i < 32; i = i + 1)
               $display("%d:%h", i, registers_r[i]);
        `endif
        end
    end

    assign rs1_val_o = rs1_val_r;
    assign rs2_val_o = rs2_val_r;
endmodule