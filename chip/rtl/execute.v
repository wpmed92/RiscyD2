`include "riscv_defs.v"

module execute(
    // Inputs
    input clk_i,
    input [ 2:0] state_i,
    input [31:0] rs1_val_i,
    input [31:0] rs2_val_i,
    input [31:0] imm_i,
    input [31:0] pc_i,
    input [45:0] decode_net_i,

    // Outputs
    output [31:0] writeback_value_o,
    output [31:0] address_o,
    output   branch_taken_o,
    output   should_stall_ex_o
);
    reg [ 3:0] alu_opcode_r;
    reg [31:0] alu_op_1_r;
    reg [31:0] alu_op_2_r;

    wire is_branch_w = decode_net_i[`IS_BEQ] || decode_net_i[`IS_BNE] || decode_net_i[`IS_BGE] || decode_net_i[`IS_BGEU] || decode_net_i[`IS_BLT] ||
                       decode_net_i[`IS_BLTU];

    wire is_store_w = decode_net_i[`IS_SB] || decode_net_i[`IS_SH]  || decode_net_i[`IS_SW];
    wire is_load_w  = decode_net_i[`IS_LB] || decode_net_i[`IS_LBU] || decode_net_i[`IS_LH] || decode_net_i[`IS_LHU] || decode_net_i[`IS_LW];


    always @* begin
        if (decode_net_i[`IS_ADDI]) begin
            alu_opcode_r <= `ALU_OP_ADD;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_ADD]) begin
            alu_opcode_r <= `ALU_OP_ADD;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_SUB]) begin
            alu_opcode_r <= `ALU_OP_SUB;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_OR]) begin
            alu_opcode_r <= `ALU_OP_OR;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_ORI]) begin
            alu_opcode_r <= `ALU_OP_OR;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_XOR]) begin
            alu_opcode_r <= `ALU_OP_XOR;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_XORI]) begin
            alu_opcode_r <= `ALU_OP_XOR;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_AND]) begin
            alu_opcode_r <= `ALU_OP_AND;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_ANDI]) begin
            alu_opcode_r <= `ALU_OP_AND;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_SLL]) begin
            alu_opcode_r <= `ALU_OP_SLL;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_SLLI]) begin
            alu_opcode_r <= `ALU_OP_SLL;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i[4:0];
        end else if (decode_net_i[`IS_SRL]) begin
            alu_opcode_r <= `ALU_OP_SRL;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_SRLI]) begin
            alu_opcode_r <= `ALU_OP_SRL;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i[4:0];
        end else if (decode_net_i[`IS_SRA]) begin
            alu_opcode_r <= `ALU_OP_SRA;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_SRAI]) begin
            alu_opcode_r <= `ALU_OP_SRA;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i[4:0];
        end else if (decode_net_i[`IS_SLT]) begin
            alu_opcode_r <= `ALU_OP_SLT;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_SLTU]) begin
            alu_opcode_r <= `ALU_OP_SLTU;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= rs2_val_i;
        end else if (decode_net_i[`IS_SLTI]) begin
            alu_opcode_r <= `ALU_OP_SLT;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_SLTIU]) begin
            alu_opcode_r <= `ALU_OP_SLTU;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_AUIPC]) begin
            alu_opcode_r <= `ALU_OP_ADD;
            alu_op_1_r   <= pc_i;
            alu_op_2_r   <= imm_i;
        end else if (decode_net_i[`IS_JAL] || decode_net_i[`IS_JALR]) begin
            alu_opcode_r <= `ALU_OP_ADD;
            alu_op_1_r   <= pc_i;
            alu_op_2_r   <= 32'd4;
        end else if (decode_net_i[`IS_LUI]) begin
            alu_opcode_r <= `ALU_OP_ADD;
            alu_op_1_r   <= imm_i;
            alu_op_2_r   <= 32'd0;
        end else if (is_load_w || is_store_w) begin
            alu_opcode_r <= `ALU_OP_ADD;
            alu_op_1_r   <= rs1_val_i;
            alu_op_2_r   <= imm_i;
        end
    end

    wire [31:0] alu_result_w;

    alu alu_inst(
        .alu_opcode_i(alu_opcode_r),
        .op_1_i(alu_op_1_r),
        .op_2_i(alu_op_2_r),
        .alu_result_o(alu_result_w)
    );

`ifdef M_EXTENSION
    wire [31:0] mul_res_w;
    wire [31:0] div_res_w;
    wire is_mul = decode_net_i[`IS_MUL] || decode_net_i[`IS_MULH] || decode_net_i[`IS_MULHSU] || decode_net_i[`IS_MULHU];
    wire is_div = decode_net_i[`IS_DIV] || decode_net_i[`IS_DIVU] || decode_net_i[`IS_REM]    || decode_net_i[`IS_REMU];

    multiplier multiplier_inst(
        .op1_i(rs1_val_i),
        .op2_i(rs2_val_i),
        .is_mul_i(decode_net_i[`IS_MUL]),
        .is_mulh_i(decode_net_i[`IS_MULH]),
        .is_mulhsu_i(decode_net_i[`IS_MULHSU]),
        .is_mulhu_i(decode_net_i[`IS_MULHU]),
        .product_o(mul_res_w)
    );

    divider divider_inst(
        .clk_i(clk_i),
        .state_i(state_i),
        .op1_i(rs1_val_i),
        .op2_i(rs2_val_i),
        .is_div_i(decode_net_i[`IS_DIV]),
        .is_divu_i(decode_net_i[`IS_DIVU]),
        .is_rem_i(decode_net_i[`IS_REM]),
        .is_remu_i(decode_net_i[`IS_REMU]),
        .writeback_val_o(div_res_w),
        .should_stall_ex_o(should_stall_ex_o)
    );
`endif

`ifndef M_EXTENSION
    assign should_stall_ex_o = 0;
`endif

    reg taken_branch_r = 0;
    reg [31:0] address_r = 0;

    always @* begin
        if (decode_net_i[`IS_BEQ]) begin
            taken_branch_r <= rs1_val_i == rs2_val_i;
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BNE]) begin
            taken_branch_r <= rs1_val_i != rs2_val_i;
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BGE]) begin
            taken_branch_r <= (rs1_val_i >= rs2_val_i) ^ (rs1_val_i[31] != rs2_val_i[31]);
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BGEU]) begin
            taken_branch_r <= rs1_val_i >= rs2_val_i;
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BLT]) begin
            taken_branch_r <= (rs1_val_i < rs2_val_i) ^ (rs1_val_i[31] != rs2_val_i[31]);
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BLTU]) begin
            taken_branch_r <= rs1_val_i < rs2_val_i;
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_JAL]) begin
            taken_branch_r <= 1;
            address_r      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_JALR]) begin
            taken_branch_r <= 1;
            address_r      <= rs1_val_i + imm_i;
        end else begin
            taken_branch_r <= 0;
        end
    end

    assign address_o = (                                      is_load_w ||  is_store_w) ?  alu_result_w :
                       (decode_net_i[`IS_JALR] || decode_net_i[`IS_JAL] || is_branch_w) ?  address_r    :
                                                                                                32'd0;

    assign writeback_value_o = 
`ifdef M_EXTENSION
                                is_div                                  ? div_res_w    :
                                is_mul                                  ? mul_res_w    :
`endif
                              ~(is_load_w || is_store_w || is_branch_w) ? alu_result_w :
                                                                                      0;
    assign branch_taken_o = taken_branch_r;
endmodule
