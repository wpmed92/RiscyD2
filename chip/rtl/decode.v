`include "riscv_defs.v"
`include "extension_defs.v"
`include "constant_defs.v"

module decode(
    // Inputs
    input [31:0] instr_i, 

    // Outputs
    output [4:0] rs1_o,
    output rs1_valid_o,
    output [4:0] rs2_o,
    output rs2_valid_o,
    output [4:0] rd_o,
    output rd_valid_o,
    output [31:0] imm_o,
    output [45:0] decode_net_o
);    
    wire is_i_type_q = (instr_i[6:2] == 5'b00000) || (instr_i[6:2] == 5'b00100) || (instr_i[6:2] == 5'b11001) || (instr_i[6:2] == 5'b11100);
    wire is_r_type_q = instr_i[6:2] == 5'b01100;
    wire is_b_type_q = instr_i[6:2] == 5'b11000;
    wire is_s_type_q = instr_i[6:2] == 5'b01000;
    wire is_j_type_q = instr_i[6:2] == 5'b11011;
    wire is_u_type_q = (instr_i[6:2] == 5'b01101) || (instr_i[6:2] == 5'b00101);

    assign rs1_valid_o = !is_u_type_q && !is_j_type_q;
    assign rs2_valid_o = is_s_type_q || is_r_type_q || is_b_type_q;
    assign rd_valid_o  = !is_s_type_q && !is_b_type_q;

    assign imm_o = is_i_type_q ? { {21{instr_i[31]}}, instr_i[30:20] } :
                   is_b_type_q ? { {20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0 } :
                   is_s_type_q ? { {21{instr_i[31]}}, instr_i[30:25], instr_i[11:7] } :
                   is_j_type_q ? { {12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0  } :
                   is_u_type_q ? { instr_i[31:12], 12'b0 } :
                                                    31'd0;
                                                    
    // Order has to be in-line with index definitions in riscv_defs.v
    assign decode_net_o = {
        // I-type ALU
        (instr_i & `INST_ANDI_MASK)  == `INST_ANDI,
        (instr_i & `INST_ADDI_MASK)  == `INST_ADDI,
        (instr_i & `INST_SLTI_MASK)  == `INST_SLTI,
        (instr_i & `INST_SLTIU_MASK) == `INST_SLTIU,
        (instr_i & `INST_ORI_MASK)   == `INST_ORI,
        (instr_i & `INST_XORI_MASK)  == `INST_XORI,
        (instr_i & `INST_SLLI_MASK)  == `INST_SLLI,
        (instr_i & `INST_SRLI_MASK)  == `INST_SRLI,
        (instr_i & `INST_SRAI_MASK)  == `INST_SRAI,
        (instr_i & `INST_LUI_MASK)   == `INST_LUI,
        (instr_i & `INST_AUIPC_MASK) == `INST_AUIPC,

        // R-type ALU
        (instr_i & `INST_AND_MASK)   == `INST_AND,
        (instr_i & `INST_ADD_MASK)   == `INST_ADD,
        (instr_i & `INST_SLT_MASK)   == `INST_SLT,
        (instr_i & `INST_SLTU_MASK)  == `INST_SLTU,
        (instr_i & `INST_OR_MASK)    == `INST_OR,
        (instr_i & `INST_XOR_MASK)   == `INST_XOR,
        (instr_i & `INST_SLL_MASK)   == `INST_SLL,
        (instr_i & `INST_SRL_MASK)   == `INST_SRL,
        (instr_i & `INST_SRA_MASK)   == `INST_SRA,
        (instr_i & `INST_SUB_MASK)   == `INST_SUB,

        // Branch
        (instr_i & `INST_BEQ_MASK)  == `INST_BEQ,
        (instr_i & `INST_BNE_MASK)  == `INST_BNE,
        (instr_i & `INST_BGE_MASK)  == `INST_BGE,
        (instr_i & `INST_BGEU_MASK) == `INST_BGEU,
        (instr_i & `INST_BLT_MASK)  == `INST_BLT,
        (instr_i & `INST_BLTU_MASK) == `INST_BLTU,
        (instr_i & `INST_JAL_MASK)  == `INST_JAL,
        (instr_i & `INST_JALR_MASK) == `INST_JALR,

        // Load/Store
        (instr_i & `INST_LB_MASK)  == `INST_LB,
        (instr_i & `INST_LBU_MASK) == `INST_LBU,
        (instr_i & `INST_LH_MASK)  == `INST_LH,
        (instr_i & `INST_LHU_MASK) == `INST_LHU,
        (instr_i & `INST_LW_MASK)  == `INST_LW,
        (instr_i & `INST_SB_MASK)  == `INST_SB,
        (instr_i & `INST_SH_MASK)  == `INST_SH,
        (instr_i & `INST_SW_MASK)  == `INST_SW,

        // Mul/Div
        (instr_i & `INST_MUL_MASK)    == `INST_MUL,
        (instr_i & `INST_MULH_MASK)   == `INST_MULH,
        (instr_i & `INST_MULHSU_MASK) == `INST_MULHSU,
        (instr_i & `INST_MULHU_MASK)  == `INST_MULHU,
        (instr_i & `INST_DIV_MASK)    == `INST_DIV,
        (instr_i & `INST_DIVU_MASK)   == `INST_DIVU,
        (instr_i & `INST_REM_MASK)    == `INST_REM,
        (instr_i & `INST_REMU_MASK)   == `INST_REMU,

        // CSR
        (instr_i & `INST_CSRRS_MASK) == `INST_CSRRS
    };

    assign rs1_o = instr_i[19:15];
    assign rs2_o = instr_i[24:20];
    assign rd_o  = instr_i[11:7];
   
endmodule
