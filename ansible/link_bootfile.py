#!/bin/env python3
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("bootfile", help="Boot file to use in /srv/tftp")
    parser.add_argument("ip", help="IP address of client")
    args = parser.parse_args()

    # make sure it's a valid bootfile
    bootfile = Path("/srv/tftp", args.bootfile)
    if not bootfile.exists():
        print("Bootfile {args.bootfile} doesn't exist")
        exit(1)

    # convert the IP address to a hex number
    hexaddr = "".join([f"{int(x):02X}" for x in args.ip.split('.')])
    hexfile = Path("/srv/tftp", hexaddr)
    if hexfile.exists():
        hexfile.unlink()
    bootfile.link_to(hexfile)
    


if __name__ == "__main__":
    main()