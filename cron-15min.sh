#!/bin/bash
# simple user level cron.  Run the files every 15 min

while true; do 
	/home/h/hallmon/slideshow.pl > /home/h/hallmon/log/slideshow.log 2>&1
	sleep 15m
done
