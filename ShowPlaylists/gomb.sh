#!/bin/bash
if [ $# -ne 2 ]
then
	echo "Usage: $0 DATE LASTDATE"
	exit
fi

date=$1
file=$2
cat $2 | while read gomb
do
	date1=`date -d "$date +2 days" +"%Y-%m-%d"`
	echo $date
	echo "J:\\FTP\\Delicious Agony\\Glass Onyon\\shows\\GOMB$gomb.mp3"  $date-11-GOMB.m3u $date1-18-GOMB.m3u
	echo "J:\\FTP\\Delicious Agony\\Glass Onyon\\shows\\GOMB$gomb.mp3" > $date-11-GOMB.m3u
	echo "J:\\FTP\\Delicious Agony\\Glass Onyon\\shows\\GOMB$gomb.mp3" > $date1-18-GOMB.m3u
	date=`date -d "$date +7 days" +"%Y-%m-%d"`
done
