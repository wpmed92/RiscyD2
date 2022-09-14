`include "imem.v"
`include "rf.v"
`include "decode.v"
`include "alu.v"
`include "dmem.v"
`include "branch.v"

module cpu(input CLK100MHZ, output [3:0] led);
    reg[31:0] pc = -4;
    reg read_en;
    wire [31:0] instr;

    reg [2:0] state = 0;
    reg blink = 0;

    // clk will increase state
    // 1 = fetch (imem)
    // 2 = decode (decode)
    // 3 = operand read (rf)
    // 4 = calculation (address or arithmetic, performed by alu)
    // 5 = load/store (dmem)
    // 6 = write back to destination register (rf)

    // Decode
    wire [4:0] rs1;
    wire rs1_en;
    wire [4:0] rs2;
    wire rs2_en;
    wire [4:0] rd;
    wire rd_en;
    wire [31:0] imm;

    wire [31:0] address;
    wire [31:0] alu_result;
    wire [31:0] load_result;
    wire [31:0] rs1_val;
    wire [31:0] rs2_val;

    wire is_i_type;
    wire is_r_type;
    wire is_s_type;
    wire is_b_type;
    wire is_u_type;
    wire is_j_type;

    // I-type arithmetic
    wire is_addi;
    wire is_slti;
    wire is_sltiu;
    wire is_xori;
    wire is_ori;
    wire is_andi;
    wire is_slli;
    wire is_srli;
    wire is_srai;

    // R-type arithmetic
    wire is_add;
    wire is_sub;
    wire is_sll;
    wire is_slt;
    wire is_sltu;
    wire is_xor;
    wire is_srl;
    wire is_sra;
    wire is_or;
    wire is_and;
    wire is_auipc;
    wire is_lui;

    // Load/store
    wire is_load;
    wire is_store;
    wire is_lb;
    wire is_lh;
    wire is_lw;
    wire is_lbu;
    wire is_lhu;
    wire is_sb;
    wire is_sh;
    wire is_sw;

    // Branch
    wire is_beq;
    wire is_bne;
    wire is_bge;
    wire is_bgeu;
    wire is_blt;
    wire is_bltu;

    // Jump
    wire is_jal;
    wire is_jalr;

    // Instruction fetch
    imem mem(state, pc, instr);

    // Decode
    decode dec(
        state,
        instr,
        rs1,
        rs1_en,
        rs2,
        rs2_en,
        rd,
        rd_en,
        imm,
        is_i_type,
        is_r_type,
        is_s_type,
        is_b_type,
        is_u_type,
        is_j_type,
        is_load,
        is_store,
        is_lb,
        is_lh,
        is_lw,
        is_sb,
        is_sh,
        is_sw,
        is_lbu,
        is_lhu,
        is_addi,
        is_slti,
        is_sltiu,
        is_xori,
        is_ori,
        is_andi,
        is_slli,
        is_srli,
        is_srai,
        is_add,
        is_sub,
        is_sll,
        is_slt,
        is_sltu,
        is_xor,
        is_srl,
        is_sra,
        is_or,
        is_and,
        is_auipc,
        is_lui,
        is_beq,
        is_bne,
        is_bge,
        is_bgeu,
        is_blt,
        is_bltu,
        is_jal,
        is_jalr
    );

    rf register_file(
        state,
        rs1_en, 
        rs1, 
        rs1_val, 
        rs2_en,
        rs2,
        rs2_val,
        rd_en,
        rd,
        is_load,
        alu_result,
        load_result
    );

    alu calc(
        state,
        rs1_val,
        rs2_val,
        imm,
        pc,
        is_addi,
        is_slti,
        is_sltiu,
        is_xori,
        is_ori,
        is_andi,
        is_slli,
        is_srli,
        is_srai,
        is_add,
        is_sub,
        is_sll,
        is_slt,
        is_sltu,
        is_xor,
        is_srl,
        is_sra,
        is_or,
        is_and,
        is_auipc,
        is_lui,
        is_load,
        is_store,
        is_b_type,
        is_jal,
        is_jalr,
        alu_result,
        address
    );

    dmem data(
        state,
        is_load,
        is_store,
        is_lb,
        is_lbu,
        is_lh,
        is_lhu,
        is_lw,
        is_sb,
        is_sh,
        is_sw,
        rs2_val,
        address,
        load_result
    );

    branch b(
        state,
        rs1_val,
        rs2_val,
        is_beq,
        is_bne,
        is_bge,
        is_bgeu,
        is_blt,
        is_bltu,
        is_jal,
        is_jalr,
        taken_branch
    );

    always @ (posedge CLK100MHZ) begin
        if (state == 3'd7) begin
            pc = taken_branch ? address : (pc + 4);
        end

        if (rd == 2) begin
            blink = alu_result[0];
        end
        
        state = (state % 7) + 1;
    end

    assign led[0] = blink;

endmodule
