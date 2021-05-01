`timescale 1ns / 1ps

module debug_test();
    reg [15:0] data;
    reg en;
    reg clk, rst;
    wire [15:0] result;
    
    initial
    begin
        clk=0;
        forever #1 clk=~clk;
    end
    
    initial
    begin
        rst=0;
        #1 rst =1;
        #1 rst=0;
    end
    
    initial
    begin
        en=0;
        #10 en=1;
        #10 en=0;
        #100 en=1;
        #100 en=0;
        #100 en=1;
        #100 en=0;
    end
    
    initial
    begin
        data=16'd0;
        #5 data=16'd5;
        #100 data=16'd1;
        #100 data =16'd10;
    end
    
    DebugUnit inst_test(
        .data(data),
        .en(en),
        .clk(clk),
        .rst(rst),
        .result(result)
    );
endmodule
