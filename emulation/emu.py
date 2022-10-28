from riscv import *
import sys
import os

ram = RAM()
cpu = RiscV(ram)

def main():
  print("RISC-V Base integer instruction set v2.0 emulation")
  
if __name__ == "__main__":
  numArgs = len(sys.argv)
  args = sys.argv

  if numArgs == 3:
    if args[1] != "-i":
      print("Unrecognized parameter '" + args[1] + "'. Use -i to pass a ROM.")
    else:
      inputRomPath = args[2]

      if not os.path.exists(inputRomPath):
        print("File does not exist at path '" + inputRomPath + "'")
      else:
        try:
          with open(inputRomPath, "rb") as rom:
            byte = rom.read(1)
            address = 0

            while byte:
              ram.write8(address, int.from_bytes(byte, byteorder="little", signed=False))
              address += 1
              byte = rom.read(1)

            print("Read " + str(address) + " bytes into Ram.")

            while True:
              if not cpu.step():
                break
              
              cpu.print_regs()

        except IOError:
          print('Error While Opening the file!')

      print(inputRomPath)
  else:
    print("Unexpected number of parameters.")
    
  main()