;
; Prints the cpu architecture.
; Only a 65816 can run cx16os so calling
; cpu_is_65816() is mostly pointless.
;
%import textio

main {
     sub start() {
        if cx16.cpu_is_65816()
            txt.print("65816")
        else
            txt.print("65C02")
        txt.nl()
    }
}
