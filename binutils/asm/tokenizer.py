from enum import Enum
import re

class TokenType(Enum):
  OP_KEYWORD = 1,
  IDENTIFIER = 2,
  REGISTER_INDEX = 3,
  SEMI_COLON = 4,
  COLON = 5,
  DOT = 6,
  COMMA = 7,
  OPEN_PARENTH = 8,
  CLOSED_PARENTH = 9,
  NUMBER = 10

  def __str__(self):
    return '%s' % self.value

class Token:
  def __init__(self, token, token_type, pos, val = None):
    self.tok_str = token
    self.token_type = token_type
    self.pos = pos
    self.val = val
  
class Tokenizer:
  def __init__(self, line, num_line):
    self.token_stream = []
    self.current_token = None
    self.token_pos = 0
    self.line = line
    self.num_line = num_line
    self.op_keywords = {
      "addi": True,
      "slti": True,
      "sltiu": True,
      "xori": True,
      "ori": True,
      "andi": True,
      "slli": True,
      "srli": True,
      "srai": True,
      "add": True,
      "sub": True,
      "sll": True,
      "slt": True,
      "sltu": True,
      "xor": True,
      "srl": True,
      "sra": True,
      "or": True,
      "and": True,
      "lb": True,
      "lh": True,
      "lw": True,
      "lbu": True,
      "lhu": True,
      "sb": True,
      "sh": True,
      "sw": True,
      "beq": True,
      "bne": True,
      "blt": True,
      "bltu": True,
      "bge": True,
      "bgeu": True,
      "jal": True,
      "jalr": True,
      "lui": True,
      "auipc": True,
      "li": True
    }
    
    self.abi_id_to_index = {
      "zero": 0, 	#hardwired to 0, ignores writes	n/a
      "ra": 1, #return address for jumps	no
      "sp":	2, #stack pointer	yes
      "gp": 3,	#global pointer	n/a
      "tp":	4, #thread pointer	n/a
      "t0":	5, #temporary register 0	no
      "t1": 6, #temporary register 1	no
      "t2": 7, #temporary register 2	no
      "s0": 8, #saved register 0 or frame pointer	yes
      "fp": 8, #saved register 0 or frame pointer	yes
      "s1": 9, #saved register 1	yes
      "a0": 10,	#return value or function argument 0	no
      "a1": 11, #return value or function argument 1	no
      "a2": 12,	#function argument 2	no
      "a3": 13, #function argument 3	no
      "a4": 14, #function argument 4	no
      "a5": 15,	#function argument 5	no
      "a6": 16,	#function argument 6	no
      "a7": 17, #function argument 7	no
      "s2": 18,	#saved register 2	yes
      "s3": 19,	#saved register 3	yes
      "s4": 20,	#saved register 4	yes
      "s5": 21,	#saved register 5	yes
      "s6": 22,	#saved register 6	yes
      "s7": 23,	#saved register 7	yes
      "s8": 24,	#saved register 8	yes
      "s9": 25,	#saved register 9	yes
      "s10": 26,	#saved register 10	yes
      "s11": 27,	#saved register 11	yes
      "t3": 28,	#temporary register 3	no
      "t4": 29,	#temporary register 4	no
      "t5": 30,	#temporary register 5	no
      "t6": 31 #temporary register 6	no
    }

  def is_terminal(self, char):
    return (char == ".") or (char == ":") or (char == " ") or (char == ",") or (char == "(") or (char == ")")

  def cur_char(self):
    return self.line[self.token_pos]

  def skip_spaces(self):
    cur_pos = self.token_pos

    while (self.cur_char() == " ") and (self.token_pos < len(self.line)):
      self.advance_token()

    self.token_pos -= int(self.token_pos != cur_pos)

  def advance_token(self):
    self.token_pos += 1

  def skip_line(self):
    self.token_pos = len(self.line) - 1

  def is_identifier(self, token):
    return token.isidentifier()

  def is_op_keyword(self, token):
    return token in self.op_keywords

  def is_int(self, elem):
    try:
      int(elem)
      return True
    except ValueError:
      return False
  
  def get_reg_id(self, token):
    if token in self.abi_id_to_index:
      return self.abi_id_to_index[token]
    elif token.startswith("r") or token.startswith("x"):
      if len(token) == 2 and self.is_int(token[1]):
        return int(token[1])
      elif len(token) == 3 and self.is_int(token[1:3:1]) and int(token[1:3:1]) < 32:
          return int(token[1:3:1])
      else:
        return None
    else:
      return None

  #support decimal, hex, and binary numbers
  def get_number(self, token):
    if re.match("^[-+]?[0-9]+$", token):
      return int(token)
    elif re.match("^[-+]?0[xX][0-9a-fA-F]+", token):
      return int(token, 0)
    elif re.match("^[-+]?0[b][0-1]+$", token):
      return int(token, 0)
    else:
      None

  def get_string_token(self, token):
    if self.get_number(token) != None:
      num = self.get_number(token)
      return Token(token, TokenType.NUMBER, (self.num_line, self.token_pos), num)
    elif self.is_op_keyword(token):
      return Token(token, TokenType.OP_KEYWORD, (self.num_line, self.token_pos))
    elif self.get_reg_id(token) != None:
      reg_index = self.get_reg_id(token)
      return Token(token, TokenType.REGISTER_INDEX, (self.num_line, self.token_pos), reg_index)
    elif self.is_identifier(token):
      return Token(token, TokenType.IDENTIFIER, (self.num_line, self.token_pos))
    else:
      #Unknown token
      return None
    
  def print_token_list(self):
    for token in self.token_stream:
      print("Val:" + str(token.val) + ", type:" + str(token.token_type) + ", line: " + str(token.pos[0]) + ", col: " + str(token.pos[1]))

  def tokenize(self):
    self.cur_string = ""

    while (self.token_pos < len(self.line)) and (self.cur_char() != ";"):
      if self.is_terminal(self.cur_char()):

        if self.cur_string:
          det_token = self.get_string_token(self.cur_string)
          self.token_stream.append(det_token)
          self.cur_string = ""
        
        if self.cur_char() == ".":
          self.token_stream.append(Token(self.cur_char(), TokenType.DOT, (self.num_line, self.token_pos)))
        elif self.cur_char() == ":":
          self.token_stream.append(Token(self.cur_char(), TokenType.COLON, (self.num_line, self.token_pos)))
        elif self.cur_char() == ",":
          self.token_stream.append(Token(self.cur_char(), TokenType.COMMA, (self.num_line, self.token_pos)))
        elif self.cur_char() == "(":
          self.token_stream.append(Token(self.cur_char(), TokenType.OPEN_PARENTH, (self.num_line, self.token_pos)))
        elif self.cur_char() == ")":
          self.token_stream.append(Token(self.cur_char(), TokenType.CLOSED_PARENTH, (self.num_line, self.token_pos)))


        self.skip_spaces()
      else:
        self.cur_string += self.cur_char()

      self.advance_token()

    if self.cur_string:
      det_token = self.get_string_token(self.cur_string)
      self.token_stream.append(det_token)
      self.cur_string = ""

    return self.token_stream