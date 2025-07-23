# Picocomputer 6502

The Picocomputer 6502 (aka rp6502) has very preliminary support.  Currently just `cbm.CHROUT` based functionality (various txt.print calls) for output and `cbm.GETIN` for reading characters from the keyboard.

Works:

 - Minimal textio output.  Most `txt.print` that doesn't use color or fancy codes.
 - Reading keyboard events (txt.waitkeys, GETIN, CHRIN, etc)

Not working:

 - Everything else

## Building / Running for rp6502

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello.rp6502` which you need to move to your Picocomputer via USB flash drive or over the USB serial.

To build manually you just need to specify the custom target file for `prog8c` but then you need to use `tools/rp6502.py` to convert the compiled `.bin` file to a `.rp6502` file.

```
prog8c -target config/rp6502.properties -out build/ -asmlist src/hello_rp6502.p8
tools/rp6502.py create -o build/hello.rp6502 -a 0x0200 -r 0x0200 build/hello_rp6502.bin
```

You can then copy the `hello.rp6502` to a USB flash drive and insert it in your Picocomputer.  From the `]` prompt use `load hello.rp6502` to launch it.

The `tools/rp6502.py` script can upload the file to the rp6502 file-system or just run it directly. `tools/rp6502.py -c .rp6502 run build/hello.rp6502`

Note that the `rp6502.py` script may reset the rp6502 back to the `]` prompt when it closes the serial interface.  You may need to connect to the serial port and type `reset` or do that via the keyboard attached to the rp6502.

