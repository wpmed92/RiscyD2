#An assembler for RISC-V v2.2 Base integer instruction set 

from tokenizer import *
from parser import *
from encoder import *
import sys
import os

class Assembler:
  def __init__(self):
    self.token_stream = []

  def assemble(self, asm_source_path):
    asm_source = open(asm_source_path, mode='r', encoding="utf-8")
    asm_lines = asm_source.read().splitlines() 
    num_line = 0

    for asm_line in asm_lines:
      print(asm_line)
      tokenizer = Tokenizer(asm_line, num_line)
      self.token_stream.extend(tokenizer.tokenize())
      num_line = num_line + 1

    parser = Parser(self.token_stream)
    ast = parser.parse()
    print(parser.symbol_table)

    encoder = Encoder(ast)
    encoder.encode(asm_source_path)

if __name__ == "__main__":
  numArgs = len(sys.argv)
  args = sys.argv

  if numArgs == 3:
    if args[1] != "-i":
      print("Unrecognized parameter '" + args[1] + "'. Usage: asm.py -i path/to/source.asm")
    else:
      inputSourcePath = args[2]

      if not os.path.exists(inputSourcePath):
        print("File does not exist at path '" + inputSourcePath + "'")
      else:
        assembler = Assembler()
        assembler.assemble(inputSourcePath)
  else:
    print("Unexpected number of parameters. Usage: asm.py -i path/to/source.asm")