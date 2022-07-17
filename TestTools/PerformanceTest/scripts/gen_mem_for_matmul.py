# -*- coding:utf-8 -*-
# Copyright (c) 2022 Komorebi660
# 功能: 生成针对于矩阵乘法(matmul)的mem.sv, 里面存放两个要进行相乘的初始矩阵。


from random import randint
import sys


verilog_head = '''// Copyright (c) 2022 Komorebi660
// %sx%s matrix to multiply and the result matrix

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
    print('Usage:\npython gen_mem_for_matmul.py [matrix size] [OUTPUT Verilog file]')
    print('Example:\npython gen_mem_for_matmul.py 16 mem.sv')
else:
    try:
        N = int(sys.argv[1])
        OUTPUT = sys.argv[2]
    except:
        print('*** Error: parameter must be integer, not %s' % (sys.argv[1], ))
        sys.exit(-1)
    if N <= 1:
        print('*** Error: parameter must be larger than 1, not %d' % (N, ))
        sys.exit(-1)

    #生成矩阵乘法的两个初始矩阵
    A, B, C = [], [], []
    for i in range(N):
        Aline, Bline, Cline = [], [], []
        for j in range(N):
            Aline.append(randint(0, 0xffffffff))
            Bline.append(randint(0, 0xffffffff))
            Cline.append(0)
        A.append(Aline)
        B.append(Bline)
        C.append(Cline)

    #计算伪矩阵乘法
    for i in range(N):
        for j in range(N):
            for k in range(N):
                C[i][j] += A[i][k] & B[k][j]

    with open(OUTPUT, 'w') as f:
        f.write(verilog_head % (str(N), str(N)))

        f.write('    // dst matrix C\n')
        for i in range(N):
            for j in range(N):
                f.write("    ram_cell[%8d] = 32'h0;  // 32'h%08x;\n" % (N*i+j, C[i][j] & 0xffffffff, ))
        f.write('    // src matrix A\n')
        for i in range(N):
            for j in range(N):
                f.write("    ram_cell[%8d] = 32'h%08x;\n" % (N*N+N*i+j, A[i][j], ))
        f.write('    // src matrix B\n')
        for i in range(N):
            for j in range(N):
                f.write("    ram_cell[%8d] = 32'h%08x;\n" % (2*N*N+N*i+j, B[i][j], ))

        f.write(verilog_tail)
