`timescale 1ns / 1ps
//  功能说明
    // ID\EX的控制信号段寄存器
// 输入
    // clk                  时钟信号
    // jalr_ID              jalr跳转指令
    // ALU_func_ID          ALU执行的运算类型
    // br_type_ID           branch的判断条件，可以是不进行branch
    // load_npc_ID          写回寄存器的值的来源（PC或者ALU计算结果）
    // wb_select_ID         写回寄存器的值的来源（Cache内容或者ALU计算结果）
    // load_type_ID         load类型
    // reg_write_en_ID      通用寄存器写使能
    // cache_write_en_ID    按字节写入data cache
    // bubbleE              EX阶段的bubble信号
    // flushE               EX阶段的flush信号
// 输出
    // jalr_EX              传给下一流水段的jalr跳转指令
    // ALU_func_EX          传给下一流水段的ALU执行的运算类型
    // br_type_EX           传给下一流水段的branch的判断条件，可以是不进行branch
    // load_npc_EX          传给下一流水段的写回寄存器的值的来源（PC或者ALU计算结果）
    // wb_select_EX         传给下一流水段的写回寄存器的值的来源（Cache内容或者ALU计算结果）
    // load_type_EX         传给下一流水段的load类型
    // reg_write_en_EX      传给下一流水段的通用寄存器写使能
    // cache_write_en_EX    传给下一流水段的按字节写入data cache

// 实验要求  
    // 无需修改


module Ctrl_EX(
    input wire clk, bubbleE, flushE,
    input wire jalr_ID,
    input wire [3:0] ALU_func_ID,
    input wire [2:0] br_type_ID,
    input wire load_npc_ID,
    input wire wb_select_ID,
    input wire [2:0] load_type_ID,
    input wire reg_write_en_ID,
    input wire [3:0] cache_write_en_ID,
    input wire op1_src_ID, op2_src_ID, 
    output reg jalr_EX,
    output reg [3:0] ALU_func_EX,
    output reg [2:0] br_type_EX,
    output reg load_npc_EX,
    output reg wb_select_EX,
    output reg [2:0] load_type_EX,
    output reg reg_write_en_EX,
    output reg [3:0] cache_write_en_EX,
    output reg op1_src_EX, op2_src_EX
    );

    initial 
    begin
        jalr_EX = 0;
        ALU_func_EX = 4'h0;
        br_type_EX = 3'h0;
        load_npc_EX = 0;
        wb_select_EX = 0;
        load_type_EX = 2'h0;
        reg_write_en_EX = 0;
        cache_write_en_EX = 3'h0;
        op1_src_EX = 0;
        op2_src_EX = 0;
        
    end
    
    always@(posedge clk)
        if (!bubbleE) 
        begin
            if (flushE)
            begin
                jalr_EX <= 0;
                ALU_func_EX <= 4'h0;
                br_type_EX <= 3'h0;
                load_npc_EX <= 0;
                wb_select_EX <= 0;
                load_type_EX <= 2'h0;
                reg_write_en_EX <= 0;
                cache_write_en_EX <= 3'h0;
                op1_src_EX <= 0;
                op2_src_EX <= 0;
            end
            else
            begin
                jalr_EX <= jalr_ID;
                ALU_func_EX <= ALU_func_ID;
                br_type_EX <= br_type_ID;
                load_npc_EX <= load_npc_ID;
                wb_select_EX <= wb_select_ID;
                load_type_EX <= load_type_ID;
                reg_write_en_EX <= reg_write_en_ID;
                cache_write_en_EX <= cache_write_en_ID;
                op1_src_EX <= op1_src_ID;
                op2_src_EX <= op2_src_ID;
            end
        end
    
endmodule