#!/bin/bash

# wttr.in figures out location from your IP, add a city name at the end of the url if that's wrong
weather=$(curl -s --max-time 5 "wttr.in/?format=%C+%t")

if [ -z "$weather" ]; then
    echo " N/A"
else
    echo " $weather"
fi
