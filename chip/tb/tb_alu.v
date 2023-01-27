`include "riscv_defs.v"

module alu_tb();
    parameter CLK_PERIOD = 10;

    reg         clk;
    reg  [ 3:0] alu_opcode;
    reg  [31:0] op_1;
    reg  [31:0] op_2;
    wire signed [31:0] alu_result_w;
    
    reg signed [31:0] expected_result;

    alu alu_inst(
        .alu_opcode_i(alu_opcode),
        .op_1_i(op_1),
        .op_2_i(op_2),
        .alu_result_o(alu_result_w)
    );

    integer out_data;
    reg log_en = 0;

    always #(CLK_PERIOD / 2) clk = ~clk;

    always @(posedge clk) begin
        if (log_en) begin
            $fwrite(out_data, "\n%b, val, %d, %d", alu_opcode, alu_result_w, expected_result);
        end
    end 

    initial begin
        out_data = $fopen("tb_alu.tbout");
        clk = 1;

        // Sync to clk
        @(posedge clk) ;

        #10 alu_opcode = `ALU_OP_ADD;
            op_1 = 32'd10;
            op_2 = 32'd2;
            expected_result = 32'd12;

        log_en = 1;

        #10 alu_opcode = `ALU_OP_SUB;
            op_1 = 32'd10;
            op_2 = 32'd2;
            expected_result = 32'd8;

        #10 alu_opcode = `ALU_OP_SUB;
            op_1 = 32'd2;
            op_2 = 32'd10;
            expected_result = -32'd8;

        // AND
        #10 alu_opcode = `ALU_OP_AND;
            op_1 = 32'd1;
            op_2 = 32'd0;
            expected_result = 32'd0;

        #10 alu_opcode = `ALU_OP_AND;
            op_1 = 32'd0;
            op_2 = 32'd1;
            expected_result = 32'd0;

        #10 alu_opcode = `ALU_OP_AND;
            op_1 = 32'd1;
            op_2 = 32'd1;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_AND;
            op_1 = 32'd0;
            op_2 = 32'd0;
            expected_result = 32'd0;

        // OR
        #10 alu_opcode = `ALU_OP_OR;
            op_1 = 32'd1;
            op_2 = 32'd0;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_OR;
            op_1 = 32'd0;
            op_2 = 32'd1;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_OR;
             op_1 = 32'd1;
             op_2 = 32'd1;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_OR;
             op_1 = 32'd0;
             op_2 = 32'd0;
            expected_result = 32'd0;

        // XOR
        #10 alu_opcode = `ALU_OP_XOR;
             op_1 = 32'd1;
             op_2 = 32'd0;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_XOR;
             op_1 = 32'd0;
             op_2 = 32'd1;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_XOR;
             op_1 = 32'd1;
             op_2 = 32'd1;
            expected_result = 32'd0;

        #10 alu_opcode = `ALU_OP_XOR;
             op_1 = 32'd0;
             op_2 = 32'd0;
            expected_result = 32'd0;

        // SLL
        #10 alu_opcode = `ALU_OP_SLL;
             op_1 = 32'd8;
             op_2 = 32'd1;
            expected_result = 32'd16;

        // SRL
        #10 alu_opcode = `ALU_OP_SRL;
             op_1 = 32'hFFFFFFFF;
             op_2 = 32'd1;
            expected_result = 32'h7FFFFFFF;

        // SRA
        #10 alu_opcode = `ALU_OP_SRA;
             op_1 = 32'hFFFFFFFF;
             op_2 = 32'd1;
            expected_result = -32'd1;

        // SLT
        #10 alu_opcode = `ALU_OP_SLT;
             op_1 = 32'hFFFFFFFF;
             op_2 = 32'd1;
            expected_result = 32'd1;

        #10 alu_opcode = `ALU_OP_SLT;
             op_1 = 32'hFFFFFFFF;
             op_2 = 32'hFFFFFFF0;
            expected_result = 32'd0;

        #10 alu_opcode = `ALU_OP_SLT;
             op_1 = 32'd1;
             op_2 = 32'd2;
            expected_result = 32'd1;

        // SLTU
        #10 alu_opcode = `ALU_OP_SLTU;
             op_1 = 32'hFFFFFFFF;
             op_2 = 32'd1;
            expected_result = 32'd0;

        #10 alu_opcode = `ALU_OP_SLTU;
             op_1 = 32'h1;
             op_2 = 32'd2;
            expected_result = 32'd1;

        log_en = 0;

        #10 $fclose(out_data);
        $finish;
        

    end
endmodule
