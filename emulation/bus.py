from ram import *
from uart import *

class Bus:
    def __init__(self):
        self.ram = RAM()
        self.uart = UART()

    def read(self, bits, address):
        if address < MEMORY_TOP:
            return self.ram.read(bits, address)
        else:
            uart_port = (address - MEMORY_TOP) % 2
            return self.uart.read(uart_port)

    def write(self, bits, address, val):
        if address < MEMORY_TOP:
            self.ram.write(bits, address, val)
        else:
            uart_port = (address - MEMORY_TOP) % 2
            self.uart.write(uart_port, val)