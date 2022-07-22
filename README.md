# RISC-V 32I CPU

## 文件结构

```
├─Figures               # 存放数据通路图
│   Design-Figure.drawio
│   Design-Figure.png
│
├─Simulation        
│   testBench.v         # 仿真文件
│
├─Source                # CPU源代码
│  ├─Cache              # 数据和指令cache
│  ├─CSR                # CSR有关部件
│  ├─ExMemSegReg        # EX-MEM级间寄存器
│  ├─IdExSegReg         # ID-EX级间寄存器
│  ├─IfIdSegReg         # IF-ID级间寄存器
│  └─MemWbSegReg        # MEM-WB级间寄存器
│    ALU.v          
│    BranchDecision.v
│    ControllerDecoder.v
│    DataExtend.v
│    GeneralRegister.v
│    Hazard.v
│    ImmExtend.v
│    NPCGenerator.v
│    Parameters.v       # 参数文件
│    PC.v
│    RV32ICore.v        # CPU顶层文件
│
└─TestTools             #测试数据生成工具
    ├─FunctionalTest    #功能测试
    └─PerformanceTest   #性能测试
```

## CPU基本情况

### ISA支持

`RISC-V 32I`的指令类型共有6种, 每种指令的具体位划分如下:

<div align=center>
<img src="./Figures/instruction_type.png" width=80%/>
</div>
</br>

本CPU支持的指令有:

```
#逻辑或算数运算指令
SLLI、SRLI、SRAI、ADD、SUB、SLL、SLT、SLTU、XOR、SRL、SRA、OR、AND、ADDI、SLTI、SLTIU、XORI、ORI、ANDI、

#load与store类型的指令
LB、LH、LW、LBU、LHU、SB、SH、SW、

#分支指令
BEQ、BNE、BLT、BLTU、BGE、BGEU、

#跳转或寄存器更新指令
LUI、AUIPC、JALR、JAL、

#CSR指令
CSRRW、CSRRS、CSRRC、CSRRWI、CSRRSI、CSRRCI
```

### 功能特性

此CPU的功能特性包括:

- 五段流水线, 带有定向旁路;
- 支持`2bits BHT`分支预测, 并可自由调整`buffer`大小;
- 支持`LRU` `n-way` `D-Cache`, 并可自由调整D-Cache配置。在`D-Cache`之后接有`main_mem`, 负责模拟主存50个时钟周期的延迟。
  
其[数据通路](./Figures/Design-Figure.png)如下:

<div align=center>
<img src="./Figures/Design-Figure.png" width=100%/>
</div>
</br>

## Getting Started

以`Vivado`开发为例, 首先需要生成`I-Cache`和`D-cache`的`Verilog`文件(*默认的`Cache`文件为`1TestAll`对应的`Verilog`文件*), 详情见[测试样例生成](./TestTools/README.md)。接下来新建`Vivado`工程, 将[Source](./Source)的代码导入, 然后将Simulation文件夹下的[testBench.v](./Simulation/testBench.v)作为仿真文件导入, 之后就可以进行仿真了。功能和性能测试结果说明也请参考[此文档](./TestTools/README.md)。

另外, 我们可以通过调节Cache的配置、分支预测器的大小、测试样例的规模来分析CPU在不同配置下的性能。