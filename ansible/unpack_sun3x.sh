#!/bin/bash
# Untested!
SUN3HOME=$1
SUN3ARC=/srv/sunos_411_dist

cd $SUN3HOME
tar -xzf $SUN3ARC/sun3x/sun3_proto_root.sunos_4_1_1.tar.Z
mkdir usr
cd usr
tar -xzf $SUN3ARC/sun3x/sun3_usr.tar.Z 
mkdir kvm
cd kvm
tar -xzf $SUN3ARC/sun3x/sun3x_kvm.tar.Z
tar -xzf $SUN3ARC/sun3x/sun3x_sys.tar.Z
cd $SUN3HOME/usr
tar -xzf $SUN3ARC/sun3x/sun3_install.tar.Z
tar -xzf $SUN3ARC/sun3x/sun3_manual.tar.Z
tar -xzf $SUN3ARC/sun3x/sun3_text.tar.Z
tar -xzf $SUN3ARC/sun3x/sun3_networking.tar.Z
cd $SUN3HOME
ln -s usr/kvm/stand/vmunix .
cp $SUN3ARC/sun3x/miniroot_sun3x .
cp $SUN3ARC/sun3x/munix* .
cd dev
./MAKEDEV std
cp usr/kvm/stand/boot.sun3x /tftpboot