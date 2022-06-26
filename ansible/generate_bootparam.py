#!/bin/env python3

import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("hostname", help="Sun3 Hostname")
    parser.add_argument("addr", help="Server IP Address")
    parser.add_argument("maskbits", help="Network mask bits")
    args = parser.parse_args()

    # generate mask bits in hex
    mask = 0xffffffff
    for i in range(32 - int(args.maskbits)):
        mask <<= 1
    mask &= 0xffffffff    
    print(f"{args.hostname}  root={args.addr}:/srv/nfsroot/{args.hostname} gateway={args.addr}:0x{mask:x} swap={args.addr}:/srv/nfsroot/{args.hostname}/swapfile")


if __name__ == "__main__":
    main()