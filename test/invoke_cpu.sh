#!/usr/bin/env bash

python3 ../binutils/asm/asm.py -i rv32i.asm -o code.o
cd ../chip/rtl
iverilog -o ../../test/test.chip ../../test/test.v
cd ../../test
vvp test.chip