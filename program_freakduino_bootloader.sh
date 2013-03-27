#!/usr/bin/env bash

PROGRAMMER=avrisp2
PROGRAMMER=usbtiny
PORT=usb
SPEED=1

BOOTLOADER_FILE=freakduino_wdt_bootloader.hex

failure(){
  xpdf -fullscreen images/Step5_failure.pdf 2> /dev/null
}


echo "Welcome to the programming of Freakduino bootloader."
echo "STEP 1: Make sure you have everything required:"
echo "  * A freakduino to program"
echo "  * An AVR-ISP programmer"

# program the device
COMMAND="avrdude -p m328p -c ${PROGRAMMER} -P ${PORT} -B ${SPEED} -U flash:w:hex/${BOOTLOADER_FILE}:i"
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

