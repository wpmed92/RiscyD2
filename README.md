# Riscy-D2

Riscy-D2 is a project to build a RISC-V based computer. The goal is to run it on an FPGA. The CPU currently supports the RV32I ISA.
This repository contains:

- chip: RTL code for a RISC-V RV32I based non-pipelined single core CPU
- binutils: An assembler that compiles an input assembly file, and emits a RISC-V flat binary and  a `.mem` file. Currently the CPU makes use of `.mem` files, whereas the emulator executes flat binaries.
- emulation: A RISC-V RV32I emulator written in Python
- test: Currently only contains an RV32I test adapted [from here](https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv)

The project is mainly educational, and is inspired by [From the Transistor to the Web Browser](https://github.com/geohot/fromthetransistor).

## Prerequisites

- Python3
- Icarus Verilog

## License

MIT
