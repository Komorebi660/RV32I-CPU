`timescale 1ns / 1ps
/* THIS FILE IS PART OF PLC-Design
*  DIS.v - a controller of the 8-segment digital tube
* 
*  THIS PROGRAM IS FREE SOFTWARE.
*  Copyright (c) 2021 Komorebi660 All Rights Reserved 
* 
*  E-mail: cyq0919@mail.ustc.edu.cn
*/

module DIS(
    input[31:0] data,
    input rst, clk,
    output reg [7:0] an,
    output reg [7:0] seg);

    reg [15:0] cnt_s;
    reg [2:0] cnt;
    reg [3:0] digit;

    //0~7 count
    always@(posedge clk or posedge rst)
    begin
        if(rst) 
        begin
            cnt<=3'b000;
            cnt_s<=16'd0;
        end
        else if (cnt_s == 16'h1111)  
        begin
            cnt <= cnt + 3'b001;
            cnt_s <= cnt_s + 16'd1;
        end
        else  cnt_s <= cnt_s + 16'd1;
    end

    //mux
    always@(cnt,data)
    begin
        an=8'b1111_1111;
        case (cnt)
            3'b000: begin an[0]=0; digit=data[3:0];   end
            3'b001: begin an[1]=0; digit=data[7:4];   end
            3'b010: begin an[2]=0; digit=data[11:8];  end
            3'b011: begin an[3]=0; digit=data[15:12]; end
            3'b100: begin an[4]=0; digit=data[19:16]; end
            3'b101: begin an[5]=0; digit=data[23:20]; end
            3'b110: begin an[6]=0; digit=data[27:24]; end
            3'b111: begin an[7]=0; digit=data[31:28]; end
        endcase
    end

    //decode
    always@(digit)
    begin
        seg[0]=1; //ca
        seg[1]=1; //cb
        seg[2]=1; //cc
        seg[3]=1; //cd
        seg[4]=1; //ce
        seg[5]=1; //cf
        seg[6]=1; //cg
        seg[7]=1; //dp
        case (digit)
            4'b0000:begin seg[0]=0; seg[1]=0; seg[2]=0; seg[3]=0; seg[4]=0; seg[5]=0; end
            4'b0001:begin seg[1]=0; seg[2]=0; end
            4'b0010:begin seg[0]=0; seg[1]=0; seg[3]=0; seg[4]=0; seg[6]=0; end
            4'b0011:begin seg[0]=0; seg[1]=0; seg[2]=0; seg[3]=0; seg[6]=0; end
            4'b0100:begin seg[1]=0; seg[2]=0; seg[5]=0; seg[6]=0; end
            4'b0101:begin seg[0]=0; seg[2]=0; seg[3]=0; seg[5]=0; seg[6]=0; end
            4'b0110:begin seg[0]=0; seg[2]=0; seg[3]=0; seg[4]=0; seg[5]=0; seg[6]=0; end
            4'b0111:begin seg[0]=0; seg[1]=0; seg[2]=0; end
            4'b1000:begin seg[0]=0; seg[1]=0; seg[2]=0; seg[3]=0; seg[4]=0; seg[5]=0; seg[6]=0; end
            4'b1001:begin seg[0]=0; seg[1]=0; seg[2]=0; seg[3]=0; seg[5]=0; seg[6]=0; end
            4'b1010:begin seg[0]=0; seg[1]=0; seg[2]=0; seg[4]=0; seg[5]=0; seg[6]=0; end
            4'b1011:begin seg[2]=0; seg[3]=0; seg[4]=0; seg[5]=0; seg[6]=0; end
            4'b1100:begin seg[0]=0; seg[3]=0; seg[4]=0; seg[5]=0; end
            4'b1101:begin seg[1]=0; seg[2]=0; seg[3]=0; seg[4]=0; seg[6]=0; end
            4'b1110:begin seg[0]=0; seg[3]=0; seg[4]=0; seg[5]=0; seg[6]=0; end
            4'b1111:begin seg[0]=0; seg[4]=0; seg[5]=0; seg[6]=0; end
        endcase  
    end

endmodule