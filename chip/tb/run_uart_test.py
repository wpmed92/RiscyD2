import subprocess

command = "cd ../rtl ; iverilog -o ../tb/uart_test.chip ../tb/uart_test.v uart_rx.v uart_tx.v;  cd ../tb ; vvp uart_test.chip"

p = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
resp = p.stdout.decode("utf-8")

assert (resp == "PASSED\n"), f'UART test failed {resp}'

print("PASSED")
