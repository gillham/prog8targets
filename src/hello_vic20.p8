;
; Hello, World!
;

%zeropage basicsafe
;%zeropage dontuse
;%option no_sysinit

%import textio

main {
     sub start() {
        txt.print("Hello, World!")
        txt.nl()
        void txt.waitkey()
        txt.lowercase()
        void txt.waitkey()
        txt.uppercase()
        txt.print("later, world!")
        txt.nl()
     }
}
