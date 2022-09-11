import subprocess

NUM_REGISTERS = 32
timeout_s = 5
expected_regs = [0x0, 0x15, 0x7, 0xfffffffc, 0x000000b4, 
                 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1,
                 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 
                 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 
                 0x1, 0x1, 0x0]

try:
    subprocess.run(['./invoke_cpu.sh'], timeout=5, capture_output=True, text=True)
except subprocess.TimeoutExpired as e:
    lines = e.stdout.splitlines()[-NUM_REGISTERS-4:-4]
    
    for reg_line in lines:
        reg_pair = reg_line.decode("utf-8").split(":")
        reg_idx = int(reg_pair[0])
        reg_value =  int(reg_pair[1], 16)
        assert (expected_regs[reg_idx] == reg_value), "Register " + str(reg_idx) + " is " + str(reg_value) + ", but should be " + str(expected_regs[reg_idx])

print("PASSED")
