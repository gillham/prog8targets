# MEGA65

The MEGA65 is a modern implementation of the Commodore 65 prototype computer that was never released.  The MEGA65 supports C64 / C65 / MEGA65 personalities.  This target is for the MEGA65 personality which has many C64 compatible devices like the SID plus additional capabilities and memory.  It is all wrapped up with a sophisticated banking / memory mapping system.  Only the bare minimum to boot and run is supported with the extra MEGA65 features but additional items will be implemented eventually.

If you want to target the C64 personality just use the normal Prog8 C64 target.

The current Prog8 custom target is known to work with the [Xemu MEGA65 emulator](https://github.lgb.hu/xemu/) as well as a recent hardware revision.

Works:
 - Most of textio
 - Reading keypresses
 - Simple disk or file I/O 

Not working:
 - Advanced DOS commands
 - Banking (using @bank and other builtin functionality)
 - Graphics
 - Sprites
 - Sound
 - UART
 - Networking
 - [everything else]

Since the MEGA65 has SID & VIC-II compatible hardware, simple graphics & sound support from the C64 should be easy to implement.  It just hasn't been done yet in the standard libraries.

The MEGA65 can have 384KB of fast chip memory and 8MB of attic ram depending on the exact revision.  This can be accessed directly but the standard libraries don't have any support yet.  The goal is to support a simple banking mechanism similar to the C64 (ROM/RAM/IO banking) or Commander X16 (RAM banking at $a000) but a full implementation is not planned.

## Building / Running for MEGA65

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_mega65.prg`.

To build manually you just need to specify the custom target file for `prog8c` to build the binary.

```
prog8c -target config/mega65.properties -out build/ -asmlist src/hello_mega65.p8
```

## Programming for the MEGA65

The MEGA65 team has an excellent book, referred to as the "Complete Compendium" [available to download](https://files.mega65.org/html/main.php?id=d668168c-1fef-4560-a530-77e9e237536d) on the MEGA65 filehost website.  It has a massive amount of technical detail on the MEGA65 and will be a critical reference during your development effort.

One important note is that the MEGA65 has a 45GS02 CPU (implemented in the FPGA) which is an enhanced version of the CSG 4510 from the Commodore 65 prototype which is itself based on the 65CE02 cpu.  Prog8 currently supports 6502, 65C02, and the 65C02 compatible mode of the 65816 processor.  Subsequently in the standard library for the MEGA65 where 45GS02 support is required for special assembly language mnemonics like MAP, a directive is used to tell the 64tass assembler to switch processors.
It looks something like this:
```
%asm {{
    .cpu "45gs02"
    LDA #00
    TAY
    TAX
    TAZ
    MAP
    EOM
    .cpu "6502"
}}
```

Note that it should be possible to specify the cpu as '65C02' since Prog8 supports that processor, but during the porting effort some odd codegen issues were noted and the decision was made to keep it at 6502 until the target was stable and revisit it. 

Also worth mentioning is that the 65CE02 has a `ROW` instruction which makes "row" a reserved word if that processor is used.  Since the Prog8 textio library has a row subroutine this causes issues with 65tass if the cpu is set to 45GS02 early.  That is another important reason for the 45GS02 assembler sections to be wrapped like shown above.  You will need to be mindful of this limitation if you use a lot of inline assembler with Prog8.
