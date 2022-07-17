# -*- coding:utf-8 -*-
# Copyright (c) 2022 Komorebi660
# 功能: 将binary文件夹内的data数据转换成D-Cache的Verilog文件


import sys


verilog_head = '''// Copyright (c) 2022 Komorebi660
// Functional Test file name: %s

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
'''

verilog_tail = '''end

endmodule
'''


if len(sys.argv) != 3:
    print('Usage:\npython gen_mem.py [INPUT data file] [OUTPUT Verilog file]')
    print('Example:\npython gen_mem.py 1testAll.data mem.sv')
else:
    INPUT = sys.argv[1]
    OUTPUT = sys.argv[2]

    try:
        inst = open(INPUT, 'r')
    except FileNotFoundError:
        print('File not found!')
        sys.exit()

    with open(OUTPUT, 'w') as f:
        f.write(verilog_head % (INPUT))

        i = 0
        for line in inst:
            line = line.strip('\n')
            f.write('        ram_cell[%8d] = 32\'h%s;\n' % (i, line))
            i = i + 1

        f.write(verilog_tail)
