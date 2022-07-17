// Copyright (c) 2022 Komorebi660
`timescale 1ns / 1ps

module CSR_EX(
    input wire clk, bubbleE, flushE,    //控制信号
    input wire [11:0] CSR_addr_ID,      //CSR寄存器在ID段的地址
    input wire [31:0] CSR_zimm_ID,      //立即数在ID段的值
    input wire CSR_zimm_or_reg_ID,      //ID段控制信号: 选择立即数还是寄存器的值
    input wire CSR_write_en_ID,         //ID段控制信号: 是否需要写CSR
    output reg [11:0] CSR_addr_EX,      //CSR寄存器在EX段的地址
    output reg [31:0] CSR_zimm_EX,      //立即数在EX段的值
    output reg CSR_zimm_or_reg_EX,      //EX段控制信号: 选择立即数还是寄存器的值
    output reg CSR_write_en_EX          //EX段控制信号: 是否需要写CSR
    );

    //initial to zero
    initial 
    begin
        CSR_addr_EX = 0;
        CSR_zimm_EX = 0;
        CSR_zimm_or_reg_EX = 0;
        CSR_write_en_EX = 0;
    end

    always@(posedge clk)
        if (!bubbleE) //not stall
        begin
            if (flushE)
            begin
                CSR_addr_EX <= 0;
                CSR_zimm_EX <= 0;
                CSR_zimm_or_reg_EX <= 0;
                CSR_write_en_EX <= 0;
            end
            else
            begin
                CSR_addr_EX <= CSR_addr_ID;
                CSR_zimm_EX <= CSR_zimm_ID;
                CSR_zimm_or_reg_EX <= CSR_zimm_or_reg_ID;
                CSR_write_en_EX <= CSR_write_en_ID;
            end
        end

endmodule
