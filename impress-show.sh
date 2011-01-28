#!/bin/bash
# Desc: autostart presentation and watch for changes in file.
# Author: Dean M.
# Date: Jan 6, 2011
# Avoid lock file issues by running the slideshow on a separate file
FILE=/home/public/TV/tv-monitor.odp
SHOWFILE=/home/public/TV/.hidden/tv-monitor.odp
cp -f $FILE $SHOWFILE
MD5=`md5sum $FILE`
sleep 20
ooimpress -norestore -view -show $SHOWFILE
while true; do
  sleep 60
  NEW=`md5sum $FILE`
  if [ ! "$MD5" == "$NEW" ]; then
    killall soffice.bin
    sleep 15
    cp -f $FILE $SHOWFILE
    ooimpress -norestore -view -show $SHOWFILE
    MD5=`md5sum $FILE`
  fi
done 
