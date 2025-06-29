#!/usr/bin/env python3

import argparse


def gen_reg(offset):
    print("; the sixteen virtual 16-bit registers in both normal unsigned mode and signed mode (s)")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &uword r{i}  = ${offset+i*2:04x}")
        else:
            print(f"    &uword r{i} = ${offset+i*2:04x}")
    print("")

def gen_word(offset):
    print("    ; signed word versions")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &word r{i}s  = ${offset+i*2:04x}")
        else:
            print(f"    &word r{i}s = ${offset+i*2:04x}")
    print("")

def gen_ubyte(offset):
    print("    ; ubyte versions (low and high bytes)")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &ubyte r{i}L  = ${offset+i*2:04x}")
        else:
            print(f"    &ubyte r{i}L = ${offset+i*2:04x}")
    print("")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &ubyte r{i}H  = ${offset+1+i*2:04x}")
        else:
            print(f"    &ubyte r{i}H = ${offset+1+i*2:04x}")
    print("")

def gen_byte(offset):
    print("    ; signed byte versions (low and high bytes)")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &byte r{i}sL  = ${offset+i*2:04x}")
        else:
            print(f"    &byte r{i}sL = ${offset+i*2:04x}")
    print("")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &byte r{i}sH  = ${offset+1+i*2:04x}")
        else:
            print(f"    &byte r{i}sH = ${offset+1+i*2:04x}")
    print("")

def gen_bool(offset):
    print("    ; boolean versions")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &bool r{i}bL  = ${offset+i*2:04x}")
        else:
            print(f"    &bool r{i}bL = ${offset+i*2:04x}")
    print("")
    for i in range(16):
        #print("i:", i)
        if i < 10:
            print(f"    &bool r{i}bH  = ${offset+1+i*2:04x}")
        else:
            print(f"    &bool r{i}bH = ${offset+1+i*2:04x}")
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
