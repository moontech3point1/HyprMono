#!/bin/bash

# waybar custom modules with return-type json want {"text":..,"class":..} on stdout
# playerctl throws an error to stderr if nothing is playing, so we just catch that and show nothing

if ! playerctl status &> /dev/null; then
    echo '{"text": "", "class": "none"}'
    exit 0
fi

status=$(playerctl status 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

if [ "$status" = "Playing" ]; then
    icon=""
else
    icon=""
fi

# trim it down so it doesn't take over the whole bar
text="$icon $artist - $title"
if [ ${#text} -gt 40 ]; then
    text="${text:0:37}..."
fi

echo "{\"text\": \"$text\", \"class\": \"$status\"}"
