# 测试样例生成

本文件夹包含了生成功能和性能测试所必需的文件, 文件结构如下:

```
├───FunctionalTest          # 功能测试
│   ├───binary              # 二进制文件
│   ├───code                # 反汇编代码
│   └───scripts             # 生成verilog文件的脚本
└───PerformanceTest         # 性能测试
    ├───code                # 源代码, 包含矩阵乘法与快速排序
    ├───scripts             # 生成verilog文件的脚本
    └───toolchains          # RISC-V 32编译工具链
        ├───riscv32-linux   
        └───riscv32-windows
```

## Functional Test

功能测试主要用于测试CPU的正确性, 包含了对每条指令的详细测试代码, 详情可见[code文件夹](./FunctionalTest/code/). 

### Getting Started

要使用这些测试样例, 需要借助[Python脚本](./FunctionalTest/scripts/)生成`I-Cache`和`D-Cache`的`Verilog/System Verilog`文件。使用命令:
```bash
python gen_instruction.py [输入inst文件] [输出Verilog文件的路径]
```
即可将二进制`inst`文件转换为`I-Cache`的`Verilog`文件, 保存在指定的路径。使用命令:
```bash
python gen_mem.py [输入data文件] [输出System Verilog文件的路径]
```
即可将二进制`data`文件转换为`D-Cache`的`System Verilog`文件, 保存在指定的路径。一个具体的示例如下:

```bash
cd FunctionalTest/scripts

#Example of generating data and inst cache file of "1testAll"
python gen_instruction.py ../binary/1testAll.inst ../../../Source/Cache/InstructionCache.v
python gen_mem.py ../binary/1testAll.data ../../../Source/Cache/mem.sv
```

### Verification

对于功能测试来说, 程序结束时`x3`寄存器的值变为`1`; 若不为`1`, 则`x3`的值代表了出错的测试点编号, 你可以在[code文件夹](./FunctionalTest/code/)中的反汇编文件定位到出错指令并进一步分析。

## Performance Test

性能测试主要用于评估Cache的不同配置以及分支预测器的不同大小对矩阵乘法和快速排序这两个典型应用的执行时间的影响。

### Getting Started

和功能测试一样, 我们需要首先借助[Python脚本](./PerformanceTest/scripts/)生成`I-Cache`和`D-Cache`的`Verilog/System Verilog`文件。示例如下:

```bash
cd PerformanceTest/scripts

#QuickSort
python gen_instruction.py ../code/QuickSort.S ../../../Source/Cache/InstructionCache.v
python gen_mem_for_quicksort.py 256 ../../../Source/Cache/mem.sv

#MatMul
python gen_instruction.py ../code/MatMul.S ../../../Source/Cache/InstructionCache.v
python gen_mem_for_matmul.py 16 ../../../Source/Cache/mem.sv
```

### Advanced

你还可以调整矩阵的大小或快排元素个数的大小来观察性能变化, 具体需要进行以下两步:

- 根据注释调整[code文件夹](./PerformanceTest/code/)文件夹内的汇编代码的立即数, 从而更改指令。
- 使用`Python`脚本生成`mem.sv`时指定匹配的参数, 从而生成足量的数据。

例如, 你想要使得排序规模由`256`变为`512`, 首先你需要更改`code/QuickSort.S`中的参数使得排序元素个数为`512`, 具体来说, 将代码的第27行中的`xor a3, zero, 0x100`调整为`xor a3, zero, 0x200`即可, 接下来你只需要通过执行:
```bash
python gen_instruction.py ../code/QuickSort.S ../../../Source/Cache/InstructionCache.v
python gen_mem_for_quicksort.py 512 ../../../Source/Cache/mem.sv
```
即可生成具有`512`个数的快速排序的`I-Cache`和`D-Cache`的`Verilog`文件。

另外, 如果你愿意, 你也可以自己编写`RISC-V`的汇编程序并借助`Python`脚本完成`I-Cache`和`D-Cache`的`Verilog`文件的生成。

### Verification

对于快速排序来说, 我们可以在程序结束后检查memory中的数据是否有序来验证CPU的正确性, **由于Cache的存在, memory中的结果可能并不完全有序, 你可以通过调小Cache来减轻这种不一致**。

对于矩阵乘法来说, 我们在`mem.sv`中已经注明了矩阵乘法的最终结果, 所以你只需要在程序执行完毕后检查memory中的值是否与`mem.sv`注释的结果保持一致即可。**同样, 由于Cache的存在, memory中的结果可能与`mem.sv`注释的结果并不完全一致, 你也可以通过调小Cache来减轻这种现象**。