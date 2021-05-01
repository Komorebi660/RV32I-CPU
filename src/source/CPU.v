`timescale 1ns / 1ps

module CPU(
    input wire clk,
    input wire rst,
    input wire [4:0] debug_address, // the address of the register checked
    input wire [31:0] SWData,       // switch data input
    output wire [15:0] read_address,// switch data address
    output wire read_enable,        // read switch data enable
    output wire [31:0] debug_data   // the data of the register checked
    );

    //InstructionMemory parameter
    reg [31:0] PC;
    wire [31:0] instruction;
    //DataMemory parameter
    wire MemWrite;
    wire [31:0] memory_data_address;
    wire [31:0] read_memory_data, write_memory_data;
    //Registers parameter
    wire RegWrite;
    wire [4:0] write_register;
    wire [4:0] read_register_1, read_register_2;
    wire [31:0] read_data_1, read_data_2;
    reg [31:0] write_data;
    //ALU parameter
    reg [31:0] A, B;
    wire [31:0] ALUResult;
    wire ALUSelect, ZERO;
    
    dist_mem_gen_0 InstructionMemory 
    (
        .a(PC[7:0]),                    // input PC
        .spo(instruction)               // output instruction
    );
    dist_mem_gen_1 DataMemory 
    (
        .a(memory_data_address[7:0]),   // input address
        .d(write_memory_data),          // input data
        .clk(clk),                      // input clk
        .we(MemWrite),                  // input write enable
        .spo(read_memory_data)          // output data
    );
    ALU inst
    (
        .a(A),                          //first element
        .b(B),                          //second element
        .s(ALUSelect),                  //select signal
        .y(ALUResult),                  //result
        .zf(ZERO)                       //zero
    );
    RegisterFile Registers
    (
        .WE(RegWrite),                  //write enable
        .clk(clk),                      //clock
        .rst(rst),
        .WA(write_register),            //write address
        .RA0(read_register_1),          //read address 1
        .RA1(read_register_2),          //read address 2
        .RA2(debug_address),
        .WD(write_data),                //write data
        .RD0(read_data_1),              //read data 1
        .RD1(read_data_2),              //read data 2
        .RD2(debug_data)
    );
    assign read_address=memory_data_address[15:0];

    /* all modules variable*/
    //generate PC
    reg [31:0] temp_PC;
    //Instruction Fetch
    reg [31:0] IR;
    //IF--ID
    reg [31:0] IF_ID_NPC;
    //Instruction Decode
    wire [5:0] OPCode;
    wire [25:0] instr_index;
    wire [15:0] immediate;
    //control unit
    reg WASelect;   //write back address select signal
    reg EX_ALUSrc, EX_ALUSelect, EX_NPCSrc;
    reg MEM_MemWrite, MEM_MemRead, MEM_Branch, MEM_JUMP;
    reg WB_RegWrite, WB_MemtoReg;
    //Hazard Detection Unit
    reg PCWrite, IRWrite, HazardSel;
    //ID--EX
    reg [31:0] ID_EX_A, ID_EX_B0, B1;
    reg [4:0] ID_EX_WA;
    reg [31:0] ID_EX_NPC;
    reg [27:0] offset;
    reg [4:0] ID_EX_RA, ID_EX_RB;
    //ID_EX control signal
    reg ID_EX_EX_ALUSrc, ID_EX_EX_ALUSelect, ID_EX_EX_NPCSrc;
    reg ID_EX_MEM_MemWrite, ID_EX_MEM_MemRead, ID_EX_MEM_Branch, ID_EX_MEM_JUMP;
    reg ID_EX_WB_MemtoReg, ID_EX_WB_RegWrite;
    //EX
    wire ALUSrc;    //choose reg[address] or immediate as B
    wire NPCSrc;    //choose jump or branch
    reg [31:0] B0;
    reg [31:0] NPC;
    // forwarding Unit
    reg [1:0] forwardA, forwardB;
    //EX--MEM
    reg ZF;
    reg [31:0] EX_MEM_Y, EX_MEM_B;
    reg [4:0] EX_MEM_WA;
    reg [31:0] EX_MEM_NPC;
    //EX_MEM control signal
    reg EX_MEM_MEM_MemWrite, EX_MEM_MEM_MemRead, EX_MEM_MEM_Branch, EX_MEM_MEM_JUMP, EX_MEM_MEM_SWReadEnable;
    reg MDR_Select;
    reg EX_MEM_WB_MemtoReg, EX_MEM_WB_RegWrite;
    //MEM
    wire PCSrc;    //choose branch or continue
    //Control Detection Unit
    reg IR_Flush, ID_EX_Flush, EX_MEM_Flush;
    //MEM--WB
    reg [31:0] MDR,MEM_WB_Y;
    reg [4:0] MEM_WB_WA;
    //MEM_WB control signal
    reg MEM_WB_WB_MemtoReg, MEM_WB_WB_RegWrite;
    //WB
    wire MemtoReg;      //choose memory[address] or result from ALU as the data to write back 


    //generate PC
    always@(posedge clk or posedge rst)
    begin
        if(rst) PC<=32'd0;
        else if(PCWrite) PC<=temp_PC;
        else PC<=PC;
    end

    //Instruction Fetch
    always@(posedge clk or posedge rst)
    begin
        if(rst) IR<=32'd0;
        else if(IR_Flush) IR<=32'd0;
        else if(IRWrite) IR<=instruction;
        else IR<=IR;
    end

    //IF--ID
    always@(posedge clk or posedge rst)
    begin
        if(rst)IF_ID_NPC<=32'd0;
        else IF_ID_NPC<=PC+32'd1;   //the width of memory is 32 bits
    end

    //Instruction Decode
    assign OPCode=IR[31:26];
    assign read_register_1=IR[25:21];
    assign read_register_2=IR[20:16];
    assign immediate=IR[15:0];
    assign instr_index=IR[25:0];
    //control unit
    always@(*)
    begin
        if(rst)
        begin
            WASelect=1'b0;
            EX_ALUSrc=1'b0;
            EX_ALUSelect=1'b0;
            EX_NPCSrc=1'b0;
            MEM_MemWrite=1'b0;
            MEM_Branch=1'b0;
            MEM_JUMP=1'b0;
            WB_MemtoReg=1'b0;
            WB_RegWrite=1'b0;
            MEM_MemRead=1'b0;
        end
        else
        case (OPCode)
            //ADD
            6'b000000: begin
                WASelect=1'b1;
                EX_ALUSrc=1'b0;
                EX_ALUSelect=1'b0;
                EX_NPCSrc=1'b0;
                MEM_MemWrite=1'b0;
                MEM_Branch=1'b0;
                MEM_JUMP=1'b0;
                WB_MemtoReg=1'b0;
                WB_RegWrite=1'b1;
                MEM_MemRead=1'b0;
            end
            //ADDI 
            6'b001000: begin
                WASelect=1'b0;
                EX_ALUSrc=1'b1;
                EX_ALUSelect=1'b0;
                EX_NPCSrc=1'b0;
                MEM_MemWrite=1'b0;
                MEM_Branch=1'b0;
                MEM_JUMP=1'b0;
                WB_MemtoReg=1'b0;
                WB_RegWrite=1'b1;
                MEM_MemRead=1'b0;
            end
            //LW
            6'b100011: begin
                WASelect=1'b0;
                EX_ALUSrc=1'b1;
                EX_ALUSelect=1'b0;
                EX_NPCSrc=1'b0;
                MEM_MemWrite=1'b0;
                MEM_Branch=1'b0;
                MEM_JUMP=1'b0;
                WB_MemtoReg=1'b1;
                WB_RegWrite=1'b1;
                MEM_MemRead=1'b1;
            end
            //SW
            6'b101011: begin
                WASelect=1'b0;
                EX_ALUSrc=1'b1;
                EX_ALUSelect=1'b0;
                EX_NPCSrc=1'b0;
                MEM_MemWrite=1'b1;
                MEM_Branch=1'b0;
                MEM_JUMP=1'b0;
                WB_MemtoReg=1'b0;
                WB_RegWrite=1'b0;
                MEM_MemRead=1'b0;
            end
            //J
            6'b000010: begin
                WASelect=1'b0;
                EX_ALUSrc=1'b0;
                EX_ALUSelect=1'b0;
                EX_NPCSrc=1'b1;
                MEM_MemWrite=1'b0;
                MEM_Branch=1'b0;
                MEM_JUMP=1'b1;
                WB_MemtoReg=1'b0;
                WB_RegWrite=1'b0;
                MEM_MemRead=1'b0;
            end
            //BEQ
            6'b000100: begin
                WASelect=1'b0;
                EX_ALUSrc=1'b0;
                EX_ALUSelect=1'b1;
                EX_NPCSrc=1'b0;
                MEM_MemWrite=1'b0;
                MEM_Branch=1'b1;
                MEM_JUMP=1'b0;
                WB_MemtoReg=1'b0;
                WB_RegWrite=1'b0;
                MEM_MemRead=1'b0;
            end
            default: begin
                WASelect=1'b0;
                EX_ALUSrc=1'b0;
                EX_ALUSelect=1'b0;
                EX_NPCSrc=1'b0;
                MEM_MemWrite=1'b0;
                MEM_Branch=1'b0;
                MEM_JUMP=1'b0;
                WB_MemtoReg=1'b0;
                WB_RegWrite=1'b0;
                MEM_MemRead=1'b0;
            end
        endcase
    end
    //Hazard Detection Unit
    always@(*)
    begin
        if( (ID_EX_MEM_MemRead==1'b1) && ( (ID_EX_WA==IR[25:21]) || (ID_EX_WA==IR[20:16]) ) )
        begin
            PCWrite=1'b0;
            IRWrite=1'b0;
            HazardSel=1'b1;
        end
        else
        begin
            PCWrite=1'b1;
            IRWrite=1'b1;
            HazardSel=1'b0;
        end
    end
    
    //ID--EX
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            ID_EX_A<=32'd0;
            ID_EX_B0<=32'd0;
            ID_EX_WA<=5'd0;
            B1<=32'd0;
            ID_EX_NPC<=32'd0;
            offset<=28'd0;
            ID_EX_RA<=5'd0;
            ID_EX_RB<=5'd0;
        end
        else
        begin
            ID_EX_A<=read_data_1;
            ID_EX_B0<=read_data_2;
            B1<={{16{immediate[15]}},immediate};
            ID_EX_NPC<=IF_ID_NPC;
            offset<={2'b00,instr_index};
            if(WASelect==1'b0) ID_EX_WA<=IR[20:16];
            else ID_EX_WA<=IR[15:11];
            ID_EX_RA<=IR[25:21];
            ID_EX_RB<=IR[20:16];
        end
    end
    //control signal
    always@(posedge clk or posedge rst)
    begin
        if(rst)begin
            ID_EX_EX_ALUSrc<=1'b0;
            ID_EX_EX_ALUSelect<=1'b0;
            ID_EX_EX_NPCSrc<=1'b0;
            ID_EX_MEM_MemWrite<=1'b0;
            ID_EX_MEM_MemRead<=1'b0;
            ID_EX_MEM_Branch<=1'b0;
            ID_EX_MEM_JUMP<=1'b0;
            ID_EX_WB_MemtoReg<=1'b0;
            ID_EX_WB_RegWrite<=1'b0;
        end
        else if( (HazardSel==1'b1) || (ID_EX_Flush==1'b1) )
        begin
            ID_EX_EX_ALUSrc<=1'b0;
            ID_EX_EX_ALUSelect<=1'b0;
            ID_EX_EX_NPCSrc<=1'b0;
            ID_EX_MEM_MemWrite<=1'b0;
            ID_EX_MEM_MemRead<=1'b0;
            ID_EX_MEM_Branch<=1'b0;
            ID_EX_MEM_JUMP<=1'b0;
            ID_EX_WB_MemtoReg<=1'b0;
            ID_EX_WB_RegWrite<=1'b0;
        end
        else 
        begin
            ID_EX_EX_ALUSrc<=EX_ALUSrc;
            ID_EX_EX_ALUSelect<=EX_ALUSelect;
            ID_EX_EX_NPCSrc<=EX_NPCSrc;
            ID_EX_MEM_MemWrite<=MEM_MemWrite;
            ID_EX_MEM_MemRead<=MEM_MemRead;
            ID_EX_MEM_Branch<=MEM_Branch;
            ID_EX_MEM_JUMP<=MEM_JUMP;
            ID_EX_WB_MemtoReg<=WB_MemtoReg;
            ID_EX_WB_RegWrite<=WB_RegWrite;
        end
    end

    //EX
    assign ALUSrc=ID_EX_EX_ALUSrc;
    assign NPCSrc=ID_EX_EX_NPCSrc;
    assign ALUSelect=ID_EX_EX_ALUSelect;
    // forwarding Unit
    always@(*)
    begin
        if(rst)
        begin
            forwardA=2'b00;
            forwardB=2'b00;
        end
        else
        begin
            // first judge EX_MEM part
            if((EX_MEM_WB_RegWrite==1'b1)&&(EX_MEM_WA==ID_EX_RA)) forwardA=2'b01;
            else if((MEM_WB_WB_RegWrite==1'b1)&&(MEM_WB_WA==ID_EX_RA)) forwardA=2'b10;
            else forwardA=2'b00;
            
            if((EX_MEM_WB_RegWrite==1'b1)&&(EX_MEM_WA==ID_EX_RB)) forwardB=2'b01;
            else if((MEM_WB_WB_RegWrite==1'b1)&&(MEM_WB_WA==ID_EX_RB)) forwardB=2'b10;
            else forwardB=2'b00;
        end
    end
    // forwardA MUX
    always@(*)
    begin
        if(forwardA==2'b00) A=ID_EX_A;
        else if(forwardA==2'b01) A=EX_MEM_Y;
        else if(forwardA==2'b10) A=write_data;
        else A=ID_EX_A;
    end
    //forwardB MUX
    always@(*)
    begin
        if(forwardB==2'b00) B0=ID_EX_B0;
        else if(forwardB==2'b01) B0=EX_MEM_Y;
        else if(forwardB==2'b10) B0=write_data;
        else B0=ID_EX_B0;
    end
    // ALU MUX
    always@(*)
    begin
        if(ALUSrc==1'b0) B=B0;
        else B=B1;
    end
    always@(*)
    begin
        if(NPCSrc==1'b0) NPC=ID_EX_NPC+B1;      //branch npc
        else NPC={ID_EX_NPC[31:28],offset};     //jump npc
    end


    //EX--MEM
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            ZF<=1'b0;
            EX_MEM_Y<=32'd0;
            EX_MEM_B<=32'd0;
            EX_MEM_WA<=5'd0;
            EX_MEM_NPC<=32'd0;
        end
        else
        begin
            ZF<=ZERO;
            EX_MEM_Y<=ALUResult;
            EX_MEM_B<=B0;
            EX_MEM_WA<=ID_EX_WA;
            EX_MEM_NPC<=NPC;
        end
    end
    //control signal
    always@(posedge clk or posedge rst)
    begin
        if(rst) begin
            EX_MEM_MEM_MemWrite<=1'b0;
            EX_MEM_MEM_MemRead<=1'b0;
            EX_MEM_MEM_Branch<=1'b0;
            EX_MEM_MEM_JUMP<=1'b0;
            EX_MEM_WB_MemtoReg<=1'b0;
            EX_MEM_WB_RegWrite<=1'b0;
            EX_MEM_MEM_SWReadEnable<=1'b0;
            MDR_Select<=1'b0;
        end
        else if(EX_MEM_Flush==1'b1)
        begin
            EX_MEM_MEM_MemWrite<=1'b0;
            EX_MEM_MEM_MemRead<=1'b0;
            EX_MEM_MEM_Branch<=1'b0;
            EX_MEM_MEM_JUMP<=1'b0;
            EX_MEM_WB_MemtoReg<=1'b0;
            EX_MEM_WB_RegWrite<=1'b0;
            EX_MEM_MEM_SWReadEnable<=1'b0;
            MDR_Select<=1'b0;
        end
        else 
        begin
            EX_MEM_MEM_MemWrite<=ID_EX_MEM_MemWrite;
            EX_MEM_MEM_MemRead<=ID_EX_MEM_MemRead;
            EX_MEM_MEM_Branch<=ID_EX_MEM_Branch;
            EX_MEM_MEM_JUMP<=ID_EX_MEM_JUMP;
            EX_MEM_WB_MemtoReg<=ID_EX_WB_MemtoReg;
            EX_MEM_WB_RegWrite<=ID_EX_WB_RegWrite;
            //LW switch data
            if(ID_EX_WB_MemtoReg && ID_EX_WB_RegWrite && ((ALUResult[15:0]==16'h8000)||(ALUResult[15:0]==16'h8001)))
            begin
                EX_MEM_MEM_SWReadEnable<=1'b1;
                MDR_Select<=1'b1;
            end
            else 
            begin
                EX_MEM_MEM_SWReadEnable<=1'b0;
                MDR_Select<=1'b0;
            end
        end
    end

    //MEM
    assign memory_data_address=EX_MEM_Y;
    assign write_memory_data=EX_MEM_B;
    assign MemWrite=EX_MEM_MEM_MemWrite;
    assign read_enable=EX_MEM_MEM_SWReadEnable;
    assign PCSrc = (EX_MEM_MEM_Branch & ZF)|EX_MEM_MEM_JUMP;    //generate PCSrc
    always@(*)
    begin
        if(PCSrc==1'b0) temp_PC=PC+32'd1;
        else temp_PC=EX_MEM_NPC;
    end
    //Control Detection Unit
    always@(*)
    begin
        if(PCSrc==1'b1)
        begin
            IR_Flush=1'b1;
            ID_EX_Flush=1'b1;
            EX_MEM_Flush=1'b1;
        end
        else
        begin
            IR_Flush=1'b0;
            ID_EX_Flush=1'b0;
            EX_MEM_Flush=1'b0;
        end
    end

    //MEM--WB
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            MDR<=32'd0;
            MEM_WB_Y<=32'd0;
            MEM_WB_WA<=5'd0;
        end
        else
        begin
            if(MDR_Select==1'b1) MDR<=SWData;
            else MDR<=read_memory_data;
            MEM_WB_Y<=EX_MEM_Y;
            MEM_WB_WA<=EX_MEM_WA;
        end
    end
    //control signal
    always@(posedge clk or posedge rst)
    begin
        if(rst)begin
            MEM_WB_WB_MemtoReg<=1'b0;
            MEM_WB_WB_RegWrite<=1'b0;
        end
        else begin
            MEM_WB_WB_MemtoReg<=EX_MEM_WB_MemtoReg;
            MEM_WB_WB_RegWrite<=EX_MEM_WB_RegWrite;
        end
    end

    //WB
    assign MemtoReg=MEM_WB_WB_MemtoReg;
    assign RegWrite=MEM_WB_WB_RegWrite;
    always@(*)
    begin
        if(MemtoReg==1'b0) write_data=MEM_WB_Y;
        else write_data=MDR;
    end
    assign write_register=MEM_WB_WA;

endmodule