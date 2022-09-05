#RISC-V Base integer instruction set v2.0
#https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
#R, I, S, and U-type instructions

from ram import *
from util import *

#32-bit mode
XLEN = 32
MASK_XLEN = 0xFFFFFFFF

class RiscV:
  def __init__(self, ram):
    self.ram = ram
    self.registers = [0] * XLEN
    self.pc = 0

    self.jump_table = {
      # I-type
      0b00000010011: self.addi,
      0b10000010011: self.addi,
      0b00100010011: self.slti,
      0b10100010011: self.slti,
      0b00110010011: self.sltiu,
      0b10110010011: self.sltiu,
      0b01000010011: self.xori,
      0b11000010011: self.xori,
      0b01100010011: self.ori,
      0b11100010011: self.ori,
      0b01110010011: self.andi,
      0b11110010011: self.andi,
      0b00010010011: self.slli,
      0b01010010011: self.srli,
      0b11010010011: self.srai,

      # R-type
      0b00000110011: self.add,
      0b10000110011: self.sub,
      0b00010110011: self.sll,
      0b00100110011: self.slt,
      0b00110110011: self.sltu,
      0b01000110011: self.xor,
      0b01010110011: self.srl,
      0b11010110011: self.sra,
      0b01100110011: self._or,
      0b01110110011: self._and,

      # Control flow
      0b00001100011: self.beq,
      0b10001100011: self.beq,
      0b00011100011: self.bne,
      0b10011100011: self.bne,
      0b01001100011: self.blt,
      0b11001100011: self.blt,
      0b01011100011: self.bge,
      0b11011100011: self.bge,
      0b01101100011: self.bltu,
      0b11101100011: self.bltu,
      0b01111100011: self.bgeu,
      0b11111100011: self.bgeu,

      # Load
      0b00000000011: self.lb,
      0b10000000011: self.lb,
      0b00010000011: self.lh,
      0b10010000011: self.lh,
      0b00100000011: self.lw,
      0b10100000011: self.lw,
      0b01000000011: self.lbu,
      0b11000000011: self.lbu,
      0b01010000011: self.lhu,
      0b11010000011: self.lhu,

      # Store
      0b00000100011: self.sb,
      0b10000100011: self.sb,
      0b00010100011: self.sh,
      0b10010100011: self.sh,
      0b00100100011: self.sw,
      0b10100100011: self.sw,

      # lui
      0b00000110111: self.lui,
      0b00010110111: self.lui,
      0b00100110111: self.lui,
      0b00110110111: self.lui,
      0b01000110111: self.lui,
      0b01010110111: self.lui,
      0b01100110111: self.lui,
      0b01110110111: self.lui,
      0b10000110111: self.lui,
      0b10010110111: self.lui,
      0b10100110111: self.lui,
      0b10110110111: self.lui,
      0b11000110111: self.lui,
      0b11010110111: self.lui,
      0b11100110111: self.lui,
      0b11110110111: self.lui,

      # auipc
      0b00000010111: self.auipc,
      0b00010010111: self.auipc,
      0b00100010111: self.auipc,
      0b00110010111: self.auipc,
      0b01000010111: self.auipc,
      0b01010010111: self.auipc,
      0b01100010111: self.auipc,
      0b01110010111: self.auipc,
      0b10000010111: self.auipc,
      0b10010010111: self.auipc,
      0b10100010111: self.auipc,
      0b10110010111: self.auipc,
      0b11000010111: self.auipc,
      0b11010010111: self.auipc,
      0b11100010111: self.auipc,
      0b11110010111: self.auipc,

      # jal
      0b00001101111: self.jal,
      0b00011101111: self.jal,
      0b00101101111: self.jal,
      0b00111101111: self.jal,
      0b01001101111: self.jal,
      0b01011101111: self.jal,
      0b01101101111: self.jal,
      0b01111101111: self.jal,
      0b10001101111: self.jal,
      0b10011101111: self.jal,
      0b10101101111: self.jal,
      0b10111101111: self.jal,
      0b11001101111: self.jal,
      0b11011101111: self.jal,
      0b11101101111: self.jal,
      0b11111101111: self.jal,

      # jalr
      0b00001100111: self.jalr,
      0b00011100111: self.jalr,
      0b00101100111: self.jalr,
      0b00111100111: self.jalr,
      0b01001100111: self.jalr,
      0b01011100111: self.jalr,
      0b01101100111: self.jalr,
      0b01111100111: self.jalr,
      0b10001100111: self.jalr,
      0b10011100111: self.jalr,
      0b10101100111: self.jalr,
      0b10111100111: self.jalr,
      0b11001100111: self.jalr,
      0b11011100111: self.jalr,
      0b11101100111: self.jalr,
      0b11111100111: self.jalr
    }

  def print_regs(self):
    reg_debug = ""

    for i in range(0, 32):
      reg_debug += "r" + str(i) + "=" + str(self.registers[i]) + "    "

    print("Registers")
    print("---------")
    print(reg_debug)


  def step(self):
    op_integer = self.fetch()
    op_decoded = self.decode(op_integer)

    try:
      self.execute(op_decoded)
      self.pc += 4
      print(str(self.pc))
    except KeyError:
      return False

    return True

  def fetch(self):
    return self.ram.read32(self.pc)

  def decode(self, op_integer):
    return Opcode(op_integer)

  def execute(self, opcode):
    self.jump_table[opcode.decode_bits()](opcode)

  def reg(self, index):
    return self.registers[index] & MASK_XLEN

  def set_reg(self, index, val):
    self.registers[index] = val

  #Integer Computational Instructions
  #Either R-type (register + register), or I-type (register + immediate)
  def addi(self, opcode):
    print("ADDI called")
    self.registers[opcode.rd()] = (sign_extend(opcode.imm12(), 11) + self.reg(opcode.rs1())) & MASK_XLEN
    return
  
  def slti(self, opcode):
    if self.reg(opcode.rs1()) < sign_extend(opcode.imm12(), 11):
      self.registers[opcode.rd()] = 1
    else:
      self.registers[opcode.rd()] = 0

  def sltiu(self, opcode):
    if to_unsigned(self.reg(opcode.rs1())) < to_unsigned(sign_extend(opcode.imm12(), 11)):
      self.registers[opcode.rd()] = 1
    else:
      self.registers[opcode.rd()] = 0

  def andi(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) & sign_extend(opcode.imm12(), 11)) & MASK_XLEN

  def ori(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) | sign_extend(opcode.imm12(), 11)) & MASK_XLEN

  def xori(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) ^ sign_extend(opcode.imm12(), 11)) & MASK_XLEN

  def slli(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) << (opcode.imm12() & 0b11111)) & MASK_XLEN

  def srli(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) >> (opcode.imm12() & 0b11111)) & MASK_XLEN

  def srai(self, opcode):
    sign_bit = self.reg(opcode.rs1()) & (1 << 31)
    self.registers[opcode.rd()] = ((self.reg(opcode.rs1()) >> (opcode.imm12() & 0b11111)) | sign_bit) & MASK_XLEN

  def add(self, opcode):
      self.registers[opcode.rd()] = (self.reg(opcode.rs1()) + self.reg(opcode.rs2())) & MASK_XLEN

  def sub(self, opcode):
      self.registers[opcode.rd()] = (self.reg(opcode.rs1()) - self.reg(opcode.rs2())) & MASK_XLEN

  def sll(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) << (self.reg(opcode.rs2()) & 0b11111)) & MASK_XLEN
  
  def slt(self, opcode):
    if self.reg(opcode.rs1()) < self.reg(opcode.rs2()):
      self.registers[opcode.rd()] = 1
    else:
      self.registers[opcode.rd()] = 0
  
  def sltu(self, opcode):
    if to_unsigned(self.reg(opcode.rs1())) < to_unsigned(self.reg(opcode.rs2())):
      self.registers[opcode.rd()] = 1
    else:
      self.registers[opcode.rd()] = 0
  
  def xor(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) ^ self.reg(opcode.rs2())) & MASK_XLEN

  def srl(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) >> (self.reg(opcode.rs2()) & 0b11111)) & MASK_XLEN

  def sra(self, opcode):
    sign_bit = self.reg(opcode.rs1()) & (1 << 31)
    self.registers[opcode.rd()] = ((self.reg(opcode.rs1()) >> (self.reg(opcode.rs2()) & 0b11111)) | sign_bit) & MASK_XLEN

  def _or(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) | self.reg(opcode.rs2())) & MASK_XLEN

  def _and(self, opcode):
    self.registers[opcode.rd()] = (self.reg(opcode.rs1()) & self.reg(opcode.rs2())) & MASK_XLEN

  #Control transfer instructions
  #J-type

  #TODO: generate misaligned instruction fetch if not at four-byte boundary
  #+/-1MiB range
  def jal(self, opcode):
    self.registers[opcode.rd()] = self.pc + 4
    self.pc = (sign_extend(opcode.J(), 20) + self.pc) & MASK_XLEN
    self.pc -= 4
    print("Executing JAL, jumping to: " + str(self.pc))

  def jalr(self, opcode):
    self.registers[opcode.rd()] = self.pc + 4
    self.pc = (sign_extend(opcode.imm12(), 11) + self.reg(opcode.rs1())) & MASK_XLEN
    self.pc -= 4

  #Branch instructions
  #B-type, +/- 4 KiB
  def set_branch_target(self, opcode):
    self.pc = sign_extend(opcode.B(), 12) + self.pc

  def beq(self, opcode):
    if self.reg(opcode.rs1()) == self.reg(opcode.rs2()): 
      self.set_branch_target(opcode)
      
  def bne(self, opcode):
    if self.reg(opcode.rs1()) != self.reg(opcode.rs2()):
      self.set_branch_target(opcode)

  def blt(self, opcode):
    if to_signed(self.reg(opcode.rs1())) < to_signed(self.reg(opcode.rs2())):
      self.set_branch_target(opcode)

  def bltu(self, opcode):
    if to_unsigned(self.reg(opcode.rs1())) < to_unsigned(self.reg(opcode.rs2())):
      self.set_branch_target(opcode)

  def bge(self, opcode):
    if to_signed(self.reg(opcode.rs1())) >= to_signed(self.reg(opcode.rs2())):
      self.set_branch_target(opcode)

  def bgeu(self, opcode):
    if to_unsigned(self.reg(opcode.rs1())) >= to_unsigned(self.reg(opcode.rs2())):
      self.set_branch_target(opcode)

  #Load instructions
  def calc_load_address(self, opcode):
    return self.reg(opcode.rs1()) + sign_extend(opcode.imm12(), 11)

  def calc_store_address(self, opcode):
    offset = sign_extend(opcode.S(), 11)
    base = self.reg(opcode.rs1())
    print("base=" + str(base) + "offset=" + str(offset))
    return self.reg(opcode.rs1()) + sign_extend(opcode.S(), 11)


  def lb(self, opcode):
    address = self.calc_load_address(opcode)
    self.registers[opcode.rd()] = sign_extend(self.ram.read8(address), 7)

  def lh(self, opcode):
    address = self.calc_load_address(opcode)
    self.registers[opcode.rd()] = sign_extend(self.ram.read16(address), 15)

  def lw(self, opcode):
    address = self.calc_load_address(opcode)
    self.registers[opcode.rd()] = self.ram.read32(address)

  def lbu(self, opcode):
    address = self.calc_load_address(opcode)
    self.registers[opcode.rd()] = zero_extend(self.ram.read16(address), 7)

  def lhu(self, opcode):
    address = self.calc_load_address(opcode)
    self.registers[opcode.rd()] = zero_extend(self.ram.read16(address), 15)

  #Store instructions
  def sb(self, opcode):
    self.ram.write8(self.calc_store_address(opcode), self.reg(opcode.rs2()) & 0xFF)
      
  def sh(self, opcode):
    self.ram.write16(self.calc_store_address(opcode), self.reg(opcode.rs2()) & 0xFFFF)

  def sw(self, opcode):
    self.ram.write32(self.calc_store_address(opcode), self.reg(opcode.rs2()))

  #U-type
  def lui(self, opcode):
    self.registers[opcode.rd()] = 0
    self.registers[opcode.rd()] = opcode.U()

  #can be used in pair with jalr to jump to any address in the 32bit address space
  def auipc(self, opcode):
    self.registers[opcode.rd()] = 0
    self.registers[opcode.rd()] = self.pc + opcode.U()


