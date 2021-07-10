`timescale 1ns / 1ps
/* THIS FILE IS PART OF PLC-Design
*  SwitchRegister.v - a controller of the switches to connect with the CPU
* 
*  THIS PROGRAM IS FREE SOFTWARE.
*  Copyright (c) 2021 Komorebi660 All Rights Reserved 
* 
*  E-mail: cyq0919@mail.ustc.edu.cn
*/

module SwitchRegister(
    input wire [31:0] data,         //input data
    input wire [15:0] address,      //input read address
    input wire write_enable,
    input wire read_enable,
    input wire clk,
    input wire rst,
    output reg [31:0] register,     //output read data
    output reg flag                 //show if you can put a new number  
    );

    reg [31:0] SWDR;    //switch data register
    reg [31:0] SWSR;    //switch state register

    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            SWDR<=32'd0;
            SWSR<=32'd0;
        end
        else if(write_enable)
        begin
            SWDR<=data;
            SWSR<=32'd1;    //once write, SWSR must be set 1
        end
        else if(read_enable)
        begin
            if(address==16'h8000) SWSR<=32'd0;  //once read data, SWSR must be set 0
        end
    end
    
    always@(*)
    begin
        //output data
        if(rst) register=32'd0;
        else if(address==16'h8000) register=SWDR;
        else if(address==16'h8001) register=SWSR;
        else register=32'd0;
    end
    
    always@(*)
    begin
        if(SWSR==32'd0) flag=1'b1;
        else flag=1'b0;
    end

endmodule
