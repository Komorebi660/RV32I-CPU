`timescale 1ns / 1ps
// 实验要求
    // 补全模块（阶段三）

module CSR_Regfile(
    input wire clk,
    input wire rst,
    input wire CSR_write_en,
    input wire [11:0] CSR_write_addr,
    input wire [11:0] CSR_read_addr,
    input wire [31:0] CSR_data_write,
    output wire [31:0] CSR_data_read
    );
    
    reg [31:0] CSR[4095:0];
    integer i;

    // init CSR file
    initial
    begin
        for(i = 0; i < 4096; i = i + 1) 
            CSR[i][31:0] <= 32'b0;
    end

    // write in clk posedge, so read data will be the old one
    always@(posedge clk or posedge rst) 
    begin 
        if (rst)
            for (i = 0; i < 4096; i = i + 1) 
                CSR[i][31:0] <= 32'b0;
        else if(CSR_write_en)
            CSR[CSR_write_addr] <= CSR_data_write;   
    end

    // read CSR file
    assign CSR_data_read = CSR[CSR_read_addr];

endmodule
