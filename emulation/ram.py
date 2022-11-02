MEMORY_TOP = 0x40000

class RAM:
    def __init__(self):
        self.memory = bytearray(MEMORY_TOP)

    #little-endian (LE): least significant byte (LSB) is at the smallest address
    def read(self, bits, address):
        if bits == 8:
            return self.memory[address]
        elif bits == 16:
            return self.memory[address] | (self.memory[address + 1] << 8)
        elif bits == 32:
            return self.memory[address] | (self.memory[address + 1] << 8) | (self.memory[address + 2] << 16) | (self.memory[address + 3] << 24)
        else:
            raise Exception(f'bits should be 8, 16 or 32, but {bits} was provided.')

    def write(self, bits, address, val):
        if bits == 8:
            self.memory[address] = val & 0xFF
        elif bits == 16:
            self.memory[address] = val & 0xFF
            self.memory[address + 1] = (val >> 8) & 0xFF
        elif bits == 32:
            self.memory[address] = val & 0xFF
            self.memory[address + 1] = (val >> 8) & 0xFF
            self.memory[address + 2] = (val >> 16) & 0xFF
            self.memory[address + 3] = (val >> 24) & 0xFF
        else:
            raise Exception(f'bits should be 8, 16 or 32, but {bits} was provided.')
