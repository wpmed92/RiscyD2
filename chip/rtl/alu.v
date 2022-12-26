`include "extension_defs.v"
`include "constant_defs.v"

module alu(
    input clk,
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
`ifdef M_EXTENSION
    input is_mul,
    input is_mulh,
    input is_mulhsu,
    input is_mulhu,
    input is_div,
    input is_divu,
    input is_rem,
    input is_remu,
`endif
    input is_auipc,
    input is_lui,
    input is_load,
    input is_store,
    input is_branch,
    input is_jal,
    input is_jalr,
    output [31:0] result,
    output [31:0] address,
    output should_stall
);
    reg [31:0] _result;
    reg [31:0] _address;
    reg [63:0] sext_rs1;
    reg [63:0] srai;
    reg [63:0] sra;

    //muldiv
    reg [63:0] muldiv_res;
    reg [31:0] abs_divisor;
    reg [31:0] abs_dividend;
    reg [31:0] u_result;

    //wait for muldiv
    reg [1:0] wait_mul = 0; 
    reg [3:0] wait_div = 0;
    reg _should_stall = 0;

    always @(posedge clk) begin
        if (state == `EXECUTE) begin

            // Since mul and div instructions don't finish in 
            // a single 100MHz clock cycle, we wait for them for 
            // some number of cycles determined based 
            // on timing analysis reports.
            if (wait_mul == 2 || wait_div == 10) begin
                wait_mul = 0;
                wait_div = 0;
                _should_stall = 0;
            end else if (wait_mul > 0) begin
                wait_mul = wait_mul + 1;
            end else if (wait_div > 0) begin
                wait_div = wait_div + 1;
            end else if (is_addi) begin
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
                sext_rs1 = { {32{rs1_val[31]}}, rs1_val };
                srai = sext_rs1 >> imm[4:0];
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
                sext_rs1 = { {32{rs1_val[31]}}, rs1_val };
                sra = sext_rs1 >> rs2_val;
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
        `ifdef M_EXTENSION
            // ---------------------
            // MUL
            // ---------------------
            //place lower bits
            end else if (is_mul && wait_mul == 0) begin
                muldiv_res = rs1_val * rs2_val;
                _result = muldiv_res[31:0];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            //place higher bits: signed x signed
            end else if (is_mulh && wait_mul == 0) begin
                muldiv_res = { {32{rs1_val[31]}}, rs1_val } * {{32{rs2_val[31]}}, rs2_val };
                _result = muldiv_res[63:32];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            //place higher bits: signed x unsigned
            end else if (is_mulhsu && wait_mul == 0) begin
                muldiv_res = { {32{rs1_val[31]}}, rs1_val } * { 32'b0, rs2_val };
                _result = muldiv_res[63:32];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            //place higher bits: unsigned x unsigned
            end else if (is_mulhu && wait_mul == 0) begin
                muldiv_res = {32'b0, rs1_val } * { 32'b0, rs2_val };
                _result = muldiv_res[63:32];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            // ---------------------
            // DIV
            // ---------------------
            end else if (is_div && wait_div == 0) begin
                abs_divisor = (rs2_val[31]) ? -rs2_val : rs2_val;
                abs_dividend = (rs1_val[31]) ? -rs1_val : rs1_val;
                u_result = abs_dividend / abs_divisor;
                
                _result = (rs1_val[31] ^ rs2_val[31]) ? -u_result : u_result;
                wait_div = wait_div + 1;
                _should_stall = 1;
            end else if (is_divu && wait_div == 0) begin
                _result = rs1_val / rs2_val;
                wait_div = wait_div + 1;
                _should_stall = 1;
            end else if (is_rem && wait_div == 0) begin
                abs_divisor = (rs2_val[31]) ? -rs2_val : rs2_val;
                abs_dividend = (rs1_val[31]) ? -rs1_val : rs1_val;
                u_result = abs_dividend % abs_divisor;
                
                _result = (rs1_val[31] ^ rs2_val[31]) ? -u_result : u_result;
                wait_div = wait_div + 1;
                _should_stall = 1;
            end else if (is_remu && wait_div == 0) begin
                _result = rs1_val % rs2_val;
                wait_div = wait_div + 1;
                _should_stall = 1;
        `endif
            end
        end
    end

    assign result = _result;
    assign address = _address;
    assign should_stall = _should_stall;
endmodule
