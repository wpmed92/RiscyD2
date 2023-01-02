`include "constant_defs.v"

module csr_rf(
    input clk,
    input [2:0] state,
    input en_csr,
    input [11:0] csr_adr,
    output [31:0] csr_val
);
    reg [63:0] cycle_counter = 0; 
    reg [31:0] _csr_val;
    
    always @(posedge clk) begin
        cycle_counter <= cycle_counter + 1;
        
        if (state == `REG_FILE_READ) begin
            
            if (en_csr) begin
                case (csr_adr)
                    12'hc00 : _csr_val = cycle_counter[31:0];
                    12'hc80 : _csr_val = cycle_counter[63:32];
                    default : _csr_val = 32'd0;
                endcase
            end
        end
    end

    assign csr_val = _csr_val;
endmodule