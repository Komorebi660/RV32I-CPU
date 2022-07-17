`timescale 1ns / 1ps
//  功能说明
    //  判断是否branch
// 输入
    // reg1               寄存器1
    // reg2               寄存器2
    // br_type            branch类型
// 输出
    // br                 是否branch


`include "Parameters.v"   
module BranchDecision(
    input wire [31:0] reg1, reg2,
    input wire [2:0] br_type,
    input wire predict_taken,
    input wire [31:0] br_target, current_pc,
    output reg [31:0] target,
    output reg taken, predict_wrong, is_branch
    );

    always @ (*)
    begin
        case(br_type)
            `NOBRANCH: begin 
                taken = 0;
                is_branch = 0;
            end
            `BEQ:  begin
                taken = (reg1 == reg2) ? 1 : 0;
                is_branch = 1;
            end
            `BNE:  begin
                taken = (reg1 == reg2) ? 0 : 1;
                is_branch = 1;
            end
            `BLTU: begin
                taken = (reg1 <  reg2) ? 1 : 0;
                is_branch = 1;
            end
            `BGEU: begin
                taken = (reg1 >= reg2) ? 1 : 0;
                is_branch = 1;
            end
            `BLT:  begin
                if (reg1[31]==0 && reg2[31]==1)
                    taken = 0;
                else if (reg1[31]==1 && reg2[31]==0)
                    taken = 1;
                else if (reg1[31]==1 && reg2[31]==1)
                    taken = (reg1 < reg2) ? 1 : 0;
                else
                    taken = (reg1 < reg2) ? 1 : 0;
                
                is_branch = 1;
            end
            `BGE:  begin
                if (reg1[31]==0 && reg2[31]==1)
                    taken = 1;
                else if (reg1[31]==1 && reg2[31]==0)
                    taken = 0;
                else if (reg1[31]==1 && reg2[31]==1)
                    taken = (reg1 >= reg2) ? 1 : 0;
                else
                    taken = (reg1 >= reg2) ? 1 : 0;
                
                is_branch = 1;
            end
            default: begin
                taken = 0;
                is_branch = 0;
            end
        endcase

        predict_wrong = taken ^ predict_taken;   //分支预测错误, 需要更新

        //若实际跳转, 则更新的分支目标是前面实际计算得到的target
        if (taken)
            target = br_target;
        //否则, 分支目标是pc+4 (顺序执行)
        else 
            target = current_pc + 4;
    end


endmodule
