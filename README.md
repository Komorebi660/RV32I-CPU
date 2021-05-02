# 简易MIPS五段流水线CPU设计

## 实验环境

- `Windows`/`Linux`
- `Vivado 2020.1`
- 开发板型号 `xc7a100tcsg324-1`

## 项目简介

本项目实现了基于`MIPS`指令集架构的简易五段流水线`CPU`，它能运行的指令有：

- ADD
- ADDI
- SW
- LW
- BEQ
- J
  
除`CPU`本身外，还包含一个累加器测试程序(具体代码见`test.txt`文件)，它能会从拨动开关中读取数据并累加，然后将结果送至七段数码管显示。

## 源码结构

- constrs
  - `CPU_test.xdc`约束文件;
- simulation
  - `debug_test.v`仿真文件;
- source
  - `ALU.v`逻辑算数运算器模块，实现加法以及比较，可自行添加更多功能;
  - `RegisterFile.v`寄存器堆模块;
  - `CPU.v`五段流水线处理器模块，在其中例化了`ALU`、`RegisterFile`、以及两个`IP`核作为`Instruction Memory`和`Data Memory`;
  - `ButtonEdge.v`按键信号处理模块，对输入的按键信号去抖动、取边沿;
  - `DIS.v`七段数码管显示模块，负责将读出的数据在七段数码管上显示;
  - `SwitchRegister.v`开关寄存器模块，为了实现CPU与外设交互所定义的模块，里面包含数据寄存器以及状态寄存器两个部分;
  - `DebugUnit.v`作为顶层模块封装上述模块，用于调试;
- `test.coe`作为测试程序送入`Instruction Memory`内.

## 数据通路

CPU数据通路示意图：

![Data_Path](/pictures/Data_Path.PNG)

模块组合图：

![Modules](/pictures/Modules.PNG)

## 注意事项

- 代码使用`Verilog`编写，利用`Vivado`进行仿真、测试、烧写；
- 在`Vivado`中导入代码前，需要例化两个`IP`核：
  - `distributed memory`, `ROM`, `Depth=256`, `Data Width=32`, `Component Name=dis_mem_gen_0`;
  - `distributed memory`, `Singal Port RAM`, `Depth=256`, `Data Width=32`, `Component Name=dis_mem_gen_1`;
- 由于正式上板测试需要信号消抖以及连接七段数码管，这将妨碍仿真，所以`ButtonEdge`模块以及`DebugUnit`模块中各包含两段代码，分别用于仿真和上板测试，请按需选择;
- 与现代处理器以**字节**为地址单位不同，本项目是以**字**作为地址单位，即`32bits`一个地址，所以在`CPU`数据通路中没有左移对齐模块，`PC`也是`+1`而不是`+4`;
- 在本项目中，`CPU`需要与拨动开关`switch`这一外设交互，定义虚拟内存地址`x8000`为开关数据寄存器，`x8001`为开关状态寄存器;

## 输入输出信号声明

- `switch[15:0]`作为累加器的输入数据;
- `btnc`作为输入数据使能信号;
- `btnu`/`btnd`用于给要读取的寄存器的地址`+`/`-` 1;
- `btnl`异步复位信号;
- `led[4:0]`指示当前七段数码管显示值对应的寄存器的地址;
- `led[15]`提示可以输入下一个数据;
- 七段数码管显示所选寄存器地址的值.

## 联系方式

E-Mail: cyq0919@mail.ustc.edu.cn

**仅供学术参考，请勿将代码直接copy为个人所用**