`timescale 1ns / 1ps
//  功能说明
    //  对指令进行译码，将其翻译成控制信号，传输给各个部件
// 输入
    // Inst              待译码指令
// 输出
    // jal               jal跳转指令
    // jalr              jalr跳转指令
    // op1_src           0表示ALU操作数1来自寄存器，1表示来自PC-4
    // op2_src           ALU的第二个操作数来源。为1时，op2选择imm，为0时，op2选择reg2
    // ALU_func          ALU执行的运算类型
    // br_type           branch的判断条件，可以是不进行branch
    // load_npc          写回寄存器的值的来源（PC或者ALU计算结果）, load_npc == 1时选择PC
    // wb_select         写回寄存器的值的来源（Cache内容或者ALU计算结果），wb_select == 1时选择cache内容
    // load_type         load类型
    // reg_write_en      通用寄存器写使能，reg_write_en == 1表示需要写回reg
    // cache_write_en    按字节写入data cache
    // imm_type          指令中立即数类型
    // CSR_write_en      是否需要写CSR寄存器
    // CSR_zimm_or_reg   CSR指令的操作数类型, 为0时选择reg, 否则选择zimm
// 实验要求
    // 补全模块


`include "Parameters.v"   
module ControllerDecoder(
    input wire [31:0] inst,
    output reg jal,
    output reg jalr,
    output reg op1_src, op2_src,
    output reg [3:0] ALU_func,
    output reg [2:0] br_type,
    output reg load_npc,
    output reg wb_select,
    output reg [2:0] load_type,
    output reg reg_write_en,
    output reg [3:0] cache_write_en,
    output reg [2:0] imm_type,
    // CSR signals
    output reg CSR_write_en,
    output reg CSR_zimm_or_reg
    );

    wire [6:0] opcode, funct7;
    wire [2:0] funct3;

    assign opcode = inst[6:0];
    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];

    always @ (*)
    begin
        if (opcode == `U_LUI)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 1;
            ALU_func = `LUI;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `UTYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;
        end
        else if (opcode == `U_AUIPC)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 1;
            op2_src = 1;
            ALU_func = `ADD;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `UTYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;
        end
        else if (opcode == `J_JAL)
        begin
            jal = 1;
            jalr = 0;
            op1_src = 0;
            op2_src = 0;
            ALU_func = 0;
            br_type = 0;
            load_npc = 1;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `JTYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;
        end
        else if (opcode == `J_JALR)
        begin
            jal = 0;
            jalr = 1;
            op1_src = 0;
            op2_src = 1;
            ALU_func = `ADD;
            br_type = 0;
            load_npc = 1;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `ITYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;
        end
        else if (opcode == `B_TYPE)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 0;
            ALU_func = `ADD;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 0;
            cache_write_en = 0;
            imm_type = `BTYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;

            case (funct3)
                `B_BEQ:  br_type = `BEQ;
                `B_BNE:  br_type = `BNE;
                `B_BLT:  br_type = `BLT;
                `B_BGE:  br_type = `BGE;
                `B_BLTU: br_type = `BLTU;
                `B_BGEU: br_type = `BGEU;
                default: br_type = `NOBRANCH;
            endcase
        end
        else if (opcode == `I_LOAD)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 1;
            ALU_func = `ADD;
            br_type = 0;
            load_npc = 0;
            wb_select = 1;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `ITYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;

            case (funct3)
                `I_LB:  load_type = `LB;
                `I_LH:  load_type = `LH;
                `I_LW:  load_type = `LW;
                `I_LBU: load_type = `LBU;
                `I_LHU: load_type = `LHU;
                default: begin
                    reg_write_en = 0;
                    load_type = `NOREGWRITE;
                end
            endcase
        end
        else if (opcode == `I_ARI)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 1;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `ITYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;

            case(funct3)
                `I_ADDI:  ALU_func = `ADD;
                `I_SLTI:  ALU_func = `SLT;
                `I_SLTIU: ALU_func = `SLTU;
                `I_XORI:  ALU_func = `XOR;
                `I_ORI:   ALU_func = `OR;
                `I_ANDI:  ALU_func = `AND;
                `I_SLLI:  ALU_func = `SLL;
                `I_SR:    begin
                    case (funct7)
                        `I_SRAI: ALU_func = `SRA;
                        `I_SRLI: ALU_func = `SRL;
                        default: ALU_func = 4'd0;
                    endcase
                end
                default:  ALU_func = 4'd0;
            endcase
        end
        else if (opcode == `S_TYPE)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 1;
            ALU_func = `ADD;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 0;
            imm_type = `STYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;

            case(funct3)
                `S_SB:   cache_write_en = 4'b0001;
                `S_SH:   cache_write_en = 4'b0011;
                `S_SW:   cache_write_en = 4'b1111;
                default: cache_write_en = 4'b0000;
            endcase   
        end
        else if (opcode == `R_TYPE)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 0;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = `RTYPE;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;

            case(funct3)
                `R_AS:  begin
                    case (funct7)
                        `R_ADD:  ALU_func = `ADD;
                        `R_SUB:  ALU_func = `SUB;
                        default: ALU_func = 4'd0;
                    endcase
                end
                `R_SLL:  ALU_func = `SLL;
                `R_SLT:  ALU_func = `SLT;
                `R_SLTU: ALU_func = `SLTU;
                `R_XOR:  ALU_func = `XOR;
                `R_SR:  begin
                    case (funct7)
                        `R_SRL:  ALU_func = `SRL;
                        `R_SRA:  ALU_func = `SRA;
                        default: ALU_func = 4'd0;
                    endcase
                end
                `R_OR:   ALU_func = `OR;
                `R_AND:  ALU_func = `AND;
                default: ALU_func = 4'd0;
            endcase
        end
        else if (opcode == `I_CSR)
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 0;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 1;
            cache_write_en = 0;
            imm_type = 0;
            CSR_write_en = 1;

            case(funct3)
                `I_CSRRC: begin
                    ALU_func=`NAND;
                    CSR_zimm_or_reg = 0;
                end 
                `I_CSRRCI: begin
                    ALU_func=`NAND;
                    CSR_zimm_or_reg = 1;
                end
                `I_CSRRS: begin
                    ALU_func=`OR;
                    CSR_zimm_or_reg = 0;
                end
                `I_CSRRSI: begin
                    ALU_func=`OR;
                    CSR_zimm_or_reg = 1;
                end
                `I_CSRRW: begin
                    ALU_func=`OP1;
                    CSR_zimm_or_reg = 0;
                end
                `I_CSRRWI: begin
                    ALU_func=`OP1;
                    CSR_zimm_or_reg = 1;
                end
                default: begin
                    ALU_func= 0;
                    CSR_zimm_or_reg = 0;
                    CSR_write_en = 0;
                end
            endcase 
        end
        else 
        begin
            jal = 0;
            jalr = 0;
            op1_src = 0;
            op2_src = 0;
            ALU_func = 0;
            br_type = 0;
            load_npc = 0;
            wb_select = 0;
            load_type = 0;
            reg_write_en = 0;
            cache_write_en = 0;
            imm_type = 0;
            CSR_write_en = 0;
            CSR_zimm_or_reg = 0;
        end
    end

endmodule