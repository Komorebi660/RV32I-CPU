`timescale 1ns / 1ps

/*
////  for programming on the development board  ////
module DebugUnit(
    input wire [15:0] data,
    input en,
    input clk, rst,
    input up, down,                 // debug regfile address +/-
    output [7:0] an,                // seven-segment digital tube parameter
    output [7:0] seg,               // seven-segment digital tube parameter
    output [4:0] debug_register,    // debug regfile address output
    output input_flag
    );
    //ButtonEdge parameter
    wire write_enable, up_enable, down_enable;
    //SwitchRegister parameter
    wire [15:0] read_address;
    wire read_enable;
    wire [31:0] read_data;
    //CPU parameter
    reg [4:0] debug_address;
    wire [31:0] debug_data;
    
    ButtonEdge en_inst
    (
        .clk(clk),
        .rst(rst),
        .key_in(en),
        .key_out(write_enable)
    );
    ButtonEdge up_inst
    (
        .clk(clk),
        .rst(rst),
        .key_in(up),
        .key_out(up_enable)
    );
    ButtonEdge down_inst
    (
        .clk(clk),
        .rst(rst),
        .key_in(down),
        .key_out(down_enable)
    );
    SwitchRegister SW
    (
        .data({16'd0,data}),
        .address(read_address),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .clk(clk),
        .rst(rst),
        .register(read_data),
        .flag(input_flag)
    );
    CPU test
    (
        .clk(clk),
        .rst(rst),
        .debug_address(debug_address),
        .SWData(read_data),
        .read_address(read_address),
        .read_enable(read_enable),
        .debug_data(debug_data)
    );

    DIS inst
    (
        .data(debug_data),
        .rst(rst), 
        .clk(clk),
        .an(an),
        .seg(seg)
    );
    
    always@(posedge clk or posedge rst)
    begin
        if(rst) debug_address<=5'b00001;
        else if(up_enable) debug_address<=debug_address+5'd1;
        else if(down_enable) debug_address<=debug_address-5'd1;
    end
    
   assign debug_register=debug_address;
    
endmodule
////  for programming on the development board  ////
*/



////  for simulation using  ////
module DebugUnit(
    input wire [15:0] data,
    input en,
    input clk, rst,
    output [15:0] result
    );
    wire write_enable;
    wire [15:0] read_address;
    wire read_enable;
    wire [31:0] read_data;
    wire [31:0] debug_data;
    
    ButtonEdge BE
    (
        .clk(clk),
        .rst(rst),
        .key_in(en),
        .key_out(write_enable)
    );
    SwitchRegister SW
    (
        .data({16'd0,data}),
        .address(read_address),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .clk(clk),
        .rst(rst),
        .register(read_data)
    );
    CPU test
    (
        .clk(clk),
        .rst(rst),
        .debug_address(5'b00001),
        .SWData(read_data),
        .read_address(read_address),
        .read_enable(read_enable),
        .debug_data(debug_data)
    );
    
    assign result=debug_data[15:0];
    
endmodule
////  for simulation using  ////
