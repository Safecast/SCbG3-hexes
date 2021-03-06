SCbG3-hexes
===========

Minimal firmwares and scripts install for bGeigie3

Hardware Needed
---------------

* USB-serial dongle.
* AVR ISP mkII (or a clone).
* bGeigie3 device to program.
* Probably a few USB cables suitable for the programmer and dongle.

Setup environment
-----------------

1. Standard install of Ubuntu 12.10. Download from
   `http://www.ubuntu.com/download/desktop`. The guide will assume that you
   have an internet connection, so configure it. It's also a good time to
   install all the Ubuntu updates.

2. Install minimally necessary packages.

        sudo apt-get install git
        sudo apt-get install python-pip
        sudo pip install --upgrade pyserial
        sudo apt-get install gcc-avr
        sudo apt-get install avr-libc
        sudo apt-get install avrdude

  Unfortunately, xpdf needs to be installed from source on Ubuntu because of a nasty segmentation fault in the Ubuntu package.

        sudo apt-get install libfreetype6-dev lesstif2-dev
        wget ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.03.tar.gz
        tar xzpf xpdf-3.03.tar.gz
        cd xpdf-3.03
        export CXXFLAGS=-fpermissive
        ./configure --with-freetype2-library=/usr/lib/i386-linux-gnu \
                    --with-freetype2-includes=/usr/include/freetype2 \
                    --with-Xm-library=/usr/lib \
                    --with-Xm-includes=/usr/include/Xm
        make
        sudo make install

  Note that you might need to change the `i386-linux-gnu` on the configure line depending on your platform.

  Optionally, install the screen command line utility to test serial connection

        sudo apt-get install screen

3. Add permissions for USB devices
    
        sudo bash -c 'mkdir -p /etc/udev/rules.d/ && echo KERNEL==\"ttyUSB[0-9]\",MODE=\"0666\" >> /etc/udev/rules.d/10-local.rules'
        sudo bash -c 'mkdir -p /etc/udev/rules.d/ && echo ATTRS{idVendor}==\"1781\",ATTRS{idProduct}==\"0c9f\",GROUP=\"adm\",MODE=\"0666\" >> /etc/udev/rules.d/10-local.rules'
        sudo bash -c 'mkdir -p /etc/udev/rules.d/ && echo ATTRS{idVendor}==\"03eb\",ATTRS{idProduct}==\"2104\",GROUP=\"adm\",MODE=\"0666\" >> /etc/udev/rules.d/10-local.rules'
        sudo /etc/init.d/udev restart

  Now if you plug an FTDI-USB dongle, you should be able to connect without error by typing in

        screen /dev/ttyUSB0 57600

4. Get the latest distribution of the bGeigie3 firmware

        cd ~
        git clone -b factory --single-branch https://github.com/Safecast/SCbG3-hexes.git

5. Setup wallpaper and shortcuts.

  1. Open folder `misc`.
  2. Drag-and-drop files `ProgramDevice.desktop` and `Update.desktop` into the Ubuntu launcher.
  3. Right-click on the desktop and select `Change Desktop Background.`
  4. Click the `+` button to add a new wallpaper and navigate to `SCbG3-hexes/misc` directory. Select `bGeigie_station_wallpaper.png` file.

  The desktop files assume the home directory is `/home/safecast`. If this is not the case, just open the files
  and replace everywhere `/home/safecast` by the proper directory.

6. Now get a bGeigie3 device to program, start the process by clicking the `Program Device` icon in the launcher, and follow the instructions.

  Or open a terminal and type

        cd ~/SCbG3-hexes
        ./run_me.sh

7. When in need of updating the firmware files from the repository, click the `Update Safecast` icon in the launcher.

  Or open a terminal and type
      
        cd ~/SCbG3-hexes
        ./update.sh

