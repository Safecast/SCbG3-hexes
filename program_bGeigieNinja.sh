#!/usr/bin/env bash

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

BGEIGIENINJA_VERSION=v1.1.4

failure(){
  xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
}


echo "Welcome to the programming script for the bGeigie-Ninja"
echo "STEP 1: Make sure you have everything required:"
echo "  * bGeigie device to program."
echo "  * USB-Serial dongle."

if [ ! -c ${SERIAL_TTYPORT} ];
then
  read -p "Please type in device name (e.g. /dev/tty.usbserialA660JVIC): " SERIAL_TTYPORT
fi

# program the device
COMMAND="avrdude -p m328p -b ${SERIAL_SPEED} -c $SERIAL_PROGRAMMER -P ${SERIAL_TTYPORT} -U flash:w:hex/bGeigieNinja-${BGEIGIENINJA_VERSION}.hex"
echo "Execute: ${COMMAND}"
$COMMAND

# test exit status
if [ $? -eq 0 ];
then
  #xpdf -fullscreen images/Step5_success.pdf 2> /dev/null
  echo "Success."
else
  #xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
  echo "Failure."
fi

