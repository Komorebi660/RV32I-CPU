# -*- coding:utf-8 -*-
# Copyright (c) 2022 Komorebi660
# 功能: 使用RISC-V工具链将汇编编译成I-Cache的Verilog文件


import os
import sys
import binascii
import platform


verilog_head = '''// Copyright (c) 2022 Komorebi660
// ASM file name: %s

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

del_command = None

if platform.system().lower() == 'windows':
    RISCV_TOOLCHAIN_PATH = '.\\..\\toolchains\\riscv32-windows\\'
    del_command = 'del'
elif platform.system().lower() == 'linux':
    RISCV_TOOLCHAIN_PATH = './../toolchains/riscv32-linux/'
    del_command = 'rm'
else:
    RISCV_TOOLCHAIN_PATH = None
    print('Unknow Platform!')
    sys.exit()


if len(sys.argv) != 3:
    print('Usage:\npython gen_instruction.py [INPUT ASM file] [OUTPUT Verilog file]')
    print('Example:\npython gen_instruction.py QuickSort.S InstructionCache.v')
else:
    INPUT = sys.argv[1]
    OUTPUT = sys.argv[2]

    res = os.system('%sriscv32-elf-as %s -o compile_tmp.o -march=rv32i' % (RISCV_TOOLCHAIN_PATH, INPUT))
    if res != 0:
        print('\nAssembling Error!')
        sys.exit()
    os.system('%sriscv32-elf-ld compile_tmp.o -o compile_tmp.om' % (RISCV_TOOLCHAIN_PATH))
    os.system('%sriscv32-elf-objcopy -O binary compile_tmp.om compile_tmp.bin' % (RISCV_TOOLCHAIN_PATH,))
    s = binascii.b2a_hex(open('compile_tmp.bin', 'rb').read())

    os.system('%s compile_tmp.om' % (del_command))
    os.system('%s compile_tmp.o' % (del_command))
    os.system('%s compile_tmp.bin' % (del_command))

    def byte_wise_reverse(b):
        return b[6:8] + b[4:6] + b[2:4] + b[0:2]

    with open(OUTPUT, 'w') as f:
        f.write(verilog_head % (INPUT,))
        for i in range(0, len(s), 8):
            instr_string = str(byte_wise_reverse(s[i:i+8]))
            if instr_string[1] == "'":
                instr_string = instr_string[2:]
            instr_string = instr_string.strip("'")
            f.write('        inst_cache[%8d] = 32\'h%s;\n' % (i//8, instr_string, ))
        f.write(verilog_tail)
