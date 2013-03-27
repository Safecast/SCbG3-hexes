
import serial
import sys
import re

from time import time

import os
# chose an implementation, depending on os
if os.name == 'posix':
  from serial.tools.list_ports_posix import *
#elif os.name == 'nt': #sys.platform == 'win32':
  #from serial.tools.list_ports_windows import *
#~ elif os.name == 'java':
else:
  raise ImportError("Sorry: no implementation for your platform ('%s') available" % (os.name,))

########
# MAIN #
########

def usage():
  print 'Usage: ' + sys.argv[0] + ' -n <number> -p <port> [-b <baudrate>]'

# default arguments
port = ''
baudrate = 57600
timeout = 10
number = -1;

if (len(sys.argv) < 3):
  usage()
  sys.exit(1)

# parse arguments
n = 1
while (n < len(sys.argv)-1):
  if (sys.argv[n] == '-p'):
    port = sys.argv[n+1]
    n += 2
  elif (sys.argv[n] == '-b'):
    baudrate = int(sys.argv[n+1])
    n += 2
  elif (sys.argv[n] == '-n'):
    number = int(sys.argv[n+1])
    n += 2
  else:
    usage()
    sys.exit(1)

if number < 0 or number > 999:
  print "Error: please provide a number between 0 and 999 with the option -n."
  sys.exit(1)

if port == '':
  re_port_mac = re.compile('^.*usbserial-[A-Za-z0-9]{8}')
  re_port_linux = re.compile('^/dev/ttyUSB[0-9]*')

  hits = 0
  iterator = sorted(comports())
  for p, desc, hwid in iterator:
    m_port = re_port.match(p)
    if m_port:
      port = p
      break

  if port == '':
    print "No matching port found."
    sys.exit(0)
  else:
    print "Found matching port '%s'. Try to open." % (port,)

# try to open serial port
try:
  ser = serial.Serial(port, baudrate, timeout=1)
except ValueError:
  print 'Wrong serial parameters. Exiting.'
  sys.exit(1)
except serial.SerialException:
  print 'Device can not be found or can not be configured.'
  sys.exit(1)

start = time()

# wait until we receive prompt:
twoBytes = list("  ")
word_number = "%3d" % number
command = "setid " + word_number
expected_result = 'Device id: ' + word_number + ' - success.'

success = False

ser.write("\r")

# read Lines
while (not success and time() - start < timeout):

  twoBytes[0] = twoBytes[1];
  twoBytes[1] = ser.read();

  if (twoBytes[0] == '\r' and twoBytes[1] == '\n'):

    ser.write('\r');

    # send command
    print "Issue command '" + command + "' to bGeigieMini."
    ser.write(command + "\r")

    # read result
    while (not success and time() - start < timeout):
      line = ser.readline()
      line = line[:-2]
      if (line == expected_result):
        success = True
      
ser.close()

if (success):
  print "Success: bGeigieMini successfully programmed with number " + word_number + "."
else:
  print "Failure."
  sys.exit(1)