class Opcode:
  op_integer = 0

  def __init__(self, op_integer):
    self.op_integer = op_integer

  def op(self):
    return self.op_integer & 0b1111111

  def rd(self):
    return (self.op_integer & (0b11111 << 7)) >> 7

  def funct3(self):
    return (self.op_integer & (0b111 << 12)) >> 12

  def rs1(self):
    return (self.op_integer & (0b11111 << 15)) >> 15

  def rs2(self):
    return (self.op_integer & (0b11111 << 20)) >> 20

  def funct7(self):
    return (self.op_integer & (0b1111111 << 25)) >> 25

  def imm12(self):
    return self.rs2() | (self.funct7() << 5)

  # On Verilog side: decode_bits = { instr[30], instr[14:12], instr[6:0] };
  def decode_bits(self):
    return  ((self.op_integer & (1 << 30)) >> 20) | (self.funct3() << 7) | self.op()

  def J(self):
    imm19_12 = (self.op_integer >> 12) & 0b11111111
    imm11 = (self.op_integer >> 20) & 0b1
    imm10_1 = (self.op_integer >> 21) & 0b1111111111
    imm20 = (self.op_integer >> 31) & 0b1

    return 0 | (imm10_1 << 1) | (imm11 << 11) | (imm19_12 << 12) | (imm20 << 20)

  def B(self):
    imm4_1 = (self.op_integer >> 8) & 0b1111
    imm11 = (self.op_integer >> 7) & 0b1
    imm10_5 = (self.op_integer >> 25) & 0b111111
    imm12 = (self.op_integer >> 31) & 0b1

    return 0 | (imm4_1 << 1) | (imm10_5 << 5) | (imm11 << 11) | (imm12 << 12)

  def S(self):
    imm4_0 = (self.op_integer >> 7) & 0b11111
    imm11_5 = (self.op_integer >> 25) & 0b1111111

    return imm4_0 | (imm11_5 << 5)

  def U(self):
    return self.op_integer >> 12
