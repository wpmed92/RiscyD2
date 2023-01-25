`include "riscv_defs.v"

module csr_rf(
    // Inputs
    input clk_i,
    input [2:0] state_i,
    input en_csr_i,
    input [11:0] csr_adr_i,

    // Outputs
    output [31:0] csr_val_o
);
    reg [63:0] cycle_counter_r = 0; 
    reg [31:0] csr_val_q;
    
    always @(posedge clk_i) begin
        cycle_counter_r <= cycle_counter_r + 1;
        
        if (state_i == `EXECUTE_1) begin
            if (en_csr_i) begin
                case (csr_adr_i)
                    12'hc00 : csr_val_q = cycle_counter_r[31:0];
                    12'hc80 : csr_val_q = cycle_counter_r[63:32];
                    default : csr_val_q = 32'd0;
                endcase
            end
        end
    end

    assign csr_val_o = csr_val_q;
endmodule