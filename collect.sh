#!/usr/bin/env sh

while [ 1 ]; do

    NOW=`date "+%Y%m%d-%H%M%S"`
    OUT="data/${NOW}.csv"

    echo "INFO: writing to $OUT" 1>&2

    python wt.py --name WT901BLE68 0000FFE4-0000-1000-8000-00805F9A34FB > $OUT 2>> ~/wittle.log.err

    echo "INFO: wrote `wc -l $OUT` lines" 1>&2

done
