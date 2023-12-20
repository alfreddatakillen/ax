#!/bin/bash
polybar-msg cmd quit
killall polybar
polybar 2>&1 | tee -a /var/log/polybar.log & disown
