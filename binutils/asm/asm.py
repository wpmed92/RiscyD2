from tokenizer import *
from parser import *
from encoder import *
import os
import argparse

parser = argparse.ArgumentParser(description='A RISC-V RV32I assembler')
parser.add_argument('-i', dest='inFile', type=str, help='Path to source file')
parser.add_argument('-o', dest='outFile', type=str, help='Path to binary output file')

class Assembler:
  def __init__(self):
    self.token_stream = []

  def assemble(self, asm_source_path, bin_path):
    asm_source = open(asm_source_path, mode='r', encoding="utf-8")
    asm_lines = asm_source.read().splitlines() 
    num_line = 0

    for asm_line in asm_lines:
      tokenizer = Tokenizer(asm_line, num_line)
      self.token_stream.extend(tokenizer.tokenize())
      num_line = num_line + 1

    parser = Parser(self.token_stream)
    ast = parser.parse()

    encoder = Encoder(ast)
    encoder.encode(asm_source_path, bin_path)

if __name__ == "__main__":
  args = parser.parse_args()

  if not os.path.exists(args.inFile):
    print(f"File does not exist at path {args.inFile}")
  else:
    assembler = Assembler()
    assembler.assemble(args.inFile, args.outFile)