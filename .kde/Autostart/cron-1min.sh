#!/bin/bash
# simple user level cron.  Run the files every min

while true; do 
	PATH/updatecache.pl > LOG/updatecache.log 2>&1
	sleep 1m
done
