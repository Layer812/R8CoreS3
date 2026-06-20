import serial
import time
import sys

# Open COM5
ser = serial.Serial()
ser.port = 'COM5'
ser.baudrate = 115200
ser.timeout = 1

try:
    ser.open()
except Exception as e:
    print(f"Error opening port: {e}")
    sys.exit(1)

# ESP32S3 hardware reset sequence:
# 1. Pull RTS low (EN = 0)
# 2. Pull DTR high (GPIO0 = 1)
# 3. Wait
# 4. Release RTS (EN = 1) -> boot into flash
print("Resetting ESP32S3...")
ser.setDTR(False)
ser.setRTS(True)
time.sleep(0.2)
ser.setDTR(False)
ser.setRTS(False)
time.sleep(0.2)

print("Reading serial output (Press Ctrl+C to stop)...")
try:
    # Print any initial data in buffer
    if ser.in_waiting > 0:
        data = ser.read(ser.in_waiting)
        sys.stdout.write(data.decode('utf-8', errors='replace'))
        sys.stdout.flush()
        
    while True:
        if ser.in_waiting > 0:
            data = ser.read(ser.in_waiting)
            sys.stdout.write(data.decode('utf-8', errors='replace'))
            sys.stdout.flush()
        time.sleep(0.01)
except KeyboardInterrupt:
    print("\nStopping...")
finally:
    ser.close()
