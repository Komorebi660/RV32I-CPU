`timescale 1ns / 1ps
//  功能说明
    //  根据跳转信号，决定执行的下一条指令地址
    //  debug端口用于simulation时批量写入数据，可以忽略
// 输入
    // predict_target    分支预测的PC
    // jal_target        jal跳转地址
    // jalr_target       jalr跳转地址
    // br_target         br跳转地址
    // jal               jal == 1时，有jal跳转
    // jalr              jalr == 1时，有jalr跳转
    // br                br == 1时，有br跳转
// 输出
    // NPC               下一条执行的指令地址


module NPC_Generator(
    input wire [31:0] predict_target, jal_target, jalr_target, br_target,
    input wire jal, jalr, br,
    output reg [31:0] NPC
    );

    always @(*)
    begin
        if(br)  // 分支预测错误时的跳转目标
            NPC = br_target;
        else if(jalr)
            NPC = jalr_target;
        else if(jal)
            NPC = jal_target;
        else    // 分支预测结果
            NPC = predict_target;
    end

endmodule