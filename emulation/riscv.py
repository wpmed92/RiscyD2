from bus import *
from util import *

#32-bit mode
XLEN = 32
MASK_XLEN = 0xFFFFFFFF

class RiscV:
  def __init__(self, bus):
    self.bus = bus
    self.registers = [0] * XLEN
    self.pc = 0
    self.cycle_counter = 0

    self.jump_table_main = {
      0b0010011: self.exe_integer_i,
      0b0110011: self.exe_integer_r,
      0b0110111: self.lui,
      0b0010111: self.auipc,
      0b1101111: self.jal,
      0b1100111: self.jalr,
      0b1100011: self.exe_control_flow,
      0b0000011: self.exe_load,
      0b0100011: self.exe_store,
      0b1110011: self.exe_system
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
      0b0000000_000: self.add,
      0b0100000_000: self.sub,
      0b0000001_000: self.mul,
      0b0000000_001: self.sll,
      0b0000001_001: self.mulh,
      0b0000000_010: self.slt,
      0b0000001_010: self.mulhsu,
      0b0000000_011: self.sltu,
      0b0000001_011: self.mulhu,
      0b0000000_100: self.xor,
      0b0000001_100: self.div,
      0b0000000_101: self.srl,
      0b0100000_101: self.sra,
      0b0000001_101: self.divu,
      0b0000000_110: self._or,
      0b0000001_110: self.rem,
      0b0000000_111: self._and,
      0b0000001_111: self.remu
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

    #System calls
    self.jump_table_system = {
      0b010: self.csrrs
    }

  def print_regs(self):
    reg_debug = ""

    for i in range(0, 32):
      reg_debug += "r" + str(i) + "=" + str(self.registers[i]) + "    "

    print("Registers")
    print("---------")
    print(reg_debug)


  def step(self):
    self.cycle_counter += 1
    op_integer = self.fetch()
    op_decoded = self.decode(op_integer)

    try:
      self.execute(op_decoded)
      self.pc += 4
      #print(f'pc={self.pc}')
    except KeyError:
      return False

    return True

  def fetch(self):
    return self.bus.read(32, self.pc)

  def decode(self, op_integer):
    return Opcode(op_integer)

  def execute(self, opcode):
    self.jump_table_main[opcode.op()](opcode)

  def exe_system(self, opcode):
    self.jump_table_system[opcode.funct3()](opcode)

  def exe_integer_i(self, opcode):
    self.jump_table_integer_i[opcode.funct3()](opcode)

  def exe_integer_r(self, opcode):
    self.jump_table_integer_r[opcode.funct7_3()](opcode)

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

  #TODO: Support more csrs
  def csr(self, adr):
    if adr == 0xC00:
      return self.cycle_counter & 0xFFFFFFFF
    elif adr == 0xC80:
      return (self.cycle_counter >> 32) & 0xFFFFFFFF
    else:
      return 0

  def csrrs(self, opcode):
    self.set_reg(opcode.rd(), self.csr(opcode.imm12()))

  #Integer Computational Instructions
  #Either R-type (register + register), or I-type (register + immediate)
  def addi(self, opcode):
    self.set_reg(opcode.rd(), (sign_extend(opcode.imm12(), 11) + self.reg(opcode.rs1())))
  
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
    self.pc += to_signed(sign_extend(opcode.J(), 20)) - 4

  def jalr(self, opcode):
    self.set_reg(opcode.rd(), self.pc + 4)
    self.pc = self.reg(opcode.rs1()) + to_signed(sign_extend(opcode.imm12(), 11)) - 4

  #Branch instructions
  #B-type, +/- 4 KiB
  def set_branch_target(self, opcode):
    self.pc = to_signed(sign_extend(opcode.B(), 12)) + self.pc
    self.pc -= 4

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
    #print(f'base={base}, offset={offset}')
    return base + to_signed(offset)

  def calc_store_address(self, opcode):
    offset = sign_extend(opcode.S(), 11)
    base = self.reg(opcode.rs1())
    return base + to_signed(offset)

  def lb(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), sign_extend(self.bus.read(8, address), 7))

  def lh(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), sign_extend(self.bus.read(16, address), 15))

  def lw(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), self.bus.read(32, address))

  def lbu(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), zero_extend(self.bus.read(8, address), 7))

  def lhu(self, opcode):
    address = self.calc_load_address(opcode)
    self.set_reg(opcode.rd(), zero_extend(self.bus.read(16, address), 15))

  #Store instructions
  def sb(self, opcode):
    self.bus.write(8, self.calc_store_address(opcode), self.reg(opcode.rs2()) & 0xFF)
      
  def sh(self, opcode):
    self.bus.write(16, self.calc_store_address(opcode), self.reg(opcode.rs2()) & 0xFFFF)

  def sw(self, opcode):
    self.bus.write(32, self.calc_store_address(opcode), self.reg(opcode.rs2()))

  def lui(self, opcode):
    self.set_reg(opcode.rd(), opcode.U())

  def auipc(self, opcode):
    self.set_reg(opcode.rd(), self.pc + opcode.U())

  #M-extension
  #place lower bits
  def mul(self, opcode):
    rs1_val = self.reg(opcode.rs1())
    rs2_val = self.reg(opcode.rs2())
    self.set_reg(opcode.rd(), rs1_val * rs2_val)

  #place higher bits: signed x signed
  def mulh(self, opcode):
    rs1_val = to_signed(self.reg(opcode.rs1()))
    rs2_val = to_signed(self.reg(opcode.rs2()))
    self.set_reg(opcode.rd(), (rs1_val * rs2_val) >> 32)

  #place higher bits: signed x unsigned
  def mulhsu(self, opcode):
    rs1_val = to_signed(self.reg(opcode.rs1()))
    rs2_val = self.reg(opcode.rs2())
    self.set_reg(opcode.rd(), (rs1_val * rs2_val) >> 32)

  #place higher bits: unsigned x unsigned
  def mulhu(self, opcode):
    rs1_val = self.reg(opcode.rs1())
    rs2_val = self.reg(opcode.rs2())
    self.set_reg(opcode.rd(), (rs1_val * rs2_val) >> 32)

  def div(self, opcode):
    rs1_val = to_signed(self.reg(opcode.rs1()))
    rs2_val = to_signed(self.reg(opcode.rs2()))
    rs1_sign_bit = (rs1_val >> 31) & 0b1
    rs2_sign_bit = (rs2_val >> 31) & 0b1
    abs_divisor = 0
    abs_dividend = 0

    if rs2_sign_bit:
      abs_divisor = -rs2_val
    else:
      abs_divisor = rs2_val

    if rs1_sign_bit:
      abs_dividend = -rs1_val
    else:
      abs_dividend = rs1_val

    u_result = abs_dividend // abs_divisor

    if (rs1_sign_bit ^ rs2_sign_bit):
      self.set_reg(opcode.rd(), -u_result)
    else:
      self.set_reg(opcode.rd(), u_result)

  def divu(self, opcode):
    rs1_val = self.reg(opcode.rs1())
    rs2_val = self.reg(opcode.rs2())
    self.set_reg(opcode.rd(), rs1_val // rs2_val)

  def rem(self, opcode):
    rs1_val = to_signed(self.reg(opcode.rs1()))
    rs2_val = to_signed(self.reg(opcode.rs2()))
    rs1_sign_bit = (rs1_val >> 31) & 0b1
    rs2_sign_bit = (rs2_val >> 31) & 0b1
    abs_divisor = 0
    abs_dividend = 0

    if rs2_sign_bit:
      abs_divisor = -rs2_val
    else:
      abs_divisor = rs2_val

    if rs1_sign_bit:
      abs_dividend = -rs1_val
    else:
      abs_dividend = rs1_val

    u_result = abs_dividend % abs_divisor

    if (rs1_sign_bit ^ rs2_sign_bit):
      self.set_reg(opcode.rd(), -u_result)
    else:
      self.set_reg(opcode.rd(), u_result)

  def remu(self, opcode):
    rs1_val = self.reg(opcode.rs1())
    rs2_val = self.reg(opcode.rs2())
    self.set_reg(opcode.rd(), rs1_val % rs2_val)

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

  def funct7_3(self):
    return self.funct3() | (self.funct7() << 3)

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
