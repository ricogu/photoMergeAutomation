#!/bin/bash

basepath="/Volumes/homes/fzelin56/Drive/Moments/Mobile/Zelin iPhone"

year=2019
fromMonth=06
toMonth=12
fromDay=13
toDay=31



for ((month=$fromMonth;month<=$toMonth;month++))
do
  mkdir rawVideo
  echo "month: $month"
  if [ -f Jessie-$year-$month.mp4 ]
  then
    echo "file Jessie-$year-$month.mp4 exist, go to next month"
    fromDay=1
    continue
  fi
  for ((day=$fromDay;day<=$toDay;day++))
  do
    echo "day: $day"

    #process month
    if [ $month -lt 10 ]
    then
      printMonth=0$month
    else
      printMonth=$month
    fi

    #process day
    if [ $day -lt 10 ]
    then
      printDay=0$day
    else
      printDay=$day
    fi
    path="$basepath/$year-$printMonth-$printDay"
    echo "path: $path"
    if [ -d "$path" ]
    then
      count_file=`ls -1 "$path"/*.MOV 2>/dev/null | wc -l`
      if [ $count_file != 0 ]
      then
        cp -n "$path"/*.MOV rawVideo
        echo "MOV files copied from $path"
      fi

      count_file=`ls -1 "$path"/*.mp4 2>/dev/null | wc -l`
      if [ $count_file != 0 ]
      then
        cp -n "$path"/*.mp4 rawVideo
        echo "mp4 files copied from $path"
      fi
    fi
  done

  fromDay=1

  for i in "rawVideo"/*.mp4; do
    ffmpeg -loglevel panic -n -i "$i" -vf "setpts=1.25*PTS" -r 30 "${i%.*}_30fps.mp4"
    echo "Converted $i into ${i%.*}_30fps.mp4"
  done

  #convert all MOV to mp4, changing framerate to 30 fps
  for i in "rawVideo"/*.MOV; do
    ffmpeg -loglevel panic -n -i "$i" -n -q:v 0 -r 30 "${i%.*}_30fps.mp4"
    echo "Converted $i into ${i%.*}_30fps.mp4"
  done



  find rawVideo/*_30fps.mp4 | sed 's:\ :\\\ :g'| sed 's/^/file /' >> index.txt

  echo "Merging all mp4 videos"
  ffmpeg -loglevel panic -safe 0 -f concat -i index.txt -n -c copy Jessie-$year-$month.mp4
  rm -rf rawVideo
  
done


