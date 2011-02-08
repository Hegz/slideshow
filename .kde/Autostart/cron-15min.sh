#!/bin/bash
# simple user level cron.  Run the files every 15 min

while true; do 
	PATH/slideshow.pl > LOG/slideshow.log 2>&1
	sleep 15m
done
