# -*- coding: utf-8 -*-
"""
Notifications
-------------

Example showing how to add notifications to a characteristic and handle the responses.

Updated on 2019-07-03 by hbldh <henrik.blidh@gmail.com>

"""

import argparse
import asyncio
import logging
import binascii
import sys
import time
from datetime import datetime

from bleak import BleakClient, BleakScanner
from bleak.backends.characteristic import BleakGATTCharacteristic

logger = logging.getLogger(__name__)

# took this from https://github.com/DanielIzquierdo/WT901BLECL/blob/master/WT901BLECL.py
class GyroProcessor():
    def __init__(self, data=None):
        # TODO: differentiate between flags  of data
        # from the differents services that can be configured in the ble device

        # Assuming the packet data is for acceleration, angular velocity and angle Data
        # (Ignoring the packet header and flag bit)
        hex_data = data[2:]
        # It is requirement of the manufacturer to cast all values to signed short values,
        # but python doesnt have this data type, thats why the following transformation exists
        transformed_hex_values = [val if val <= 127 else (256-val)*-1 for val in hex_data]
        for i in range(0,3):
            if i == 0:
                # "Acceleration"
                self.ax = float((int(transformed_hex_values[i+1])<<8)| (int(transformed_hex_values[i]) & 255))/32768*(16*9.8)
                self.ay = float((int(transformed_hex_values[i+3])<<8)| (int(transformed_hex_values[i+2]) & 255))/32768*(16*9.8)
                self.az = float((int(transformed_hex_values[i+5])<<8)| (int(transformed_hex_values[i+4]) & 255))/32768*(16*9.8)

            if i == 1:
                # "Angular Velocity"
                self.wx = float((int(transformed_hex_values[i+6])<<8)| (int(transformed_hex_values[i+5]) & 255))/32768*2000
                self.wy = float((int(transformed_hex_values[i+8])<<8)| (int(transformed_hex_values[i+7]) & 255))/32768*2000
                self.wz = float((int(transformed_hex_values[i+10])<<8)| (int(transformed_hex_values[i+9]) & 255))/32768*2000

            if i == 2:
                # "Angles"
                self.rollx = float((int(transformed_hex_values[i+11])<<8)| (int(transformed_hex_values[i+10]) & 255))/32768*180
                self.pitchy = float((int(transformed_hex_values[i+13])<<8)| (int(transformed_hex_values[i+12]) & 255))/32768*180
                self.yawz = float((int(transformed_hex_values[i+15])<<8)| (int(transformed_hex_values[i+14]) & 255))/32768*180


def notification_handler(characteristic: BleakGATTCharacteristic, data: bytearray):
    """Simple notification handler which prints the data received."""
    processor = GyroProcessor(data)
    rollx = processor.rollx
    pitchy = processor.pitchy
    yawz = processor.yawz
    # timenow = time.strftime("%Y-%m-%d %H%M%S %f", time.localtime(time.time())),
    # timenow = datetime.now().strftime("%Y-%m-%d %H%M%S.%f")
    timenow = datetime.now().isoformat(timespec="milliseconds")
    logger.info("%s: %s", characteristic.description, binascii.hexlify(data))
    print("%-15s, %7.3f, %7.3f, %7.3f, %7.4f, %7.4f, %7.4f" % (timenow, rollx, pitchy, yawz, processor.ax, processor.ay, processor.az))


async def main(args: argparse.Namespace):
    logger.info("starting scan...")

    if args.address:
        device = await BleakScanner.find_device_by_address(
            args.address, cb=dict(use_bdaddr=args.macos_use_bdaddr)
        )
        if device is None:
            logger.error("could not find device with address '%s'", args.address)
            return
    else:
        device = await BleakScanner.find_device_by_name(
            args.name, cb=dict(use_bdaddr=args.macos_use_bdaddr)
        )
        if device is None:
            logger.error("could not find device with name '%s'", args.name)
            return

    logger.info("connecting to device...")

    async with BleakClient(device) as client:
        logger.info("Connected")

        await client.start_notify(args.characteristic, notification_handler)
        await asyncio.sleep(3600.0)
        await client.stop_notify(args.characteristic)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    device_group = parser.add_mutually_exclusive_group(required=True)

    device_group.add_argument(
        "--name",
        metavar="<name>",
        help="the name of the bluetooth device to connect to",
    )
    device_group.add_argument(
        "--address",
        metavar="<address>",
        help="the address of the bluetooth device to connect to",
    )

    parser.add_argument(
        "--macos-use-bdaddr",
        action="store_true",
        help="when true use Bluetooth address instead of UUID on macOS",
    )

    parser.add_argument(
        "characteristic",
        metavar="<notify uuid>",
        help="UUID of a characteristic that supports notifications",
    )

    parser.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="sets the log level to debug",
    )

    args = parser.parse_args()

    log_level = logging.DEBUG if args.debug else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)-15s %(name)-8s %(levelname)s: %(message)s",
    )

    asyncio.run(main(args))
