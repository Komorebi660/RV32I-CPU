`timescale 1ns / 1ps
// 功能说明
    // ID-EX段CSR控制寄存器
// 输入
    // clk                  输入时钟
    // bubbleE              EX阶段的bubble信号
    // flushE               EX阶段的flush信号
    // CSR_addr_ID          ID段的CSR寄存器地址
    // CSR_zimm_ID          ID段的立即数
    // CSR_zimm_or_reg_ID   ID段的源操作数选择信号
    // CSR_write_en_ID      ID段的CSR寄存器写信号
// 输出
    // CSR_addr_EX          EX段的CSR寄存器地址
    // CSR_zimm_EX          EX段的立即数
    // CSR_zimm_or_reg_EX   EX段的源操作数选择信号
    // CSR_write_en_EX      EX段的CSR寄存器写信号
    

module CSR_EX(
    input wire clk, bubbleE, flushE,
    input wire [11:0] CSR_addr_ID,
    input wire [31:0] CSR_zimm_ID,
    input wire CSR_zimm_or_reg_ID,
    input wire CSR_write_en_ID,
    output reg [11:0] CSR_addr_EX,
    output reg [31:0] CSR_zimm_EX,
    output reg CSR_zimm_or_reg_EX,
    output reg CSR_write_en_EX
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
