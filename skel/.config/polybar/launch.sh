#!/bin/bash
polybar-msg cmd quit
killall polybar
polybar 2>&1 | tee -a /tmp/polybar.log & disown
echo "Bars launched..."
