`include "riscv_defs.v"

module decode(
    input [31:0] instr, 
    output [4:0] rs1,
    output rs1_valid,
    output [4:0] rs2,
    output rs2_valid,
    output [4:0] rd,
    output rd_valid,
    output [31:0] imm,
    output is_i_type,
    output is_r_type,
    output is_s_type,
    output is_b_type,
    output is_u_type,
    output is_j_type,
    output is_load,
    output is_store,
    output is_lb,
    output is_lh,
    output is_lw,
    output is_sb,
    output is_sh,
    output is_sw,
    output is_lbu,
    output is_lhu,
    output is_addi,
    output is_slti,
    output is_sltiu,
    output is_xori,
    output is_ori,
    output is_andi,
    output is_slli,
    output is_srli,
    output is_srai,
    output is_add,
    output is_sub,
    output is_sll,
    output is_slt,
    output is_sltu,
    output is_xor,
    output is_srl,
    output is_sra,
    output is_or,
    output is_and,
    output is_mul,
    output is_mulh,
    output is_mulhsu,
    output is_mulhu,
    output is_div,
    output is_divu,
    output is_rem,
    output is_remu,
    output is_auipc,
    output is_lui,
    output is_beq,
    output is_bne,
    output is_bge,
    output is_bgeu,
    output is_blt,
    output is_bltu,
    output is_jal,
    output is_jalr
);    
    wire is_i_type_q = (instr[6:2] == 5'b00000) || (instr[6:2] == 5'b00100) || (instr[6:2] == 5'b11001);
    wire is_r_type_q = instr[6:2] == 5'b01100;
    wire is_b_type_q = instr[6:2] == 5'b11000;
    wire is_s_type_q = instr[6:2] == 5'b01000;
    wire is_j_type_q = instr[6:2] == 5'b11011;
    wire is_u_type_q = (instr[6:2] == 5'b01101) || (instr[6:2] == 5'b00101);

    wire [4:0] rs1_q = instr[19:15];
    wire [4:0] rs2_q = instr[24:20];
    wire [4:0] rd_q = instr[11:7];

    assign rs1_valid = !is_u_type_q && !is_j_type_q;
    assign rs2_valid = is_s_type_q || is_r_type_q || is_b_type_q;
    assign rd_valid = !is_s_type_q && !is_b_type_q;

    assign imm = is_i_type_q ? { {21{instr[31]}}, instr[30:20] } :
                 is_b_type_q ? { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 } :
                 is_s_type_q ? { {21{instr[31]}}, instr[30:25], instr[11:7] } :
                 is_j_type_q ? { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0  } :
                 is_u_type_q ? { instr[31:12], 12'b0 } :
                                                31'd0;

    wire [11:0] decode_bits = { instr[30], instr[14:12], instr[6:0] };

    // TODO: refactor separate scalar net decode entitites intto a single vector net
    // This simplifies passing the decoded entitites to other modules. To simplify indexing
    // into the vector net, constants for the indexes can be defined, like `define IS_ADDI 3

    // Load/store
    assign dec_out  = (instr & `INST_LB_MASK)  == `INST_LB;
    assign is_lh    = (instr & `INST_LH_MASK)  == `INST_LH;
    assign is_lw    = (instr & `INST_LW_MASK)  == `INST_LW;
    assign is_lbu   = (instr & `INST_LBU_MASK) == `INST_LBU;
    assign is_lhu   = (instr & `INST_LHU_MASK) == `INST_LHU;
    assign is_sb    = (instr & `INST_SB_MASK)  == `INST_SB;
    assign is_sh    = (instr & `INST_SH_MASK)  == `INST_SH;
    assign is_sw    = (instr & `INST_SW_MASK)  == `INST_SW;
    assign is_load  = instr[6:2] == 5'b00000;
    assign is_store = instr[6:2] == 5'b01000;

    // I-type arithmetic
    assign is_addi  = (instr & `INST_ADDI_MASK)  == `INST_ADDI;
    assign is_slti  = (instr & `INST_SLTI_MASK)  == `INST_SLTI;
    assign is_sltiu = (instr & `INST_SLTIU_MASK) == `INST_SLTIU;
    assign is_xori  = (instr & `INST_XORI_MASK)  == `INST_XORI;
    assign is_ori   = (instr & `INST_ORI_MASK)   == `INST_ORI;
    assign is_andi  = (instr & `INST_ANDI_MASK)  == `INST_ANDI;
    assign is_slli  = (instr & `INST_SLLI_MASK)  == `INST_SLLI;
    assign is_srli  = (instr & `INST_SRLI_MASK)  == `INST_SRLI;
    assign is_srai  = (instr & `INST_SRAI_MASK)  == `INST_SRAI;

    // R-type arithmetic
    assign is_add  = (instr & `INST_ADD_MASK)  == `INST_ADD;
    assign is_sub  = (instr & `INST_SUB_MASK)  == `INST_SUB;
    assign is_sll  = (instr & `INST_SLL_MASK)  == `INST_SLL;
    assign is_slt  = (instr & `INST_SLT_MASK)  == `INST_SLT;
    assign is_sltu = (instr & `INST_SLTU_MASK) == `INST_SLTU;
    assign is_xor  = (instr & `INST_XOR_MASK)  == `INST_XOR;
    assign is_srl  = (instr & `INST_SRL_MASK)  == `INST_SRL;
    assign is_sra  = (instr & `INST_SRA_MASK)  == `INST_SRA;
    assign is_or   = (instr & `INST_OR_MASK)   == `INST_OR;
    assign is_and  = (instr & `INST_AND_MASK)  == `INST_AND;

    //RV32M
    assign is_mul    = (instr & `INST_MUL_MASK)    == `INST_MUL;
    assign is_mulh   = (instr & `INST_MULH_MASK)   == `INST_MULH;
    assign is_mulhsu = (instr & `INST_MULHSU_MASK) == `INST_MULHSU;
    assign is_mulhu  = (instr & `INST_MULHU_MASK)  == `INST_MULHU;
    assign is_div    = (instr & `INST_DIV_MASK)    == `INST_DIV;
    assign is_divu   = (instr & `INST_DIVU_MASK)   == `INST_DIVU;
    assign is_rem    = (instr & `INST_REM_MASK)    == `INST_REM;
    assign is_remu   = (instr & `INST_REMU_MASK)   == `INST_REMU;

    // Branch
    assign is_beq  = (instr & `INST_BEQ_MASK)  == `INST_BEQ;
    assign is_bne  = (instr & `INST_BNE_MASK)  == `INST_BNE;
    assign is_bge  = (instr & `INST_BGE_MASK)  == `INST_BGE;
    assign is_bgeu = (instr & `INST_BGEU_MASK) == `INST_BGEU;
    assign is_blt  = (instr & `INST_BLT_MASK)  == `INST_BLT;
    assign is_bltu = (instr & `INST_BLTU_MASK) == `INST_BLTU;

    // Jump
    assign is_jal =  instr[6:2] == 5'b11011;
    assign is_jalr = instr[6:2] == 5'b11001;

    assign is_auipc = instr[6:2] == 5'b00101;
    assign is_lui   = instr[6:2] == 5'b01101;

    assign is_i_type = is_i_type_q;
    assign is_r_type = is_r_type_q;
    assign is_b_type = is_b_type_q;
    assign is_s_type = is_s_type_q;
    assign is_j_type = is_j_type_q;
    assign is_u_type = is_u_type_q;

    assign rs1 = rs1_q;
    assign rs2 = rs2_q;
    assign rd = rd_q;
   
endmodule
