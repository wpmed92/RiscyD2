import subprocess
import glob
import os

NUM_REGISTERS = 32
test_cases = []

def to_signed(n):
    n = n & 0xffffffff
    return (n ^ 0x80000000) - 0x80000000

def get_expected_regs(regs_path):
    with open(regs_path) as f:
        out = []
        lines = f.read().splitlines()
        for line in lines:
            out.append(int(line.split("=")[1]))

        return out

def run_test(test_case):
    compile_command = f'python3 ../binutils/asm/asm.py -i {test_case["asm"]} -o code.o'
    run_command = "cd ../chip/rtl ; iverilog -o ../../test/test.chip ../../test/test.v ;  cd ../../test ; vvp test.chip"
    p = subprocess.run(compile_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    p = subprocess.run(run_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    lines = p.stdout.decode("utf-8").splitlines()[-NUM_REGISTERS:]

    assert len(lines) > 0, f'Error while invoking CPU:\n{p.stderr}'

    expected_regs = test_case["regs"]

    for reg_line in lines:
        reg_pair = reg_line.split(":")
        reg_idx = int(reg_pair[0])
        reg_value =  to_signed(int(reg_pair[1], 16))
        assert (expected_regs[reg_idx] == reg_value), f'{test_case["asm"]} Error: Register {reg_idx} is {reg_value}, but should be {expected_regs[reg_idx]}'

    print(f'{test_case["asm"]} PASSED')

for test_asm in glob.glob("*.asm"):
    run_test({ 
        "asm": test_asm, 
        "regs": get_expected_regs(os.path.splitext(test_asm)[0] + ".regs")
    })
