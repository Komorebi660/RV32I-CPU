// Copyright (c) 2022 Komorebi660
// Functional Test file name: ../binary/CSRtest.data

module mem #(                    
    parameter  ADDR_LEN  = 11    
) (
    input  clk, rst,
    input  [ADDR_LEN-1:0] addr, // memory address
    output reg [31:0] rd_data,  // data read out
    input  wr_req,              // write request
    input  [31:0] wr_data       // data write in
);
localparam MEM_SIZE = 1<<ADDR_LEN;
reg [31:0] ram_cell [MEM_SIZE];

always @ (posedge clk or posedge rst)
    if(rst)
        rd_data <= 0;
    else
        rd_data <= ram_cell[addr];

always @ (posedge clk)
    if(wr_req) 
        ram_cell[addr] <= wr_data;

initial begin
        ram_cell[       0] = 32'h00000193;
        ram_cell[       1] = 32'h00f00093;
        ram_cell[       2] = 32'h00009073;
        ram_cell[       3] = 32'h00003173;
        ram_cell[       4] = 32'h06111063;
        ram_cell[       5] = 32'h000c7073;
        ram_cell[       6] = 32'h00003173;
        ram_cell[       7] = 32'h00700093;
        ram_cell[       8] = 32'h04111863;
        ram_cell[       9] = 32'h00200193;
        ram_cell[      10] = 32'h00100093;
        ram_cell[      11] = 32'h00209073;
        ram_cell[      12] = 32'h002c6173;
        ram_cell[      13] = 32'h02111e63;
        ram_cell[      14] = 32'h00201173;
        ram_cell[      15] = 32'h01900093;
        ram_cell[      16] = 32'h02111863;
        ram_cell[      17] = 32'h00300193;
        ram_cell[      18] = 32'h003c5073;
        ram_cell[      19] = 32'h00700093;
        ram_cell[      20] = 32'h0030a173;
        ram_cell[      21] = 32'h01800093;
        ram_cell[      22] = 32'h00111c63;
        ram_cell[      23] = 32'h00301173;
        ram_cell[      24] = 32'h01f00093;
        ram_cell[      25] = 32'h00111663;
        ram_cell[      26] = 32'h00100193;
        ram_cell[      27] = 32'hffdff06f;
        ram_cell[      28] = 32'h0000006f;
end

endmodule
