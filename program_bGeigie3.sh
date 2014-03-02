#!/usr/bin/env bash

ISP_PROGRAMMER="avrisp2"
#ISP_PROGRAMMER="usbtiny"
ISP_SPEED_SLOW=4
ISP_SPEED_FAST=1

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

BGEIGIE_VERSION=v3.2.7
MASSSTORAGE_VERSION=v3.2.7

XPDF_OPT=-fullscreen

failure(){
  xpdf $XPDF_OPT images/Step_Failure.pdf 2> /dev/null
}


echo "Welcome to the flashing script for the bGeigie 3"
echo "STEP 1: Make sure you have everything required:"
echo "  * bGeigie device to program."
echo "  * AVR programmer (AVR-ISP-MKII)."
echo "  * USB A-male to mini-B cable."

#read -p "Click ENTER when ready..."
xpdf $XPDF_OPT images/Step0.pdf 2> /dev/null

echo "STEP 2: Make sure everything is ready:"
echo "  * bGeigie device is connected to AVR ISP programmer."
echo "  * SD card ejected."
echo "  * Selector 1 is ON and 2 is OFF."

#read -p "Click ENTER when ready..."
xpdf $XPDF_OPT images/Step1.pdf 2> /dev/null

# perform chip erase
COMMAND="avrdude -p m32u4 -c $ISP_PROGRAMMER -P usb  -B $ISP_SPEED_SLOW -e"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't erase 32U4."
  failure
  exit 1
fi

# program fuses of 32U4
COMMAND="avrdude -p m32u4 -c $ISP_PROGRAMMER -P usb  -B $ISP_SPEED_SLOW -U lfuse:w:0xde:m -U hfuse:w:0xd8:m -U efuse:w:0xcb:m"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program fuses of 32U4."
  failure
  exit 1
fi

# program firmware of 32U4
COMMAND="avrdude -p m32u4 -c $ISP_PROGRAMMER -P usb -B $ISP_SPEED_FAST -U flash:w:hex/MassStorage-${MASSSTORAGE_VERSION}.hex"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program firmware of 32U4."
  failure
  exit 1
fi

# lock the chip
COMMAND="avrdude -p m32u4 -c $ISP_PROGRAMMER -P usb  -B $ISP_SPEED_SLOW -U lock:w:0x28:m"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't lock the 32U4."
  failure
  exit 1
fi

echo "STEP 3: Make sure everything is ready:"
echo "  * bGeigie device is connected to AVR ISP programmer."
echo "  * SD card ejected."
echo "  * Selector 1 is OFF and 2 is ON."

#read -p "ready ? [yY] "
xpdf $XPDF_OPT images/Step2.pdf 2> /dev/null

# perorm a chip erase to unlock all lock bits before programming
COMMAND="avrdude -p m1284p -c $ISP_PROGRAMMER -P usb -B $ISP_SPEED_SLOW -e"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't erase the chip."
  failure
  exit 1
fi

# now program the fuse
COMMAND="avrdude -p m1284p -c $ISP_PROGRAMMER -P usb -B $ISP_SPEED_SLOW -U lfuse:w:0xff:m -U hfuse:w:0xdc:m -U efuse:w:0xfd:m"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program fuses of 1284P"
  failure
  exit 1
fi

# finally, upload the bootloader
COMMAND="avrdude -p m1284p -c $ISP_PROGRAMMER -P usb -B $ISP_SPEED_FAST -U flash:w:hex/bGeigie3-${BGEIGIE_VERSION}.hex"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't program bootloader to 1284P"
  failure
  exit 1
fi

# now, lock the bootloader section and the fuses
COMMAND="avrdude -p m1284p -c $ISP_PROGRAMMER -P usb -B $ISP_SPEED_SLOW -U lock:w:0x28:m"
echo $COMMAND
$COMMAND
if [ $? -ne 0 ];
then
  echo "Failure: couldn't lock the 1284p"
  failure
  exit 1
fi

xpdf $XPDF_OPT images/Step3.pdf 2> /dev/null

echo "STEP 4: Prepare bGeigie for operations."
echo "  * Insert SD card."
echo "  * Set selectors 1 and 2 to ON."
echo "  * Press RESET button for 1 second."
echo "  * Wait until LEDs finish blinking."

xpdf $XPDF_OPT images/Step4.pdf 2> /dev/null

echo "STEP 5: Test Mass Storage function."
echo "  * Insert SD card."
echo "  * Selector 1 and 2 are ON."
echo "  * Connect bGeigie to computer via USB mini cable."

xpdf $XPDF_OPT images/Step5.pdf 2> /dev/null

xpdf $XPDF_OPT images/Step6.pdf 2> /dev/null

read -p "Is mass storage mounting correctly ? [nY] "
echo "  * Unmount mass storage."

xpdf $XPDF_OPT images/Step7.pdf 2> /dev/null

echo "STEP 6: Test and configure bGeigie device."
echo "  * Turn bGeigie ON by pressing push button for 2 seconds until LED blinks."
read -p "Input the bGeigie Serial ID : " BGEIGIE_SID
CHOICE=${BGEIGIE_SID:-1}

if [ $BGEIGIE_SID -eq -1 ]
then
  echo "Failure: Please input valid bGeigie serial ID number."
  failure
  exit 1
fi

while [ ! -c ${SERIAL_TTYPORT} ];
do
  read -p "Please enter a valid serial port : " SERIAL_TTYPORT
done

echo "Running test and configure routine..."

COMMAND="python bin/bgeigie_diagnostic.py -p $SERIAL_TTYPORT -b 57600 -n $BGEIGIE_SID"
echo $COMMAND
$COMMAND

if [ $? -eq 0 ];
then
  xpdf $XPDF_OPT images/Step_Success.pdf 2> /dev/null
  echo "Success. You can close this terminal."
else
  xpdf $XPDF_OPT images/Step_Failure.pdf 2> /dev/null
  echo "Failure. Try to find out what went wrong above."
fi

