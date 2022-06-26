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


Serial Port A is 9600 baud by default.  I've set the norm/diag switch to diag so I have to hit a key to get to the boot prom (normal doesn't return anything)

## Getting the Sun MAC address

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



## Using the image

TBD



## Building the Pi Image

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