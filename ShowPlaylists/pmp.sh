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
	echo "J:\\FTP\\Delicious Agony\\Progressive Music Planet\\PMP-$date.mp3" > $date-20-PMP.m3u
done
