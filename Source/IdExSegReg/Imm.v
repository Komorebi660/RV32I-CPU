`timescale 1ns / 1ps
//  功能说明
    //  ID/EX.Imm 段寄存器
// 实验要求
    // 无需修改

module Imm_EX(
    input wire clk, bubbleE, flushE,
    input wire [31:0] imm_in,
    output reg [31:0] imm_out
    );
    initial imm_out = 0;
    
    always@(posedge clk)
        if (!bubbleE) 
        begin
            if (flushE)
                imm_out <= 0;
            else 
                imm_out <= imm_in;
        end
endmodule