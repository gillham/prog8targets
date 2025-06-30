;
; Simplistic example of textio output and reading keyboard input.
;
%launcher none
%import textio

main {
    sub start() {
        ubyte i
        ubyte key

        txt.cls()

        txt.nl()
        txt.print("Hello World! From Prog8.")
        txt.nl()

        txt.nl()
        repeat 5 {
            for i in 32 to 127 {
                txt.chrout(i)
            }
        }
        txt.nl()


        txt.nl()
        txt.print("Press any key to continue...")
        void txt.waitkey()
        txt.nl()

        txt.nl()
        txt.print("Press keys to show them, ctrl-c resets machine.")
        txt.nl()

        ; look for keys forever
        repeat {
            void, key = cbm.GETIN()

            if key != $00 {
                ;txt.plot(0,40)
                txt.print("key: ")
                txt.chrout(key)
                txt.spc()
                txt.print_ubhex(key, true)
                txt.nl()    ; remove after plot() works
            }

            ; ctrl-c exits / resets machine
            if key == $03
                break
        }
    }
}
