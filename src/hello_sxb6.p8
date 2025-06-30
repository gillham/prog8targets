%launcher none
;%import syslib
;%zeropage basicsafe

main {
    sub start() {
        ubyte char

        cbm.CHROUT(14)  ; lowercase
        for char in "\nHello, World! From Prog8.\n" {
            cbm.CHROUT(char)
        }
    }
}
