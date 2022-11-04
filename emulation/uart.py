class UART:
    def __init__(self):
        self.r_tx_ready = 0
        self.w_tx_byte = 0x00

    def read(self, port):
        if port == 0:
            old = self.r_tx_ready

            if (self.r_tx_ready == 1):
                self.r_tx_ready = 0
            
            return old

    def write(self, port, val):
        if port == 1:
            self.w_tx_byte = val & 0xFF
            print(chr(self.w_tx_byte), end='')
            self.r_tx_ready = 1

