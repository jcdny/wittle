#!/usr/bin/env sh
DATA=/data/tilt

exec >> $DATA/log/tilt-graphs.log 2>&1

cd $DATA/scripts || (echo "FATAL: cd to $DATA/scripts failed"; exit 1)

echo "******************** generate tilt graphs as of `date`"

echo "*** Daily.R `date`"
R --slave -s < daily.R

echo "*** Showme.R `date`"
R --slave -s < showme.R

echo "*** rclone `date`"
rclone sync $DATA/graphs/ s3:j3ff.com/graphs/

echo "******************** graphs done as of `date`"
