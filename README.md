# prog8targets
Various custom targets for Prog8.

- F256 [Foenix F256](https://c256foenix.com/) 6502/65816 retro computer. Now [available](https://github.com/irmen/prog8/blob/master/examples/customtarget/targetconfigs/f256.properties) available in the main [Prog8](https://github.com/irmen/) repository.
- rp6502 [Picocomputer 6502](https://picocomputer.github.io/)
- SXB6 [WDC W65C816SXB SBC](https://wdc65xx.com/Single-Board-Computers/w65c816sxb/)
- Commodore VIC-20 with [different memory maps](https://sleepingelephant.com/denial/wiki/index.php/Memory_Map).
- Commander X16 or OtterX running [cx16os](https://github.com/cnelson20/cx16os) 


## Foenix F256

This target is preliminary with mostly textio support. It requires the microkernel and can be launched from SuperBasic, DOS, File Manager, etc.

Works:

 - Most textio output (no scroll_down/scroll_left/scroll_right)
 - Reading keyboard events (txt.waitkeys, GETIN, CHRIN, etc)

Not working:

 - Disk or file I/O
 - Graphics
 - Sprites
 - Sound
 - Memory banking (via MMU)
 - Networking
 - [everything else]

### Building / Running for F256

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_f256.pgz` which you need to move to your F256.

To build manually you just need to specify the custom target file:
```
prog8c -target config/f256.properties -out build/ -asmlist src/hello_f256.p8
```

Once you move `hello_f256.pgz` to your F256 (you might want to just call it hello.pgz) you run it from SuperBasic with `/- hello_f256.pgz` or just `/- hello_f256` or `/- hello` if you called it `hello.pgz`

## Picocomputer 6502

The Picocomputer 6502 (aka rp6502) has very preliminary support.  Currently just `cbm.CHROUT` based functionality (various txt.print calls) for output and `cbm.GETIN` for reading characters from the keyboard.

Works:

 - Minimal textio output.  Most `txt.print` that doesn't use color or fancy codes.
 - Reading keyboard events (txt.waitkeys, GETIN, CHRIN, etc)

Not working:

 - Everything else

### Building / Running for rp6502

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello.rp6502` which you need to move to your Picocomputer via USB flash drive or over the USB serial.

To build manually you just need to specify the custom target file for `prog8c` but then you need to use `tools/rp6502.py` to convert the compiled `.bin` file to a `.rp6502` file.

```
prog8c -target config/rp6502.properties -out build/ -asmlist src/hello_rp6502.p8
tools/rp6502.py create -o build/hello.rp6502 -a 0x0200 -r 0x0200 build/hello_rp6502.bin
```

You can then copy the `hello.rp6502` to a USB flash drive and insert it in your Picocomputer.  From the `]` prompt use `load hello.rp6502` to launch it.

The `tools/rp6502.py` script can upload the file to the rp6502 file-system or just run it directly. `tools/rp6502.py -c .rp6502 run build/hello.rp6502`

Note that the `rp6502.py` script may reset the rp6502 back to the `]` prompt when it closes the serial interface.  You may need to connect to the serial port and type `reset` or do that via the keyboard attached to the rp6502.

## WDC W65C816SXB

### Building / Running for W65C816SXB
Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_sxb6.bin` which you need to upload to your W65C816SXB via
the USB "TIDE" port and the `tools/sxb6` script.

To build manually you just need to specify the custom target file for `prog8c` to build the binary.

```
prog8c -target config/w65c816sxb.properties -out build/ -asmlist src/hello_sxb6.p8
```

You can then write ("upload") the file to ram on the W65C816SXB and run it using the `tools/sxb6` script. Check my [sxb repository](https://github.com/gillham/sxb) for more information about the script.

```
tools/sxb6 -d /dev/tty.usbserial-3 write 0x0200 build/hello_sxb6.bin
tools/sxb6 -d /dev/tty.usbserial-3 exec 0x0200
screen -L /dev/tty.usbserial-3 57600
```

## Commodore VIC-20

The Commodore VIC-20 has a somewhat complicated memory map with 3 different load addresses and various amounts of free memory.  And some missing memory in the map as well.  The VIC-20 memory map changes when using a memory expansion cartridge depending on its size.  There is a great expansion cartridge available called the [PenUltimate+](https://www.tfw8b.com/product/penultimate/) that is up to version 3.  It can fill in all of the VIC-20 memory holes and even expand it further.  Check it out.

Works:

 - Minimal textio output (txt.print*)
 - Reading keypresses

Not working:

 - Disk or file I/O
 - Graphics
 - Sprites
 - Sound
 - [everything else]


The [various memory map options](https://sleepingelephant.com/denial/wiki/index.php/Memory_Map) are too much to fully cover here, but I'll list enough information to explain the target configs.

The stock VIC-20 has 5KB of RAM.  The RAM is in the lowest 8KB footprint but 3KB of it is missing (hence the 5KB). The load address for the stock VIC-20 is $1001 which is right after the 3KB hole.

The simplest expansion for the VIC-20 just fills in the 3KB hole.  The 3KB expansion is available as just a RAM cartridge or as part of the Super Expander BASIC extension cartridge.  The load address with the 3KB hole filled in is $0401.

Finally larger expansions are generally in blocks of 8KB. These do not fill in the 3KB but just extend from the 8KB mark onwards.  The exception is the modern PenUltimate+ cartridge which has lots of tricks for expansion beyond the official Commodore cartridges from the 80s.
With the 8KB expansions the load address is $1201.  This is because the screen memory is moved to $1000 so it is always at the start of ram, no matter how many 8KB blocks are added.

With prog8 I am currently calling these three targets:
    - `vic20` is the stock 5KB system
    - `vic20plus3` is the stock system with the 3KB hole filled via an expansion
    - `vic20plus8` is the stock system with additonal 8KB blocks and the 3KB hole not filled in.

Note that there should probably be a target for each possible increment of expansion memory and one for the special modes the PenUltimate+ cartridge allows.  These extra targets can be added in the future as the VIC-20 support improves.  There is no reason to rush to create a ton of targets that partially work.  The three above are the bare minimum to support the different load addresses.

For memory configurations beyond the `vic20plus8` you'll need to adjust memtop. This can be done with `%memtop $8000` if you have a 24KB expansion.  Block 3 runs from $6000 to $7fff and memtop should be set to the next address ($8000) past the end of the block.

### Building / Running for Commodore VIC-20

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_vic20.bin`, `build/hello_vic20plus3.prg` and `build/hello_vic20plus8.prg`.

To build manually you just need to specify the custom target file for `prog8c` to build the binary.

```
prog8c -target config/vic20.properties -out build/ -asmlist src/hello_vic20.p8
prog8c -target config/vic20plus3.properties -out build/ -asmlist src/hello_vic20plus3.p8
prog8c -target config/vic20plus8.properties -out build/ -asmlist src/hello_vic20plus8.p8
```


## Commander X16 / OtterX running cx16os

IF you install an 65C816 (or an (OtterX cpu switcher)[https://www.tindie.com/products/wavicle/65xx-cpu-switcher-for-otterx-and-x16/]) in your Commander X16 or OtterX, you can run cx16os.

With cx16os you get a terminal based multitasking os with some Unix like features.
While cx16os requires a 65C816, the Prog8 compiler support is limited to the 65C02 emulation mode.
Prog8 does support inline assembler and the 64tass assembler supports 65C816 code.
As a result you can support 65C816 functionality via assembler and use an inline assembler
layer to support any calls that can't work in emulation mode.

The examples here just use 65C02 code as generated by the Prog8 compiler, but are not
particularly advanced.  They are meant to demonstrate the basic functionality.  They
do work fine without any special 65C816 handling.

The cx16os target is defined in the file `config/cx16os.properties` and there is also the file
`config/cx16os.24kb_properties` which is meant to support the larger memory mode (still 65C02)
but is still very preliminary.


### Building / Running for cx16os

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_cx16os.prg`, `build/arch.prg`, `build/pwd.prg`, and `build/uname.prg`.  These last three provide output
similar to Unix commands of the same name.

To build manually you just need to specify the custom target file for `prog8c` to build the binary.

```
prog8c -target config/cx16os.properties -out build/ -asmlist src/hello_cx16os.p8
prog8c -target config/cx16os.properties -out build/ -asmlist src/arch.p8
prog8c -target config/cx16os.properties -out build/ -asmlist src/pwd.p8
prog8c -target config/cx16os.properties -out build/ -asmlist src/uname.p8
```

The resulting files can be copied into your cx16os installation directory under bin.
For example under Linux or macOS you might use `cp build/uname.prg OS/bin/uname` if
you have an installation of cx16os in the `OS` directory.

To use the simple cx16os examples just run `make` and they will be in build/.
If you download the latest cx16os and unzip it here you will have an `OS` directory.
You can then use the command line below to boot cx16os.

`x16emu -debug -quality best -scale 2 -rtc -c816 -nvram nvram.bin -fsroot OS/`

#### Running cx16os examples

Included in the examples are `arch`, `hello`, `pwd` (I name it `pwd8` to test it), and `uname`.
These are like their Linux/Unix counterparts except `hello` which just prints a "Hello World" style
message.

The `uname` command takes various arguments and prints information about the system.  Try `uname -a` to get all of the information available.

Arguments:
```
    -a all available info
    -b total banks / memory
    -i hardware platform
    -k kernal version
    -m architecture
    -o operating system
    -p architecture
    -r kernal version
    -s SMC version
    -v VERA version
```

### cx16os libraries

This is currently just copies of a few Commander X16 native libraries with very minor adjustments. These will be slowly converted over to support cx16os API calls more fully.

Just minimal chrout / chrin support is working for cx16os.  That allows a lot of the textio library to work, at least partially.

## cx16os "include" files

Currently there is `os.p8` which defines various cx16os api calls as `extsub` stubs.
These will get arguments and return values added as the functions are used / needed.



