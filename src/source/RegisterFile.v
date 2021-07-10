`timescale 1ns / 1ps
/* THIS FILE IS PART OF PLC-Design
*  RegsiterFile.v - A core element of the CPU
* 
*  THIS PROGRAM IS FREE SOFTWARE.
*  Copyright (c) 2021 Komorebi660 All Rights Reserved 
* 
*  E-mail: cyq0919@mail.ustc.edu.cn
*/

module RegisterFile 
(   //address space is 32*32bits  
    input wire WE, clk, rst,                //write enable and clock signal
    input wire [4:0] WA,RA0,RA1,RA2,        //5 bits write and read address
    input wire [31:0] WD,                   //32 bits write data
    output reg [31:0] RD0,RD1,RD2           //32 bits read data
);
    
    reg [31:0] reg_file [31:0];     //32 32bits registers

    //read
    always@(*)
    begin
        if(RA0==5'd0) RD0=32'd0;    //x0==0
        else RD0=reg_file[RA0];
    end
    always@(*)
    begin
        if(RA1==5'd0) RD1=32'd0;    //x0==0
        else RD1=reg_file[RA1];
    end
    always@(*)
    begin
        if(RA2==5'd0) RD2=32'd0;    //x0==0
        else RD2=reg_file[RA2];
    end

    //write
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            reg_file[0]<=32'd0;
            reg_file[1]<=32'd0;
            reg_file[2]<=32'd0;
            reg_file[3]<=32'd0;
            reg_file[4]<=32'd0;
        end
        else if(WE) reg_file[WA]<=WD;
    end
        
        
endmodule