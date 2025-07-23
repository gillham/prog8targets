# Commodore VIC-20

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

## Building / Running for Commodore VIC-20

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_vic20.bin`, `build/hello_vic20plus3.prg` and `build/hello_vic20plus8.prg`.

To build manually you just need to specify the custom target file for `prog8c` to build the binary.

```
prog8c -target config/vic20.properties -out build/ -asmlist src/hello_vic20.p8
prog8c -target config/vic20plus3.properties -out build/ -asmlist src/hello_vic20plus3.p8
prog8c -target config/vic20plus8.properties -out build/ -asmlist src/hello_vic20plus8.p8
```

