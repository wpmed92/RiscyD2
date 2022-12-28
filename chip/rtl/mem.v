//True Dual Port with Byte-Wide Write Enable
`include "constant_defs.v"

module mem
#(
    //--------------------------------------------------------------------------
    parameter   NUM_COL             =   4,
    parameter   COL_WIDTH           =   8,
    parameter   ADDR_WIDTH          =  15,
    // Addr  Width in bits : 2 *ADDR_WIDTH = RAM Depth
    parameter   DATA_WIDTH      =  NUM_COL*COL_WIDTH  // Data  Width in bits
    //----------------------------------------------------------------------
) (
    input clkA,
    input [2:0]state,
    input enaA,
    input [NUM_COL-1:0] weA,
    input [ADDR_WIDTH-1:0] addrA,
    input [DATA_WIDTH-1:0] dinA,
    output reg [DATA_WIDTH-1:0] doutA,
    input clkB,
    input enaB,
    input [NUM_COL-1:0] weB,
    input [ADDR_WIDTH-1:0] addrB,
    input [DATA_WIDTH-1:0] dinB,
    output reg [DATA_WIDTH-1:0] doutB
);

// Core Memory
reg [DATA_WIDTH-1:0]   ram_block [0:(2**ADDR_WIDTH)-1];
integer                i;

initial begin
    $readmemh("code.mem", ram_block);
end

// Port-A Operation (instructions)
always @ (posedge clkA) begin
    if(enaA && state == `FETCH_DECODE) begin
        for(i=0;i<NUM_COL;i=i+1) begin
            if(weA[i]) begin
                ram_block[addrA][i*COL_WIDTH +: COL_WIDTH] <= dinA[i*COL_WIDTH +: COL_WIDTH];
            end
        end

        doutA <= ram_block[addrA];
    end
end

// Port-B Operation (memory):
always @ (posedge clkB) begin
    if(enaB && state == `LOAD_STORE) begin
        for(i=0;i<NUM_COL;i=i+1) begin
            if(weB[i]) begin
                ram_block[addrB][i*COL_WIDTH +: COL_WIDTH] <= dinB[i*COL_WIDTH +: COL_WIDTH];
            end
        end

        doutB <= ram_block[addrB];
    end
end

endmodule
