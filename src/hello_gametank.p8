%launcher none
%import textio
%option romable

main {
    sub start() {
        ubyte color=0
        uword j
        ubyte i


        ;sys.memset(gametank.SCREENRAM, $ff, txt.vcolor)
        ;sys.memset(gametank.SCREENRAM, $4000, $00)

        txt.plot(0,0)
        txt.rvs_on()
        txt.print("Hello")
        txt.rvs_off()
        txt.print(" World!")
        txt.nl()

        const ubyte YELLOW  = 0 << 5
        const ubyte ORANGE  = 1 << 5
        const ubyte RED     = 2 << 5
        const ubyte MAGENTA = 3 << 5
        const ubyte VIOLET  = 4 << 5
        const ubyte BLUE    = 5 << 5
        const ubyte CYAN    = 6 << 5
        const ubyte GREEN   = 7 << 5

        const ubyte COLOR_YELLOW = YELLOW | %00011000 | %00000111
        const ubyte COLOR_GREEN = GREEN | %00011000 | %00000101

        ubyte LUMA = %00000101
        ubyte SATU = %00011000

        txt.plot(0,4)

        ;txt.vcolor = LUMA | SATU | YELLOW
        txt.vcolor = COLOR_YELLOW
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | ORANGE
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | RED
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | MAGENTA
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | VIOLET
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | BLUE
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | CYAN
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = LUMA | SATU | GREEN
        for i in 0 to 23 {
            txt.chrout('A')
        }

        txt.vcolor = 7
        txt.setchr(15,15, 'A')
        txt.setclr(15,15, 40)

        txt.setcc(16,16, 'B', 63)
        txt.setcc(17,17, txt.getchr(16,16), txt.getclr(16,16))

        ubyte gp1a
        ubyte gp1b
        ubyte key
        repeat {
            gp1a = gametank.GAMEPAD2    ; read throw-away to reset select on *other* controller
            gp1a = gametank.GAMEPAD1    ; read 1st buttons
            gp1b = gametank.GAMEPAD1    ; read 2nd buttons
            key = cbm.GETIN2()
            txt.plot(1,18)
            txt.print_ubbin(gp1a, false)
            txt.spc()
            txt.print_ubbin(gp1b, false)
            txt.spc()
            txt.print_ubhex(key, false)
        }
        repeat {}
    }
}

cbm {
%option merge

inline asmsub GETIN2() clobbers(X,Y) -> ubyte @A {
    ; -- just like GETIN, but omits the carry flag result value.
    ;    just for convenience because GETIN is so often used to just read keyboard input,
    ;    where you don't have to deal with a potential error status
    %asm {{
        phx
        phy
        lda  gametank.GAMEPAD2  ; causes *other* controller to reset select line
        lda  gametank.GAMEPAD1  ; read 1st set of buttons
        ldx  gametank.GAMEPAD1  ; read 2nd set of buttons
        ; check for dpad/buttons
        tay ; stash 1st byte
        txa ; move 2nd byte
        and  #%00000001         ; dpad_right
        bne  +
        lda  #'d'
        jmp  _done
+       txa
        and  #%00000010         ; dpad_left
        bne  +
        lda  #'a'
        jmp  _done
+       txa
        and  #%00000100         ; dpad_down
        bne  +
        lda  #'s'
        jmp  _done
+       txa
        and  #%00001000         ; dpad_up
        bne  +
        lda  #'w'
        jmp  _done
+       txa
        and  #%00010000         ; button_x
        bne  +
        lda  #'f'
        jmp  _done
+       txa
        and  #%00100000         ; button_c
        bne  +
        lda  #' '
        jmp  _done
+       tya  ; get 1st byte
        and  #%00010000         ; button_z (1st byte)
        bne  +
        lda  #'2'
        jmp  _done
+       tya
        and  #%00100000         ; button_enter (1st byte)
        bne  +
        lda  #'1'
        jmp  _done
+       lda  #0
_done   nop
        ply
        plx
    }}
}


}
