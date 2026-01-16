; Prog8 definitions for the Minicube 64 fantasy console
; Including memory registers, I/O registers, Basic and Kernal subroutines.

%option no_symbol_prefixing, ignore_unused

cbm {
    ; Commodore (CBM) common variables, vectors and kernal routines

        &ubyte  TIME_HI         = $ed       ; software jiffy clock, hi byte
        &ubyte  TIME_MID        = $ee       ;  .. mid byte
        &ubyte  TIME_LO         = $ef       ;    .. lo byte. Updated by IRQ every 1/60 sec


inline asmsub STOP2() clobbers(X,A) -> bool @Pz  {
    ; -- just like STOP, but omits the special keys result value in A.
    ;    just for convenience because most of the times you're only interested in the stop pressed or not status.
    %asm {{
        ;jsr  cbm.STOP
    }}
}

inline asmsub GETIN2() clobbers(X,Y) -> ubyte @A {
    ; -- just like GETIN, but omits the carry flag result value.
    ;    just for convenience because GETIN is so often used to just read keyboard input,
    ;    where you don't have to deal with a potential error status
    %asm {{
        lda  mc64.INPUT1
    }}
}

asmsub RDTIM16() clobbers(X) -> uword @AY {
    ; --  like RDTIM() but only returning the lower 16 bits in AY for convenience
    %asm {{
        jsr  cbm.RDTIM
        pha
        txa
        tay
        pla
        rts
    }}
}

asmsub SETTIML(long jiffies @R0R1) {
    ; -- just like SETTIM, but with a single 32 bit (lower 24 bits used) argument.
    %asm {{
        lda  cx16.r0
        ldx  cx16.r0+1
        ldy  cx16.r0+2
        jmp  SETTIM
    }}
}

asmsub RDTIML() clobbers(X) -> long @R0R1 {
    ; --  like RDTIM() and returning the timer value as a 32 bit (lower 24 bits used) value.
    %asm {{
        jsr  RDTIM
        sta  cx16.r0
        stx  cx16.r0+1
        sty  cx16.r0+2
        lda  #0
        sta  cx16.r0+3
        rts
    }}
}

sub CLEARST() {
    ; -- Set the ST status variable back to 0. (there's no direct kernal call for this)
    ;    Note: a drive error state (blinking led) isn't cleared! You can use diskio.status() to clear that.
;    SETNAM(0, $0000)
;    SETLFS(15, 3, 15)
;    void OPEN()
;    CLOSE(15)
}

asmsub kbdbuf_clear() {
    ; -- convenience helper routine to clear the keyboard buffer
    %asm {{
-       jsr  GETIN
        cmp  #0
        bne  -
        rts
    }}
}

}

mc64 {
        const uword Screen  = $ed00
        const uword Color   = $ee00
        const uword Palette = $ef00
        const uword Bitmap  = $f000

        ; minicube64 I/O registers (...)
        &ubyte  VIDEO           = $0100         ; VIDEO memory block
        &ubyte  COLORS          = $0101         ; COLORS memory block
        &uword  INPUT           = $0102         ; INPUT (controllers)
        &ubyte  INPUT1          = $0102         ; INPUT controller 1
        &ubyte  INPUT2          = $0103         ; INPUT controller 2
        &ubyte  AUDIO           = $0104

        ; IRQ vectors are not at normal 6502 spot
        &uword  NMI_IRQ         = $010c
        &uword  VBLANK_IRQ      = $010e

        &ubyte  AUDIO_REGS      = $0110
        &ubyte  AUDIO_VOLUMES   = $0111
        &ubyte  AUDIO_CHANNEL1  = $0112
        &ubyte  AUDIO_CHANNEL2  = $0112+4
        &ubyte  AUDIO_CHANNEL3  = $0112+8
        &ubyte  AUDIO_CHANNEL4  = $0112+12

}

%import shared_sys_functions

sys {
    ; ------- lowlevel system routines --------

    const ubyte target = 4          ;  compilation target specifier.  255=virtual, 128=C128, 64=C64, 32=PET, 25=Foenix F256, 20=plus4, 16=CommanderX16, 8=atari800XL, 7=Neo6502, 6=wdcsxb6, 5=rp6502, 4=Plus/4+C16

    const ubyte SIZEOF_BOOL  = 1
    const ubyte SIZEOF_BYTE  = 1
    const ubyte SIZEOF_UBYTE = 1
    const ubyte SIZEOF_WORD  = 2
    const ubyte SIZEOF_UWORD = 2
    const ubyte SIZEOF_FLOAT = 5
    const byte  MIN_BYTE     = -128
    const byte  MAX_BYTE     = 127
    const ubyte MIN_UBYTE    = 0
    const ubyte MAX_UBYTE    = 255
    const word  MIN_WORD     = -32768
    const word  MAX_WORD     = 32767
    const uword MIN_UWORD    = 0
    const uword MAX_UWORD    = 65535
    ; MIN_FLOAT and MAX_FLOAT are defined in the floats module if imported


    sub  disable_runstop_and_charsetswitch() {
        p8_sys_startup.disable_runstop_and_charsetswitch()
    }

    sub  enable_runstop_and_charsetswitch() {
        p8_sys_startup.enable_runstop_and_charsetswitch()
    }

asmsub  set_irq(uword handler @AY) clobbers(A)  {
	%asm {{
	    php
	    sei
        sta  _vector
        sty  _vector+1
		lda  #<_irq_handler
		sta  cbm.CINV
		lda  #>_irq_handler
		sta  cbm.CINV+1
		plp
		rts
_irq_handler
        jsr  sys.save_prog8_internals
        cld

        jsr  _run_custom
        pha
		jsr  sys.restore_prog8_internals
		pla
		beq  +                  ; skip default IRQ handler
		jmp  cbm.IRQDFRT	; continue with normal kernal irq routine
+		lda  mc64.TEDIRR       ; read interrupt status register
		sta  mc64.TEDIRR       ; write same value to clear active interrupts
		pla
		tay
		pla
		tax
		pla
		rti

_run_custom
		jmp  (_vector)
		.section BSS
_vector	.word ?
		.send BSS
        ; !notreached!
    }}
}

asmsub  restore_irq() clobbers(A) {
	%asm {{
	    php
		sei
		lda  #<cbm.IRQDFRT
		sta  cbm.CINV
		lda  #>cbm.IRQDFRT
		sta  cbm.CINV+1
		lda  #%00000010
		sta  mc64.TEDIER 	; restore only raster irq
		plp
		rts
	}}
}

asmsub  set_rasterirq(uword handler @AY, uword rasterpos @R0) clobbers(A) {
	%asm {{
	    php
	    sei
        sta  user_vector
        sty  user_vector+1
        lda  cx16.r0
        ldy  cx16.r0+1
		jsr  sys.set_rasterline
 		;lda  #%00000001
		;sta  mc64.IREQMASK   ; enable raster interrupt signals from vic

        lda  #<_raster_irq_handler
        sta  cbm.CINV
        lda  #>_raster_irq_handler
        sta  cbm.CINV+1
        plp
        rts

_raster_irq_handler
		jsr  sys.save_prog8_internals
		cld

        jsr  _run_custom
        pha
        jsr  sys.restore_prog8_internals
        lda  #$02
        sta  mc64.TEDIRR			; acknowledge raster irq
        pla
        beq  +
		jmp  cbm.IRQDFRT                ; continue with kernal irq routine
+		pla
		tay
		pla
		tax
		pla
		rti

_run_custom
		jmp  (user_vector)
		.section BSS
user_vector	.word ?
		.send BSS

		; !notreached!
	}}
}

    asmsub update_rasterirq(uword handler @AY, uword rasterpos @R0) clobbers(A) {
        ; -- just update the IRQ handler and raster line position for the raster IRQ
        ;    this is much more efficient than calling set_rasterirq() again every time.
        ;    (but you have to call that one initially at least once to setup the prog8 handler itself)
        %asm {{
            php
            sei
            sta  sys.set_rasterirq.user_vector
            sty  sys.set_rasterirq.user_vector+1
            lda  cx16.r0L
            ldy  cx16.r0H
            jsr  sys.set_rasterline
            plp
            rts
        }}
    }

asmsub  set_rasterline(uword line @AY) {
    ; -- only set a new raster line for the raster IRQ
    %asm {{
        sta  mc64.RASTER     ; set the raster line number where interrupt should occur
        lda  mc64.SCROLY
        and  #%01111111
        cpy  #0
        beq  +
        ora  #%10000000
+       sta  mc64.SCROLY     ; clear most significant bit of raster position
        rts
    }}
}


    asmsub reset_system()  {
        ; Soft-reset the system back to initial power-on Basic prompt.
        %asm {{
            sei
            jmp  cbm.RESET      ; Jump to reset vector?
        }}
    }

    asmsub wait(uword jiffies @AY) {
        ; --- wait approximately the given number of jiffies (1/60th seconds) (N or N+1)
        ;     note: the system irq handler has to be active for this to work as it depends on the system jiffy clock
        %asm {{
            stx  P8ZP_SCRATCH_B1
            sta  P8ZP_SCRATCH_W1
            sty  P8ZP_SCRATCH_W1+1

_loop       lda  P8ZP_SCRATCH_W1
            ora  P8ZP_SCRATCH_W1+1
            bne  +
            ldx  P8ZP_SCRATCH_B1
            rts

+           lda  cbm.TIME_LO
            sta  P8ZP_SCRATCH_B1
-           lda  cbm.TIME_LO
            cmp  P8ZP_SCRATCH_B1
            beq  -

            lda  P8ZP_SCRATCH_W1
            bne  +
            dec  P8ZP_SCRATCH_W1+1
+           dec  P8ZP_SCRATCH_W1
            jmp  _loop
        }}
    }

    asmsub waitvsync() clobbers(A) {
        ; --- busy wait till the next vsync has occurred (approximately), without depending on custom irq handling.
        ;     note: a more accurate way to wait for vsync is to set up a vsync irq handler instead.
        %asm {{
-           lda  mc64.RSTL8    ; highest bit of raster line
            and  #%00000001
            beq  -
-           lda  mc64.RSTL8    ; highest bit of raster line
            and  #%00000001
            bne  -
            rts
        }}
    }

    inline asmsub waitrastborder() {
        ; --- busy wait till the raster position has reached the bottom screen border (approximately)
        ;     note: a more accurate way to do this is by using a raster irq handler instead.
        %asm {{
-           lda  mc64.RSTL8    ; highest bit of raster line
            and  #%00000001
            beq  -
        }}
    }

    asmsub waitrasterline(uword line @AY) {
        ; -- CPU busy wait until the given raster line is reached
        %asm {{
            cpy  #0
            bne  _larger
-           cmp  mc64.RASTER
            bne  -
            bit  mc64.SCROLY
            bmi  -
            rts
_larger
            cmp  mc64.RASTER
            bne  _larger
            bit  mc64.SCROLY
            bpl  _larger
            rts
        }}
    }

    inline asmsub disable_caseswitch() {
        %asm {{
            lda  #$80
            sta  1351
        }}
    }

    inline asmsub enable_caseswitch() {
        %asm {{
            lda  #0
            sta  1351
        }}
    }

    asmsub exit(ubyte returnvalue @A) {
        ; -- immediately exit the program with a return code in the A register
        %asm {{
            sta  p8_sys_startup.cleanup_at_exit._exitcode
            ldx  prog8_lib.orig_stackpointer
            txs
            jmp  p8_sys_startup.cleanup_at_exit
        }}
    }

    asmsub exit2(ubyte resulta @A, ubyte resultx @X, ubyte resulty @Y) {
        ; -- immediately exit the program with result values in the A, X and Y registers.
        %asm {{
            sta  p8_sys_startup.cleanup_at_exit._exitcode
            stx  p8_sys_startup.cleanup_at_exit._exitcodeX
            sty  p8_sys_startup.cleanup_at_exit._exitcodeY
            ldx  prog8_lib.orig_stackpointer
            txs
            jmp  p8_sys_startup.cleanup_at_exit
        }}
    }

    asmsub exit3(ubyte resulta @A, ubyte resultx @X, ubyte resulty @Y, bool carry @Pc) {
        ; -- immediately exit the program with result values in the A, X and Y registers, and the Carry flag in the status register.
        %asm {{
            sta  p8_sys_startup.cleanup_at_exit._exitcode
            lda  #0
            rol  a
            sta  p8_sys_startup.cleanup_at_exit._exitcarry
            stx  p8_sys_startup.cleanup_at_exit._exitcodeX
            sty  p8_sys_startup.cleanup_at_exit._exitcodeY
            ldx  prog8_lib.orig_stackpointer
            txs
            jmp  p8_sys_startup.cleanup_at_exit
        }}
    }

    inline asmsub push(ubyte value @A) {
        %asm {{
            pha
        }}
    }

    inline asmsub pushw(uword value @AY) {
        %asm {{
            pha
            tya
            pha
        }}
    }

    inline asmsub push_returnaddress(uword address @XY) {
        %asm {{
            ; push like JSR would:  address-1,  MSB first then LSB
            cpx  #0
            bne  +
            dey
+           dex
            tya
            pha
            txa
            pha
        }}
    }

    asmsub get_as_returnaddress(uword address @XY) -> uword @AX {
        %asm {{
            ; return the address like JSR would push onto the stack:  address-1,  MSB first then LSB
            cpx  #0
            bne  +
            dey
+           dex
            tya
            rts
        }}
    }

    inline asmsub pop() -> ubyte @A {
        %asm {{
            pla
        }}
    }

    inline asmsub popw() -> uword @AY {
        %asm {{
            pla
            tay
            pla
        }}
    }

    inline asmsub pushl(long value @R0R1) {
        %asm {{
            lda  cx16.r0
            pha
            lda  cx16.r0+1
            pha
            lda  cx16.r0+2
            pha
            lda  cx16.r0+3
            pha
        }}
    }

    inline asmsub popl() -> long @R0R1 {
        %asm {{
            pla
            sta  cx16.r0+3
            pla
            sta  cx16.r0+2
            pla
            sta  cx16.r0+1
            pla
            sta  cx16.r0
        }}
    }

    sub cpu_is_65816() -> bool {
        ; Returns true when you have a 65816 cpu, false when it's a 6502.
        return false
    }
}

cx16 {
    ; the sixteen virtual 16-bit registers that the CX16 has defined in the zeropage
    ; they are in zeropage on the Minicube64 as well.
; the sixteen virtual 16-bit registers in both normal unsigned mode and signed mode (s)
    &uword r0  = $0000
    &uword r1  = $0002
    &uword r2  = $0004
    &uword r3  = $0006
    &uword r4  = $0008
    &uword r5  = $000a
    &uword r6  = $000c
    &uword r7  = $000e
    &uword r8  = $0010
    &uword r9  = $0012
    &uword r10 = $0014
    &uword r11 = $0016
    &uword r12 = $0018
    &uword r13 = $001a
    &uword r14 = $001c
    &uword r15 = $001e

    ; signed word versions
    &word r0s  = $0000
    &word r1s  = $0002
    &word r2s  = $0004
    &word r3s  = $0006
    &word r4s  = $0008
    &word r5s  = $000a
    &word r6s  = $000c
    &word r7s  = $000e
    &word r8s  = $0010
    &word r9s  = $0012
    &word r10s = $0014
    &word r11s = $0016
    &word r12s = $0018
    &word r13s = $001a
    &word r14s = $001c
    &word r15s = $001e

    ; signed long versions
    &long r0r1sl = $0000
    &long r2r3sl = $0004
    &long r4r5sl = $0008
    &long r6r7sl = $000c
    &long r8r9sl = $0010
    &long r10r11sl = $0014
    &long r12r13sl = $0018
    &long r14r15sl = $001c

    ; ubyte versions (low and high bytes)
    &ubyte r0L  = $0000
    &ubyte r1L  = $0002
    &ubyte r2L  = $0004
    &ubyte r3L  = $0006
    &ubyte r4L  = $0008
    &ubyte r5L  = $000a
    &ubyte r6L  = $000c
    &ubyte r7L  = $000e
    &ubyte r8L  = $0010
    &ubyte r9L  = $0012
    &ubyte r10L = $0014
    &ubyte r11L = $0016
    &ubyte r12L = $0018
    &ubyte r13L = $001a
    &ubyte r14L = $001c
    &ubyte r15L = $001e

    &ubyte r0H  = $0001
    &ubyte r1H  = $0003
    &ubyte r2H  = $0005
    &ubyte r3H  = $0007
    &ubyte r4H  = $0009
    &ubyte r5H  = $000b
    &ubyte r6H  = $000d
    &ubyte r7H  = $000f
    &ubyte r8H  = $0011
    &ubyte r9H  = $0013
    &ubyte r10H = $0015
    &ubyte r11H = $0017
    &ubyte r12H = $0019
    &ubyte r13H = $001b
    &ubyte r14H = $001d
    &ubyte r15H = $001f

    ; signed byte versions (low and high bytes)
    &byte r0sL  = $0000
    &byte r1sL  = $0002
    &byte r2sL  = $0004
    &byte r3sL  = $0006
    &byte r4sL  = $0008
    &byte r5sL  = $000a
    &byte r6sL  = $000c
    &byte r7sL  = $000e
    &byte r8sL  = $0010
    &byte r9sL  = $0012
    &byte r10sL = $0014
    &byte r11sL = $0016
    &byte r12sL = $0018
    &byte r13sL = $001a
    &byte r14sL = $001c
    &byte r15sL = $001e

    &byte r0sH  = $0001
    &byte r1sH  = $0003
    &byte r2sH  = $0005
    &byte r3sH  = $0007
    &byte r4sH  = $0009
    &byte r5sH  = $000b
    &byte r6sH  = $000d
    &byte r7sH  = $000f
    &byte r8sH  = $0011
    &byte r9sH  = $0013
    &byte r10sH = $0015
    &byte r11sH = $0017
    &byte r12sH = $0019
    &byte r13sH = $001b
    &byte r14sH = $001d
    &byte r15sH = $001f

    ; boolean versions
    &bool r0bL  = $0000
    &bool r1bL  = $0002
    &bool r2bL  = $0004
    &bool r3bL  = $0006
    &bool r4bL  = $0008
    &bool r5bL  = $000a
    &bool r6bL  = $000c
    &bool r7bL  = $000e
    &bool r8bL  = $0010
    &bool r9bL  = $0012
    &bool r10bL = $0014
    &bool r11bL = $0016
    &bool r12bL = $0018
    &bool r13bL = $001a
    &bool r14bL = $001c
    &bool r15bL = $001e

    &bool r0bH  = $0001
    &bool r1bH  = $0003
    &bool r2bH  = $0005
    &bool r3bH  = $0007
    &bool r4bH  = $0009
    &bool r5bH  = $000b
    &bool r6bH  = $000d
    &bool r7bH  = $000f
    &bool r8bH  = $0011
    &bool r9bH  = $0013
    &bool r10bH = $0015
    &bool r11bH = $0017
    &bool r12bH = $0019
    &bool r13bH = $001b
    &bool r14bH = $001d
    &bool r15bH = $001f


    asmsub save_virtual_registers() clobbers(A,Y) {
		; TODO: Romable
        %asm {{
            ldy  #31
    -       lda  cx16.r0,y
            sta  _cx16_vreg_storage,y
            dey
            bpl  -
            rts

            .section BSS
    _cx16_vreg_storage
            .word ?,?,?,?,?,?,?,?
            .word ?,?,?,?,?,?,?,?
            .send BSS
            ; !notreached!
        }}
    }

    asmsub restore_virtual_registers() clobbers(A,Y) {
        %asm {{
            ldy  #31
    -       lda  save_virtual_registers._cx16_vreg_storage,y
            sta  cx16.r0,y
            dey
            bpl  -
            rts
        }}
    }

    sub cpu_is_65816() -> bool {
        ; Returns true when you have a 65816 cpu, false when it's a 6502.
        return false
    }

}

p8_sys_startup {
    ; program startup and shutdown machinery. Needs to reside in normal system ram.

; TODO cleanup banking: (this is from C64)
asmsub  init_system()  {
    ; Initializes the machine to a sane starting state.
    ; Called automatically by the loader program logic.
    ; This means that the KERNAL and CHARGEN ROMs are banked in,
    ; BASIC ROM is NOT banked in (so we have another 8Kb of RAM at our disposal),
    ; the VIC, SID and CIA chips are reset, screen is cleared, and the default IRQ is set.
    ; Also a different color scheme is chosen to identify ourselves a little.
    ; Uppercase charset is activated.
    %asm {{
        ; should setup irq and video/etc
; keep irq off for now
        sei
        lda  #$0f
        sta  mc64.VIDEO   ; video ram at $f000

        lda  #63
        sta  $ffe0
        sta  $fff0

        lda  #<_irq
        sta  mc64.NMI_IRQ
        lda  #>_irq
        sta  mc64.NMI_IRQ+1
        lda  #<_virq
        sta  mc64.VBLANK_IRQ
        lda  #>_virq
        sta  mc64.VBLANK_IRQ+1
        cli
        rts
_irq:
        lda  $ffe0
        eor  #%00111111
        sta  $ffe0
        rti
_virq:
;        lda  $fff0
;        eor  #%00111111
;        sta  $fff0
        inc  cbm.TIME_LO
        bcc  +
        inc  cbm.TIME_MID
        bcc  +
        inc  cbm.TIME_HI
;        jsr  txt.redraw_asm
+       rti
    }}
}

asmsub  init_system_phase2()  {
    %asm {{
        ; do we need anything.
;        cld
;        clc
;        clv
        rts
    }}
}

asmsub  cleanup_at_exit() {
    ; executed when the main subroutine does rts
    %asm {{
        ; TODO cleanup.
loop:   jmp  loop
        lda  _exitcarry
        lsr  a
        lda  _exitcode
        ldx  _exitcodeX
        ldy  _exitcodeY
        rts

        .section BSS
_exitcarry  .byte ?
_exitcode   .byte ?
_exitcodeX  .byte ?
_exitcodeY  .byte ?
        .send BSS

        ; !notreached!
    }}
}

asmsub  disable_runstop_and_charsetswitch() clobbers(A) {
    %asm {{
        lda  #$80
        sta  1351   ; disable charset switching
        lda  #103
        sta  806    ; disable run/stop key
        rts
    }}
}

asmsub  enable_runstop_and_charsetswitch() clobbers(A) {
    %asm {{
        lda  #0
        sta  1351   ; enable charset switching
        lda  #101
        sta  806    ; enable run/stop key
        rts
    }}
}

}
