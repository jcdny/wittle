## scan a device across connection types

##for DEV in rtu:////dev/tty.usbserial-840
DEV=rtu:///dev/cu.usbserial-840
SPD=230400 ## from 4800 9600 19200 38400 57600 115200 230400
STOP=1
PARITY=none

ID=80

CMD="modbus --target $DEV --speed $SPD --stop-bits $STOP --parity $PARITY --timeout 2s suid:$ID"
## --endianness little
##$CMD rh:int16:0x33 repeat

if [ $SPD -ne 230400 ]; then
    echo Setting speed to 230400 with $CMD
    $CMD wr:uint16:0x69:0xb588
    $CMD wr:uint16:0x04:0x0007
    $CMD wr:uint16:0x00:0x0000
fi

## set cutoff
if false; then 
    $CMD wr:uint16:0x69:0xb588
    $CMD wr:uint16:0x65:100
    $CMD wr:uint16:0x63:5
    $CMD wr:uint16:0x64:0
    $CMD wr:uint16:0x00:0x0000
fi

## Need to restart at high baud
SPD=230400
CMD="modbus --target $DEV --speed $SPD --stop-bits $STOP --parity $PARITY --timeout 2s suid:$ID"
echo $CMD

#$CMD rh:int16:0x63+2
$CMD rh:int16:0x30+25 \
     rh:int16:0x32+1 \
     rh:int16:0x30+25 \
     rh:int16:0x32+1 

     
## all registers


## this sets FAST MODE; will force 230400 baud and will write fdx,dx,dz continuously to the serial port.

#$CMD wr:uint16:0x69:0xb588
#$CMD wr:uint16:0x62:0x0001
