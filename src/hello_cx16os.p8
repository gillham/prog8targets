;
; Minimal example cx16os application.
;
%import textio

main {
    str hello = "Hello, World!  (From Prog8)"

     sub start() {
        txt.print(hello)
        txt.nl()
    }
}

