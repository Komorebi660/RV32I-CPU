`timescale 1ns / 1ps
//  功能说明
    //  算数运算和逻辑运算功能部件
// 输入
    // op1               第一个操作数
    // op2               第二个操作数
    // ALU_func          运算类型
// 输出
    // ALU_out           运算结果


`include "Parameters.v"   
module ALU(
    input wire [31:0] op1,
    input wire [31:0] op2,
    input wire [3:0] ALU_func,
    output reg [31:0] ALU_out
    );

    always @ (*)
    begin
        case(ALU_func)
            `ADD: ALU_out = op1 + op2;
            `SUB: ALU_out = op1 - op2;
            `XOR: ALU_out = op1 ^ op2;
            `OR:  ALU_out = op1 | op2;
            `AND: ALU_out = op1 & op2;
            `SLL: ALU_out = op1 << op2[4:0];
            `SRL: ALU_out = op1 >> op2[4:0];
            `SRA: ALU_out = {{32{op1[31]}}, op1[31:0]} >> op2[4:0];
            `SLT: begin
                if (op1[31]==0 && op2[31]==1)
                    ALU_out = 0;
                else if (op1[31]==1 && op2[31]==0)
                    ALU_out = 1;
                else if (op1[31]==1 && op2[31]==1)
                    ALU_out = (op1 < op2) ? 1 : 0;
                else
                    ALU_out = (op1 < op2) ? 1 : 0;
            end
            `SLTU: ALU_out = (op1 < op2) ? 32'd1 : 32'd0;
            `LUI:  ALU_out = op2;
            `OP1:  ALU_out = op1;
            `OP2:  ALU_out = op2;
            `NAND: ALU_out = (~op1) & op2; //CSRRC
            default: ALU_out = 32'b0;
        endcase
    end
endmodule

