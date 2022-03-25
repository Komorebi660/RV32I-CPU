`timescale 1ns / 1ps
// Description: This testBench Help users to initial the bram content, by loading .data file and .inst file.
//				Then give signals to start the execution of our cpu
//				When all instructions finish their executions, this testBench will dump the Instruction Bram and Data Bram's content to .txt files 
//              !!! ALL YOU NEED TO CHANGE IS 4 FILE PATH BELOW !!!	
//				(they are all optional, you can run cpu without change paths here,if files are failed to open, we will not dump the content to .txt and will not try to initial your bram)

`define DataCacheContentLoadPath "D:\\Git\\calab-verilog\\Lab2\\Simulation\\1testAll.data"                //Modify to path/to/your/testdata
`define InstCacheContentLoadPath "D:\\Git\\calab-verilog\\Lab2\\Simulation\\1testAll.inst"                //Modify to path/to/your/testdata
`define DataCacheContentSavePath "D:\\Git\\calab-verilog\\Lab2\\Simulation\\DumpDataCacheContent.txt"      //Modify to path/to/your/testdata
`define InstCacheContentSavePath "D:\\Git\\calab-verilog\\Lab2\\Simulation\\DumpInstCacheContent.txt"      //Modify to path/to/your/testdata
`define BRAMWORDS 4096  //a word is 32bit, so our bram is 4096*32bit

