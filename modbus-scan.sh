## scan a device across connection types

##for DEV in rtu:////dev/tty.usbserial-840
for DEV in rtu:///dev/cu.usbserial-840; do
    for SPD in 4800 9600 19200 38400 57600 115200 230400; do
        for STOP in 1; do ## 0 1 2; do
            for PARITY in none; do ## even odd; do
                ID=80
                while [ $ID -lt 81 ]; do
                    echo $DEV @ $SPD 8 PAR $PARITY STOP $STOP ID $ID
                    modbus --target $DEV --speed $SPD --stop-bits $STOP --parity $PARITY --timeout 1s \
                           suid:$ID \
                           rh:int16:0x32+1

                    ID=`expr $ID + 1`

                done
            done
        done
    done
done
