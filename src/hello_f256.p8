%output library
%launcher none
%option no_sysinit
%import textio
;%import strings

main {
    str hello = "Hello, World from Prog8!"

    sub start() {
        ubyte i

        for i in 32 to 63 {
            txt.clear_screenchars(i)
        }


        txt.fill_screen(' ', $2f)

        txt.print(hello)
        txt.nl()
        txt.nl()
        txt.nl()
        txt.print("This is a test....")
        txt.nl()

        txt.setchr(20, 20, 'A')
        txt.setchr(21, 21, 'B')
        txt.setchr(22, 22, 'C')

        txt.setchr(25, 25, txt.getchr(20, 20))
        txt.setchr(26, 26, txt.getchr(21, 21))
        txt.setchr(27, 27, txt.getchr(22, 22))

        txt.setclr(20,20, $f3)
        txt.setclr(21,21, $f4)
        txt.setclr(22,22, $f5)

        txt.setclr(25,25, txt.getclr(20,20))
        txt.setclr(26,26, txt.getclr(21,21))
        txt.setclr(27,27, txt.getclr(22,22))

        txt.print("Second print message.\n")

        txt.print("screen_ptr: ")
        txt.spc()
        txt.print_uwhex(txt.screen_ptr, true)
        txt.spc()

        repeat {}           ; just halt for now
    }
}

