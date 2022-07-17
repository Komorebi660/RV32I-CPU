# -*- coding:utf-8 -*-
# Copyright (c) 2022 Komorebi660
# 功能: 将binary文件夹内的inst数据转换成I-Cache的Verilog文件


import sys


verilog_head = '''// Copyright (c) 2022 Komorebi660
// Functional Test file name: %s

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
'''

verilog_tail = '''end

    always@(posedge clk)
    begin
        data <= addr_valid ? inst_cache[dealt_addr] : 32'h0;
    end

endmodule
'''


if len(sys.argv) != 3:
    print('Usage:\npython gen_instruction.py [INPUT inst file] [OUTPUT Verilog file]')
    print('Example:\npython gen_instruction.py 1testAll.inst InstructionCache.v')
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
            f.write('        inst_cache[%8d] = 32\'h%s;\n' % (i, line))
            i = i + 1

        f.write(verilog_tail)
