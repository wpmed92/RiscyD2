`include "riscv_defs.v"

module riscyd2_soc(
    // Inputs
    input CLK100MHZ, 
    input uart_txd_in,
    input [3:0] sw,

    // Outputs
    output [3:0] led,
    output uart_rxd_out
);
    // Decode
    wire [31:0] instr_w;
    wire [4:0] rs1_w;
    wire rs1_en_w;
    wire [4:0] rs2_w;
    wire rs2_en_w;
    wire [4:0] rd_w;
    wire rd_en_w;
    wire [31:0] imm_w;
    wire [31:0] csr_val_w;

    wire [31:0] address_w;
    wire [31:0] alu_result_w;
    wire [31:0] load_result_w;
    wire [31:0] rs1_val_w;
    wire [31:0] rs2_val_w;

    wire [45:0] decode_net_w;
    wire taken_branch_w;
    wire should_stall_ex_w;

    decode decode_inst(
        .instr_i(instr_w),
        .rs1_o(rs1_w),
        .rs1_valid_o(rs1_en_w),
        .rs2_o(rs2_w),
        .rs2_valid_o(rs2_en_w),
        .rd_o(rd_w),
        .rd_valid_o(rd_en_w),
        .imm_o(imm_w),
        .decode_net_o(decode_net_w)
    );

    rf rf_inst(
        .clk_i(CLK100MHZ),
        .state_i(state_q),
        .rs1_en_i(rs1_en_w), 
        .rs1_i(rs1_w), 
        .rs2_en_i(rs2_en_w),
        .rs2_i(rs2_w),
        .rd_en_i(rd_en_w),
        .rd_i(rd_w),
        .is_load_i(decode_net_w[`IS_LB : `IS_LW]),
        .is_csr_i(decode_net_w[`IS_CSRRS]),
        .alu_result_i(alu_result_w),
        .load_result_i(load_result_w),
        .csr_val_i(csr_val_w),
        .rs1_val_o(rs1_val_w), 
        .rs2_val_o(rs2_val_w)
    );

    csr_rf csr_rf_inst(
        .clk_i(CLK100MHZ),
        .state_i(state_q),
        .en_csr_i(decode_net_w[`IS_CSRRS]),
        .csr_adr_i(imm_w[11:0]),
        .csr_val_o(csr_val_w)
    );

     execute execute_inst(
        .clk_i(CLK100MHZ),
        .state_i(state_q),
        .rs1_val_i(rs1_val_w),
        .rs2_val_i(rs2_val_w),
        .imm_i(imm_w),
        .pc_i(pc_q),
        .decode_net_i(decode_net_w),
        .writeback_value_o(alu_result_w),
        .address_o(address_w),
        .branch_taken_o(taken_branch_w),
        .should_stall_ex_o(should_stall_ex_w)
    );

    mmio mmio_instance(
        .clk_i(CLK100MHZ),
        .state_i(state_q),
        .is_lb_i(decode_net_w[`IS_LB]),
        .is_lbu_i(decode_net_w[`IS_LBU]),
        .is_lh_i(decode_net_w[`IS_LH]),
        .is_lhu_i(decode_net_w[`IS_LHU]),
        .is_lw_i(decode_net_w[`IS_LW]),
        .is_sb_i(decode_net_w[`IS_SB]),
        .is_sh_i(decode_net_w[`IS_SH]),
        .is_sw_i(decode_net_w[`IS_SW]),
        .pc_i(pc_q),
        .address_i(address_w),
        .data_i(rs2_val_w),
        .uart_txd_i(uart_txd_in),
        .sw_i(sw),
        .data_o(load_result_w),
        .instr_o(instr_w),
        .led_o(led),
        .uart_rxd_o(uart_rxd_out)
    );


    reg [31:0] pc_q, next_pc_q      = 0;
    reg [2:0]  state_q, next_state_q = 0;

    always @ (posedge CLK100MHZ) begin
        next_state_q <= should_stall_ex_w ? `EXECUTE_2 : (next_state_q + 1) % 5;

         if (next_state_q == `WRITE_BACK && !should_stall_ex_w) begin
            next_pc_q    <= taken_branch_w    ? address_w    : (next_pc_q + 4);
        end
    end

    always @ (posedge CLK100MHZ) begin
        state_q <= should_stall_ex_w ? `EXECUTE_2  : next_state_q;
        pc_q    <= next_pc_q;
    end

endmodule
