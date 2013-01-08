#!/usr/bin/env bash
echo "Checking for updates"
git pull

ISP_PROGRAMMER=arduino
ISP_TTYPORT=/dev/ttyUSB0
ISP_SPEED=19200

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

echo "Welcome to the flashing script for the bGeigie 3"
echo "Make sure you have connected your bgeigie to your avr isp programmer and let's roll"
# ls ?
read -p "Where is the AVR ISP programmer plugged ? [$ISP_TTYPORT] " ISP_TTYPORT

echo "Eject SD card, on the selector 1 is on and 2 off"
read -p "ready ? [yY] "

avrdude -p m32u4 -c $ISP_PROGRAMMER -P $ISP_TTYPORT -b $ISP_SPEED -U lfuse:w:0xde:m -U hfuse:w:0xd8:m -U efuse:w:0xcb:m
avrdude -p m32u4 -c $ISP_PROGRAMMER -P $ISP_TTYPORT -b $ISP_SPEED -U flash:w:hex/MassStorage-v3.0.5.hex

echo "SD card still ejected, on the selector 1 is off and 2 on"
read -p "ready ? [yY] "

avrdude -p m1284p -c $ISP_PROGRAMMER -P $ISP_TTYPORT -b $ISP_SPEED -U lfuse:w:0xff:m -U hfuse:w:0xdc:m -U efuse:w:0xfd:m
avrdude -p m1284p -c $ISP_PROGRAMMER -P $ISP_TTYPORT -b $ISP_SPEED -U flash:w:hex/optiboot_atmega1284p_8MHz.hex

echo "Selector 1 is on, 2 is on."
read -p "Done ? [yY] "

echo "Unplug AVR ISP programmer."
read -p "Done ? [yY] "

echo "Plug in Serial programmer."
read -p "Done ? [yY] "

read -p "Where is the AVR ISP programmer plugged ? [$SERIAL_TTYPORT] " SERIAL_TTYPORT

avrdude -p m1284p -b $SERIAL_SPEED -c $SERIAL_PROGRAMMER -P $SERIAL_TTYPORT -U flash:w:hex/bGeigie3-v3.0.5-iRover-JP.hex

echo "Push SD card back in."
read -p "Done ? [yY] "

echo "Running test routine..."

python bin/bgeigie_diagnostic.py -p $SERIAL_TTYPORT -b 57600

