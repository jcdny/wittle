while [ 1 ]; do
    echo "******************** generate as of `date`"
    (echo "dt,x,y,z,ax,ay,az"; cat `ls -1 data/2*.csv | sort`) > ~/tmp/all.csv
    R --slave -s < daily.R
    R --slave -s < showme.R
    echo "******************** done as of `date`"
    echo "******************** sleeping for 1 hour"
    sleep 3600
done
