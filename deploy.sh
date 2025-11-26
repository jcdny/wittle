#!/bin/bash
MODE=${1:DIFF}

if [ -z "$DATA" ]; then
    export DATA="/data/tilt"
fi

if [ ! -d $DATA/scripts ]; then
    echo "Script dir $DATA/scripts missing"
    exit 1
fi

echo "Deploying as of `date`"

for a in util.R \
	     showme.R \
	     daily.R \
	     wt.py \
	     collect.sh \
	     tilt-graphs.sh \
         ; do

    if [ "$MODE" = "prod" ]; then
        cmp -s $a $DATA/scripts/$a || (echo "copying $a to $DATA/scripts"; cp $a $DATA/scripts)
    else
        if [ ! -r $DATA/scripts/$a ]; then
            echo "** New file $a"
        else
            echo diff -C $a $DATA/scripts/$a
            diff -C 2 $a $DATA/scripts/$a
        fi
    fi
done
