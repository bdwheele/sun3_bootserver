#!/bin/bash -x

NETBSD=/srv/netbsd-9.2
SUN3HOME=$1

# Copy the boot stuff
gunzip -c $NETBSD/miniroot.fs.gz > /srv/tftp/miniroot.fs
cp $NETBSD/netboot /srv/tftp
gunzip -c $NETBSD/netbsd-DISKLESS3X.gz > $SUN3HOME/netbsd.sun3x
gunzip -c $NETBSD/netbsd-DISKLESS.gz > $SUN3HOME/netbsd.sun3

# use the included dev directory to populate the dev directory for
# the client.
tar -xvf ../resources/netbsd_9.2_dev.tar -C $SUN3HOME

# install the rest of the packages.
pushd $SUN3HOME
for n in base etc man comp misc games text modules rescue; do
    tar -xf $NETBSD/$n.tgz
    echo
done

exit

# packages not installed:
#debug.tgz
#tests.tgz
#xbase.tgz
#xcomp.tgz
#xdebug.tgz
#xetc.tgz
#xfont.tgz
#xserver.tgz
