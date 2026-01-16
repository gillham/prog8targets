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

PCC=prog8c -srcdirs src -asmlist -out build
PCCARGSF256=-target config/f256.properties
PCCARGSRP6502=-target config/rp6502.properties
PCCARGSSXB6=-target config/w65c816sxb.properties
PCCARGSVIC20=-target config/vic20.properties
PCCARGSVIC20P3=-target config/vic20plus3.properties
PCCARGSVIC20P8=-target config/vic20plus8.properties
PCCARGSCX16OS=-target config/cx16os.properties
PCCARGSPLUS4=-target config/plus4.properties
PCCARGSMEGA65=-target config/mega65.properties
PCCARGSGTRC=-target config/gametank.properties -varsgolden -slabsgolden

PROGS	= build/hello_f256.pgz build/hello.rp6502 build/hello_sxb6.bin \
	  build/hello_vic20.prg build/hello_vic20plus3.prg build/hello_vic20plus8.prg \
	  build/hello_cx16os.prg build/hello_plus4.prg build/hello_mega65.prg \
	  build/hello_gametank.bin  build/arch.prg build/pwd.prg build/uname.prg

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

build/hello_vic20.prg: src/hello_vic20.p8
	$(PCC) $(PCCARGSVIC20) $<

build/hello_vic20plus3.prg: src/hello_vic20plus3.p8
	$(PCC) $(PCCARGSVIC20P3) $<

build/hello_vic20plus8.prg: src/hello_vic20plus8.p8
	$(PCC) $(PCCARGSVIC20P8) $<

build/hello_cx16os.prg: src/hello_cx16os.p8
	$(PCC) $(PCCARGSCX16OS) $<

build/hello_plus4.prg: src/hello_plus4.p8
	$(PCC) $(PCCARGSPLUS4) $<

build/hello_mega65.prg: src/hello_mega65.p8
	$(PCC) $(PCCARGSMEGA65) $<

build/hello_gametank.bin: src/hello_gametank.p8
	$(PCC) $(PCCARGSGTRC) $<

build/arch.prg: src/arch.p8
	$(PCC) $(PCCARGSCX16OS) $<

build/pwd.prg: src/pwd.p8
	$(PCC) $(PCCARGSCX16OS) $<

build/uname.prg: src/uname.p8
	$(PCC) $(PCCARGSCX16OS) $<

clean:
	$(RM) build/*

emu-gametank: build/hello_gametank.bin
	gte $<

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
