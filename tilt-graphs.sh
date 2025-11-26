#!/usr/bin/env sh
DATA=/data/tilt

exec >> $DATA/log/tilt-graphs.log 2>&1

cd $DATA/scripts || (echo "FATAL: cd to $DATA/scripts failed"; exit 1)

echo "******************** generate tilt graphs as of `date`"

R --slave -s < daily.R
R --slave -s < showme.R

echo "******************** graphs done as of `date`"
