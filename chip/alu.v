module alu(
    input [2:0] state,
    input [31:0] rs1_val,
    input [31:0] rs2_val,
    input [31:0] imm,
    input [31:0] pc,
    input is_addi,
    input is_slti,
    input is_sltiu,
    input is_xori,
    input is_ori,
    input is_andi,
    input is_slli,
    input is_srli,
    input is_srai,
    input is_add,
    input is_sub,
    input is_sll,
    input is_slt,
    input is_sltu,
    input is_xor,
    input is_srl,
    input is_sra,
    input is_or,
    input is_and,
    input is_auipc,
    input is_lui,
    input is_load,
    input is_store,
    input is_branch,
    input is_jal,
    input is_jalr,
    output [31:0] result,
    output [31:0] address
);
    reg[31:0] _result;
    reg[31:0] _address;
    reg[63:0] sext_rs1;
    reg[63:0] srai;
    reg[63:0] sra;

    always @(state) begin
        if (state == 3'd5) begin
            sext_rs1 = { {32{rs1_val[31]}}, rs1_val };
            srai = sext_rs1 >> imm[4:0];
            sra = sext_rs1 >> rs2_val;

            if (is_addi) begin
                _result = rs1_val + imm;
            end else if (is_xori) begin
                _result = rs1_val ^ imm;
            end else if (is_ori) begin
                _result = rs1_val | imm;
            end else if (is_ori) begin
                _result = rs1_val | imm;
            end else if (is_andi) begin
                _result = rs1_val & imm;
            end else if (is_slli) begin
                _result = rs1_val << imm[4:0];
            end else if (is_srli) begin
                _result = rs1_val >> imm[4:0];
            end else if (is_srai) begin
                _result = srai[31:0];
            end else if (is_slti) begin
                _result = { 31'b0, (rs1_val < imm) ^ (rs1_val[31] != imm[31]) };
            end else if (is_sltiu) begin
                _result = { 31'b0, rs1_val < imm };
            end else if (is_add) begin
                _result = rs1_val + rs2_val;
            end else if (is_sub) begin
                _result = rs1_val - rs2_val;
            end else if (is_sll) begin
                _result = rs1_val << rs2_val;
            end else if (is_srl) begin
                _result = rs1_val >> rs2_val;
            end else if (is_sra) begin
                _result = sra[31:0];
            end else if (is_or) begin
                _result = rs1_val | rs2_val;
            end else if (is_xor) begin
                _result = rs1_val ^ rs2_val;
            end else if (is_and) begin
                _result = rs1_val & rs2_val;
            end else if (is_slt) begin
                _result = { 31'b0, (rs1_val < rs2_val) ^ (rs1_val[31] != rs2_val[31]) };
            end else if (is_sltu) begin
                _result = { 31'b0, rs1_val < rs2_val };
            end else if (is_auipc) begin
                _result = pc + imm;
            end else if (is_branch) begin
                _address = pc + imm;
            end else if (is_jal) begin
                _address = pc + imm;
                _result = pc + 4;
            end else if (is_jalr) begin
                _address = rs1_val + imm;
                _result = pc + 4;
            end else if (is_lui) begin
                _result = imm;
            end else if (is_load || is_store) begin
                _address = rs1_val + imm;
            end else begin
                _result = 0;
                _address = 0;
            end
        end
    end

    assign result = _result;
    assign address = _address;
endmodule