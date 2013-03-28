#!/usr/bin/env bash

SERIAL_PROGRAMMER=arduino
SERIAL_TTYPORT=/dev/ttyUSB0
SERIAL_SPEED=57600

BGEIGIEMINI_VERSION=v1.4.6
BGEIGIEMINI_VARIANT=JPVM

failure(){
  xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
}


# choose to also program serial number, or not
if [ $# -eq 0 ];
then
  BGEIGIEMINI_SERIAL_NUMBER=-1
else
  if [ $1 = '--help' ];
  then
    echo "Usage: " $0 " [number]"
    exit 1
  fi
  BGEIGIEMINI_SERIAL_NUMBER=$1
fi

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

if [ $BGEIGIEMINI_SERIAL_NUMBER -ne -1 ];
then
  # program the configuration uploader
  COMMAND="avrdude -p m328p -b ${SERIAL_SPEED} -c $SERIAL_PROGRAMMER -P ${SERIAL_TTYPORT} -U flash:w:hex/bGeigieMini-configBurner.hex"
  echo "Upload config burner: ${COMMAND}"
  $COMMAND
  # test exit status
  if [ $? -ne 0 ];
  then
    echo "Failure: couldn't program number burner."
    exit 1
  fi


  COMMAND="python bin/bGeigieMini_configure.py -p $SERIAL_TTYPORT -b $SERIAL_SPEED -n $BGEIGIEMINI_SERIAL_NUMBER"
  echo "Execute: ${COMMAND}"
  $COMMAND
  # test exit status
  if [ $? -ne 0 ];
  then
    echo "Failure: couldn't burn serial number to bGeigie."
    exit 1
  fi
fi

# program the device
COMMAND="avrdude -p m328p -b ${SERIAL_SPEED} -c $SERIAL_PROGRAMMER -P ${SERIAL_TTYPORT} -U flash:w:hex/bGeigieMini-${BGEIGIEMINI_VERSION}-${BGEIGIEMINI_VARIANT}.hex"
echo "Execute: ${COMMAND}"
$COMMAND

# test exit status
if [ $? -eq 0 ];
then
  echo "All success."
else
  echo "Failure: writing bGeigie firmware failed."
  exit 1
fi

