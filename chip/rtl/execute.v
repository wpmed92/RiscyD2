`include "extension_defs.v"
`include "constant_defs.v"
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

    //Outputs
    output [31:0] writeback_value_o,
    output [31:0] address_o,
    output   branch_taken_o
);

    //muldiv
    /*
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
    */
    reg [ 3:0] alu_opcode_q;
    reg [31:0] alu_op_1_q;
    reg [31:0] alu_op_2_q;

    wire is_branch_w = decode_net_i[`IS_BEQ] || decode_net_i[`IS_BNE] || decode_net_i[`IS_BGE] || decode_net_i[`IS_BGEU] || decode_net_i[`IS_BLT] ||
                     decode_net_i[`IS_BLTU];

    wire is_store_w = decode_net_i[`IS_SB] || decode_net_i[`IS_SH]  || decode_net_i[`IS_SW];
    wire is_load_w  = decode_net_i[`IS_LB] || decode_net_i[`IS_LBU] || decode_net_i[`IS_LH] || decode_net_i[`IS_LHU] || decode_net_i[`IS_LW];


    always @* begin
        if (decode_net_i[`IS_ADDI]) begin
            alu_opcode_q <= `ALU_OP_ADD;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_ADD]) begin
            alu_opcode_q <= `ALU_OP_ADD;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_SUB]) begin
            alu_opcode_q <= `ALU_OP_SUB;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_OR]) begin
            alu_opcode_q <= `ALU_OP_OR;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_ORI]) begin
            alu_opcode_q <= `ALU_OP_OR;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_XOR]) begin
            alu_opcode_q <= `ALU_OP_XOR;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_XORI]) begin
            alu_opcode_q <= `ALU_OP_XOR;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_AND]) begin
            alu_opcode_q <= `ALU_OP_AND;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_ANDI]) begin
            alu_opcode_q <= `ALU_OP_AND;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_SLL]) begin
            alu_opcode_q <= `ALU_OP_SLL;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_SLLI]) begin
            alu_opcode_q <= `ALU_OP_SLL;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i[4:0];
        end else if (decode_net_i[`IS_SRL]) begin
            alu_opcode_q <= `ALU_OP_SRL;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_SRLI]) begin
            alu_opcode_q <= `ALU_OP_SRL;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i[4:0];
        end else if (decode_net_i[`IS_SRA]) begin
            alu_opcode_q <= `ALU_OP_SRA;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_SRAI]) begin
            alu_opcode_q <= `ALU_OP_SRA;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i[4:0];
        end else if (decode_net_i[`IS_SLT]) begin
            alu_opcode_q <= `ALU_OP_SLT;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_SLTU]) begin
            alu_opcode_q <= `ALU_OP_SLTU;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= rs2_val_i;
        end else if (decode_net_i[`IS_SLTI]) begin
            alu_opcode_q <= `ALU_OP_SLT;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_SLTIU]) begin
            alu_opcode_q <= `ALU_OP_SLTU;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_AUIPC]) begin
            alu_opcode_q <= `ALU_OP_ADD;
            alu_op_1_q   <= pc_i;
            alu_op_2_q   <= imm_i;
        end else if (decode_net_i[`IS_JAL] || decode_net_i[`IS_JALR]) begin
            alu_opcode_q <= `ALU_OP_ADD;
            alu_op_1_q   <= pc_i;
            alu_op_2_q   <= 32'd4;
        end else if (decode_net_i[`IS_LUI]) begin
            alu_opcode_q <= `ALU_OP_ADD;
            alu_op_1_q   <= imm_i;
            alu_op_2_q   <= 32'd0;
        end else if (is_load_w || is_store_w) begin
            alu_opcode_q <= `ALU_OP_ADD;
            alu_op_1_q   <= rs1_val_i;
            alu_op_2_q   <= imm_i;
        end
    end

    wire [31:0] alu_result_w;

    alu alu_inst(
        .alu_opcode_i(alu_opcode_q),
        .op_1_i(alu_op_1_q),
        .op_2_i(alu_op_2_q),
        .alu_result_o(alu_result_w)
    );

    /*              wb                 addr
        load        - (from mem)     alu_result_q                  (the wb is retrieved from memory, the address is the mem address)
        store       -                alu_result_q                  (no wb, the address is the mem address)
        jump        alu_result_q     pc_i + imm_i / rs1_val_i      (the wb is the return address, the address is where we jump)
        branch      -                pc_i + imm_i
        alu         alu_result_q     -
    */

    reg taken_branch_q = 0;
    reg [31:0] address_q = 0;

    always @* begin
        if (decode_net_i[`IS_BEQ]) begin
            taken_branch_q <= rs1_val_i == rs2_val_i;
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BNE]) begin
            taken_branch_q <= rs1_val_i != rs2_val_i;
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BGE]) begin
            taken_branch_q <= (rs1_val_i >= rs2_val_i) ^ (rs1_val_i[31] != rs2_val_i[31]);
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BGEU]) begin
            taken_branch_q <= rs1_val_i >= rs2_val_i;
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BLT]) begin
            taken_branch_q <= (rs1_val_i < rs2_val_i) ^ (rs1_val_i[31] != rs2_val_i[31]);
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_BLTU]) begin
            taken_branch_q <= rs1_val_i < rs2_val_i;
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_JAL]) begin
            taken_branch_q <= 1;
            address_q      <= pc_i + imm_i;
        end else if (decode_net_i[`IS_JALR]) begin
            taken_branch_q <= 1;
            address_q      <= rs1_val_i + imm_i;
        end else begin
            taken_branch_q <= 0;
        end
    end

    assign address_o = (                                      is_load_w ||  is_store_w) ?  alu_result_w :
                       (decode_net_i[`IS_JALR] || decode_net_i[`IS_JAL] || is_branch_w) ?  address_q    :
                                                                                                32'd0;

    assign writeback_value_o = ~(is_load_w || is_store_w || is_branch_w) ? alu_result_w : 0;
    assign branch_taken_o = taken_branch_q;

    //TODO: separate out multiplier

    //TODO: mux for writeback value

    /*divider div_int_inst(
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
            end else if (is_branch) begin
                _address = pc + imm;
            end else if (is_jal) begin
                _address = pc + imm;
            end else if (is_jalr) begin
                _address = rs1_val + imm;
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
    end*/
endmodule
