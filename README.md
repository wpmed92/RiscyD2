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

## Running on an FPGA

RiscyD2 was tested on an Arty A7 35T board. To see it in action, compile `sample/led_blink.asm`:
`python3 binutils/asm/asm.py -i sample/led_blink.asm -o code.o`
This will emit a `code.o` flat binary and a `code.mem` memory file, which `$readmemh` will load into `mem`.
Add the design sources to a Vivado project. Add the constraint file (`chip/fpga/arty_a7/arty_a7_35t.xdc`).
For the synthesizer to pick up the memory file correctly, add it to the design sources, and Vivado will put it into a Memory folder.
Deploy the design to your board. If everything went well all 4 leds will light up, and `led[0]` and `led[2]` will blink with a 1Hz frequency.

## License

MIT
