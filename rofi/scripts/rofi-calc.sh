#!/bin/bash

rofi -dmenu -p "Calc:" -theme-str 'window {width: 20%;}' |
  awk '{print "'"$(</dev/stdin)"'" | bc -l}' | rofi -dmenu -p "Result"
