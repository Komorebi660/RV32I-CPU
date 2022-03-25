#Copyright (c) 2022 Komorebi660
#This script can change .S Files into .inst & .data files which can be loaded by our FPGA's Block memories.

#Deal with .S Files
ASM_SOURCE = $(wildcard *.S)
INSTONLY = $(patsubst %.S,%.inst,$(ASM_SOURCE))
DATAANDINST = $(patsubst %.S,%.data,$(ASM_SOURCE))
OMFILE = $(patsubst %.S,%.om,$(ASM_SOURCE))
OFILE = $(patsubst %.S,%.o,$(ASM_SOURCE))
OBJDUMP = $(patsubst %.S,%.txt,$(ASM_SOURCE))
all: InstOnly DataAndInst Objdump cleanTMP
InstOnly: $(INSTONLY)
DataAndInst: $(DATAANDINST)
OMFile: $(OMFILE)
OFile: $(OFILE)
Objdump: $(OBJDUMP)

#rules
Bin2Data: ./Utils/Bin2Data.c
	gcc -o Bin2Data ./Utils/Bin2Data.c
%.o: %.S
	./Utils/riscv32-unknown-elf-as $< -o $@ -march=rv32i
%.om: %.o
	./Utils/riscv32-unknown-elf-ld $< -o $@
%-Data.bin: %.om
	./Utils/riscv32-unknown-elf-objcopy -O binary $< $@
%-Inst.bin: %.om
	./Utils/riscv32-unknown-elf-objcopy --dump-section .text=$@ $<
%.data: %-Data.bin Bin2Data
	./Bin2Data $< $@
%.inst: %-Inst.bin Bin2Data
	./Bin2Data $< $@
%.txt: %.om
	./Utils/riscv32-unknown-elf-objdump -d $< > $@
cleanTMP:
	-rm -f *.om *.o *.bin Bin2Data
clean:
	-rm -f *.data *.inst *.txt *.om *.o *.bin Bin2Data
cleanASM:
	-rm -f *.S

.SUFFIXES:
