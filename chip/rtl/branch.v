module branch(
    input clk,
    input [2:0] state,
    input [31:0] rs1_val,
    input [31:0] rs2_val,
    input is_beq,
    input is_bne,
    input is_bge,
    input is_bgeu,
    input is_blt,
    input is_bltu,
    input is_jal,
    input is_jalr,
    output taken_branch
);
    reg _taken_branch = 0;

    always @(posedge clk) begin
        if (state == 3'd2) begin
            if (is_beq) begin
                _taken_branch <= rs1_val == rs2_val;
            end else if (is_bne) begin
                _taken_branch <= rs1_val != rs2_val;
            end else if (is_bge) begin
                _taken_branch <= (rs1_val >= rs2_val) ^ (rs1_val[31] != rs2_val[31]);
            end else if (is_bgeu) begin
                _taken_branch <= rs1_val >= rs2_val;
            end else if (is_blt) begin
                _taken_branch <= (rs1_val < rs2_val) ^ (rs1_val[31] != rs2_val[31]);
            end else if (is_bltu) begin
                _taken_branch <= rs1_val < rs2_val;
            end else if (is_jal || is_jalr) begin
                _taken_branch <= 1;
            end else begin
                _taken_branch <= 0;
            end
        end
    end

    assign taken_branch = _taken_branch;
endmodule
