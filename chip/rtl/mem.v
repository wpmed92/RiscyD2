//True Dual Port with Byte-Wide Write Enable
`include "constant_defs.v"

module mem
#(
    //--------------------------------------------------------------------------
    parameter   NUM_COL             =   4,
    parameter   COL_WIDTH           =   8,
    parameter   ADDR_WIDTH          =  14,
    // Addr  Width in bits : 2 *ADDR_WIDTH = RAM Depth
    parameter   DATA_WIDTH      =  NUM_COL*COL_WIDTH  // Data  Width in bits
    //----------------------------------------------------------------------
) (
    // Inputs
    input clkA_i,
    input [2:0] state_i,
    input enaA_i,
    input [NUM_COL-1:0] weA_i,
    input [ADDR_WIDTH-1:0] addrA_i,
    input [DATA_WIDTH-1:0] dinA_i,

    input clkB_i,
    input enaB_i,
    input [NUM_COL-1:0] weB_i,
    input [ADDR_WIDTH-1:0] addrB_i,
    input [DATA_WIDTH-1:0] dinB_i,

    // Outputs
    output reg [DATA_WIDTH-1:0] doutA_o,
    output reg [DATA_WIDTH-1:0] doutB_o
);

// Core Memory
reg [DATA_WIDTH-1:0]   ram_block [0:(2**ADDR_WIDTH)-1];
integer                i;

initial begin
    $readmemh("code.mem", ram_block);
end

// Port-A Operation (instructions)
always @ (posedge clkA_i) begin
    if(enaA_i && state_i == `FETCH_DECODE) begin
        for(i=0;i<NUM_COL;i=i+1) begin
            if(weA_i[i]) begin
                ram_block[addrA_i][i*COL_WIDTH +: COL_WIDTH] <= dinA_i[i*COL_WIDTH +: COL_WIDTH];
            end
        end

        doutA_o <= ram_block[addrA_i];
    end
end

// Port-B Operation (memory):
always @ (posedge clkB_i) begin
    if(enaB_i && state_i == `LOAD_STORE) begin
        for(i=0;i<NUM_COL;i=i+1) begin
            if(weB_i[i]) begin
                ram_block[addrB_i][i*COL_WIDTH +: COL_WIDTH] <= dinB_i[i*COL_WIDTH +: COL_WIDTH];
            end
        end

        doutB_o <= ram_block[addrB_i];
    end
end

endmodule
