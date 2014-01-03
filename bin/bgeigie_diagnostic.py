
import serial
import io
import sys
import re

from time import time, sleep

import os
# chose an implementation, depending on os
if os.name == 'posix':
  from serial.tools.list_ports_posix import *
#elif os.name == 'nt': #sys.platform == 'win32':
  #from serial.tools.list_ports_windows import *
#~ elif os.name == 'java':
else:
  raise ImportError("Sorry: no implementation for your platform ('%s') available" % (os.name,))

# bGeigie diagnostic object

class BGeigieDiagnostic:
  # general parameters
  version = None
  ID = None
  # radio
  RadioEnabled = False
  RadioInit = False
  # gps
  GPSTypeMTK = False
  GPSStart = False
  # SD
  SDInserted = False
  SDInit = False
  SDOpen = False
  SDRW = False
  # SD Reader
  SDReaderEnabled = False
  SDReaderInit = False
  # Features
  PwrManageEnabled = False
  CmdLineIntEnabled = False
  CoordTruncEnabled = False
  # environment
  Temperature = 0
  Humidity = 0
  BatteryVoltage = 0
  FreeRam = 0

  # This function parses a line from the diagnostic
  def parse(self,line):

    diag = line.split(',')  # split at comma

    if (diag[0] == "Version"):
      self.version = diag[1]
    elif (diag[0] == "Device ID"):
      self.ID = diag[1]

    elif (diag[0] == "Radio enabled"):
      if (diag[1] == "yes"):
        self.RadioEnabled = True
    elif (diag[0] == "Radio initialized"):
      if (diag[1] == "yes"):
        self.RadioInit = True

    elif (diag[0] == "GPS type MTK"):
      if (diag[1] == "yes"):
        self.GPSTypeMTK = True
    elif (diag[0] == "GPS system startup"):
      if (diag[1] == "yes"):
        self.GPSStart = True

    elif (diag[0] == "SD inserted"):
      if (diag[1] == "yes"):
        self.SDInserted = True
    elif (diag[0] == "SD initialized"):
      if (diag[1] == "yes"):
        self.SDInit = True
    elif (diag[0] == "SD open file"):
      if (diag[1] == "yes"):
        self.SDOpen = True
    elif (diag[0] == "SD read write"):
      if (diag[1] == "yes"):
        self.SDRW = True

    elif (diag[0] == "SD reader enabled"):
      if (diag[1] == "yes"):
        self.SDReaderEnabled = True
    elif (diag[0] == "SD reader initialized"):
      if (diag[1] == "yes"):
        self.SDReaderInit = True

    elif (diag[0] == "Power management enabled"):
      if (diag[1] == "yes"):
        self.PwrManageEnabled = True

    elif (diag[0] == "Command line interface enabled"):
      if (diag[1] == "yes"):
        self.CmdLineIntEnabled = True

    elif (diag[0] == "Coordinate truncation enabled"):
      if (diag[1] == "yes"):
        self.CoordTruncEnabled = True

    elif (diag[0] == "Temperature"):
      try:
        self.Temperature = int(diag[1][:-1])
      except ValueError:
        print 'Warning : unrecognized temperature format.'
    elif (diag[0] == "Humidity"):
      try:
        self.Humidity = int(diag[1][:-1])
      except ValueError:
        print 'Warning : unrecognized humidity format.'
    elif (diag[0] == "Battery voltage"):
      try:
        self.BatteryVoltage = int(diag[1][:-2])
      except ValueError:
        print 'Warning : unrecognized battery voltage format.'
    elif (diag[0] == "System free RAM"):
      try:
        self.FreeRam = int(diag[1][:-1])
      except ValueError:
        print 'Warning : unrecognized free RAM format.'


  # Diagnostic analysis method
  # Returns True if device if operational
  #         False otherwise
  def diagnosticAnalysis(self):
    print "DIAGNOSTIC"

    print "  Device SID : " + self.ID

    print "  Radio : ",
    if (not self.RadioEnabled or not self.RadioInit):
      radio_success = False
      print "failed ",
      if (not self.RadioEnabled):
        print "(cause : Radio not enabled)"
      elif (not self.RadioInit):
        print "(cause : Radio fails initialization)"
      else:
        print "(cause : unknown)"
    else:
      radio_success = True
      print "success"

    print "  GPS : ",
    if (not self.GPSTypeMTK or not self.GPSStart):
      gps_success = False
      print "failed ",
      if (not self.GPSTypeMTK):
        print "(cause : Wrong GPS type (not MTK))"
      elif (not self.GPSStart):
        print "(cause : GPS Start test fails)"
      else:
        print "(cause : unknown)"
    else:
      gps_success = True
      print "success"

    print "  SD card : ",
    if (not self.SDInserted or not self.SDInit or not self.SDOpen or not self.SDRW):
      sd_success = False
      print "failed ",
      if (not self.SDInserted):
        print "(cause : SD card not inserted)"
      elif (not self.SDInit):
        print "(cause : SD card initialization fails)"
      elif (not self.SDOpen):
        print "(cause : File open test fails)"
      elif (not self.SDRW):
        print "(cause : Read/Write test fails)"
      else:
        print "(cause : unknown)"
    else:
      sd_success = True
      print "success"

    print "  SD Reader : ",
    if (not self.SDReaderEnabled or not self.SDInit):
      sdreader_success = False
      print "failed ",
      if (not self.SDReaderEnabled):
        print "(cause : SD Reader not enabled)"
      elif (not self.SDInit):
        print "(cause : SD Reader initialization fails)"
      else:
        print "(cause : unknown)"
    else:
      sdreader_success = True
      print "success"

    print "  Required features : ",
    if (not self.PwrManageEnabled or not self.CmdLineIntEnabled or not self.CoordTruncEnabled):
      features_success = False
      print "failed"
      if (not self.PwrManageEnabled):
        print "    Power Management required"
      if (not self.CmdLineIntEnabled):
        print "    Command Line Interface required"
      if (not self.CoordTruncEnabled):
        print "    Coordination Truncation required"
    else:
      features_success = True
      print "success"

    if (radio_success and sd_success and sdreader_success and gps_success and features_success):
      return True
    else:
      print "Result : bGeigie faulty."
      return False

