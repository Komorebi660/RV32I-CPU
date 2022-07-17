`timescale 1ns / 1ps
//  功能说明
    // IF\ID的指令段寄存器
// 输入
    // clk               时钟信号
    // addr              Instruction Cache的读指令地址
    // bubbleD           ID阶段的bubble信号
    // flushD            ID阶段的flush信号
// 输出
    // inst_ID           传给下一流水段的指令


module IR_ID(
    input wire clk, bubbleD, flushD,
    input wire [31:2] addr,
    output wire [31:0] inst_ID
    );

    wire [31:0] inst_ID_raw;

    InstructionCache InstructionCache1(
        .clk(clk),
        .addr(addr),
        .data(inst_ID_raw)
    );

    // Add flush and bubble support
    // if chip not enabled, output output last read result
    // else if chip clear, output 0
    // else output values from cache
    reg bubble_ff = 1'b0;
    reg flush_ff = 1'b0;
    reg [31:0] inst_ID_old = 32'b0;

    always@(posedge clk)
    begin
        bubble_ff <= bubbleD;
        flush_ff <= flushD;
        if(!bubble_ff)  //处理多bubble情况
            inst_ID_old <= inst_ID_raw;
    end

    assign inst_ID = bubble_ff ? inst_ID_old : (flush_ff ? 32'b0 : inst_ID_raw);

endmodule