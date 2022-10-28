class RAM:
    def __init__(self):
        self.memory = bytearray(0x200000)

    #little-endian (LE): least significant byte (LSB) is at the smallest address
    def read8(self, address):
        return self.memory[address]

    def read16(self, address):
        return self.memory[address] | (self.memory[address + 1] << 8)

    def read32(self, address):
        return self.memory[address] | (self.memory[address + 1] << 8) | (self.memory[address + 2] << 16) | (self.memory[address + 3] << 24)

    def write8(self, address, val):
        self.memory[address] = val & 0xFF

    def write16(self, address, val):
        self.memory[address] = val & 0xFF
        self.memory[address + 1] = (val >> 8) & 0xFF

    def write32(self, address, val):
        self.memory[address] = val & 0xFF
        self.memory[address + 1] = (val >> 8) & 0xFF
        self.memory[address + 2] = (val >> 16) & 0xFF
        self.memory[address + 3] = (val >> 24) & 0xFF