
mask_32bit = 0xFFFFFFFF

def sign_extend(number, from_bit):
  sign_extended_val = 0
  sign_bit = number & (1 << from_bit)

  if sign_bit != 0:
    sign_extended_val = ((mask_32bit << from_bit) | number) & mask_32bit
  else:
    sign_extended_val = number & mask_32bit

  return sign_extended_val

def to_unsigned(number):
  return (number + (1 << 32))

def to_signed(n):
    n = n & 0xffffffff
    return (n ^ 0x80000000) - 0x80000000

def zero_extend(num, from_bit):
    return num


