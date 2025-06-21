#!/bin/sh

PCC=prog8c

mkdir -p build/

${PCC} -target ./f256.properties -out build/ -asmlist src/hello_f256.p8 || exit 1
${PCC} -target ./f256.properties -out build/ -asmlist src/tehtriz_f256.p8 || exit 1

mdel f:hello.pgz
mcopy build/hello_f256.bin f:hello.pgz

#mdel f:tehtriz.pgz
#mcopy build/tehtriz_f256.bin f:tehtriz.pgz

