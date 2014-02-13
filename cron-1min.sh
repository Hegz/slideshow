#!/bin/bash
# simple user level cron.  Run the files every min

while true; do 
	/home/h/hallmon/updatecache.pl > /home/h/hallmon/log/updatecache.log 2>&1
	sleep 1m
done