module testBench(
    );
    reg CPU_CLK;
    reg CPU_RST;
    reg [31:0] CPU_Debug_DataCache_A2;
    reg [31:0] CPU_Debug_DataCache_WD2;
    reg [3:0] CPU_Debug_DataCache_WE2;
    wire [31:0] CPU_Debug_DataCache_RD2;
    reg [31:0] CPU_Debug_InstCache_A2;
    reg [31:0] CPU_Debug_InstCache_WD2;
    reg [3:0] CPU_Debug_InstCache_WE2;
    wire [31:0] CPU_Debug_InstCache_RD2;
    //generate clock signal
    always #1 CPU_CLK = ~CPU_CLK;
    // Connect the CPU core
    RV32ICore RV32ICore1(
        .CPU_CLK(CPU_CLK),
        .CPU_RST(CPU_RST),
        .CPU_Debug_DataCache_A2(CPU_Debug_DataCache_A2),
        .CPU_Debug_DataCache_WD2(CPU_Debug_DataCache_WD2),
        .CPU_Debug_DataCache_WE2(CPU_Debug_DataCache_WE2),
        .CPU_Debug_DataCache_RD2(CPU_Debug_DataCache_RD2),
        .CPU_Debug_InstCache_A2(CPU_Debug_InstCache_A2),
        .CPU_Debug_InstCache_WD2(CPU_Debug_InstCache_WD2),
        .CPU_Debug_InstCache_WE2(CPU_Debug_InstCache_WE2),
        .CPU_Debug_InstCache_RD2(CPU_Debug_InstCache_RD2)
        );
    //define file handles
    integer LoadDataCacheFile;
    integer LoadInstCacheFile;
    integer SaveDataCacheFile;
    integer SaveInstCacheFile;
    //
    integer i;
    //
    initial 
    begin
        $display("Initialing reg values..."); 
        CPU_Debug_DataCache_WD2 = 32'b0;
        CPU_Debug_DataCache_WE2 = 4'b0;
        CPU_Debug_InstCache_WD2 = 32'b0;
        CPU_Debug_InstCache_WE2 = 4'b0;
        CPU_Debug_DataCache_A2 = 32'b0;
        CPU_Debug_InstCache_A2 = 32'b0;
        CPU_CLK=1'b0;
        CPU_RST = 1'b0;
        #10
        
        $display("Loading DataCache Content from file..."); 
        LoadDataCacheFile = $fopen(`DataCacheContentLoadPath,"r");
        if(LoadDataCacheFile==0)
            $display("Failed to Open %s, Do Not Load DataCache values from file!",`DataCacheContentLoadPath);
        else    begin  
            CPU_Debug_DataCache_A2 = 32'h0;     
            $fscanf(LoadDataCacheFile,"%h",CPU_Debug_DataCache_WD2);
            if($feof(LoadDataCacheFile))
                CPU_Debug_DataCache_WE2 = 4'b0;
            else
                CPU_Debug_DataCache_WE2 = 4'b1111;
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
            begin
                if($feof(LoadDataCacheFile))
                    CPU_Debug_DataCache_WE2 = 4'b0;
                else
                    CPU_Debug_DataCache_WE2 = 4'b1111;
                @(negedge CPU_CLK);
                CPU_Debug_DataCache_A2 = CPU_Debug_DataCache_A2+4;
                $fscanf(LoadDataCacheFile,"%h",CPU_Debug_DataCache_WD2);
            end
            $fclose(LoadDataCacheFile);
        end
        
        $display("Loading InstCache Content from file..."); 
        LoadInstCacheFile = $fopen(`InstCacheContentLoadPath,"r");
        if(LoadInstCacheFile==0)
            $display("Failed to Open %s, Do Not Load InstCache values from file!",`InstCacheContentLoadPath);
        else    begin  
            CPU_Debug_InstCache_A2 = 32'h0;     
            $fscanf(LoadInstCacheFile,"%h",CPU_Debug_InstCache_WD2);
            if($feof(LoadInstCacheFile))
                CPU_Debug_InstCache_WE2 = 4'b0;
            else
                CPU_Debug_InstCache_WE2 = 4'b1111;
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
            begin
                if($feof(LoadInstCacheFile))
                    CPU_Debug_InstCache_WE2 = 4'b0;
                else
                    CPU_Debug_InstCache_WE2 = 4'b1111;
                @(negedge CPU_CLK);
                CPU_Debug_InstCache_A2 = CPU_Debug_InstCache_A2+4;
                $fscanf(LoadInstCacheFile,"%h",CPU_Debug_InstCache_WD2);
            end
            $fclose(LoadInstCacheFile);
        end
        
        $display("Start Instruction Execution!"); 
        #10;   
        CPU_RST = 1'b1;
        #10;   
        CPU_RST = 1'b0;
        #400000 												// waiting for instruction Execution to End
        $display("Finish Instruction Execution!"); 
        
        $display("Saving DataCache Content to file..."); 
        CPU_Debug_DataCache_A2 = 32'hfffffffc;
        #10
        SaveDataCacheFile = $fopen(`DataCacheContentSavePath,"w");
        if(SaveDataCacheFile==0)
            $display("Failed to Open %s, Do Not Save DataCache values to file!",`DataCacheContentSavePath);
        else
        begin
            $fwrite(SaveDataCacheFile,"i\tAddr\tAddr\tData\tData\n");
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
                begin
                @(posedge CPU_CLK);
                CPU_Debug_DataCache_A2 = CPU_Debug_DataCache_A2+4;
                @(posedge CPU_CLK);
                @(negedge CPU_CLK);
                $fwrite(SaveDataCacheFile,"%4d\t%8h\t%4d\t%8h\t%4d\n",i,CPU_Debug_DataCache_A2,CPU_Debug_DataCache_A2,CPU_Debug_DataCache_RD2,CPU_Debug_DataCache_RD2);
                end
            $fclose(SaveDataCacheFile);
        end
        
        $display("Saving InstCache Content to file..."); 
        SaveInstCacheFile = $fopen(`InstCacheContentSavePath,"w");
        if(SaveInstCacheFile==0)
            $display("Failed to Open %s, Do Not Save InstCache values to file!",`InstCacheContentSavePath);
        else
        begin
            CPU_Debug_InstCache_A2 = 32'hfffffffc;
            #10
            $fwrite(SaveInstCacheFile,"i\tAddr\tAddr\tData\tData\n");
            #10
            for(i=0;i<`BRAMWORDS;i=i+1)
                begin
                @(posedge CPU_CLK);
                CPU_Debug_InstCache_A2 = CPU_Debug_InstCache_A2+4;
                @(posedge CPU_CLK);
                @(negedge CPU_CLK);
                $fwrite(SaveInstCacheFile,"%4d\t%8h\t%4d\t%8h\t%4d\n",i,CPU_Debug_InstCache_A2,CPU_Debug_InstCache_A2,CPU_Debug_InstCache_RD2,CPU_Debug_InstCache_RD2);
                end
            $fclose(SaveInstCacheFile);      
        end      

        $display("Simulation Ended!"); 
        $stop();
    end
    
endmodule
