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
    reg [63:0] mul_res;
    reg [31:0] divisor;
    reg [31:0] dividend;

    reg div_triggered = 0;
    reg div_start = 0;       // start signal
    wire div_busy;           // calculation in progress
    wire div_valid;          // quotient and remainder are valid
    wire div_dbz;            // divide by zero flag
    wire [31:0] quotient;    // quotient
    wire [31:0] remainder;   // remainder

    divider div_int_inst(
        .clk(clk),
        .start(div_start),
        .busy(div_busy),
        .x(dividend),
        .y(divisor),
        .q(quotient),
        .r(remainder),
        .valid(div_valid)
    );

    //wait for muldiv
    reg [1:0] wait_mul = 0; 
    reg _should_stall = 0;

    always @(posedge clk) begin
        if (state == `WRITE_BACK) begin
            wait_mul = 0;
            div_triggered = 0;
        end else if (state == `EXECUTE) begin

            // Since mul and div instructions don't finish in 
            // a single 100MHz clock cycle, we wait for them for 
            // some number of cycles determined based 
            // on timing analysis reports.
            if (wait_mul == `WAIT_MUL_CYCLES) begin
                _should_stall = 0;
            end else if (wait_mul > 0) begin
                wait_mul = wait_mul + 1;
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
                mul_res = rs1_val * rs2_val;
                _result = mul_res[31:0];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            //place higher bits: signed x signed
            end else if (is_mulh && wait_mul == 0) begin
                mul_res = { {32{rs1_val[31]}}, rs1_val } * {{32{rs2_val[31]}}, rs2_val };
                _result = mul_res[63:32];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            //place higher bits: signed x unsigned
            end else if (is_mulhsu && wait_mul == 0) begin
                mul_res = { {32{rs1_val[31]}}, rs1_val } * { 32'b0, rs2_val };
                _result = mul_res[63:32];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            //place higher bits: unsigned x unsigned
            end else if (is_mulhu && wait_mul == 0) begin
                mul_res = {32'b0, rs1_val } * { 32'b0, rs2_val };
                _result = mul_res[63:32];
                wait_mul = wait_mul + 1;
                _should_stall = 1;
            // ---------------------
            // DIV
            // ---------------------
            end else if (is_div || is_divu || is_rem || is_remu) begin
                if (is_div || is_rem) begin
                    dividend = (rs1_val[31]) ? -rs1_val : rs1_val;
                    divisor  = (rs2_val[31]) ? -rs2_val : rs2_val;
                end else begin
                    dividend = rs1_val;
                    divisor = rs2_val;
                end
            
                if (!div_triggered) begin
                    div_start = 1;
                    div_triggered = 1;
                    _should_stall = 1;
                end else if (div_start) begin
                    div_start = 0;
                end else if (div_valid) begin
                    if (is_div) begin
                        _result = (rs1_val[31] ^ rs2_val[31]) ? -quotient : quotient;
                    end else if (is_rem) begin
                        _result = (rs1_val[31] ^ rs2_val[31]) ? -remainder : remainder;
                    end else if (is_divu) begin
                        _result = quotient;
                    end else begin
                        _result = remainder;
                    end

                    _should_stall = 0;
                end
        `endif
            end
        end
    end

    assign result = _result;
    assign address = _address;
    assign should_stall = _should_stall;
endmodule
