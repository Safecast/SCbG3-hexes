#!/usr/bin/env bash

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

BGEIGIEMINI_VERSION=v1.4.5
BGEIGIEMINI_VARIANT=JPVM

failure(){
  xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
}


echo "Welcome to the programming script for the bGeigie-Mini"
echo "STEP 1: Make sure you have everything required:"
echo "  * bGeigie device to program."
echo "  * USB-Serial dongle."

if [ ! -c ${SERIAL_TTYPORT} ];
then
  read -p "Please type in device name (e.g. /dev/tty.usbserialA660JVIC): " SERIAL_TTYPORT
fi

echo "Please, choose firmware variant to upload:"
echo "  1 - Post Office"
echo "  2 - PlusShield, MTK GPS"
echo "  3 - Standard, MTK GPS"
echo "  4 - PlusShield, Canmore GPS"
echo "  5 - Standard, Canmore GPS"
read -p "Enter choice [1]: " CHOICE
CHOICE=${CHOICE:-1}

case $CHOICE in
  1 )
    BGEIGIEMINI_VARIANT=JPVM 
    ;;
  2 )
    BGEIGIEMINI_VARIANT=PVM 
    ;;
  3 )
    BGEIGIEMINI_VARIANT=M 
    ;;
  4 )
    BGEIGIEMINI_VARIANT=PVC 
    ;;
  5 )
    BGEIGIEMINI_VARIANT=C
    ;;
  * )
    echo "Invalide choice. Please retry."
    exit 1
    ;;
esac

# program the device
COMMAND="avrdude -p m328p -b ${SERIAL_SPEED} -c $SERIAL_PROGRAMMER -P ${SERIAL_TTYPORT} -U flash:w:hex/bGeigieMini-${BGEIGIEMINI_VERSION}-${BGEIGIEMINI_VARIANT}.hex"
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

