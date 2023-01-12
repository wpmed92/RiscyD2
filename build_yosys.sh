# Taken from geohot: https://github.com/geohot/tinygrad/blob/master/accel/cherry/build.sh

#!/usr/bin/env bash
set -ex
mkdir -p out
cd out

BASE=/Users/ahmedharmouche/Documents/hardware/fpga

# yosys 0.25
$BASE/yosys/bin/yosys -p "synth_xilinx -flatten -nowidelut -arch xc7 -top cpu; write_json riscyd2_soc.json" ../chip/rtl/cpu.v ../chip/rtl/alu.v ../chip/rtl/branch.v ../chip/rtl/csr_rf.v ../chip/rtl/decode.v ../chip/rtl/gpio.v ../chip/rtl/divider.v ../chip/rtl/mem.v ../chip/rtl/mmio.v ../chip/rtl/rf.v ../chip/rtl/uart_rx.v ../chip/rtl/uart_tx.v

# nextpnr-xilinx a46afc6ff8aca9a4b9275b3385bfec70f008e10b
# cmake -DARCH=xilinx -DBUILD_GUI=no -DBUILD_PYTHON=no -DUSE_OPENMP=No .
# git submodule init && git submodule update
# python3 xilinx/python/bbaexport.py --device xc7a35tcsg324-1 --bba xilinx/xc7a35t.bba
# ./bbasm --l xilinx/xc7a35t.bba xilinx/xc7a35t.bin
$BASE/nextpnr-xilinx/nextpnr-xilinx --chipdb $BASE/nextpnr-xilinx/xilinx/xc7a35t.bin --xdc ../chip/fpga/arty_a7/arty_a7_35t.xdc --json riscyd2_soc.json --write riscyd2_soc_routed.json --fasm riscyd2_soc.fasm

# prjxray d756999cf0db834d5f547be5476c6a5b2c2edc9b
XRAY_UTILS_DIR=$BASE/prjxray/utils
XRAY_TOOLS_DIR=$BASE/prjxray/build/tools
XRAY_DATABASE_DIR=$BASE/prjxray/database

"${XRAY_UTILS_DIR}/fasm2frames.py" --db-root "${XRAY_DATABASE_DIR}/artix7" --part xc7a35tcsg324-1 riscyd2_soc.fasm > riscyd2_soc.frames
"${XRAY_TOOLS_DIR}/xc7frames2bit" --part_file "${XRAY_DATABASE_DIR}/artix7/xc7a100tcsg324-1/part.yaml" --part_name xc7a35tcsg324-1 --frm_file riscyd2_soc.frames --output_file riscyd2_soc.bit