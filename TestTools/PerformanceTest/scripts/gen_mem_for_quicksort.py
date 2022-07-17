# -*- coding:utf-8 -*-
# Copyright (c) 2022 Komorebi660
# 功能: 生成针对于快速排序(quicksort)的mem.sv, 里面存放即将被排序的数据。


from random import shuffle
import sys


verilog_head = '''// Copyright (c) 2022 Komorebi660
// %s number to sort

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
    print('Usage:\npython gen_mem_for_quicksort.py [numver of data] [OUTPUT Verilog file]')
    print('Example:\npython gen_mem_for_quicksort.py 256 mem.sv')
else:
    try:
        N = int(sys.argv[1])
        OUTPUT = sys.argv[2]
    except:
        print('*** Error: parameter must be integer, not %s' % (sys.argv[1], ))
        sys.exit(-1)
    if N <= 2:
        print('*** Error: parameter must be larger than 2, not %d' % (N, ))
        sys.exit(-1)

    with open(OUTPUT, 'w') as f:
        f.write(verilog_head % str(N))

        #生成随机排列的数据
        lst = list(range(N))
        shuffle(lst)

        for i in range(N):
            f.write("    ram_cell[%8d] = 32'h%08x;\n" % (i, lst[i], ))

        f.write(verilog_tail)
