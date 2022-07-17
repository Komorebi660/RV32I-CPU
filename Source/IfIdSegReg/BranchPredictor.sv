//分支预测器

module BranchPredictor #(
    parameter  BUFFER_LEN  = 10        // BTB和BHT的地址长度
)(
    input  clk, rst,
    input  [31:0] pc,                   // 输入pc
    input  [31:0] update_pc,            // 待更新的表项(用PC寻址)
    input  [31:0] real_target,          // 待更新表项对应的实际分支目标地址
    input  real_taken,                  // 实际是否跳转
    input  predict_wrong,               // 分支预测错误
    input  is_branch,                   // 是否为分支指令(用于更新BHT)
    output reg predict_taken,           // 预测是否跳转
    output reg [31:0] predict_target    // 预测跳转目标
);

    wire btb_valid, bht_result, update_btb;
    wire [31:0] btb_result;
    
    //当分支预测错误且实际跳转时, 更新BTB表项
    assign update_btb = predict_wrong & real_taken;

    always @(*)
    begin
        //predict_taken = 0;
        //predict_target = pc + 4;
        
        //只有当BHT预测跳转且BTB有效时才能预测taken
        predict_taken = btb_valid & bht_result;
        
        if(predict_taken)
            predict_target = btb_result;
        else 
            predict_target = pc + 4;
        
    end

    _BHT #(
        .BHT_ADDR_LEN (10)    
    ) bht_inst (
        .clk(clk), 
        .rst(rst),
        .pc(pc),                   
        .update_pc(update_pc),            
        .is_taken(real_taken),                    
        .is_branch(is_branch),                   
        .predict_taken(bht_result)     //BHT预测的结果           
    );

    _BTB #(
        .BTB_ADDR_LEN (8)    
    ) btb_inst (
        .clk(clk), 
        .rst(rst),
        .pc(pc),                   
        .update_pc(update_pc),                               
        .update_target(real_target),                      
        .update(update_btb),            //是否需要更新BTB        
        .btb_valid(btb_valid),          //BTB是否hit       
        .predict_target(btb_result)         
    );

endmodule





module _BHT #(
    parameter  BHT_ADDR_LEN  = 10       // BHT地址长度
)(
    input  clk, rst,
    input  [31:0] pc,                   // 输入pc
    input  [31:0] update_pc,            // 待更新的BHT表项(用PC寻址)
    input  is_taken,                    // 实际是否跳转
    input  is_branch,                   // update_pc是否为分支指令(是否需要更新BHT)
    output predict_taken                // 预测是否跳转
);

    localparam TAG_ADDR_LEN    = 32 - BHT_ADDR_LEN;     // 计算TAG长度
    localparam BHT_SIZE        = 1 << BHT_ADDR_LEN;     // 计算BHT大小

    reg [1:0] branch_history [BHT_SIZE];    // 2 bit表示分支历史

    // pc寻址bht
    wire [BHT_ADDR_LEN-1:0] bht_addr;
    assign bht_addr = pc[BHT_ADDR_LEN-1:0];

    // update_pc寻址bht
    wire [BHT_ADDR_LEN-1:0] update_bht_addr;
    assign update_bht_addr = update_pc[BHT_ADDR_LEN-1:0];

    //bht状态{00, 01, 10, 11}
    enum {STRONGLY_NOT_TAKEN, WEAKLY_NOT_TAKEN, WEAKLY_TAKEN, STRONGLY_TAKEN} bht_stat;

    //直接看branch_history的最高位来预测
    assign predict_taken = branch_history[bht_addr][1] ? 1 : 0;

    //更新BHT, 下降沿触发以保证获取最新值
    always@(negedge clk or posedge rst) 
    begin 
        //初始化BHT
        if(rst)
            for(integer i = 0; i < BHT_SIZE; i++)
            begin
                branch_history[i] <= WEAKLY_TAKEN;  //初始设置为weakly taken
            end
        //更新BHT
        else if(is_branch)
        begin
            case (branch_history[update_bht_addr])
                STRONGLY_NOT_TAKEN: begin
                    if(is_taken) branch_history[update_bht_addr] <= WEAKLY_NOT_TAKEN;
                    else branch_history[update_bht_addr] <= STRONGLY_NOT_TAKEN;
                end
                WEAKLY_NOT_TAKEN: begin
                    if(is_taken) branch_history[update_bht_addr] <= WEAKLY_TAKEN;
                    else branch_history[update_bht_addr] <= STRONGLY_NOT_TAKEN;
                end
                WEAKLY_TAKEN:begin
                    if(is_taken) branch_history[update_bht_addr] <= STRONGLY_TAKEN;
                    else branch_history[update_bht_addr] <= WEAKLY_NOT_TAKEN;
                end
                STRONGLY_TAKEN:begin
                    if(is_taken) branch_history[update_bht_addr] <= STRONGLY_TAKEN;
                    else branch_history[update_bht_addr] <= WEAKLY_TAKEN;
                end
            endcase
        end
    end

endmodule



module _BTB #(
    parameter  BTB_ADDR_LEN  = 10       // BTB地址长度
)(
    input  clk, rst,
    input  [31:0] pc,                   // 输入pc
    input  [31:0] update_pc,            // 待更新的BTB表项(用PC寻址)
    input  [31:0] update_target,        // 待更新表项对应的分支目标地址
    input  update,                      // 是否需要更新
    output reg btb_valid,               // 预测是否跳转
    output reg [31:0] predict_target    // 预测跳转目标
);

    localparam TAG_ADDR_LEN    = 32 - BTB_ADDR_LEN;     // 计算TAG长度
    localparam BTB_SIZE        = 1 << BTB_ADDR_LEN;     // 计算BTB大小

    reg [            31:0] target_addr [BTB_SIZE];      // 跳转目标地址
    reg [TAG_ADDR_LEN-1:0] tags        [BTB_SIZE];      // tag位
    reg                    valid       [BTB_SIZE];      // valid位


    // 将输入待预测的pc拆分成2个部分
    wire [BTB_ADDR_LEN-1:0] btb_addr;
    wire [TAG_ADDR_LEN-1:0] tag_addr;
    assign {tag_addr, btb_addr} = pc;

    wire [BTB_ADDR_LEN-1:0] update_btb_addr;
    wire [TAG_ADDR_LEN-1:0] update_tag_addr;
    assign {update_tag_addr, update_btb_addr} = update_pc;


    //判断BTB是否命中
    always @ (*) 
    begin             
        if(valid[btb_addr] && tags[btb_addr] == tag_addr)
        begin
            btb_valid = 1'b1;
            predict_target = target_addr[btb_addr];
        end
        else
        begin
            btb_valid = 1'b0;
            predict_target = pc + 4; //正常的下一条指令
        end
    end

    //更新BTB, 下降沿触发以保证获取最新值
    always@(negedge clk or posedge rst) 
    begin 
        //初始化BTB
        if(rst)
            for(integer i = 0; i < BTB_SIZE; i++)
            begin
                target_addr[i] <= 0;
                tags[i] <= 0;
                valid[i] <= 0;
            end
        //更新BTB
        else if(update)
        begin
            tags[update_btb_addr] <= update_tag_addr;
            valid[update_btb_addr] <= 1'b1;
            target_addr[update_btb_addr] <= update_target;
        end
    end

endmodule
