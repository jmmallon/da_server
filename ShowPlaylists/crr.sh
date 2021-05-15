#!/bin/bash
if [ $# -ne 4 ]
then
	echo "Usage: $0 DATE COUNT LASTSHOW GAP-BETWEEN-NEW-AND-OLD-SHOWS"
	echo ./crr.sh 2021-02-12 7 13 7 - first show is 2021-02-19
	exit
fi

date=$1
count=$2
number1=$3
interval=$4
for (( i=0; i<$count; i++))
do
	number1=$(($number1+1))
	number1p=$(printf "%03d" $number1)
	number2=$(($number1-$interval))
	number2p=$(printf "%03d" $number2)

	for j in $number1p $number2p
	do
		date=`date -d "$date +7 days" +"%Y-%m-%d"`
		echo Doing $date
		echo "J:\\FTP\\Delicious Agony\\CherryRed\\CherryRedRadio$j.mp3" > $date-09-Cherry.m3u
		ln $date-09-Cherry.m3u $(date -d "$date +1 day" +"%Y-%m-%d")-12-Cherry.m3u
		ln $date-09-Cherry.m3u $(date -d "$date +14 day" +"%Y-%m-%d")-09-Cherry.m3u
		ln $date-09-Cherry.m3u $(date -d "$date +15 day" +"%Y-%m-%d")-12-Cherry.m3u
	done
	date=`date -d "$date +14 days" +"%Y-%m-%d"`
done
