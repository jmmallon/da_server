#!/bin/bash
if [ $# -ne 2 ]
then
	echo "Usage: $0 DATE LASTDATE"
	exit
fi

date=$1
lastdate=$2
while [[ $date < "$lastdate" ]]
do
	date=`date -d "$date +7 days" +"%Y-%m-%d"`
	echo $date
	echo "J:\\FTP\\Delicious Agony\\NewEARS\\NE-$date.mp3" > $date-14-NE.m3u
	date2=`date -d "$date +1 day" +"%Y-%m-%d"`
	ln $date-14-NE.m3u $date2-19-NE.m3u
done
