#!/usr/bin/env python3

import argparse


def gen_reg(offset):
    print("; the sixteen virtual 16-bit registers in both normal unsigned mode and signed mode (s)")
    for i in range(16):
        print(f"    &uword r{i:<2} = ${offset+i*2:04x}")
    print("")

def gen_word(offset):
    print("    ; signed word versions")
    for i in range(16):
        print(f"    &word r{f'{i}s':<3} = ${offset+i*2:04x}")
    print("")

def gen_ubyte(offset):
    print("    ; ubyte versions (low and high bytes)")
    for i in range(16):
        #print("i:", i)
        print(f"    &ubyte r{f'{i}L':<3} = ${offset+i*2:04x}")
    print("")
    for i in range(16):
        print(f"    &ubyte r{f'{i}H':<3} = ${offset+1+i*2:04x}")
    print("")

def gen_byte(offset):
    print("    ; signed byte versions (low and high bytes)")
    for i in range(16):
        print(f"    &byte r{f'{i}sL':<4} = ${offset+i*2:04x}")
    print("")
    for i in range(16):
        #print("i:", i)
        print(f"    &byte r{f'{i}sH':<4} = ${offset+1+i*2:04x}")
    print("")

def gen_bool(offset):
    print("    ; boolean versions")
    for i in range(16):
        #print("i:", i)
        print(f"    &bool r{f'{i}bL':<4} = ${offset+i*2:04x}")
    print("")
    for i in range(16):
        #print("i:", i)
        print(f"    &bool r{f'{i}bH':<4} = ${offset+1+i*2:04x}")
    print("")



def main():
    parser = argparse.ArgumentParser( prog='gen_syslib', description='Generates CX16 registers for Prog8 syslib', epilog='Check GitHub Issues.')
    parser.add_argument('start')    # starting byte in hex, no prefix
    args = parser.parse_args()
    start = int(args.start, 16)
    #print(start)
    gen_reg(start)
    gen_word(start)
    gen_ubyte(start)
    gen_byte(start)
    gen_bool(start)



if __name__  == "__main__":
    main()
