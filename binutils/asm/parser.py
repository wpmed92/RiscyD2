from enum import Enum
from tokenizer import TokenType

class OpType(Enum):
  ARITHMETIC_R = 1,
  ARITHMETIC_I = 2,
  LOAD = 3,
  STORE = 4,
  JAL = 5,
  JALR = 6,
  BRANCH = 7,
  U_TYPE = 8

class OpStatement:
  def __init__(self, name = None, rd = None, rs1 = None, rs2 = None, imm = None, _type = None, is_pseudo = False):
    self.name = name
    self.rd = rd
    self.rs1 = rs1
    self.rs2 = rs2
    self.imm = imm
    self.type = _type
    self.is_pseudo = is_pseudo
    self.has_offset = False
    self.pc = 0

class Parser:
  def __init__(self, token_stream):
    self.token_stream = token_stream
    self.token_pos = 0
    self.ast_list = []
    self.cur_address = 0
    self.symbol_table = {}
    self.op_metadata = {
      #Arithemtic I-type
      "addi": { "type": OpType.ARITHMETIC_I},
      "slti": { "type": OpType.ARITHMETIC_I},
      "sltiu": { "type": OpType.ARITHMETIC_I},
      "xori": { "type": OpType.ARITHMETIC_I},
      "ori": { "type": OpType.ARITHMETIC_I },
      "andi": { "type": OpType.ARITHMETIC_I },
      "slli": { "type": OpType.ARITHMETIC_I },
      "srli": { "type": OpType.ARITHMETIC_I },
      "srai": { "type": OpType.ARITHMETIC_I },
      #Arithmetic R-type
      "add": { "type": OpType.ARITHMETIC_R },
      "sub": { "type": OpType.ARITHMETIC_R },
      "sll": { "type": OpType.ARITHMETIC_R },
      "slt": { "type": OpType.ARITHMETIC_R },
      "sltu": { "type": OpType.ARITHMETIC_R },
      "xor": { "type": OpType.ARITHMETIC_R },
      "srl": { "type": OpType.ARITHMETIC_R },
      "sra": { "type": OpType.ARITHMETIC_R },
      "or": { "type": OpType.ARITHMETIC_R },
      "and": { "type": OpType.ARITHMETIC_R },
      #Load I-type
      "lb": {"type": OpType.LOAD},
      "lh": {"type": OpType.LOAD},
      "lw": {"type": OpType.LOAD},
      "lhu": {"type": OpType.LOAD},
      "lbu": {"type": OpType.LOAD},
      #Store S-type
      "sw": {"type": OpType.STORE},
      "sh": {"type": OpType.STORE},
      "sb": {"type": OpType.STORE},
      #Branch B-type
      "beq": {"type": OpType.BRANCH},
      "bne": {"type": OpType.BRANCH},
      "blt": {"type": OpType.BRANCH},
      "bltu": {"type": OpType.BRANCH},
      "bge": {"type": OpType.BRANCH},
      "bgeu": {"type": OpType.BRANCH},
      #Jump J-type
      "jal": {"type": OpType.JAL},
      "jalr": {"type": OpType.JALR},
      #U-type
      "lui": {"type": OpType.U_TYPE},
      "auipc": {"type": OpType.U_TYPE}
    }

  def parse_op_statement(self):
    if self.cur_token().token_type != TokenType.OP_KEYWORD:
      return None

    op_name = self.cur_token().tok_str
    op_type =  self.op_metadata[op_name]["type"]

    stmt = OpStatement()
    stmt.type = op_type
    stmt.name = op_name

    if op_type == OpType.ARITHMETIC_I:
      stmt = self.parse_arithmetic(stmt, is_i_type=True)
    elif op_type == OpType.ARITHMETIC_R:
      stmt = self.parse_arithmetic(stmt, is_i_type=False)
    elif op_type == OpType.LOAD:
      stmt = self.parse_load_store_jalr(stmt, is_load_or_jalr=True)
    elif op_type == OpType.STORE:
      stmt = self.parse_load_store_jalr(stmt, is_load_or_jalr=False)
    elif op_type == OpType.BRANCH:
      stmt = self.parse_branch(stmt)
    elif op_type == OpType.JAL:
      stmt = self.parse_jal(stmt)
    elif op_type == OpType.JALR:
      stmt = self.parse_load_store_jalr(stmt, is_load_or_jalr=True)
    elif op_type == OpType.U_TYPE:
      stmt = self.parse_u_type(stmt)
    else:
      raise Exception("Unknown statement: " + str(op_type))
    
    self.advance_token()

    return stmt

  def parse_arithmetic(self, stmt, is_i_type):
    #parse destination register, rd
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rd = self.cur_token().val

    #parse source register, rs1
    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()
    
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rs1 = self.cur_token().val

    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()

    if is_i_type:
      if self.peek_token().token_type == TokenType.NUMBER:
        self.advance_token()
        stmt.imm = self.cur_token().val
      else:
        raise Exception("Expected a number")
    else:
      if self.peek_token().token_type == TokenType.REGISTER_INDEX:
        self.advance_token()
        stmt.rs2 = self.cur_token().val
      else:
        raise Exception("Expected a register identifier")

    return stmt

  #ld ra, 0(sp)
  #sb ra, 0(sp)
  def parse_load_store_jalr(self, stmt, is_load_or_jalr):
    #parse destination register, rd
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    if is_load_or_jalr:
      stmt.rd = self.cur_token().val
    else:
      stmt.rs2 = self.cur_token().val

    #parse offset, immediate
    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()
    
    if self.peek_token().token_type != TokenType.NUMBER:
      raise Exception("Expected a number")

    self.advance_token()

    stmt.imm = self.cur_token().val

    #parse base, rs1
    if self.peek_token().token_type != TokenType.OPEN_PARENTH:
      raise Exception("Expected a '(', got: " + str(self.peek_token().val))

    self.advance_token()

    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rs1 = self.cur_token().val

    if self.peek_token().token_type != TokenType.CLOSED_PARENTH:
      raise Exception("Expected a ')'")

    self.advance_token()

    return stmt

  #bge t0, t2, loop_end
  def parse_branch(self, stmt):
    #parse source register, rs1
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rs1 = self.cur_token().val

    #parse source register, rs2
    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()
    
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rs2 = self.cur_token().val

    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()

    if self.peek_token().token_type == TokenType.NUMBER:
      self.advance_token()
      stmt.imm = self.cur_token().val
    elif self.peek_token().token_type == TokenType.IDENTIFIER:
      self.advance_token()
      stmt.imm = self.cur_token().tok_str
    else:
      raise Exception("Expected a number")
    
    return stmt

  def parse_jal(self, stmt):
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rd = self.cur_token().val

    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()

    #immediate
    if self.peek_token().token_type == TokenType.NUMBER:
      self.advance_token()

      stmt.imm = self.cur_token().val
    #offset
    elif self.peek_token().token_type == TokenType.IDENTIFIER:
      self.advance_token()
      stmt.has_offset = True
      stmt.imm = self.cur_token().tok_str
    else:
      raise Exception("Expected a number or an identifier")

    return stmt

  def parse_u_type(self, stmt):
    if self.peek_token().token_type != TokenType.REGISTER_INDEX:
      raise Exception("Expected a register identifier")

    self.advance_token()

    stmt.rd = self.cur_token().val

    if self.peek_token().token_type != TokenType.COMMA:
      raise Exception("Expected a comma")

    self.advance_token()

    if self.peek_token().token_type != TokenType.NUMBER:
      raise Exception("Expected a number")

    self.advance_token()

    stmt.imm = self.cur_token().val

    return stmt

  def peek_token(self):
    return self.token_stream[self.token_pos + 1]

  def advance_token(self):
    self.token_pos += 1

  def cur_token(self):
    return self.token_stream[self.token_pos]

  def parse(self):
    while self.token_pos < len(self.token_stream):
      ast = self.parse_op_statement()

      if ast != None:
        self.ast_list.append(ast)
        ast.pc = self.cur_address
        self.cur_address += 4

    return self.ast_list
    