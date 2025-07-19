# CX16 OS support for Prog8

## Prog8 system libraries

This is currently just copies of a few Commander X16 native libraries with very
minor adjustments.  These will be slowly converted over to support cx16os.

Just minimal chrout / chrin support is working for cx16os.  That allows a lot of
the textio library to work, at least partially.

## "Include" files

This is currently just `os.p8` which defines various cx16os api calls as `extsub` stubs.
These will get arguments and return values added as the functions are used / needed.

## License

The original Prog8 license applies to the files that are modified copies from
the official repository.

Not `os.p8` which was created independently from cx16os documentation.

