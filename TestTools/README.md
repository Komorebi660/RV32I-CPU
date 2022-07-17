## 测试样例生成

本文件夹包含了生成功能和性能测试所必需的文件。

#### Functional Test

```bash
cd FunctionalTest/scripts

#Example of generating data and inst cache file of "1testAll"
python gen_instruction.py ../binary/1testAll.inst ../../../Source/Cache/InstructionCache.v
python gen_mem.py ../binary/1testAll.data ../../../Source/Cache/mem.sv
```

#### Performance Test

```bash
cd PerformanceTest/scripts

#QuickSort
python gen_instruction.py ../code/QuickSort.S ../../../Source/Cache/InstructionCache.v
python gen_mem_for_quicksort.py 256 ../../../Source/Cache/mem.sv

#MatMul
python gen_instruction.py ../code/MatMul.S ../../../Source/Cache/InstructionCache.v
python gen_mem_for_matmul.py 16 ../../../Source/Cache/mem.sv
```
