# Commodore Plus/4

The Commodore 264 series, consists of the Plus/4, Commodore 16, and Commodore 116.  These models use the TED chip for graphics and sound and have different memory configurations with more advanced banking than the Commodore 64.

The current Prog8 custom target is known to work with the Plus/4 and Commodore 16 (C16).  

Works:
 - Most of textio
 - Reading keypresses

Not working:
 - ROM banking (and RAM/ROM switching)
 - Disk or file I/O
 - Graphics
 - Sprites (no hardware sprites on this platform)
 - Sound
 - [everything else]


The Plus/4 has 64KB of RAM and has support for switching between all RAM and having ROM mapped.  Which ROMs are mapped can also be controlled, but is not yet supported by any Prog8 library modules. The C16 is very similar and has 16KB of RAM. There are a few other hardware differences, like the Plus/4 having a full ACIA serial UART, but we will generally be addressing common features with Prog8 libraries.

Due to the C16 having only 16KB of RAM versus the 64KB on the Plus/4, care must be taken when building for the C16 to include an appropriate `%memtop $3ff6` directive. The BASIC MEMTOP value on Plus/4 is $fd00 and $3ff6 on C16. This allows the compiler to warn you when your program is too large for available RAM.

With prog8  there is currently a single target that can be used for both the Plus/4 and C16. This is called `plus4` and is defined in the `config/plus4.properties` file. Programs built with this target have been tested in VICE on the Plus/4 and C16 and a single PRG will run on both as long as it fits in the available RAM on the C16.

## Building / Running for Commodore Plus/4

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_plus4.prg`.

To build manually you just need to specify the custom target file for `prog8c` to build the binary.

```
prog8c -target config/plus4.properties -out build/ -asmlist src/hello_plus4.p8
```

