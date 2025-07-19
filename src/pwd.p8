;
; Minimal example cx16os application.
;
%import textio
%import os

main {
    uword pathbuf = memory("pathbuf", 128, 0)

     sub start() {
        os.get_pwd(pathbuf, 128)
        txt.print(pathbuf)
        txt.nl()
    }
}

