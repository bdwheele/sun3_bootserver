# Sun3 Raspberry Pi bootserver 

Inspired by booterizer (https://github.com/unxmaal/booterizer) and an old post of mine on classiccmp (https://marc.info/?l=classiccmp&m=131518210215438&w=2)

## Requirements

* A Sun3 machine (tested on a Sun 3/60)
* Raspberry Pi 4
* 8G+ SD card
* Image + tool to uncompress xz file
* Tool to write image to SD card


## Connection Topology 

I've got a headless Sun 3/60, so I'm running both the network and serial console
through the raspberry pi.  Optional if you have a terminal or working monitor/keyboard/mouse
````
(wireless) <-net-> [raspberry pi]  <-net-> [hub/switch] <-net-> [sun3]
                          ^                                       ^
                          +--> [usb/ser] <---> [null modem] ------+
````

Research:
* Ethernet crossover cable?

## Serial Setup

During a diagnotic boot, Serial Port A is 9600,8,n,1 and Serial Port B is 1200,8,n,1.


Serial Port A is 9600 baud by default.  I've set the norm/diag switch to diag so I have to hit a key to get to the boot prom (normal doesn't return anything -- console not set up)

Per the NetBSD install:

 The console location (ttya, ttyb, or keyboard/display) is controlled by address 0x1F in the EEPROM, which you can examine and change in the PROM monitor by entering q1f followed by a numeric value (or just a `.' if you don't want to change it). Console values are:

00    Default graphics display

10    tty a (9600-N-8-1)

11    tty b (1200-N-8-1)

20    Color option board on P4 



## Getting the Sun MAC address

If you can only use diag mode, the mac address can be retrieved via the eprom data:
```
>^i
Compiled on pest at 09/02/87 in /usr/src/sun/mon3/SUN3F
>s3
>e
00000000: 0117?   <-- format 0x01, machine type 17  (Sun 3/60)
00000002: 0800?   <-\
00000004: 2000?     +--- MAC address:  08:00:20:00:4E:BD
00000006: 4EBD?   <-/
00000008: 22A9?   <-\
0000000A: 84D5?   <-+--- Date of manufacture 0x229A84D5 => 580551893 => Wed May 25 04:24:53 1988
0000000C: 0080?   <-\
0000000E: 41D6?   <-+--- Unique serial number 0x080041D6
00000010: 0000? 
00000012: 0000? 
00000014: 0000? q
>
```

Machine types:
* 0x11 => Sun 3/160
* 0x12 => Sun 3/50
* 0x13 => Sun 3/260
* 0x14 => Sun 3/110
* 0x17 => Sun 3/60
* 0x41 => Sun 3/460
* 0x42 => Sun 3/80




## Useful references

http://www.bitsavers.org/pdf/sun/sunos/4.0/800-1736-10A_PROM_Users_Manual_198805.pdf

http://www.bitsavers.org/pdf/sun/sunos/4.0.3/800-1736-10A_PROM_Users_Manual_Addenda_and_Errata_198904.pdf

http://www-lehre.inf.uos.de/~sp/Man/_Man_SunOS_4.1.3_html/html8/boot.8s.html



## Building the Pi Server

### Create base Pi OS SD Card

On your workstation of choice... 

* Download the Rasberry Pi OS Lite image from https://www.raspberrypi.com/software/operating-systems/
    * Version 11 (bullseye)
    * 2022-04-7
* Write the image to an SD card
* Insert the card into the Pi and boot it

### Set up the Pi 

On the PI...

* Set up the system:
    * Enter the username/password for the system during the first boot config
    * `sudo raspi-config`
    * System Options / Wireless LAN => Set up your Wifi
    * System Options / Network at Boot => Yes
    * Interface Options / SSH  =>  Yes
    * Exit raspi-config
    * `reboot`
    * Retrieve the wireless IP address by running "ip addr list" and looking for the wlan0 inet entry.

### Install prereqs on bootserver
This can be done either on the Pi or on the workstation.  I prefer the 
latter, since it allows for copy/paste  

* On the PI:
    * Use the keyboard :)
* On your workstation:
    * Log into the pi machine via ssh.  Use the username, password, and address supplied above

````
sudo bash
apt update
apt install -y git ansible 
````

### Clone the repository
Get this repository on the system
```
git clone https://github.com/bdwheele/sun3_bootserver.git
```

### Modify the settings
Modify the settings.yml file to customize for your environment.  The build can
be used multiple times to provide a bootserver for more than one machine.

If the sun3 os is set to "sunos", it will (attempt) to install SunOS 4.1.1

If it is set to "netbsd", the version in netbsd_version will be used, from 
version 1.6 to 9.2  (tested with 1.6 and 9.2)

If the tty_server is enabled, a user will be configured to allow ssh access to
the USB<->serial device specified using the tio program.

### Run the bootstrap

```
./build_bootserver.sh
```

# Known issues

## SunOS Issues
Ugh, for some reason I cannot get SunOS 4.1.1 to network boot.  It will reliably:
* RARP for an IP
* TFTP boot the boot loader
* Use bootparamd to get the root filesystem
* Mount NFS root
* Load the kernel
* boot the kernel
* Fail when asking more information from bootparamd

Packets for the second round of bootparamd are sent to the wrong IP -- 
specifically, the MAC destination is ff:ff:ff:ff:ff:ff and the IP destination 
is 192.168.0.0 (the network address, since my hosts are on 192.168.0.0/24).  
So that means the Pi never gets the packet and no reply ever shows up.

WHOAMI response:
```
0000   08 00 20 00 4e bd dc a6 32 43 9d 00 08 00 45 00   .. .N...2C....E.
0010   00 68 6a 0d 40 00 40 11 4f 24 c0 a8 00 01 c0 a8   .hj.@.@.O$......
0020   00 02 c7 16 03 ff 00 54 81 b9 1f 73 f2 15 00 00   .......T...s....
0030   00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0040   00 00 00 00 03 34 00 00 00 2c 00 00 00 06 6d 79   .....4...,....my
0050   73 75 6e 33 00 00 00 00 00 06 28 6e 6f 6e 65 29   sun3......(none)
0060   00 00 00 00 00 01 00 00 00 c0 00 00 00 a8 00 00   ................
0070   00 00 00 00 00 01                                 ......
```
Network addresses are stored as network type (4 bytes), and then each
of the bytes in the IP address are stored as a 4 byte int, big-endian.

At 0x62 - 0x65, is the network type  (0x00000001).  0x66-0x69 is the first
byte of the IP (0xc0 = 192), 0x6a-0x6d is the 2nd byte (0xa8 = 168),
0x6e-0x71 is the 3rd byte (0x00 = 0), and the last byte is at 0x72-0x75 
(0x01 = 1)

So the content is making it correctly.

Later the kernel will ask for the root path, and the IP is encoded the same
way starting at 0x52:

GETFILE response:
```
0000   08 00 20 00 4e bd dc a6 32 43 9d 00 08 00 45 00   .. .N...2C....E.
0010   00 70 7c f6 40 00 40 11 3c 33 c0 a8 00 01 c0 a8   .p|.@.@.<3......
0020   00 02 03 34 03 fe 00 5c 81 c1 1f 73 f2 16 00 00   ...4...\...s....
0030   00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0040   00 00 00 00 00 0b 31 39 32 2e 31 36 38 2e 30 2e   ......192.168.0.
0050   31 00 00 00 00 01 00 00 00 c0 00 00 00 a8 00 00   1...............
0060   00 00 00 00 00 01 00 00 00 13 2f 73 72 76 2f 6e   ........../srv/n
0070   66 73 72 6f 6f 74 2f 6d 79 73 75 6e 33 00         fsroot/mysun3.
```

And here's the failing call:
```
0000   ff ff ff ff ff ff 08 00 20 00 4e bd 08 00 45 00   ........ .N...E.
0010   00 80 00 00 00 00 ff 11 3a 1a c0 a8 00 02 c0 a8   ........:.......
0020   00 00 03 ff 00 6f 00 6c 00 00 1f f9 fa eb 00 00   .....o.l........
0030   00 00 00 00 00 02 00 01 86 a0 00 00 00 02 00 00   ................
0040   00 05 00 00 00 01 00 00 00 18 1f f4 6e 7b 00 00   ............n{..
0050   00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00   ................
0060   00 00 00 00 00 00 00 00 00 00 00 01 86 ba 00 00   ................
0070   00 01 00 00 00 01 00 00 00 14 00 00 00 01 ff ff   ................
0080   ff c0 ff ff ff a8 00 00 00 00 00 00 00 02         ..............

```

0x00 - 0x05 is the destination MAC ether broadcast.
0x06 - 0x0b is the source MAC address (the Sun3)
0x1a - 0x1d is the source IP (the sun3)
0x1e - 0x22 is the destination address (which should be c0a80001)


No idea why SunOS 4.1.1 (and 4.1.1u1) sends packets to the wrong address.