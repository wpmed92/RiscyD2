`include "riscv_defs.v"
`include "extension_defs.v"
`include "constant_defs.v"


module riscyd2_soc(
    // Inputs
    input CLK100MHZ, 
    input uart_txd_in,
    input [3:0] sw,

    // Outputs
    output [3:0] led,
    output uart_rxd_out
);
    reg[31:0] pc = 0;
    reg read_en;
    wire [31:0] instr;

    reg [2:0] state = 0;

    // clk will increase state
    // 0 = fetch, decode
    // 1 = rf, csr_rf read
    // 2 = execute (alu, muldiv, branch)
    // 3 = mem/gpio access
    // 4 = writeback

    // Decode
    wire [4:0] rs1;
    wire rs1_en;
    wire [4:0] rs2;
    wire rs2_en;
    wire [4:0] rd;
    wire rd_en;
    wire [31:0] imm;
    wire [31:0] csr_val;

    wire [31:0] address;
    wire [31:0] alu_result;
    wire [31:0] load_result;
    wire [31:0] rs1_val;
    wire [31:0] rs2_val;

    wire [45:0] decode_net;

    decode decode_inst(
        .instr_i(instr),
        .rs1_o(rs1),
        .rs1_valid_o(rs1_en),
        .rs2_o(rs2),
        .rs2_valid_o(rs2_en),
        .rd_o(rd),
        .rd_valid_o(rd_en),
        .imm_o(imm),
        .decode_net_o(decode_net)
    );

    rf rf_inst(
        .clk_i(CLK100MHZ),
        .state_i(state),
        .rs1_en_i(rs1_en), 
        .rs1_i(rs1), 
        .rs2_en_i(rs2_en),
        .rs2_i(rs2),
        .rd_en_i(rd_en),
        .rd_i(rd),
        .is_load_i(decode_net[`IS_LB : `IS_LW]),
        .is_csr_i(decode_net[`IS_CSRRS]),
        .alu_result_i(alu_result),
        .load_result_i(load_result),
        .csr_val_i(csr_val),
        .rs1_val_o(rs1_val), 
        .rs2_val_o(rs2_val)
    );

    csr_rf csr_rf_inst(
        .clk_i(CLK100MHZ),
        .state_i(state),
        .en_csr_i(decode_net[`IS_CSRRS]),
        .csr_adr_i(imm[11:0]),
        .csr_val_o(csr_val)
    );

     execute execute_inst(
        .clk_i(CLK100MHZ),
        .state_i(state),
        .rs1_val_i(rs1_val),
        .rs2_val_i(rs2_val),
        .imm_i(imm),
        .pc_i(pc),
        .decode_net_i(decode_net),
        .writeback_value_o(alu_result),
        .address_o(address),
        .branch_taken_o(taken_branch)
    );

    mmio mmio_instance(
        .clk_i(CLK100MHZ),
        .state_i(state),
        .is_lb_i(decode_net[`IS_LB]),
        .is_lbu_i(decode_net[`IS_LBU]),
        .is_lh_i(decode_net[`IS_LH]),
        .is_lhu_i(decode_net[`IS_LHU]),
        .is_lw_i(decode_net[`IS_LW]),
        .is_sb_i(decode_net[`IS_SB]),
        .is_sh_i(decode_net[`IS_SH]),
        .is_sw_i(decode_net[`IS_SW]),
        .pc_i(pc),
        .address_i(address),
        .data_i(rs2_val),
        .uart_txd_i(uart_txd_in),
        .sw_i(sw),
        .data_o(load_result),
        .instr_o(instr),
        .led_o(led),
        .uart_rxd_o(uart_rxd_out)
    );

    always @ (posedge CLK100MHZ) begin
        state <= (state + 1) % 5;

        if (state == `WRITE_BACK) begin
            pc <= taken_branch ? address : (pc + 4);
        end
    end

endmodule