###################
# SERIAL COMMANDS #
###################

eol = '\r'

def run_diagnostics(serial):

  bgd = BGeigieDiagnostic()

  cmd = 'diagnostics'

  serial.write(eol)

  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(0.2)

  start = time()
  gotStart = False
  success = False

  # read Lines
  while (not success and time() - start < timeout):
    line = ser.readline()
    line = line[:-2] # strip \r\n at end of line

    if (line == "--- Diagnostic START ---"):
      gotStart = True
      start = time()
      continue

    if (gotStart and line == "--- Diagnostic END ---"):
      success = True
      break

    if (gotStart):
      start = time()         # reset timeout

      bgd.parse(line)        # parse the received line

  if (success):
    return bgd
  else:
    print "Timeout : failed to perform diagnostic. Check connection between USB-serial dongle and device."
    return -1


# Configure the bGeigie device for post office operations
def configure_device(serial, sid):

  serial.write(eol)

  cmd = 'config ID ' + ("%3d" % sid)
  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(1)

  cmd = 'config CoordTrunc on'
  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(1)

  cmd = 'config SerialOutput off'
  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(1)

  cmd = 'config SDRW off'
  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(1)

  cmd = 'config HVSense off'
  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(1)

  cmd = 'config save'
  print "Issue command '" + cmd + "' to bGeigie3."
  ser.write(cmd + eol)

  sleep(1)


# Read the configuration of the device
def check_config(serial, mem, sid):

  if (mem == 'file'):
    cmd = 'config show file'
  elif (mem == 'eeprom'):
    cmd = 'config show eeprom'
  else:
    cmd = 'config show'

  serial.write(eol)

  sleep(0.1)

  serial.write(cmd + eol)
  
  start = time()

  CHKID = "%3d" % sid

  # read Lines
  while (time() - start < timeout):
    line = ser.readline()
    line = line[:-2] # strip \r\n at end of line

    pair = line.split(':')

    if (pair[0] == "ID" and pair[1] != CHKID):
      return False

    if (pair[0] == "SerialOutput" and pair[1] != "0"):
      return False

    if (pair[0] == "CoordTrunc" and pair[1] != "1"):
      return False

    if (pair[0] == "HVSense" and pair[1] != "0"):
      return False

    if (pair[0] == "SDRW" and pair[1] != "0"):
      return False
    else:
      break

  return True
  


########
# MAIN #
########

def usage():
  print 'Usage: ' + sys.argv[0] + ' -p <port> [-b <baudrate>]'

# default arguments
port = ''
baudrate = 57600
timeout = 10

sid = 300

# parse arguments
n = 1
while (n < len(sys.argv)):
  if (sys.argv[n] == '-p'):
    port = sys.argv[n+1]
    n += 2
  elif (sys.argv[n] == '-b'):
    baudrate = int(sys.argv[n+1])
    n += 2
  elif (sys.argv[n] == '-n'):
    sid = int(sys.argv[n+1])
    n += 2
  else:
    usage()
    sys.exit(1)

if port == '':
  re_port_mac = re.compile('^.*usbserial-[A-Za-z0-9]{8}')
  re_port_linux = re.compile('^/dev/ttyUSB[0-9]*')
  re_port = re_port_linux

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


# configure the device
configure_device(ser, sid)

# run the diagnostics
bgd = run_diagnostics(ser)

# check the config is saved to file and eeprom
chk_ram    = check_config(ser, 'RAM', sid)
chk_eeprom = check_config(ser, 'eeprom', sid)
chk_file   = check_config(ser, 'file', sid)
      
# close serial port
ser.close()

# check the results of all tests
if (bgd != -1):
  if bgd.diagnosticAnalysis():
    if (not chk_ram):
      print "Error: RAM does not contain correct configuration."
    if (not chk_eeprom):
      print "Error: EEPROM does not contain correct configuration."
    if (not chk_file):
      print "Error: Configuration File does not contain correct configuration."
    if (chk_ram and chk_eeprom and chk_file):
      print "Result : bGeigie ready for operation."
      sys.exit(0) #success
    else:
      sys.exit(1) # fail
  else:
    sys.exit(1) # fail
else:
  print "Timeout : failed to perform diagnostic. Check connection between USB-serial dongle and device."
  sys.exit(1) #fail



