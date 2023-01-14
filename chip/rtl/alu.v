`include "riscv_defs.v"

module alu(
    // Inputs
    input  [ 3:0] alu_opcode_i,
    input  [31:0] op_1_i,
    input  [31:0] op_2_i,

    // Outputs
    output reg [31:0] alu_result_o
);

reg [63:0] alu_temp_result;

always@* begin
    case(alu_opcode_i)
        `ALU_OP_ADD  : alu_result_o = op_1_i  + op_2_i;
        `ALU_OP_SUB  : alu_result_o = op_1_i  - op_2_i;
        `ALU_OP_OR   : alu_result_o = op_1_i  | op_2_i;
        `ALU_OP_XOR  : alu_result_o = op_1_i  ^ op_2_i;
        `ALU_OP_AND  : alu_result_o = op_1_i  & op_2_i;
        `ALU_OP_SLL  : alu_result_o = op_1_i << op_2_i;
        `ALU_OP_SRL  : alu_result_o = op_1_i >> op_2_i;
        `ALU_OP_SRA  : begin
            alu_temp_result = { {32{op_1_i[31]}}, op_1_i } >> op_2_i;
            alu_result_o    = alu_temp_result[31:0];
        end
        `ALU_OP_SLT  : alu_result_o = { 31'b0, (op_1_i < op_2_i) ^ (op_1_i[31] != op_2_i[31]) };
        `ALU_OP_SLTU : alu_result_o = { 31'b0, (op_1_i < op_2_i) };
        default      : alu_result_o = 0;

    endcase
end


endmodule