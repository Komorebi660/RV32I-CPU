`timescale 1ns / 1ps

module ButtonEdge(
	input clk, rst,
	input key_in,
	output reg key_out);
	
	////  for simulation using  ////
    reg key_out0;
    wire posedge_change;
    always@(posedge clk or posedge rst)
    begin
        if(rst) key_out0<=0;
        else key_out0<=key_in; 
    end
    assign posedge_change=!key_out0 & key_in;

    always@(posedge clk or posedge rst)
    begin
        if(rst) key_out<=0;
        else if(posedge_change) key_out<=1;
        else key_out<=0;
    end
    ////  for simulation using  ////
    
    /*
    ////  for programming on the development board  ////
    reg key_in0, key_out0, key_out1;
    reg [19:0] cnt;

    wire change, posedge_change;

    //10ms
    parameter count=20'hF4240;

    // remove jitter
    always@(posedge clk)
	    key_in0<=key_in;

    assign change=(key_in & !key_in0)|(!key_in & key_in0);

    always@(posedge clk or posedge rst)
        if(rst) cnt<=0;
        else if(change) cnt<=0;
	    else cnt<=cnt+1;

    always@(posedge clk or posedge rst)
        if(rst)
        begin
            key_out0<=0;
            key_out1<=0;
        end
	    else if(cnt==count-1) key_out0<=key_in;
        else key_out1<=key_out0;

    //taking the rising edge
    assign posedge_change = !key_out1 & key_out0;

    always@(posedge clk or posedge rst)
        if(rst) key_out<=0;
        else if(posedge_change) key_out<=1;
        else key_out<=0;
 ////  for programming on the development board  ////
*/
endmodule
