// Copyright (c) 2022 Komorebi660
// Functional Test file name: ../binary/CSRtest.inst

module InstructionCache(
    input wire clk,
    input wire [31:2] addr,
    output reg [31:0] data
);

    // local variable
    wire addr_valid = (addr[31:14] == 18'h0);
    wire [11:0] dealt_addr = addr[13:2];
    // cache content
    reg [31:0] inst_cache[0:4095];


    initial begin
        data = 32'h0;
        inst_cache[       0] = 32'h00000193;
        inst_cache[       1] = 32'h00f00093;
        inst_cache[       2] = 32'h00009073;
        inst_cache[       3] = 32'h00003173;
        inst_cache[       4] = 32'h06111063;
        inst_cache[       5] = 32'h000c7073;
        inst_cache[       6] = 32'h00003173;
        inst_cache[       7] = 32'h00700093;
        inst_cache[       8] = 32'h04111863;
        inst_cache[       9] = 32'h00200193;
        inst_cache[      10] = 32'h00100093;
        inst_cache[      11] = 32'h00209073;
        inst_cache[      12] = 32'h002c6173;
        inst_cache[      13] = 32'h02111e63;
        inst_cache[      14] = 32'h00201173;
        inst_cache[      15] = 32'h01900093;
        inst_cache[      16] = 32'h02111863;
        inst_cache[      17] = 32'h00300193;
        inst_cache[      18] = 32'h003c5073;
        inst_cache[      19] = 32'h00700093;
        inst_cache[      20] = 32'h0030a173;
        inst_cache[      21] = 32'h01800093;
        inst_cache[      22] = 32'h00111c63;
        inst_cache[      23] = 32'h00301173;
        inst_cache[      24] = 32'h01f00093;
        inst_cache[      25] = 32'h00111663;
        inst_cache[      26] = 32'h00100193;
        inst_cache[      27] = 32'hffdff06f;
        inst_cache[      28] = 32'h0000006f;
end

    always@(posedge clk)
    begin
        data <= addr_valid ? inst_cache[dealt_addr] : 32'h0;
    end

endmodule
