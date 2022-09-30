module decode(
    input clk,
    input [2:0] state,
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
    reg _is_i_type;
    reg _is_r_type;
    reg _is_b_type;
    reg _is_s_type;
    reg _is_j_type;
    reg _is_u_type;

    reg _rs1_valid;
    reg _rs2_valid;
    reg _rd_valid;

    reg [4:0] _rs1;
    reg [4:0] _rs2;
    reg [4:0] _rd;
    reg [31:0] _imm;

    reg _is_addi;
    reg _is_slti;
    reg _is_sltiu;
    reg _is_xori;
    reg _is_ori;
    reg _is_andi;
    reg _is_slli;
    reg _is_srli;
    reg _is_srai;

    reg _is_load;
    reg _is_store;
    reg _is_lb;
    reg _is_lh;
    reg _is_lbu;
    reg _is_lhu;
    reg _is_lw;
    reg _is_sb;
    reg _is_sh;
    reg _is_sw;

    reg _is_add;
    reg _is_sub;
    reg _is_sll;
    reg _is_slt;
    reg _is_sltu;
    reg _is_xor;
    reg _is_srl;
    reg _is_sra;
    reg _is_or;
    reg _is_and;

    reg _is_auipc;
    reg _is_lui;

    reg _is_beq;
    reg _is_bne;
    reg _is_bge;
    reg _is_bgeu;
    reg _is_blt;
    reg _is_bltu;

    reg _is_jal;
    reg _is_jalr;

    reg [10:0] decode_bits;
    
    always @(posedge clk) begin
        if (state == 3'd2) begin
            _is_i_type = (instr[6:2] == 5'b00000) || (instr[6:2] == 5'b00100) || (instr[6:2] == 5'b11001);
            _is_r_type = instr[6:2] == 5'b01100;
            _is_b_type = instr[6:2] == 5'b11000;
            _is_s_type = instr[6:2] == 5'b01000;
            _is_j_type = instr[6:2] == 5'b11011;
            _is_u_type = (instr[6:2] == 5'b01101) || (instr[6:2] == 5'b00101);

            _rs1 = instr[19:15];
            _rs2 = instr[24:20];
            _rd = instr[11:7];

            _rs1_valid = !_is_u_type && !_is_j_type;
            _rs2_valid = _is_s_type || _is_r_type || _is_b_type;
            _rd_valid = !_is_s_type && !_is_b_type;


            // Decode immediate based on instruction type
            if (_is_i_type) begin
                _imm = { {21{instr[31]}}, instr[30:20] };
            end
            else if (_is_b_type) begin
                _imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
            end
            else if (_is_s_type) begin
                _imm = { {21{instr[31]}}, instr[30:25], instr[11:7] };
            end
            else if (_is_j_type) begin
                _imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0  };
            end
            else if (_is_u_type) begin
                _imm = { instr[31:12], 12'b0 };
            end
            else begin
                _imm = 0;
            end

            decode_bits = { instr[30], instr[14:12], instr[6:0] };

            // Load/store
            _is_lb = decode_bits == 11'b0_000_0000011 || decode_bits == 11'b1_000_0000011;
            _is_lh = decode_bits == 11'b0_001_0000011 || decode_bits == 11'b1_001_0000011;
            _is_lw = decode_bits == 11'b0_010_0000011 || decode_bits == 11'b1_010_0000011;
            _is_lbu = decode_bits == 11'b0_100_0000011 || decode_bits == 11'b1_100_0000011;
            _is_lhu = decode_bits == 11'b0_101_0000011 || decode_bits == 11'b1_101_0000011;
            _is_sb = decode_bits == 11'b0_000_0100011 || decode_bits == 11'b1_000_0100011;
            _is_sh = decode_bits == 11'b0_001_0100011 || decode_bits == 11'b1_001_0100011;
            _is_sw = decode_bits == 11'b0_010_0100011 || decode_bits == 11'b1_010_0100011;
            _is_load = instr[6:2] == 5'b00000;
            _is_store = instr[6:2] == 5'b01000;

            // I-type arithmetic
            _is_addi =  decode_bits == 11'b0_000_0010011  || decode_bits == 11'b1_000_0010011;
            _is_slti =  decode_bits == 11'b0_010_0010011  || decode_bits == 11'b1_010_0010011;
            _is_sltiu = decode_bits == 11'b0_011_0010011  || decode_bits == 11'b1_011_0010011;
            _is_xori =  decode_bits == 11'b0_100_0010011  || decode_bits == 11'b1_100_0010011;
            _is_ori = decode_bits == 11'b0_110_0010011  || decode_bits == 11'b1_110_0010011;
            _is_andi =  decode_bits == 11'b0_111_0010011  || decode_bits == 11'b1_111_0010011;
            _is_slli =  decode_bits == 11'b0_001_0010011;
            _is_srli =  decode_bits == 11'b0_101_0010011;
            _is_srai =  decode_bits == 11'b1_101_0010011;

            // R-type arithmetic
            _is_add  = decode_bits == 11'b0_000_0110011;
            _is_sub  = decode_bits == 11'b1_000_0110011;
            _is_sll  = decode_bits == 11'b0_001_0110011;
            _is_slt  = decode_bits == 11'b0_010_0110011;
            _is_sltu = decode_bits == 11'b0_011_0110011;
            _is_xor  = decode_bits == 11'b0_100_0110011;
            _is_srl  = decode_bits == 11'b0_101_0110011;
            _is_sra  = decode_bits == 11'b1_101_0110011;
            _is_or   = decode_bits == 11'b0_110_0110011;
            _is_and  = decode_bits == 11'b0_111_0110011;

            // Branch
            _is_beq = decode_bits == 11'b0_000_1100011  || decode_bits == 11'b1_000_1100011;
            _is_bne = decode_bits == 11'b0_001_1100011  || decode_bits == 11'b1_001_1100011;
            _is_bge = decode_bits == 11'b0_101_1100011  || decode_bits == 11'b1_101_1100011;
            _is_bgeu = decode_bits == 11'b0_111_1100011 || decode_bits == 11'b1_111_1100011;
            _is_blt = decode_bits == 11'b0_100_1100011  || decode_bits == 11'b1_100_1100011;
            _is_bltu = decode_bits == 11'b0_110_1100011 || decode_bits == 11'b1_110_1100011;

            // Jump
            _is_jal =  instr[6:2] == 5'b11011;
            _is_jalr = instr[6:2] == 5'b11001;

            _is_auipc = instr[6:2] == 5'b00101;
            _is_lui   = instr[6:2] == 5'b01101;
        end
    end


    assign is_i_type = _is_i_type;
    assign is_r_type = _is_r_type;
    assign is_b_type = _is_b_type;
    assign is_s_type = _is_s_type;
    assign is_j_type = _is_j_type;
    assign is_u_type = _is_u_type;

    assign rs1_valid = _rs1_valid;
    assign rs2_valid = _rs2_valid;
    assign rd_valid = _rd_valid;

    assign is_load = _is_load;
    assign is_store = _is_store;
    assign is_lb = _is_lb;
    assign is_lh = _is_lh;
    assign is_lw = _is_lw;
    assign is_sb = _is_sb;
    assign is_sh = _is_sh;
    assign is_sw = _is_sw;
    assign is_lbu = _is_lbu;
    assign is_lhu = _is_lhu;

    assign is_addi =  _is_addi;
    assign is_slti =  _is_slti;
    assign is_sltiu = _is_sltiu;
    assign is_xori =  _is_xori;
    assign is_ori = _is_ori;
    assign is_andi = _is_andi;
    assign is_slli = _is_slli;
    assign is_srli = _is_srli;
    assign is_srai = _is_srai;

    assign is_add  = _is_add;
    assign is_sub  = _is_sub;
    assign is_sll  = _is_sll;
    assign is_slt  = _is_slt;
    assign is_sltu = _is_sltu;
    assign is_xor  = _is_xor;
    assign is_srl  = _is_srl;
    assign is_sra  = _is_sra;
    assign is_or   = _is_or;
    assign is_and  = _is_and;

    assign is_auipc = _is_auipc;
    assign is_lui   = _is_lui;

    assign is_beq  = _is_beq;
    assign is_bne  = _is_bne;
    assign is_bge  = _is_bge;
    assign is_bgeu = _is_bgeu;
    assign is_blt  = _is_blt;
    assign is_bltu = _is_bltu;

    assign is_jal = _is_jal;
    assign is_jalr = _is_jalr;

    assign rs1 = _rs1;
    assign rs2 = _rs2;
    assign rd = _rd;
    assign imm = _imm;
endmodule