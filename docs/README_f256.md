# Foenix F256

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

## Building / Running for F256

Use the `Makefile` (by running `make`) if you can and it will generate `build/hello_f256.pgz` which you need to move to your F256.

To build manually you just need to specify the custom target file:
```
prog8c -target config/f256.properties -out build/ -asmlist src/hello_f256.p8
```

Once you move `hello_f256.pgz` to your F256 (you might want to just call it hello.pgz) you run it from SuperBasic with `/- hello_f256.pgz` or just `/- hello_f256` or `/- hello` if you called it `hello.pgz`

