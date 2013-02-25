#!/usr/bin/env bash
echo "Checking for updates"
git pull

ISP_PROGRAMMER=usbtiny
ISP_TTYPORT=usb
ISP_SPEED=19200

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

BGEIGIE_VERSION=v3.0.8-iRover-JP
MASSSTORAGE_VERSION=v3.0.8

echo "Welcome to the flashing script for the bGeigie 3"
echo "STEP 1: Make sure you have everything required:"
echo "  * bGeigie device to program."
echo "  * AVR programmer (USBTiny)."
echo "  * USB-Serial dongle."

#read -p "Click ENTER when ready..."
xpdf -fullscreen images/Step1.pdf 2> /dev/null

echo "STEP 2: Make sure everything is ready:"
echo "  * bGeigie device is connected to AVR ISP programmer."
echo "  * SD card ejected."
echo "  * Selector 1 is ON and 2 is OFF."

#read -p "Click ENTER when ready..."
xpdf -fullscreen images/Step2.pdf 2> /dev/null

avrdude -p m32u4 -c $ISP_PROGRAMMER -U lfuse:w:0xde:m -U hfuse:w:0xd8:m -U efuse:w:0xcb:m
avrdude -p m32u4 -c $ISP_PROGRAMMER -B 0.5 -U flash:w:hex/MassStorage-${MASSSTORAGE_VERSION}.hex

echo "STEP 3: Make sure everything is ready:"
echo "  * bGeigie device is connected to AVR ISP programmer."
echo "  * SD card ejected."
echo "  * Selector 1 is OFF and 2 is ON."

#read -p "ready ? [yY] "
xpdf -fullscreen images/Step3.pdf 2> /dev/null

avrdude -p m1284p -c $ISP_PROGRAMMER -U lfuse:w:0xff:m -U hfuse:w:0xdc:m -U efuse:w:0xfd:m
avrdude -p m1284p -c $ISP_PROGRAMMER -B 0.5 -U flash:w:hex/optiboot_atmega1284p_8MHz.hex

echo "STEP 4: Make sure everything is ready:"
echo "  * bGeigie device is connected to AVR ISP programmer."
echo "  * SD card ejected."
echo "  * Selector 1 is OFF and 2 is ON."

#read -p "ready ? [yY] "
xpdf -fullscreen images/Step4.pdf 2> /dev/null

if [ ! -c ${SERIAL_TTYPORT} ];
then
  read -p "Where is the AVR ISP programmer plugged ? " SERIAL_TTYPORT
fi

avrdude -p m1284p -b $SERIAL_SPEED -c $SERIAL_PROGRAMMER -P ${SERIAL_TTYPORT} -U flash:w:hex/bGeigie3-${BGEIGIE_VERSION}.hex

echo "Running test routine..."

python bin/bgeigie_diagnostic.py -p $SERIAL_TTYPORT -b 57600

