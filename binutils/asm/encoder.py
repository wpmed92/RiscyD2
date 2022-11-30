class Encoder:
  def __init__(self, ast):
    self.ast = ast
    self.op_i = 0b0010011
    self.op_r = 0b0110011
    self.op_load = 0b0000011
    self.op_branch = 0b1100011
    self.op_store = 0b0100011
    self.op_jal = 0b1101111
    self.op_jalr = 0b1100111
    self.op_lui = 0b0110111
    self.op_auipc = 0b0010111
    self.op_system = 0b1110011

    self.encode_table = {
      #Arithmetic instructions (I-type)
      "addi" : { "op": self.op_i, "funct3": 0b000, "funct7": 0,         "encode": self.encode_i_common },
      "slti":  { "op": self.op_i, "funct3": 0b010, "funct7": 0,         "encode": self.encode_i_common },
      "sltiu": { "op": self.op_i, "funct3": 0b011, "funct7": 0,         "encode": self.encode_i_common },
      "xori":  { "op": self.op_i, "funct3": 0b100, "funct7": 0,         "encode": self.encode_i_common },
      "ori":   { "op": self.op_i, "funct3": 0b110, "funct7": 0,         "encode": self.encode_i_common },
      "andi":  { "op": self.op_i, "funct3": 0b111, "funct7": 0,         "encode": self.encode_i_common },
      "slli":  { "op": self.op_i, "funct3": 0b001, "funct7": 0,         "encode": self.encode_i_shift_left  },
      "srli":  { "op": self.op_i, "funct3": 0b101, "funct7": 0,         "encode": self.encode_i_shift_right },
      "srai":  { "op": self.op_i, "funct3": 0b101, "funct7": 0b0100000, "encode": self.encode_i_shift_right },

      #Arithemtic instructions (R-type)
      "add":   { "op": self.op_r, "funct3": 0b000, "funct7": 0,         "encode": self.encode_r_common },
      "sub":   { "op": self.op_r, "funct3": 0b000, "funct7": 0b0100000, "encode": self.encode_r_common },
      "sll":   { "op": self.op_r, "funct3": 0b001, "funct7": 0,         "encode": self.encode_r_common },
      "slt":   { "op": self.op_r, "funct3": 0b010, "funct7": 0,         "encode": self.encode_r_common },
      "sltu":  { "op": self.op_r, "funct3": 0b011, "funct7": 0,         "encode": self.encode_r_common },
      "xor":   { "op": self.op_r, "funct3": 0b100, "funct7": 0,         "encode": self.encode_r_common },
      "srl":   { "op": self.op_r, "funct3": 0b101, "funct7": 0,         "encode": self.encode_r_common },
      "sra":   { "op": self.op_r, "funct3": 0b101, "funct7": 0b0100000, "encode": self.encode_r_common },
      "or":    { "op": self.op_r, "funct3": 0b110, "funct7": 0,         "encode": self.encode_r_common },
      "and":   { "op": self.op_r, "funct3": 0b111, "funct7": 0,         "encode": self.encode_r_common },

      #RV32M
      "mul":    { "op": self.op_r, "funct3": 0b000, "funct7": 0b0000001, "encode": self.encode_r_common },
      "mulh":   { "op": self.op_r, "funct3": 0b001, "funct7": 0b0000001, "encode": self.encode_r_common },
      "mulhsu": { "op": self.op_r, "funct3": 0b010, "funct7": 0b0000001, "encode": self.encode_r_common },
      "mulhu":  { "op": self.op_r, "funct3": 0b011, "funct7": 0b0000001, "encode": self.encode_r_common },
      "div":    { "op": self.op_r, "funct3": 0b100, "funct7": 0b0000001, "encode": self.encode_r_common },
      "divu":   { "op": self.op_r, "funct3": 0b101, "funct7": 0b0000001, "encode": self.encode_r_common },
      "rem":    { "op": self.op_r, "funct3": 0b110, "funct7": 0b0000001, "encode": self.encode_r_common },
      "remu":   { "op": self.op_r, "funct3": 0b111, "funct7": 0b0000001, "encode": self.encode_r_common },

      #Jump instructions (J-type)
      "jal":  { "op": self.op_jal,  "funct3": 0b000, "funct7": 0,       "encode": self.encode_jal },
      "jalr": { "op": self.op_jalr, "funct3": 0b000, "funct7": 0,       "encode": self.encode_i_common },

      #LUI, AUIPC (U-type)
      "lui":   { "op": self.op_lui,  "funct3": 0b000, "funct7": 0,      "encode": self.encode_u_type },
      "auipc": { "op": self.op_auipc, "funct3": 0b000, "funct7": 0,      "encode": self.encode_u_type },

      #Branch instructions (B-type)
      "beq":  { "op": self.op_branch, "funct3": 0b000, "funct7": 0, "encode": self.encode_branch_common },
      "bne":  { "op": self.op_branch, "funct3": 0b001, "funct7": 0, "encode": self.encode_branch_common },
      "blt":  { "op": self.op_branch, "funct3": 0b100, "funct7": 0, "encode": self.encode_branch_common },
      "bge":  { "op": self.op_branch, "funct3": 0b101, "funct7": 0, "encode": self.encode_branch_common },
      "bltu": { "op": self.op_branch, "funct3": 0b110, "funct7": 0, "encode": self.encode_branch_common },
      "bgeu": { "op": self.op_branch, "funct3": 0b111, "funct7": 0, "encode": self.encode_branch_common },

      #Load instructions (I-type)
      "lb":  { "op": self.op_load, "funct3": 0b000, "funct7": 0, "encode": self.encode_i_common },
      "lh":  { "op": self.op_load, "funct3": 0b001, "funct7": 0, "encode": self.encode_i_common },
      "lw":  { "op": self.op_load, "funct3": 0b010, "funct7": 0, "encode": self.encode_i_common },
      "lbu": { "op": self.op_load, "funct3": 0b100, "funct7": 0, "encode": self.encode_i_common },
      "lhu": { "op": self.op_load, "funct3": 0b101, "funct7": 0, "encode": self.encode_i_common },

      #Store instructions (S-type)
      "sb": { "op": self.op_store, "funct3": 0b000, "funct7": 0, "encode": self.encode_store_common },
      "sh": { "op": self.op_store, "funct3": 0b001, "funct7": 0, "encode": self.encode_store_common },
      "sw": { "op": self.op_store, "funct3": 0b010, "funct7": 0, "encode": self.encode_store_common },

      #System
      "csrrs": { "op": self.op_system, "funct3": 0b010, "funct7": 0, "encode": self.encode_i_common }
    }

  def to_little_endian_4byte_hex(self, num):
    return ("{:02x}".format((num >> 24) & 255) + 
            "{:02x}".format((num >> 16) & 255) +
            "{:02x}".format((num >> 8) & 255) +
            "{:02x}".format(num & 255)
            )

  def encode(self, asm_source_path, bin_path):
    if not bin_path:
      bin_path = asm_source_path.rsplit(".", 1)[0] + ".o"
      mem_path = asm_source_path.rsplit(".", 1)[0] + ".mem"
    else:
      mem_path = bin_path.rsplit(".", 1)[0] + ".mem"

    out_bin = open(bin_path, "wb")
    out_mem = open(mem_path, "w")

    for stmt in self.ast:
      encoded_stmt = self.encode_stmt(stmt)
      hex_line = self.to_little_endian_4byte_hex(encoded_stmt)
      out_bin.write(encoded_stmt.to_bytes(4, byteorder='little', signed=False))
      out_mem.write(hex_line)
      out_mem.write("\n")

    out_bin.close()
    out_mem.close()

  def encode_stmt(self, stmt):
    entry = self.encode_table[stmt.name]
    return entry["encode"](entry, stmt)

  #common I-type encoding
  def encode_i_common(self, entry, stmt):
    if (stmt.imm > 4095):
      raise Exception("Immediate value is out of range (-1024, 1023): " + str(stmt.imm))
    
    op = entry["op"]
    funct3 = entry["funct3"]
    imm12 = stmt.imm & 0b111111111111

    return (op | (stmt.rd << 7) | (funct3 << 12) | (stmt.rs1 << 15) | (imm12 << 20))

  #specialized I-type encoding (shift)
  def encode_i_shift_left(self, entry, stmt):
    stmt.imm = stmt.imm & 0b000000011111
    return self.encode_i_common(entry, stmt)

  def encode_i_shift_right(self, entry, stmt):
    stmt.imm = (stmt.imm & 0b000000011111) | (entry["funct7"] << 5)
    return self.encode_i_common(entry, stmt)

  #common R-type encoding (no special case)
  def encode_r_common(self, entry, stmt):
    op = entry["op"]
    funct3 = entry["funct3"]
    funct7 = entry["funct7"]

    return op | (stmt.rd << 7) | (funct3 << 12) | (stmt.rs1 << 15) | (stmt.rs2 << 20) | (funct7 << 25)

  #J-type
  def encode_jal(self, entry, stmt):
    op = entry["op"]
    imm10_1 = (stmt.imm >> 1) & 0b1111111111
    imm11 = (stmt.imm >> 11) & 0b1
    imm19_12 = (stmt.imm >> 12) & 0b11111111
    imm20 = (stmt.imm >> 20) & 0b1

    return op | (stmt.rd  << 7) | (imm19_12 << 12) | (imm11 << 20) | (imm10_1 << 21) | (imm20 << 31)

  #B-type
  def encode_branch_common(self, entry, stmt):
    op = entry["op"]
    funct3 = entry["funct3"]

    imm4_1 = (stmt.imm >> 1) & 0b1111
    imm10_5 = (stmt.imm >> 5) & 0b111111
    imm11 = (stmt.imm >> 11) & 0b1
    imm12 = (stmt.imm >> 12) & 0b1

    return op | (imm11 << 7) | (imm4_1 << 8) | (funct3 << 12) | (stmt.rs1 << 15) | (stmt.rs2 << 20) | (imm10_5 << 25) | (imm12 << 31)

  #Store (S-type)
  def encode_store_common(self, entry, stmt):
    op = entry["op"]
    funct3 = entry["funct3"]

    imm4_0 = stmt.imm & 0b11111
    imm11_5 = (stmt.imm >> 5) & 0b1111111

    return op | (imm4_0 << 7) | (funct3 << 12) | (stmt.rs1 << 15) | (stmt.rs2 << 20) | (imm11_5 << 25)

  def encode_u_type(self, entry, stmt):
    op = entry["op"]
    imm_U = stmt.imm << 12

    return op | (stmt.rd << 7) | (imm_U)