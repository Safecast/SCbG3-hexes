#!/usr/bin/env bash
echo "Checking for updates"
git pull

echo "Welcome to the flashing script for the bGeigie 3"
echo "Make sure you have connected your bgeigie to your avr isp programmer and let's roll"
# ls ?
read -p "Where is the AVR ISP programmer plugged ? [/dev/ttyUSB0] "

echo "Eject SD card, on the selector 1 is on and 2 off"
read -p "ready ? [yY] "

avrdude -p m1248p -c stk500v1 -P /dev/ttyUSB0 -b 19200 -U flash:w:m1248p.hex

echo "SD card still ejected, on the selector 1 is off and 2 on"
read -p "ready ? [yY] "

avrdude -p m32u4 -c stk500v1 -P /dev/ttyUSB0 -b 19200 -U lfuse:w:0xff:m -U hfuse:w:0x99:m -U efuse:w:0xf3:m
avrdude -p m32u4 -c stk500v1 -P /dev/ttyUSB0 -b 19200 -U flash:w:m32u4.hex
