import serial
import time
import os
import argparse

parser = argparse.ArgumentParser(description='Util to send exe to RiscyD2')
parser.add_argument('-i', dest='inFile', type=str, help='Path to exe')

#replace with your board's id
device_id = "/dev/tty.usbserial-210319B4A2F21"

ser = serial.Serial(
    device_id,
    baudrate = 9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=0
)

def send_exe(path):
  exe_bytes = []

  with open(path, "rb") as exe:
      byte = exe.read(1)
      exe_bytes.append(int.from_bytes(byte, "little"))

      while byte:
          byte = exe.read(1)
          if (byte != b''):
            exe_bytes.append(int.from_bytes(byte, "little"))

  # First 4 bytes are size of the exe
  print("Len=" + str(len(exe_bytes)))
  exe_bytes.insert(0, len(exe_bytes))
  exe_bytes.insert(1, 0)
  exe_bytes.insert(2, 0)
  exe_bytes.insert(3, 0)

  ser.write(exe_bytes)

  time.sleep(2)

if __name__ == "__main__":
  args = parser.parse_args()

  if not os.path.exists(args.inFile):
    print(f"File does not exist at path {args.inFile}")
  else:
    send_exe(args.inFile)
    ser.close()
