`include "constant_defs.v"

module csr_rf(
    // Inputs
    input clk_i,
    input [2:0] state_i,
    input en_csr_i,
    input [11:0] csr_adr_i,

    // Outputs
    output [31:0] csr_val_o
);
    reg [63:0] cycle_counter = 0; 
    reg [31:0] _csr_val;
    
    always @(posedge clk_i) begin
        cycle_counter <= cycle_counter + 1;
        
        if (state_i == `REG_FILE_READ) begin
            if (en_csr_i) begin
                case (csr_adr_i)
                    12'hc00 : _csr_val = cycle_counter[31:0];
                    12'hc80 : _csr_val = cycle_counter[63:32];
                    default : _csr_val = 32'd0;
                endcase
            end
        end
    end

    assign csr_val_o = _csr_val;
endmodule