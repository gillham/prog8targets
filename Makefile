#
# Simple Makefile for a Prog8 program.
#

# Cross-platform removal command
ifeq ($(OS),Windows_NT)
    CLEAN = del /Q build\* 
    CP = copy
    RM = del /Q
    MD = mkdir
else
    CLEAN = rm -f build/*
    CP = cp -p
    RM = rm -f
    MD = mkdir -p
endif

PCC=prog8c
PCCARGSF256=-srcdirs src -asmlist -target f256.properties -out build
PCCARGSRP6502=-srcdirs src -asmlist -target rp6502.properties -out build
PCCARGSSXB6=-srcdirs src -asmlist -target w65c816sxb.properties -out build

PROGS	= build/hello_f256.pgz build/hello.rp6502 build/hello_sxb6.bin

all: build $(PROGS)
rp6502: build build/hello.rp6502 run-rp6502 screenrp6502
sxb6: build build/hello_sxb6.bin run-sxb6 screensxb6

build:
	$(MD) build/

build/hello_f256.pgz: build/hello_f256.bin
	${CP} $< $@

build/hello_f256.bin: src/hello_f256.p8
	$(PCC) $(PCCARGSF256) $<

build/hello.rp6502: build/hello_rp6502.bin
	tools/rp6502.py create -o $@ -a 0x0200 -r 0x0200 $<

build/hello_rp6502.bin: src/hello_rp6502.p8
	$(PCC) $(PCCARGSRP6502) $<

build/hello_sxb6.bin: src/hello_sxb6.p8
	$(PCC) $(PCCARGSSXB6) $<

clean:
	$(RM) build/*

run-rp6502: build/hello.rp6502
	tools/rp6502.py -c .rp6502 run $<

run-sxb6: build/hello_sxb6.bin
	tools/sxb6 -d /dev/tty.usbserial-3 write 0x0200 $<
	tools/sxb6 -d /dev/tty.usbserial-3 exec 0x0200

screenrp6502:
	screen /dev/tty.usbmodem2101 115200

screensxb6:
	screen /dev/tty.usbserial-3 57600

#
# end-of-file
#
