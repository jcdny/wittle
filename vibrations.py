import serial
import binascii

# Configuration
PORT = '/dev/cu.usbserial-840'        # Replace with your serial port (e.g., '/dev/ttyUSB0' on Linux/Mac or 'COM3' on Windows)
BAUDRATE = 230400      # Adjust to match your device's settings
TIMEOUT = 5          # Timeout in seconds
CHUNK_SIZE = 1024

SEP = bytearray.fromhex('500306')


def read_and_parse_serial(port, baudrate, timeout):
    try:
        with serial.Serial(port, baudrate, timeout=timeout) as ser:
            print(f"Listening on {port} at {baudrate} baud...\nPress Ctrl+C to stop.\n")

            buffer = bytearray()

            while True:
                chunk = ser.read(CHUNK_SIZE)
                if chunk:
                    buffer.extend(chunk)
                    while SEP in buffer:
                        line, _, buffer = buffer.partition(SEP)
                        packet = binascii.hexlify(line)
                        plen = len(line)
                        if plen == 8:
                            print(f"Received {plen}:{packet}")
                        else:
                            print(f"Received {plen}:{packet} SHORT")

    except serial.SerialException as e:
        print(f"Serial error: {e}")
    except KeyboardInterrupt:
        print("\nStopped by user.")

if __name__ == "__main__":
    read_and_parse_serial(PORT, BAUDRATE, TIMEOUT)
