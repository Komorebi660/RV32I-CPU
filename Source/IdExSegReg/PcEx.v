`timescale 1ns / 1ps
//  功能说明
    // ID\EX的PC段寄存器
// 输入
    // clk               时钟信号
    // PC_ID             PC寄存器传来的指令地址
    // predict_taken_ID  ID段传来的分支预测结果
    // bubbleE           EX阶段的bubble信号
    // flushE            EX阶段的flush信号
// 输出
    // PC_EX             传给下一流水段的PC地址
    // predict_taken_EX  传给Branch Decision的分支预测结果


module PC_EX(
    input wire clk, bubbleE, flushE,
    input wire [31:0] PC_ID,
    input predict_taken_ID,
    output reg [31:0] PC_EX,
    output reg predict_taken_EX
    );

    initial PC_EX = 0;
    initial predict_taken_EX = 0;
    
    always@(posedge clk)
        if (!bubbleE) 
        begin
            if (flushE)
            begin
                PC_EX <= 0;
                predict_taken_EX <= 0;
            end
            else 
            begin
                PC_EX <= PC_ID;
                predict_taken_EX <= predict_taken_ID;
            end
        end
    
endmodule