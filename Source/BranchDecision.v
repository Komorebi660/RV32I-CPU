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
    output reg br
    );

    always @ (*)
    begin
        case(br_type)
            `NOBRANCH: br = 0;
            `BEQ:  br = (reg1 == reg2) ? 1 : 0;
            `BNE:  br = (reg1 == reg2) ? 0 : 1;
            `BLTU: br = (reg1 <  reg2) ? 1 : 0;
            `BGEU: br = (reg1 >= reg2) ? 1 : 0;
            `BLT:  begin
                if (reg1[31]==0 && reg2[31]==1)
                    br = 0;
                else if (reg1[31]==1 && reg2[31]==0)
                    br = 1;
                else if (reg1[31]==1 && reg2[31]==1)
                    br = (reg1 < reg2) ? 1 : 0;
                else
                    br = (reg1 < reg2) ? 1 : 0;
            end
            `BGE:  begin
                if (reg1[31]==0 && reg2[31]==1)
                    br = 1;
                else if (reg1[31]==1 && reg2[31]==0)
                    br = 0;
                else if (reg1[31]==1 && reg2[31]==1)
                    br = (reg1 >= reg2) ? 1 : 0;
                else
                    br = (reg1 >= reg2) ? 1 : 0;
            end
            default: br = 0;
        endcase
    end

endmodule
