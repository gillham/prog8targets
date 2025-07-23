# WDC W65C816SXB

## Building / Running for W65C816SXB
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

