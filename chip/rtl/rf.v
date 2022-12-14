`include "constant_defs.v"
`include "extension_defs.v"

module rf(
    input clk,
    input [2:0] state,
    input rs1_en, 
    input [4:0] rs1,
    output [31:0] rs1_val, 
    input rs2_en, 
    input [4:0] rs2,
    output [31:0] rs2_val, 
    input rd_en,
    input [4:0] rd,
    input is_load,
    input is_csr,
    input [31:0] alu_result,
    input [31:0] load_result,
    input [31:0] csr_val
);
    reg [31:0] registers[0:31];

    reg [31:0] _rs1_val;
    reg [31:0] _rs2_val;

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 0;
    end

    always @(posedge clk) begin
        if (state == `REG_FILE_READ) begin
            _rs1_val <= rs1_en ? registers[rs1] : 0;
            _rs2_val <= rs2_en ? registers[rs2] : 0;
        end else if (state == `WRITE_BACK && rd_en && rd != 0) begin
            registers[rd] = is_load ? load_result : 
                            is_csr  ? csr_val :
                            alu_result;
       `ifdef ISA_TEST
            for (i = 0; i < 32; i = i + 1)
               $display("%d:%h", i, registers[i]);
        `endif
        end
    end

    assign rs1_val = _rs1_val;
    assign rs2_val = _rs2_val;
endmodule