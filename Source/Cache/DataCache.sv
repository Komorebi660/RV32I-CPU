// Copyright (c) 2022 Komorebi660
// LRU多路组相联cache

module DataCache #(
    parameter  LINE_ADDR_LEN = 2,                               // line内地址长度，决定了每个line具有2^LINE_ADDR_LEN个word
    parameter  SET_ADDR_LEN  = 3,                               // 组地址长度，决定了一共有2^SET_ADDR_LEN组
    parameter  TAG_ADDR_LEN  = 12-LINE_ADDR_LEN-SET_ADDR_LEN,   // tag长度
    parameter  WAY_CNT       = 2                                // 组相连度，决定了每组中有多少路line
)(
    input             clk, rst,
    output            miss,         // 对CPU发出的miss信号
    input      [31:0] addr,         // 读写请求地址
    input             rd_req,       // 读请求信号
    output reg [31:0] rd_data,      // 读出的数据，一次读一个word
    input      [3: 0] wr_en,        // 写请求信号, 分别使能四个byte
    input      [31:0] wr_data       // 要写入的数据，一次写一个word
);

    // 计算主存地址长度MEM_ADDR_LEN，主存大小=2^MEM_ADDR_LEN个line
    localparam MEM_ADDR_LEN    = TAG_ADDR_LEN + SET_ADDR_LEN; 
    // 计算未使用的地址的长度
    localparam UNUSED_ADDR_LEN = 32 - TAG_ADDR_LEN - SET_ADDR_LEN - LINE_ADDR_LEN - 2;       
    // 计算line中word的数量，即每line有2^LINE_ADDR_LEN个word
    localparam LINE_SIZE       = 1 << LINE_ADDR_LEN;
    // 计算一共有多少组，即2^SET_ADDR_LEN个组         
    localparam SET_SIZE        = 1 << SET_ADDR_LEN;         

    // cache内容
    reg  [               31:0]   cache_mem [SET_SIZE][WAY_CNT][LINE_SIZE]; //SET_SIZE个set, 每个set有WAY_CNT个line，每个line有LINE_SIZE个word
    reg  [   TAG_ADDR_LEN-1:0]  cache_tags [SET_SIZE][WAY_CNT];            
    reg                              valid [SET_SIZE][WAY_CNT];            
    reg                              dirty [SET_SIZE][WAY_CNT];            
    reg  [               15:0]       count [SET_SIZE][WAY_CNT];            //用于记录每一路最近访问的情况           
    // 将输入地址addr拆分成这5个部分
    wire [              2-1:0]   word_addr;                   
    wire [  LINE_ADDR_LEN-1:0]   line_addr;
    wire [   SET_ADDR_LEN-1:0]    set_addr;
    wire [   TAG_ADDR_LEN-1:0]    tag_addr;
    wire [UNUSED_ADDR_LEN-1:0] unused_addr;
    // 访问内存的地址
    reg  [   SET_ADDR_LEN-1:0] mem_rd_set_addr = 0;
    reg  [   TAG_ADDR_LEN-1:0] mem_rd_tag_addr = 0;
    wire [   MEM_ADDR_LEN-1:0] mem_rd_addr = {mem_rd_tag_addr, mem_rd_set_addr};
    reg  [   MEM_ADDR_LEN-1:0] mem_wr_addr = 0;
    // 与内存交换的读写数据(一个line)
    reg  [               31:0] mem_wr_line [LINE_SIZE];
    wire [               31:0] mem_rd_line [LINE_SIZE];
    // 主存响应读写的握手信号
    wire  mem_gnt;    
    // 内存写的请求信号
    wire wr_req;

    // cache 状态机的状态定义
    // IDLE代表就绪，SWAP_OUT代表正在换出，SWAP_IN代表正在换入，SWAP_IN_OK代表换入后进行一周期的写入cache操作。
    enum  {IDLE, SWAP_OUT, SWAP_IN, SWAP_IN_OK} cache_stat;   

    // 拆分32bits地址信号
    assign {unused_addr, tag_addr, set_addr, line_addr, word_addr} = addr;  

    //只要wr_en有一位为1, 说明有写请求
    assign wr_req = |wr_en;

    // 判断输入的address是否在cache中命中
    reg cache_hit = 1'b0;
    integer way = 0;    // 命中时位于cache set内的哪一个way
    always @ (*) 
    begin
        // 对set内的每一组遍历
        for(way = 0; way < WAY_CNT; way++)
        begin
            // 如果cache line有效，并且tag与输入地址中的tag相等，则命中              
            if(valid[set_addr][way] && cache_tags[set_addr][way] == tag_addr)
            begin
                cache_hit = 1'b1;
                break;
            end
            else
                cache_hit = 1'b0;
        end
    end

    //cache控制状态机
    integer swap_way = 0;    // swap时选择cache set内的哪一个way
    always @ (posedge clk or posedge rst) 
    begin
        if(rst) 
        begin
            cache_stat <= IDLE;
            for(integer i = 0; i < SET_SIZE; i++) 
            begin
                for(integer j = 0; j < WAY_CNT; j++)
                begin
                    dirty[i][j] = 1'b0;
                    valid[i][j] = 1'b0;
                    count[i][j] = 0;
                end
            end
            mem_wr_addr <= 0;
            for(integer k = 0; k < LINE_SIZE; k++)
                mem_wr_line[k] <= 0;
            {mem_rd_tag_addr, mem_rd_set_addr} <= 0;
            rd_data <= 0;
        end 
        else 
        begin
            case(cache_stat)
            IDLE: begin
                if(cache_hit) // 如果cache命中
                begin
                    if(rd_req) //读请求
                    begin
                        rd_data <= cache_mem[set_addr][way][line_addr];
                        //所有valid路的count右移一位
                        for(integer i = 0; i < WAY_CNT; i++)
                            if(valid[set_addr][i])
                                count[set_addr][i] <= {1'b0, count[set_addr][i][15:1]};
                        count[set_addr][way][15] <= 1'b1;  //被访问, 最高位置1
                    end 
                    else if(wr_req) //写请求
                    begin
                        // write data in bytes
                        if (wr_en[0])
                            cache_mem[set_addr][way][line_addr][7:0] <= wr_data[7:0];
                        if (wr_en[1])
                            cache_mem[set_addr][way][line_addr][15:8] <= wr_data[15:8];
                        if (wr_en[2])
                            cache_mem[set_addr][way][line_addr][23:16] <= wr_data[23:16];
                        if (wr_en[3])
                            cache_mem[set_addr][way][line_addr][31:24] <= wr_data[31:24];
                        
                        dirty[set_addr][way] <= 1'b1;               //置脏位
                        //所有valid路的count右移一位
                        for(integer i = 0; i < WAY_CNT; i++)
                            if(valid[set_addr][i])
                                count[set_addr][i] <= {1'b0, count[set_addr][i][15:1]};
                        count[set_addr][way][15] <= 1'b1;           //被访问, 最高位置1
                    end 
                end 
                else // 如果cache未命中
                begin
                    if(wr_req | rd_req) //有读写请求，则需要进行换入
                    begin
                        // 寻找可以直接换入的路
                        for(swap_way = 0; swap_way < WAY_CNT; swap_way++)
                            // 如果这一路无效或者不脏, 则可以直接换入
                            if(!valid[set_addr][swap_way] || !dirty[set_addr][swap_way])             
                                break;
                        
                        if(swap_way < WAY_CNT) //直接换入
                            cache_stat <= SWAP_IN;
                        else //上面的循环未找到可以直接换入的way, 则按照LRU找一路换出
                        begin
                            //寻找最近最少使用的块
                            automatic integer min = 16'hffff;
                            for(integer i = 0; i < WAY_CNT; i++)
                                if(valid[set_addr][i] && count[set_addr][i] <= min)
                                begin
                                    min = count[set_addr][i];
                                    swap_way = i;
                                end
                            cache_stat  <= SWAP_OUT;
                            mem_wr_addr <= {cache_tags[set_addr][swap_way], set_addr};
                            mem_wr_line <= cache_mem[set_addr][swap_way];
                        end 
                        // 读内存地址
                        {mem_rd_tag_addr, mem_rd_set_addr} <= {tag_addr, set_addr};
                    end
                end
            end
            SWAP_OUT: begin
                if(mem_gnt)
                // 如果主存握手信号有效，说明换出成功，跳到下一状态 
                begin           
                    cache_stat <= SWAP_IN;
                end
            end
            SWAP_IN: begin
                if(mem_gnt) 
                // 如果主存握手信号有效，说明换入成功，跳到下一状态
                begin           
                    cache_stat <= SWAP_IN_OK;
                end
            end
            SWAP_IN_OK: begin  
                // 上一个周期换入成功，这周期将主存读出的line写入cache         
                for(integer i = 0; i < LINE_SIZE; i++)  
                    cache_mem[mem_rd_set_addr][swap_way][i] <= mem_rd_line[i];
                //更新其余标志位
                cache_tags[mem_rd_set_addr][swap_way] <= mem_rd_tag_addr;       // 更新tag
                valid     [mem_rd_set_addr][swap_way] <= 1'b1;                  // 置valid
                dirty     [mem_rd_set_addr][swap_way] <= 1'b0;                  // 清空dirty
                count     [mem_rd_set_addr][swap_way] <= 16'h8000;              //被访问, 最高位置1
                cache_stat                            <= IDLE;                  // 回到就绪状态
                
                //所有valid路的count右移一位
                for(integer i = 0; i < WAY_CNT; i++)
                    if(valid[mem_rd_set_addr][i])
                        count[mem_rd_set_addr][i] <= {1'b0, count[mem_rd_set_addr][i][15:1]};
            end
            endcase
        end
    end

    wire mem_rd_req = (cache_stat == SWAP_IN ); // 读内存请求
    wire mem_wr_req = (cache_stat == SWAP_OUT); // 写内存请求
    // 读写内存地址
    wire [MEM_ADDR_LEN-1 :0] mem_addr = mem_rd_req ? mem_rd_addr : ( mem_wr_req ? mem_wr_addr : 0);

    // 当有读写请求时，如果cache不处于就绪(IDLE)状态，或者未命中，则miss=1
    assign miss = (rd_req | wr_req) & ~(cache_hit && cache_stat==IDLE) ;     

    // 主存，每次读写以line 为单位
    main_mem #(     
        .LINE_ADDR_LEN  ( LINE_ADDR_LEN          ),
        .ADDR_LEN       ( MEM_ADDR_LEN           )
    ) main_mem_instance (
        .clk            ( clk                    ),
        .rst            ( rst                    ),
        .gnt            ( mem_gnt                ),
        .addr           ( mem_addr               ),
        .rd_req         ( mem_rd_req             ),
        .rd_line        ( mem_rd_line            ),
        .wr_req         ( mem_wr_req             ),
        .wr_line        ( mem_wr_line            )
    );

endmodule
