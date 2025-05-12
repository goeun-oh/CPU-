import serial
import threading

PORT = '/dev/ttyUSB1'
BAUDRATE = 9600

ser = serial.Serial(PORT, BAUDRATE, timeout=0.5)

def receive_ascii():
    while True:
        if ser.in_waiting:
            raw_data = ser.read(1)
            if raw_data:
                print(f"RX ▶ {raw_data}  (HEX: {[hex(b) for b in raw_data]})")

recv_thread = threading.Thread(target=receive_ascii, daemon=True)
recv_thread.start()

print("TX ▶ ASCII 문자열을 입력하세요 (Ctrl+C로 종료)")
try:
    while True:
        msg = input()
        if msg:
            ser.write(msg.encode('ascii'))  # ✅ 줄바꿈 제거
except KeyboardInterrupt:
    print("\n[종료]")
    ser.close()
