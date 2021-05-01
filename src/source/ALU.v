`timescale 1ns / 1ps

module ALU #(parameter N=32)(
    input [N-1:0] a, b,     //input two 32bits numbers
    input s,                //function select
    output reg [N-1:0] y,   //output answer        
    output zf);             //zero signal

    localparam ADD=1'b0, CMP=1'b1;
    reg of;                 //overflow signal

    always@(*)
    begin
        of=0;
        case(s)
        //ADD function
        ADD:begin
            y=a + b;
            if((a[N-1]==b[N-1])&&(a[N-1]!=y[N-1])) of=1;
            else of=0;
        end
        //Compare funtion
        CMP:begin
            y=a^b;
        end
        endcase
    end
    //generate zero signal
    assign zf = ~|y;
endmodule
