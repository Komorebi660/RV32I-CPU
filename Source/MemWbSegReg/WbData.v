`timescale 1ns / 1ps
//  功能说明
    // MEM\WB的写回寄存器内容
    // 为了数据同步，Data Extension和Data Cache集成在其中
// 输入
    // clk               时钟信号
    // wb_select         选择写回寄存器的数据：如果为0，写回ALU计算结果，如果为1，写回Memory读取的内容
    // load_type         load指令类型
    // write_en          Data Cache写使能
    // addr              Data Cache的写地址，也是ALU的计算结果
    // in_data           Data Cache的写入数据
    // bubbleW           WB阶段的bubble信号
    // flushW            WB阶段的flush信号
// 输出
    // data_WB           传给下一流水段的写回寄存器内容


module WB_Data_WB(
    input wire clk, rst, bubbleW, flushW,
    input wire wb_select,
    input wire [2:0] load_type,
    output wire miss,       //cache miss信号
    input wire read_en,     //读cache使能
    input  [3:0] write_en,  //写cache使能, 针对每一个byte
    input  [31:0] addr,
    input  [31:0] in_data,
    output wire [31:0] data_WB
    );

    wire [31:0] data_raw;
    wire [31:0] data_WB_raw;

    //data cache
    DataCache DataCache1(
        .clk(clk),
        .rst(rst),
        .miss(miss),
        .wr_en(write_en << addr[1:0]),          //根据地址移位, 定位到相应的byte
        .rd_req(read_en),
        .addr(addr),
        .wr_data(in_data << (8 * addr[1:0])),   //sb和sw都是把低位的数据写入对应的地址中，因此写入数据也需要相应地移位
        .rd_data(data_raw)
    );

    //统计miss次数
    reg miss_old;
    always@(posedge clk)
    begin
        if(rst)
            miss_old <= 1'b0;
        else 
            miss_old <= miss;
    end
    reg [31:0] miss_count;
    always@(posedge clk)
    begin
        if(rst)
            miss_count <= 32'd0;
        else if(miss & ~miss_old)   //检测上升沿
            miss_count <= miss_count + 32'd1;
    end
    //统计hit次数
    reg [31:0] hit_count;
    always@(posedge clk)
    begin
        if(rst)
            hit_count <= 32'd0;
        //非miss且有读写请求
        else if(~miss & ~miss_old & (read_en|(|write_en)))
            hit_count <= hit_count + 32'd1;
    end

    // Add flush and bubble support
    // if chip not enabled, output output last read result
    // else if chip clear, output 0
    // else output values from cache

    reg bubble_ff = 1'b0;
    reg flush_ff = 1'b0;
    reg wb_select_old = 0;
    reg [31:0] data_WB_old = 32'b0;
    reg [31:0] addr_old;
    reg [2:0] load_type_old;

    DataExtend DataExtend1(
        .data(data_raw),
        .addr(addr_old[1:0]),
        .load_type(load_type_old),
        .dealt_data(data_WB_raw)
    );

    always@(posedge clk)
    begin
        bubble_ff <= bubbleW;
        flush_ff <= flushW;
        data_WB_old <= data_WB;
        addr_old <= addr;
        wb_select_old <= wb_select;
        load_type_old <= load_type;
    end

    assign data_WB = bubble_ff ? data_WB_old :
                                 (flush_ff ? 32'b0 : 
                                             (wb_select_old ? data_WB_raw :
                                                              addr_old));

endmodule