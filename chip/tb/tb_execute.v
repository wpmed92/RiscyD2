`include "riscv_defs.v"

module execute_tb();
    parameter CLK_PERIOD = 10;

    reg         clk;
    reg  [ 2:0] state_q = `EXECUTE_1;
    reg  [31:0] rs1_val_q = 32'd0;
    reg  [31:0] rs2_val_q = 32'd0;
    reg  [31:0] imm_q = 32'd0;
    reg  [31:0]  pc_q = 32'd0;
    reg  [45:0] decode_net_q = 36'd0;


    wire [31:0] writeback_value_w;
    wire [31:0] address_w;
    wire   branch_taken_w;

    execute execute_inst(
        .clk_i(clk_q),
        .state_i(state_q),
        .rs1_val_i(rs1_val_q),
        .rs2_val_i(rs2_val_q),
        .imm_i(imm_q),
        .pc_i(pc_q),
        .decode_net_i(decode_net_q),
        .writeback_value_o(writeback_value_w),
        .address_o(address_w),
        .branch_taken_o(branch_taken_w)
    );

    reg [ 6:0] op_sel = 0;
    reg [31:0] expected_wb_q = 0;

    // Concetanate expected execute output values for each opcode
    reg [160:0] test_data [0:45];
    integer i = 0;
    integer j = 0;
    integer out_data;
    reg [31:0] expected_wb_val;
    reg [31:0] expected_addr_val;
    reg expected_taken_branch;

    always #(CLK_PERIOD / 2) clk = ~clk;


    initial begin 
        out_data = $fopen("tb_execute.tbout");

        #10 for (i = 0; i < 36; i = i + 1)
            test_data[i] = 0;

        // ALU                /* rs1            rs2            imm        wb_val addr   taken_branch */
        test_data[`IS_ADDI]  = { 32'd1,         32'bx,         32'd4,     32'd5, 32'd0, 1'b0 };

        test_data[`IS_ADD]   = { 32'd1,         32'd3,         32'bx,     32'd4, 32'd0, 1'b0 };

        test_data[`IS_SUB]   = { 32'd1,         32'd3,         32'bx,    -32'd2, 32'd0, 1'b0 };

        test_data[`IS_ORI]   = { 32'd0,         32'bx,         32'd0,     32'd0, 32'd0, 1'b0 };

        test_data[`IS_OR]    = { 32'd1,         32'd0,         32'bx,     32'd1, 32'd0, 1'b0 };

        test_data[`IS_ANDI]  = { 32'd1,         32'bx,         32'd0,     32'd0, 32'd0, 1'b0 };

        test_data[`IS_AND]   = { 32'd1,         32'd1,         32'bx,     32'd1, 32'd0, 1'b0 };

        test_data[`IS_XORI]  = { 32'd1,         32'bx,         32'd1,     32'd0, 32'd0, 1'b0 };

        test_data[`IS_XOR]   = { 32'd1,         32'd0,         32'bx,     32'd1, 32'd0, 1'b0 };

        test_data[`IS_SLLI]  = { 32'd2,         32'bx,         32'd1,     32'd4, 32'd0, 1'b0 };

        test_data[`IS_SLL]   = { 32'd2,         32'd2,         32'bx,     32'd8, 32'd0, 1'b0 };

        test_data[`IS_SRLI]  = { 32'd4,         32'bx,         32'd1,     32'd2, 32'd0, 1'b0 };

        test_data[`IS_SRL]   = { 32'd8,         32'd1,         32'bx,     32'd4, 32'd0, 1'b0 };

        test_data[`IS_SRAI]  = { 32'd4,         32'bx,         32'd1,     32'd2, 32'd0, 1'b0 };

        test_data[`IS_SRA]   = { 32'd8,         32'd1,         32'bx,     32'd4, 32'd0, 1'b0 };

        test_data[`IS_SLTI]  = { 32'd1,         32'bx,         32'd0,     32'd0, 32'd0, 1'b0 };

        test_data[`IS_SLT]   = { 32'hffff_ffff, 32'd2,         32'bx,     32'd1, 32'd0, 1'b0 };

        test_data[`IS_SLTIU] = { 32'hffff_ffff, 32'bx,         32'd2,     32'd0, 32'd0, 1'b0 };

        test_data[`IS_SLTU]  = { 32'd2,         32'hffff_ffff, 32'bx,     32'd1, 32'd0, 1'b0 };

        test_data[`IS_AUIPC] = { 32'bx,         32'bx,         32'd4,     32'd4, 32'd0, 1'b0 };

        test_data[`IS_LUI]   = { 32'bx,         32'bx,         32'd10,   32'd10, 32'd0, 1'b0 };

        // Branch            /* rs1            rs2            imm        wb_val addr    taken_branch */
        test_data[`IS_BEQ]  = { 32'd1,         32'd1,         32'd4,     32'd0, 32'd4,  1'b1 };

        test_data[`IS_BNE]  = { 32'd1,         32'd1,         32'd8,     32'd0, 32'd8,  1'b0 };

        test_data[`IS_BGE]  = { 32'hffff_ffff, 32'd0,         32'd12,    32'd0, 32'd12, 1'b0 };

        test_data[`IS_BGEU] = { 32'hffff_ffff, 32'd0,         32'd8,     32'd0, 32'd8,  1'b1 };

        test_data[`IS_BLT]  = { 32'hffff_ffff, 32'd2,         32'd4,     32'd0, 32'd4,  1'b1 };

        test_data[`IS_BLTU] = { 32'hffff_ffff, 32'd2,         32'd8,     32'd0, 32'd8,  1'b0 };

        // Load/Store        /* rs1            rs2            imm        wb_val addr    taken_branch */
        test_data[`IS_SB]   = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_SH]   = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_SW]   = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_LB]   = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_LBU]  = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_LH]   = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_LHU]  = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        test_data[`IS_LW]   = { 32'd1,         32'bx,         32'd4,     32'd0, 32'd5,  1'b0 };

        // Jump              /* rs1            rs2            imm        wb_val addr    taken_branch */
        test_data[`IS_JAL]  = { 32'bx,         32'bx,         32'd4,     32'd4, 32'd4,  1'b1 };

        test_data[`IS_JALR] = { 32'd8,         32'bx,         32'd4,     32'd4, 32'd12, 1'b1 };

        #10;

        for (j = 9; j < 46; j = j + 1) begin
            # 10 rs1_val_q        = test_data[j][160:129];
            rs2_val_q             = test_data[j][128:97];
            imm_q                 = test_data[j][96:65];
            expected_wb_val       = test_data[j][64:33];
            expected_addr_val     = test_data[j][32:1];
            expected_taken_branch = test_data[j][0];
            decode_net_q[j]       = 1;

            # 10 $fwrite(out_data, "\n%d, wb_val, %d, %d, addr_val, %d, %d, taken_branch, %d, %d", j, writeback_value_w, expected_wb_val, address_w,   expected_addr_val, branch_taken_w,  expected_taken_branch);

            # 10 decode_net_q     = 0;
            rs1_val_q             = 0;
            rs2_val_q             = 0;
            imm_q                 = 0;
            expected_wb_val       = 0;
            expected_addr_val     = 0;
            expected_taken_branch = 0;
		end

        $fclose(out_data);
        $finish;
    end
endmodule