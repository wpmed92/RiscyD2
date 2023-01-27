![RiscyD2](./demo/riscyd2_banner.png)

---

RiscyD2 is a tiny RISC-V based microcontroller/softcore running on a Digilent Arty A7-35T board.

## Project structure

- chip: RTL code for a RISC-V CPU core implementing the RV32I base instruction set, with M standard extension support.
- binutils: Contains an assembler that emits RISC-V flat binary.
- emulation: A RISC-V RV32IM emulator written in Python.
- test: Simple unit tests for arithemtic, load/store and csr instructions.

The project is mainly educational, and is inspired by [From the Transistor to the Web Browser](https://github.com/geohot/fromthetransistor).

## Prerequisites

- Icarus Verilog
- Python3
- PySerial

## Running on an FPGA

RiscyD2 currently only supports Arty A7-35T, but the plan is to add support for more boards.

To set it up:
- Compile the `bootrom`: 

`python3 binutils/asm/asm.py -i os/bootrom.asm -o code.o`

- Save the `code.mem` file you got from the previous step
- Create a Vivado project
- Add the content of `chip/rtl` as design sources
- Add `code.mem` as a Memory file
- Add constraints located under `chip/fpga/arty_a7/arty_a7_35t.xdc` as constraint file
- Synthesize, implement and generate bitstream
- Load the bitstream to the board

At this point the chip is deployed to the board, and the `bootrom` is running. It continously checks the UART port for incoming exe files.

## Programming RiscyD2

To compile programs for the board you can either use the assembler in the repository (recommended to run the programs in the `sample` folder), or use a real compiler, like [GCC](https://github.com/riscv-collab/riscv-gnu-toolchain).

### Toy examples

Compile an example program located under `sample`:

`python3 binutils/asm/asm.py -i sample/switches.asm -o exe.o`

### Real-world examples

For a relatively complex example program, see the [porting](https://github.com/wpmed92/TinyMaix-RiscyD2) of [TinyMaix](https://github.com/sipeed/TinyMaix) to RiscyD2.

To compile C programs, the following toolchain is recommended:

- [GCC](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [Picolibc](https://github.com/picolibc/picolibc)
- [riscyd2.h](lib/riscyd2.h)
- [riscyd2.ld](lib/riscyd2.ld) (Picolibc linker script)


Send the exe through UART:

`python3 tools/talk2d2.py -i path/to/exe`

The binary format is fairly simple: the first 4 bytes encode the size of the exe, followed by the exe. That's it.

To listen to incoming data from the board, run:

`python3 tools/listen2d2.py`

(NOTE: to get the ID of your board run `ls /dev/tty.*` in your terminal.)

## License

MIT
