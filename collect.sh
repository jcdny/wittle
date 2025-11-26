#!/usr/bin/env sh
if [ -z "$DATA" ]; then
    export DATA=/data/tilt
fi

NOW=`date "+%Y%m%d-%H%M%S"`
OUT="$DATA/data/${NOW}.csv"


echo "INFO: writing to $OUT" 1>&2

python $DATA/scripts/wt.py --name WT901BLE68 0000FFE4-0000-1000-8000-00805F9A34FB > $OUT 

echo "INFO: wrote `wc -l $OUT` lines" 1>&2

