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

    self.jump_table_main = {
      0b0010011: self.exe_integer_i,
      0b0110011: self.exe_integer_r,
      0b0110111: self.lui,
      0b0010111: self.auipc,
      0b1101111: self.jal,
      0b1100111: self.jalr,
      0b1100011: self.exe_control_flow,
      0b0000011: self.exe_load,
      0b0100011: self.exe_store
    }

    #I-type integer arithmetic
    self.jump_table_integer_i = {
      0b000: self.addi,
      0b010: self.slti,
      0b011: self.sltiu,
      0b100: self.xori,
      0b110: self.ori,
      0b111: self.andi,
      0b001: self.slli,
      0b101: self.srli_srai,
    }

    #R-type integer arithmetic
    self.jump_table_integer_r = {
      0b000: self.add_sub,
      0b001: self.sll,
      0b010: self.slt,
      0b011: self.sltu,
      0b100: self.xor,
      0b101: self.srl_sra,
      0b110: self._or,
      0b111: self._and
    }

    #Control flow instructions
    self.jump_table_control_flow = {
      0b000: self.beq,
      0b001: self.bne,
      0b100: self.blt,
      0b101: self.bge,
      0b110: self.bltu,
      0b111: self.bgeu
    }

    #Load instructions
    self.jump_table_load = {
      0b000: self.lb,
      0b001: self.lh,
      0b010: self.lw,
      0b100: self.lbu,
      0b101: self.lhu
    }

    #Store instructions
    self.jump_table_store = {
      0b000: self.sb,
      0b001: self.sh,
      0b010: self.sw
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
    print(op_integer)

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
    self.jump_table_main[opcode.op()](opcode)

  def exe_integer_i(self, opcode):
    self.jump_table_integer_i[opcode.funct3()](opcode)

  def exe_integer_r(self, opcode):
    self.jump_table_integer_r[opcode.funct3()](opcode)

  def exe_control_flow(self, opcode):
    self.jump_table_control_flow[opcode.funct3()](opcode)

  def exe_load(self, opcode):
    self.jump_table_load[opcode.funct3()](opcode)

  def exe_store(self, opcode):
    self.jump_table_store[opcode.funct3()](opcode)

  def reg(self, index):
    return self.registers[index] & MASK_XLEN

  def set_reg(self, index, val):
    if (index > 0):
      self.registers[index] = val & MASK_XLEN

  #Integer Computational Instructions
  #Either R-type (register + register), or I-type (register + immediate)
  def addi(self, opcode):
    print("ADDI called")
    self.set_reg(opcode.rd(), (sign_extend(opcode.imm12(), 11) + self.reg(opcode.rs1())))
    return
  
  def slti(self, opcode):
    rs1 = self.reg(opcode.rs1())
    imm = sign_extend(opcode.imm12(), 11)
    rs1_sign_bit = rs1 & (1 << 31)
    imm_sign_bit = imm & (1 << 31)

    if (rs1 < imm) ^ (rs1_sign_bit != imm_sign_bit):
      self.set_reg(opcode.rd(), 1)
    else:
      self.set_reg(opcode.rd(), 0)

  def sltiu(self, opcode):
    if to_unsigned(self.reg(opcode.rs1())) < to_unsigned(sign_extend(opcode.imm12(), 11)):
      self.set_reg(opcode.rd(), 1)
    else:
      self.set_reg(opcode.rd(), 0)

  def andi(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) & sign_extend(opcode.imm12(), 11)))

  def ori(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) | sign_extend(opcode.imm12(), 11)))

  def xori(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) ^ sign_extend(opcode.imm12(), 11)))

  def slli(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) << (opcode.imm12() & 0b11111)))

  def srli(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) >> (opcode.imm12() & 0b11111)))

  def srli_srai(self, opcode):
    is_arithmetic_shift = (opcode.imm12() >> 5) > 0

    if is_arithmetic_shift:
      self.srai(opcode)
    else:
      self.srli(opcode)

  def srai(self, opcode):
    rs1 = self.reg(opcode.rs1())

    if (self.reg(opcode.rs1()) & (1 << 31)):
      rs1 = rs1 | (0xFFFFFFFF << 32)

    self.set_reg(opcode.rd(), (rs1 >> (opcode.imm12() & 0b11111)))
  
  def srli(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) >> (opcode.imm12() & 0b11111)))

  def add_sub(self, opcode):
    is_sub = (opcode.imm12() >> 5) > 0

    if is_sub:
      self.sub(opcode)
    else:
      self.add(opcode)

  def add(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) + self.reg(opcode.rs2())))

  def sub(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) - self.reg(opcode.rs2())))

  def sll(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) << (self.reg(opcode.rs2()) & 0b11111)))
  
  def slt(self, opcode):
    rs1 = self.reg(opcode.rs1())
    rs2 = self.reg(opcode.rs2())
    rs1_sign_bit = rs1 & (1 << 31)
    rs2_sign_bit = rs2 & (1 << 31)

    if (rs1 < rs2) ^ (rs1_sign_bit != rs2_sign_bit):
      self.set_reg(opcode.rd(), 1)
    else:
      self.set_reg(opcode.rd(), 0)
  
  def sltu(self, opcode):
    if to_unsigned(self.reg(opcode.rs1())) < to_unsigned(self.reg(opcode.rs2())):
      self.set_reg(opcode.rd(), 1)
    else:
      self.set_reg(opcode.rd(), 0)
  
  def xor(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) ^ self.reg(opcode.rs2())))

  def srl_sra(self, opcode):
    is_arithmetic_shift = (opcode.imm12() >> 5) > 0

    if is_arithmetic_shift:
      self.sra(opcode)
    else:
      self.srl(opcode)

  def srl(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) >> (self.reg(opcode.rs2()) & 0b11111)))

  def sra(self, opcode):
    rs1 = self.reg(opcode.rs1())

    if (self.reg(opcode.rs1()) & (1 << 31)):
      rs1 = rs1 | (0xFFFFFFFF << 32)

    self.set_reg(opcode.rd(), (rs1 >> (self.reg(opcode.rs2()) & 0b11111)))

  def _or(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) | self.reg(opcode.rs2())))

  def _and(self, opcode):
    self.set_reg(opcode.rd(), (self.reg(opcode.rs1()) & self.reg(opcode.rs2())))

  def jal(self, opcode):
    self.set_reg(opcode.rd(), self.pc + 4)
    self.pc = (sign_extend(opcode.J(), 20) + self.pc) & MASK_XLEN
    self.pc -= 4

  def jalr(self, opcode):
    self.set_reg(opcode.rd(), self.pc + 4)
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
    base = self.reg(opcode.rs1())
    offset = sign_extend(opcode.imm12(), 11)
    return base + offset

  def calc_store_address(self, opcode):
    offset = sign_extend(opcode.S(), 11)
    base = self.reg(opcode.rs1())
    return base + offset

  def lb(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), sign_extend(self.ram.read8(address), 7))

  def lh(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), sign_extend(self.ram.read16(address), 15))

  def lw(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), self.ram.read32(address))

  def lbu(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), zero_extend(self.ram.read16(address), 7))

  def lhu(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), zero_extend(self.ram.read16(address), 15))

  #Store instructions
  def sb(self, opcode):
    self.ram.write8(self.calc_store_address(opcode), self.reg(opcode.rs2()) & 0xFF)
      
  def sh(self, opcode):
    self.ram.write16(self.calc_store_address(opcode), self.reg(opcode.rs2()) & 0xFFFF)

  def sw(self, opcode):
    self.ram.write32(self.calc_store_address(opcode), self.reg(opcode.rs2()))

  def lui(self, opcode):
    self.set_reg(opcode.rd(), opcode.U())

  def auipc(self, opcode):
    self.set_reg(opcode.rd(), self.pc + opcode.U())

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
    return self.op_integer & 0xFFFFF000
