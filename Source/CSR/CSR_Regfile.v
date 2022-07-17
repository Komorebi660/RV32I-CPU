// Copyright (c) 2022 Komorebi660
`timescale 1ns / 1ps

module CSR_Regfile #(
    parameter CSR_ADDR_LEN = 4
)(
    input wire clk,
    input wire rst,
    input wire CSR_write_en,
    input wire [11:0] CSR_write_addr,
    input wire [11:0] CSR_read_addr,
    input wire [31:0] CSR_data_write,
    output wire [31:0] CSR_data_read
);

    localparam CSR_SIZE = 1 << CSR_ADDR_LEN;
    localparam UNUSED_ADDR_LEN = 12 - CSR_ADDR_LEN;
    
    reg [31:0] CSR[CSR_SIZE-1 : 0];
    integer i;

    wire [CSR_ADDR_LEN-1   : 0] write_addr;
    wire [UNUSED_ADDR_LEN-1: 0] unused_write_addr;
    assign {unused_write_addr, write_addr} = CSR_write_addr;

    wire [CSR_ADDR_LEN-1   : 0] read_addr;
    wire [UNUSED_ADDR_LEN-1: 0] unused_read_addr;
    assign {unused_read_addr, read_addr} = CSR_read_addr;

    // init CSR file
    initial
    begin
        for(i = 0; i < CSR_SIZE; i = i + 1) 
            CSR[i][31:0] <= 32'b0;
    end

    // write in clk posedge, so read data will be the old one
    always@(posedge clk or posedge rst) 
    begin 
        if (rst)
            for (i = 0; i < CSR_SIZE; i = i + 1) 
                CSR[i][31:0] <= 32'b0;
        else if(CSR_write_en)
            CSR[write_addr] <= CSR_data_write;   
    end

    // read CSR file
    assign CSR_data_read = CSR[read_addr];

endmodule
