import serial
import binascii

# Configuration
PORT = '/dev/cu.usbserial-840'        # Replace with your serial port (e.g., '/dev/ttyUSB0' on Linux/Mac or 'COM3' on Windows)
BAUDRATE = 230400      # Adjust to match your device's settings
TIMEOUT = 5          # Timeout in seconds

def read_serial_data(port, baudrate, timeout, num_bytes):
    try:
        # Open the serial port
        with serial.Serial(port, baudrate, timeout=timeout) as ser:
            print(f"Opened serial port {port} at {baudrate} baud.")

            # Read data
            data = ser.read(num_bytes)
            print(f"Read {len(data)} bytes:")
            print(binascii.hexlify(data))

    except serial.SerialException as e:
        print(f"Error opening or reading from serial port: {e}")

if __name__ == "__main__":
    read_serial_data(PORT, BAUDRATE, TIMEOUT, 1024)
