#!/usr/bin/env bash

ISP_PROGRAMMER="-c avrisp2 -P usb -B 0.5"

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

BGEIGIE_VERSION=v3.1.1-iRover-JP
MASSSTORAGE_VERSION=v3.1.1

failure(){
  xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
}

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

# program fuses of 32U4
COMMAND="avrdude -p m32u4 $ISP_PROGRAMMER -U lfuse:w:0xde:m -U hfuse:w:0xd8:m -U efuse:w:0xcb:m"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program fuses of 32U4."
  failure
  exit 1
fi

# program firmware of 32U4
COMMAND="avrdude -p m32u4 $ISP_PROGRAMMER -U flash:w:hex/MassStorage-${MASSSTORAGE_VERSION}.hex"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program firmware of 32U4."
  failure
  exit 1
fi

echo "STEP 3: Make sure everything is ready:"
echo "  * bGeigie device is connected to AVR ISP programmer."
echo "  * SD card ejected."
echo "  * Selector 1 is OFF and 2 is ON."

#read -p "ready ? [yY] "
xpdf -fullscreen images/Step3.pdf 2> /dev/null

COMMAND="avrdude -p m1284p $ISP_PROGRAMMER -U lfuse:w:0xff:m -U hfuse:w:0xdc:m -U efuse:w:0xfd:m"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program fuses of 1284P"
  failure
  exit 1
fi

COMMAND="avrdude -p m1284p $ISP_PROGRAMMER -U flash:w:hex/optiboot_atmega1284p_8MHz.hex"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program bootloader to 1284P"
  failure
  exit 1
fi

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

COMMAND="avrdude -p m1284p -b $SERIAL_SPEED -c $SERIAL_PROGRAMMER -P ${SERIAL_TTYPORT} -U flash:w:hex/bGeigie3-${BGEIGIE_VERSION}.hex"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't load bGeigie3 firmware to 1284P"
  failure
  exit 1
fi

echo "Running test routine..."

COMMAND="python bin/bgeigie_diagnostic.py -p $SERIAL_TTYPORT -b 57600"
echo $COMMAND
$COMMAND

if [ $? -eq 0 ];
then
  xpdf -fullscreen images/Step5_success.pdf 2> /dev/null
  echo "Success. You can close this terminal."
else
  xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
  echo "Failure. Try to find out what went wrong above."
fi

