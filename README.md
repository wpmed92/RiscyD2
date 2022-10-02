# Riscy-D2

Riscy-D2 is a project to build a RISC-V based computer. The goal is to run it on an FPGA. The CPU currently supports the RV32I ISA.
This repository contains:

- chip: RTL code for a RISC-V RV32I based non-pipelined single core CPU
- binutils: An assembler that compiles an input assembly file, and emits a RISC-V flat binary and  a `.mem` file. Currently the CPU makes use of `.mem` files, whereas the emulator executes flat binaries.
- emulation: A RISC-V RV32I emulator written in Python
- test: Currently only contains an RV32I test adapted [from here](https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv)

The project is mainly educational, and is inspired by [From the Transistor to the Web Browser](https://github.com/geohot/fromthetransistor).

## Prerequisites

- Icarus Verilog
- Python3
- PySerial

## Running on an FPGA

RiscyD2 currently only supports Arty A7 35T.

To set it up:
- Compile the `bootrom`: 

`python3 binutils/asm/asm.py -i os/bootrom.asm -o code.o`

- Save the `code.mem` file you got from the previous step
- Create a Vivado project
- Add the content of `chip/rtl` as design sources
- Add `code.mem` as a Memory file
- Add constraints located under `chip/fpga/arty_a7/arty_a7_35t.xdc` as constraint file
- Synthesize, implement and generate bitstream
- Load the bitstream to board

At this point the chip is deployed to the board, and `bootrom` is running. It continously checks the UART port for incoming exe files.

To send an exe:

- Compile an example program located under `sample`:

`python3 binutils/asm/asm.py -i sample/switches.asm -o exe.o`

- Send the exe through UART:

`python3 tools/talk2d2.py -i path/to/exe`

(NOTE: to get the ID of your board run `ls /dev/tty.*` in your terminal.)

## License

MIT
