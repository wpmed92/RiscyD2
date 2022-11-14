import serial

with serial.Serial("/dev/tty.usbserial-210319B4A2F21", baudrate=9600, parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS, timeout=1000) as ser:
    s = ser.read(1)
    out = ""
    
    while (s != b'\x00'):
        out += s.decode("utf-8")
        s = ser.read(1)

    print(f'Riscy says "{out}"')
    
