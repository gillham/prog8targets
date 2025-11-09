; Prog8 definitions for the Commodore VIC-20
; Including memory registers, I/O registers, Basic and Kernal subroutines.

%option no_symbol_prefixing, ignore_unused

cbm {
    ; Commodore (CBM) common variables, vectors and kernal routines

        &ubyte  TIME_HI         = $a0       ; software jiffy clock, hi byte
        &ubyte  TIME_MID        = $a1       ;  .. mid byte
        &ubyte  TIME_LO         = $a2       ;    .. lo byte. Updated by IRQ every 1/60 sec
        &ubyte  STATUS          = $90       ; kernal status variable for I/O
        &ubyte  STKEY           = $91       ; various keyboard statuses (updated by IRQ)
        &ubyte  SFDX            = $cb       ; current key pressed (matrix value) (updated by IRQ)
        &ubyte  SHFLAG          = $028d     ; various modifier key status (updated by IRQ)

        &ubyte  COLOR           = $0286     ; cursor color
        &ubyte  HIBASE          = $0288     ; screen base address / 256 (hi-byte of screen memory address)

        &uword  IERROR          = $0300
        &uword  IMAIN           = $0302
        &uword  ICRNCH          = $0304
        &uword  IQPLOP          = $0306
        &uword  IGONE           = $0308
        &uword  IEVAL           = $030a
        &ubyte  SAREG           = $030c     ; register storage for A for SYS calls
        &ubyte  SXREG           = $030d     ; register storage for X for SYS calls
        &ubyte  SYREG           = $030e     ; register storage for Y for SYS calls
        &ubyte  SPREG           = $030f     ; register storage for P (status register) for SYS calls
        &uword  USRADD          = $0311     ; vector for the USR() basic command
        ; $0313 is unused.
        &uword  CINV            = $0314     ; IRQ vector (in ram)
        &uword  CBINV           = $0316     ; BRK vector (in ram)
        &uword  NMINV           = $0318     ; NMI vector (in ram)
        &uword  IOPEN           = $031a
        &uword  ICLOSE          = $031c
        &uword  ICHKIN          = $031e
        &uword  ICKOUT          = $0320
        &uword  ICLRCH          = $0322
        &uword  IBASIN          = $0324
        &uword  IBSOUT          = $0326
        &uword  ISTOP           = $0328
        &uword  IGETIN          = $032a
        &uword  ICLALL          = $032c
        &uword  USERCMD         = $032e
        &uword  ILOAD           = $0330
        &uword  ISAVE           = $0332

        &uword  NMI_VEC         = $FFFA     ; 6502 nmi vector, determined by the kernal if banked in
        &uword  RESET_VEC       = $FFFC     ; 6502 reset vector, determined by the kernal if banked in
        &uword  IRQ_VEC         = $FFFE     ; 6502 interrupt vector, determined by the kernal if banked in

        ; the default addresses for the character screen chars and colors
        const  uword  Screen    = $1000     ; to have this as an array[22*23] the compiler would have to support array size > 255
        const  uword  Colors    = $9400     ; to have this as an array[22*23] the compiler would have to support array size > 255


; ---- CBM ROM kernal routines (VIC-20 addresses) ----

extsub $CB1E = STROUT(uword strptr @ AY) clobbers(A, X, Y)      ; print null-terminated string (use txt.print instead)
extsub $E518 = CINT() clobbers(A,X,Y)                           ; (alias: SCINIT) initialize screen editor and video chip
extsub $E55F = CLEARSCR() clobbers(A,X,Y)                       ; clear the screen
extsub $E581 = HOMECRSR() clobbers(A,X,Y)                       ; cursor to top left of screen
;extsub $EA31 = IRQDFRT() clobbers(A,X,Y)                        ; default IRQ routine
;extsub $EA81 = IRQDFEND() clobbers(A,X,Y)                       ; default IRQ end/cleanup

extsub $FD8D = RAMTAS() clobbers(A,X,Y)                         ; initialize RAM, tape buffer, screen
extsub $FDF9 = IOINIT() clobbers(A, X)                          ; initialize I/O devices (CIA, SID, IRQ)

extsub $FF8A = RESTOR() clobbers(A,X,Y)                         ; restore default I/O vectors
extsub $FF8D = VECTOR(uword userptr @ XY, bool dir @ Pc) clobbers(A,Y)     ; read/set I/O vector table
extsub $FF90 = SETMSG(ubyte value @ A)                          ; set Kernal message control flag
extsub $FF93 = SECOND(ubyte address @ A) clobbers(A)            ; (alias: LSTNSA) send secondary address after LISTEN
extsub $FF96 = TKSA(ubyte address @ A) clobbers(A)              ; (alias: TALKSA) send secondary address after TALK
extsub $FF99 = MEMTOP(uword address @ XY, bool dir @ Pc) -> uword @ XY     ; read/set top of memory  pointer
extsub $FF9C = MEMBOT(uword address @ XY, bool dir @ Pc) -> uword @ XY     ; read/set bottom of memory  pointer
extsub $FF9F = SCNKEY() clobbers(A,X,Y)                         ; scan the keyboard
extsub $FFA2 = SETTMO(ubyte timeout @ A)                        ; set time-out flag for IEEE bus
extsub $FFA5 = ACPTR() -> ubyte @ A                             ; (alias: IECIN) input byte from serial bus
extsub $FFA8 = CIOUT(ubyte databyte @ A)                        ; (alias: IECOUT) output byte to serial bus
extsub $FFAB = UNTLK() clobbers(A)                              ; command serial bus device to UNTALK
extsub $FFAE = UNLSN() clobbers(A)                              ; command serial bus device to UNLISTEN
extsub $FFB1 = LISTEN(ubyte device @ A) clobbers(A)             ; command serial bus device to LISTEN
extsub $FFB4 = TALK(ubyte device @ A) clobbers(A)               ; command serial bus device to TALK
extsub $FFB7 = READST() -> ubyte @ A                            ; read I/O status word  (use CLEARST to reset it to 0)
extsub $FFBA = SETLFS(ubyte logical @ A, ubyte device @ X, ubyte secondary @ Y)   ; set logical file parameters
extsub $FFBD = SETNAM(ubyte namelen @ A, str filename @ XY)     ; set filename parameters
extsub $FFC0 = OPEN() clobbers(X,Y) -> bool @Pc, ubyte @A      ; (via 794 ($31A)) open a logical file
extsub $FFC3 = CLOSE(ubyte logical @ A) clobbers(A,X,Y)         ; (via 796 ($31C)) close a logical file
extsub $FFC6 = CHKIN(ubyte logical @ X) clobbers(A,X) -> bool @Pc    ; (via 798 ($31E)) define an input channel
extsub $FFC9 = CHKOUT(ubyte logical @ X) clobbers(A,X)          ; (via 800 ($320)) define an output channel
extsub $FFCC = CLRCHN() clobbers(A,X)                           ; (via 802 ($322)) restore default devices
extsub $FFCF = CHRIN() clobbers(X, Y) -> ubyte @ A   ; (via 804 ($324)) input a character (for keyboard, read a whole line from the screen) A=byte read.
extsub $FFD2 = CHROUT(ubyte character @ A)                      ; (via 806 ($326)) output a character
extsub $FFD5 = LOAD(ubyte verify @ A, uword address @ XY) -> bool @Pc, ubyte @ A, uword @ XY     ; (via 816 ($330)) load from device
extsub $FFD8 = SAVE(ubyte zp_startaddr @ A, uword endaddr @ XY) -> bool @ Pc, ubyte @ A          ; (via 818 ($332)) save to a device
extsub $FFDB = SETTIM(ubyte low @ A, ubyte middle @ X, ubyte high @ Y)      ; set the software clock
extsub $FFDE = RDTIM() -> ubyte @ A, ubyte @ X, ubyte @ Y       ; read the software clock (A=lo,X=mid,Y=high)
extsub $FFE1 = STOP() clobbers(X) -> bool @ Pz, ubyte @ A       ; (via 808 ($328)) check the STOP key (and some others in A)     also see STOP2
extsub $FFE4 = GETIN() clobbers(X,Y) -> bool @Pc, ubyte @ A     ; (via 810 ($32A)) get a character       also see GETIN2
extsub $FFE7 = CLALL() clobbers(A,X)                            ; (via 812 ($32C)) close all files
extsub $FFEA = UDTIM() clobbers(A,X)                            ; update the software clock
extsub $FFED = SCREEN() -> ubyte @ X, ubyte @ Y                 ; get size of text screen into X (columns) and Y (rows)
extsub $FFF0 = PLOT(ubyte col @ Y, ubyte row @ X, bool dir @ Pc) clobbers(A) -> ubyte @ Y, ubyte @ X       ; read/set position of cursor on screen (Y=column, X=row).  Also see txt.plot
extsub $FFF3 = IOBASE() -> uword @ XY                           ; read base address of I/O devices


inline asmsub STOP2() clobbers(X,A) -> bool @Pz  {
    ; -- just like STOP, but omits the special keys result value in A.
    ;    just for convenience because most of the times you're only interested in the stop pressed or not status.
    %asm {{
        jsr  cbm.STOP
    }}
}

inline asmsub GETIN2() clobbers(X,Y) -> ubyte @A {
    ; -- just like GETIN, but omits the carry flag result value.
    ;    just for convenience because GETIN is so often used to just read keyboard input,
    ;    where you don't have to deal with a potential error status
    %asm {{
        jsr  cbm.GETIN
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

sub CLEARST() {
    ; -- Set the ST status variable back to 0. (there's no direct kernal call for this)
    ;    Note: a drive error state (blinking led) isn't cleared! You can use diskio.status() to clear that.
    SETNAM(0, $0000)
    SETLFS(15, 3, 15)
    void OPEN()
    CLOSE(15)
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

vic20 {
        ; platform variables
        ; difference between screen ram page ($1E) and color ram page ($96)
        const ubyte SCREEN_COLOR_OFFSET = $84

        ; vic20 I/O registers (VIC, VIA)

        ; ---- VIC 6560 registers ----
        &ubyte  VICCR0          = $9000
        &ubyte  VICCR1          = $9001
        &ubyte  VICCR2          = $9002
        &ubyte  VICCR3          = $9003
        &ubyte  VICCR4          = $9004
        &ubyte  VICCR5          = $9005
        &ubyte  VICCR6          = $9006
        &ubyte  VICCR7          = $9007
        &ubyte  VICCR8          = $9008
        &ubyte  VICCR9          = $9009
        &ubyte  VICCRA          = $900a
        &ubyte  VICCRB          = $900b
        &ubyte  VICCRC          = $900c
        &ubyte  VICCRD          = $900d
        &ubyte  VICCRE          = $900e
        &ubyte  VICCRF          = $900f

        ; ---- VIA 6522 1 & 2 registers ----
        ; VIA 1
        &ubyte  VIA1PB          = $9110     ; Port B I/O register
        &ubyte  VIA1PA1         = $9111     ; Port A I/O register
        &ubyte  VIA1DDRB        = $9112     ; Port B data direction register
        &ubyte  VIA1DDRA        = $9113     ; Port A data direction register
        &ubyte  VIA1T1CL        = $9114     ; Timer 1 least significant byte (LSB) of count
        &ubyte  VIA1T1CH        = $9115     ; Timer 1 most significant byte (MSB) of count
        &ubyte  VIA1T1LL        = $9116     ; Timer 1 low order (LSB) latch byte
        &ubyte  VIA1T1LH        = $9117     ; Timer 1 high order (MSB) latch byte (VIA1T1HL)
        &ubyte  VIA1T2CL        = $9118     ; Timer 2 low order (LSB) counter and LSB latch
        &ubyte  VIA1T2CH        = $9119     ; Timer 2 high order (MSB) counter and MSB latch
        &ubyte  VIA1SR          = $911A     ; Shift register for parallel/serial conversion
        &ubyte  VIA1ACR         = $911B     ; Auxiliary control register
        &ubyte  VIA1PCR         = $911C     ; Peripheral control register for handshaking
        &ubyte  VIA1IFR         = $911D     ; Interrupt flag register (IFR)
        &ubyte  VIA1IER         = $911E     ; Interrupt enable register (IER)
        &ubyte  VIA1PA2         = $911F     ; Mirror of port A I/O minus CA1/CA2 control lines
        ; VIA 2
        &ubyte  VIA2PB          = $9120     ; Port B I/O register
        &ubyte  VIA2PA1         = $9121     ; Port A I/O register
        &ubyte  VIA2DDRB        = $9122     ; Port B data direction register
        &ubyte  VIA2DDRA        = $9123     ; Port A data direction register
        &ubyte  VIA2T1CL        = $9124     ; Timer 1 least significant byte (LSB) of count
        &ubyte  VIA2T1CH        = $9125     ; Timer 1 most significant byte (MSB) of count
        &ubyte  VIA2T1LL        = $9126     ; Timer 1 low order (LSB) latch byte
        &ubyte  VIA2T1LH        = $9127     ; Timer 1 high order (MSB) latch byte (VIA2T1HL)
        &ubyte  VIA2T2CL        = $9128     ; Timer 2 low order (LSB) counter and LSB latch
        &ubyte  VIA2T2CH        = $9129     ; Timer 2 high order (MSB) counter and MSB latch
        &ubyte  VIA2SR          = $912A     ; Shift register for parallel/serial conversion
        &ubyte  VIA2ACR         = $912B     ; Auxiliary control register
        &ubyte  VIA2PCR         = $912C     ; Peripheral control register for handshaking
        &ubyte  VIA2IFR         = $912D     ; Interrupt flag register (IFR)
        &ubyte  VIA2IER         = $912E     ; Interrupt enable register (IER)
        &ubyte  VIA2PA2         = $912F     ; Mirror of port A I/O minus CA1/CA2 control lines

        ; ---- end of VIA registers ----

asmsub banks(ubyte banks @A) {
    ; -- set the memory bank configuration
    ;    see https://www.vic20-wiki.com/wiki/Bank_Switching
    %asm {{
        and  #%00000111
        sta  P8ZP_SCRATCH_REG
        sei
        lda  $01
        and  #%11111000
        ora  P8ZP_SCRATCH_REG
        sta  $01
        cli
        rts
    }}
}

inline asmsub getbanks() -> ubyte @A {
    ; -- get the current memory bank configuration
    ;    see https://www.vic20-wiki.com/wiki/Bank_Switching
    %asm {{
        lda  $01
        and  #%00000111
    }}
}

    asmsub x16jsrfar() {
        %asm {{
            ; setup a JSRFAR call (using X16 call convention)
            sta  P8ZP_SCRATCH_W2        ; save A
            sty  P8ZP_SCRATCH_W2+1      ; save Y
            php
            pla
            sta  P8ZP_SCRATCH_REG       ; save Status

            pla
            sta  P8ZP_SCRATCH_W1
            pla
            sta  P8ZP_SCRATCH_W1+1

            ; retrieve arguments
            ldy  #$01
            lda  (P8ZP_SCRATCH_W1),y            ; grab low byte of target address
            sta  _jmpfar+1
            iny
            lda  (P8ZP_SCRATCH_W1),y            ; now the high byte
            sta  _jmpfar+2
            iny
            lda  (P8ZP_SCRATCH_W1),y            ; then the target bank
            sta  P8ZP_SCRATCH_B1

            ; adjust return address to skip over the arguments
            clc
            lda  P8ZP_SCRATCH_W1
            adc  #3
            sta  P8ZP_SCRATCH_W1
            lda  P8ZP_SCRATCH_W1+1
            adc  #0
            pha
            lda  P8ZP_SCRATCH_W1
            pha
            lda  $01        ; save old ram banks
            pha
            ; set target bank, restore A, Y and flags
            lda  P8ZP_SCRATCH_REG
            pha
            lda  P8ZP_SCRATCH_B1
            jsr  banks
            lda  P8ZP_SCRATCH_W2
            ldy  P8ZP_SCRATCH_W2+1
            plp
            jsr  _jmpfar        ; do the actual call
            ; restore bank without clobbering status flags and A register
            sta  P8ZP_SCRATCH_W1
            php
            pla
            sta  P8ZP_SCRATCH_B1
            pla
            jsr  banks
            lda  P8ZP_SCRATCH_B1
            pha
            lda  P8ZP_SCRATCH_W1
            plp
            rts

_jmpfar     jmp  $0000          ; modified
        }}
    }

;    sub get_vic_memory_base() -> uword {
;        ; one of the 4 possible banks. $0000/$4000/$8000/$c000.
;        vic20.CIA2DDRA |= %11
;        return ((vic20.CIA2PRA & 3) ^ 3) as uword << 14
;    }

;    sub get_char_matrix_ptr() -> uword {
;        ; Usually the character screen matrix is at 1024-2039 (see above)
;        ; However the vic memory configuration can be altered and this moves these registers with it.
;        ; So this routine determines it dynamically from the VIC memory setup.
;        uword chars_matrix_offset = (vic20.VMCSB & $f0) as uword << 6
;        return get_vic_memory_base() + chars_matrix_offset
;    }

;    sub get_bitmap_ptr() -> uword {
;        return get_vic_memory_base() + ((vic20.VMCSB & %00001000) as uword << 10)
;    }

}

sys {
    ; ------- lowlevel system routines --------

    const ubyte target = 20         ;  compilation target specifier.  255=virtual, 128=C128, 64=C64, 32=PET, 25=Foenix F256, 20=VIC20, 16=CommanderX16, 8=atari800XL, 7=Neo6502, 6=wdcsxb6, 5=rp6502

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

    asmsub save_prog8_internals() {
        ; TODO: Romable
        %asm {{
            lda  P8ZP_SCRATCH_B1
            sta  save_SCRATCH_ZPB1
            lda  P8ZP_SCRATCH_REG
            sta  save_SCRATCH_ZPREG
            lda  P8ZP_SCRATCH_W1
            sta  save_SCRATCH_ZPWORD1
            lda  P8ZP_SCRATCH_W1+1
            sta  save_SCRATCH_ZPWORD1+1
            lda  P8ZP_SCRATCH_W2
            sta  save_SCRATCH_ZPWORD2
            lda  P8ZP_SCRATCH_W2+1
            sta  save_SCRATCH_ZPWORD2+1
            rts
save_SCRATCH_ZPB1	.byte  0
save_SCRATCH_ZPREG	.byte  0
save_SCRATCH_ZPWORD1	.word  0
save_SCRATCH_ZPWORD2	.word  0
            ; !notreached!
        }}
    }

    asmsub restore_prog8_internals() {
        %asm {{
            lda  save_prog8_internals.save_SCRATCH_ZPB1
            sta  P8ZP_SCRATCH_B1
            lda  save_prog8_internals.save_SCRATCH_ZPREG
            sta  P8ZP_SCRATCH_REG
            lda  save_prog8_internals.save_SCRATCH_ZPWORD1
            sta  P8ZP_SCRATCH_W1
            lda  save_prog8_internals.save_SCRATCH_ZPWORD1+1
            sta  P8ZP_SCRATCH_W1+1
            lda  save_prog8_internals.save_SCRATCH_ZPWORD2
            sta  P8ZP_SCRATCH_W2
            lda  save_prog8_internals.save_SCRATCH_ZPWORD2+1
            sta  P8ZP_SCRATCH_W2+1
            rts
        }}
    }

asmsub  set_irq(uword handler @AY) clobbers(A)  {
	%asm {{
	    sei
        sta  _modified+1
        sty  _modified+2
		lda  #<_irq_handler
		sta  cbm.CINV
		lda  #>_irq_handler
		sta  cbm.CINV+1
		cli
		rts
_irq_handler
        jsr  sys.save_prog8_internals
        cld
_modified
        jsr  $ffff                      ; modified
        pha
		jsr  sys.restore_prog8_internals
		pla
		beq  +
		jmp  cbm.IRQDFRT		; continue with normal kernal irq routine
+		lda  #$ff
		sta  vic20.VICIRQ			; acknowledge raster irq
		lda  vic20.CIA1ICR		; acknowledge CIA1 interrupt
		pla
		tay
		pla
		tax
		pla
		rti
    }}
}

asmsub  restore_irq() clobbers(A) {
	%asm {{
		sei
		lda  #<cbm.IRQDFRT
		sta  cbm.CINV
		lda  #>cbm.IRQDFRT
		sta  cbm.CINV+1
		lda  #0
		sta  vic20.IREQMASK	; disable raster irq
		lda  #%10000001
		sta  vic20.CIA1ICR	; restore CIA1 irq
		cli
		rts
	}}
}

asmsub  set_rasterirq(uword handler @AY, uword rasterpos @R0) clobbers(A) {
	%asm {{
	    sei
        sta  _modified+1
        sty  _modified+2
        lda  cx16.r0
        ldy  cx16.r0+1
        jsr  _setup_raster_irq
        lda  #<_raster_irq_handler
        sta  cbm.CINV
        lda  #>_raster_irq_handler
        sta  cbm.CINV+1
        cli
        rts

_raster_irq_handler
		jsr  sys.save_prog8_internals
		cld
_modified
        jsr  $ffff              ; modified
        pha
        jsr  sys.restore_prog8_internals
        lda  #$ff
        sta  vic20.VICIRQ			; acknowledge raster irq
        pla
        beq  +
		jmp  cbm.IRQDFRT                ; continue with kernal irq routine
+		pla
		tay
		pla
		tax
		pla
		rti

_setup_raster_irq
		pha
		lda  #%01111111
		sta  vic20.CIA1ICR    ; "switch off" interrupts signals from cia-1
		sta  vic20.CIA2ICR    ; "switch off" interrupts signals from cia-2
		and  vic20.SCROLY
		sta  vic20.SCROLY     ; clear most significant bit of raster position
		lda  vic20.CIA1ICR    ; ack previous irq
		lda  vic20.CIA2ICR    ; ack previous irq
		pla
		sta  vic20.RASTER     ; set the raster line number where interrupt should occur
		cpy  #0
		beq  +
		lda  vic20.SCROLY
		ora  #%10000000
		sta  vic20.SCROLY     ; set most significant bit of raster position
+		lda  #%00000001
		sta  vic20.IREQMASK   ; enable raster interrupt signals from vic
		rts
	}}
}


    asmsub reset_system()  {
        ; Soft-reset the system back to initial power-on Basic prompt.
        %asm {{
            sei
            lda  #14
            sta  $01        ; bank the kernal in
            jmp  (cbm.RESET_VEC)
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
-           bit  vic20.VICCR4
            bpl  -
-           bit  vic20.VICCR4
            bmi  -
            rts
        }}
    }

    inline asmsub waitrastborder() {
        ; --- busy wait till the raster position has reached the bottom screen border (approximately)
        ;     note: a more accurate way to do this is by using a raster irq handler instead.
        %asm {{
-           bit  vic20.SCROLY
            bpl  -
        }}
    }

    asmsub internal_stringcopy(uword source @R0, uword target @AY) clobbers (A,Y) {
        ; Called when the compiler wants to assign a string value to another string.
        %asm {{
		sta  P8ZP_SCRATCH_W1
		sty  P8ZP_SCRATCH_W1+1
		lda  cx16.r0
		ldy  cx16.r0+1
		jmp  prog8_lib.strcpy
        }}
    }

    asmsub memcopy(uword source @R0, uword target @R1, uword count @AY) clobbers(A,X,Y) {
        ; note: only works for NON-OVERLAPPING memory regions!
        ; note: can't be inlined because is called from asm as well
        %asm {{
            ldx  cx16.r0
            stx  P8ZP_SCRATCH_W1        ; source in ZP
            ldx  cx16.r0+1
            stx  P8ZP_SCRATCH_W1+1
            ldx  cx16.r1
            stx  P8ZP_SCRATCH_W2        ; target in ZP
            ldx  cx16.r1+1
            stx  P8ZP_SCRATCH_W2+1
            cpy  #0
            bne  _longcopy

            ; copy <= 255 bytes
            tay
            bne  _copyshort
            rts     ; nothing to copy

_copyshort
            dey
            beq  +
-           lda  (P8ZP_SCRATCH_W1),y
            sta  (P8ZP_SCRATCH_W2),y
            dey
            bne  -
+           lda  (P8ZP_SCRATCH_W1),y
            sta  (P8ZP_SCRATCH_W2),y
            rts

_longcopy
            sta  P8ZP_SCRATCH_B1        ; lsb(count) = remainder in last page
            tya
            tax                         ; x = num pages (1+)
            ldy  #0
-           lda  (P8ZP_SCRATCH_W1),y
            sta  (P8ZP_SCRATCH_W2),y
            iny
            bne  -
            inc  P8ZP_SCRATCH_W1+1
            inc  P8ZP_SCRATCH_W2+1
            dex
            bne  -
            ldy  P8ZP_SCRATCH_B1
            bne  _copyshort
            rts
        }}
    }

    asmsub memset(uword mem @R0, uword numbytes @R1, ubyte value @A) clobbers(A,X,Y) {
        %asm {{
            ldy  cx16.r0
            sty  P8ZP_SCRATCH_W1
            ldy  cx16.r0+1
            sty  P8ZP_SCRATCH_W1+1
            ldx  cx16.r1
            ldy  cx16.r1+1
            jmp  prog8_lib.memset
        }}
    }

    asmsub memsetw(uword mem @R0, uword numwords @R1, uword value @AY) clobbers(A,X,Y) {
        %asm {{
            ldx  cx16.r0
            stx  P8ZP_SCRATCH_W1
            ldx  cx16.r0+1
            stx  P8ZP_SCRATCH_W1+1
            ldx  cx16.r1
            stx  P8ZP_SCRATCH_W2
            ldx  cx16.r1+1
            stx  P8ZP_SCRATCH_W2+1
            jmp  prog8_lib.memsetw
        }}
    }

    asmsub memcmp(uword address1 @R0, uword address2 @R1, uword size @AY) -> byte @A {
        ; Compares two blocks of memory
        ; Returns -1 (255), 0 or 1, meaning: block 1 sorts before, equal or after block 2.
        %asm {{
            sta  P8ZP_SCRATCH_REG   ; lsb(size)
            sty  P8ZP_SCRATCH_B1    ; msb(size)
            lda  cx16.r0
            ldy  cx16.r0+1
            sta  P8ZP_SCRATCH_W1
            sty  P8ZP_SCRATCH_W1+1
            lda  cx16.r1
            ldy  cx16.r1+1
            sta  P8ZP_SCRATCH_W2
            sty  P8ZP_SCRATCH_W2+1

            ldx  P8ZP_SCRATCH_B1
            beq  _no_msb_size

_loop_msb_size
            ldy  #0
-           lda  (P8ZP_SCRATCH_W1),y
            cmp  (P8ZP_SCRATCH_W2),y
            bcs  +
            lda  #-1
            rts
+           beq  +
            lda  #1
            rts
+           iny
            bne  -
            inc  P8ZP_SCRATCH_W1+1
            inc  P8ZP_SCRATCH_W2+1
            dec  P8ZP_SCRATCH_B1        ; msb(size) -= 1
            dex
            bne  _loop_msb_size

_no_msb_size
            lda  P8ZP_SCRATCH_REG       ; lsb(size)
            bne  +
            rts

+           ldy  #0
-           lda  (P8ZP_SCRATCH_W1),y
            cmp  (P8ZP_SCRATCH_W2),y
            bcs  +
            lda  #-1
            rts
+           beq  +
            lda  #1
            rts
+           iny
            cpy  P8ZP_SCRATCH_REG       ; lsb(size)
            bne  -

            lda #0
            rts
        }}
    }

    inline asmsub read_flags() -> ubyte @A {
        %asm {{
        php
        pla
        }}
    }

    inline asmsub clear_carry() {
        %asm {{
        clc
        }}
    }

    inline asmsub set_carry() {
        %asm {{
        sec
        }}
    }

    inline asmsub clear_irqd() {
        %asm {{
        cli
        }}
    }

    inline asmsub set_irqd() {
        %asm {{
        sei
        }}
    }

    inline asmsub irqsafe_set_irqd() {
        %asm {{
        php
        sei
        }}
    }

    inline asmsub irqsafe_clear_irqd() {
        %asm {{
        plp
        }}
    }

    inline asmsub disable_caseswitch() {
        %asm {{
            lda  #$80
            sta  657
        }}
    }

    inline asmsub enable_caseswitch() {
        %asm {{
            lda  #0
            sta  657
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
            sta  p8_sys_startup.cleanup_at_exit._exitcodeCarry
            stx  p8_sys_startup.cleanup_at_exit._exitcodeX
            sty  p8_sys_startup.cleanup_at_exit._exitcodeY
            ldx  prog8_lib.orig_stackpointer
            txs
            jmp  p8_sys_startup.cleanup_at_exit
        }}
    }

    inline asmsub progend() -> uword @AY {
        %asm {{
            lda  #<prog8_program_end
            ldy  #>prog8_program_end
        }}
    }

    inline asmsub progstart() -> uword @AY {
        %asm {{
            lda  #<prog8_program_start
            ldy  #>prog8_program_start
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
}

cx16 {
    ; the sixteen virtual 16-bit registers that the CX16 has defined in the zeropage
    ; they are simulated on the vic20 as well but their location in memory is different
    ; (because there's no room for them in the zeropage in the default configuration)
    ; Note that when using ZP options that free up more of the zeropage (such as %zeropage kernalsafe)
    ; there might be enough space to put them there after all, and the compiler will change these addresses!
; the sixteen virtual 16-bit registers in both normal unsigned mode and signed mode (s)
    &uword r0  = $02e0
    &uword r1  = $02e2
    &uword r2  = $02e4
    &uword r3  = $02e6
    &uword r4  = $02e8
    &uword r5  = $02ea
    &uword r6  = $02ec
    &uword r7  = $02ee
    &uword r8  = $02f0
    &uword r9  = $02f2
    &uword r10 = $02f4
    &uword r11 = $02f6
    &uword r12 = $02f8
    &uword r13 = $02fa
    &uword r14 = $02fc
    &uword r15 = $02fe

    ; signed word versions
    &word r0s  = $02e0
    &word r1s  = $02e2
    &word r2s  = $02e4
    &word r3s  = $02e6
    &word r4s  = $02e8
    &word r5s  = $02ea
    &word r6s  = $02ec
    &word r7s  = $02ee
    &word r8s  = $02f0
    &word r9s  = $02f2
    &word r10s = $02f4
    &word r11s = $02f6
    &word r12s = $02f8
    &word r13s = $02fa
    &word r14s = $02fc
    &word r15s = $02fe

    ; ubyte versions (low and high bytes)
    &ubyte r0L  = $02e0
    &ubyte r1L  = $02e2
    &ubyte r2L  = $02e4
    &ubyte r3L  = $02e6
    &ubyte r4L  = $02e8
    &ubyte r5L  = $02ea
    &ubyte r6L  = $02ec
    &ubyte r7L  = $02ee
    &ubyte r8L  = $02f0
    &ubyte r9L  = $02f2
    &ubyte r10L = $02f4
    &ubyte r11L = $02f6
    &ubyte r12L = $02f8
    &ubyte r13L = $02fa
    &ubyte r14L = $02fc
    &ubyte r15L = $02fe

    &ubyte r0H  = $02e1
    &ubyte r1H  = $02e3
    &ubyte r2H  = $02e5
    &ubyte r3H  = $02e7
    &ubyte r4H  = $02e9
    &ubyte r5H  = $02eb
    &ubyte r6H  = $02ed
    &ubyte r7H  = $02ef
    &ubyte r8H  = $02f1
    &ubyte r9H  = $02f3
    &ubyte r10H = $02f5
    &ubyte r11H = $02f7
    &ubyte r12H = $02f9
    &ubyte r13H = $02fb
    &ubyte r14H = $02fd
    &ubyte r15H = $02ff

    ; signed byte versions (low and high bytes)
    &byte r0sL  = $02e0
    &byte r1sL  = $02e2
    &byte r2sL  = $02e4
    &byte r3sL  = $02e6
    &byte r4sL  = $02e8
    &byte r5sL  = $02ea
    &byte r6sL  = $02ec
    &byte r7sL  = $02ee
    &byte r8sL  = $02f0
    &byte r9sL  = $02f2
    &byte r10sL = $02f4
    &byte r11sL = $02f6
    &byte r12sL = $02f8
    &byte r13sL = $02fa
    &byte r14sL = $02fc
    &byte r15sL = $02fe

    &byte r0sH  = $02e1
    &byte r1sH  = $02e3
    &byte r2sH  = $02e5
    &byte r3sH  = $02e7
    &byte r4sH  = $02e9
    &byte r5sH  = $02eb
    &byte r6sH  = $02ed
    &byte r7sH  = $02ef
    &byte r8sH  = $02f1
    &byte r9sH  = $02f3
    &byte r10sH = $02f5
    &byte r11sH = $02f7
    &byte r12sH = $02f9
    &byte r13sH = $02fb
    &byte r14sH = $02fd
    &byte r15sH = $02ff

    ; boolean versions
    &bool r0bL  = $02e0
    &bool r1bL  = $02e2
    &bool r2bL  = $02e4
    &bool r3bL  = $02e6
    &bool r4bL  = $02e8
    &bool r5bL  = $02ea
    &bool r6bL  = $02ec
    &bool r7bL  = $02ee
    &bool r8bL  = $02f0
    &bool r9bL  = $02f2
    &bool r10bL = $02f4
    &bool r11bL = $02f6
    &bool r12bL = $02f8
    &bool r13bL = $02fa
    &bool r14bL = $02fc
    &bool r15bL = $02fe

    &bool r0bH  = $02e1
    &bool r1bH  = $02e3
    &bool r2bH  = $02e5
    &bool r3bH  = $02e7
    &bool r4bH  = $02e9
    &bool r5bH  = $02eb
    &bool r6bH  = $02ed
    &bool r7bH  = $02ef
    &bool r8bH  = $02f1
    &bool r9bH  = $02f3
    &bool r10bH = $02f5
    &bool r11bH = $02f7
    &bool r12bH = $02f9
    &bool r13bH = $02fb
    &bool r14bH = $02fd
    &bool r15bH = $02ff

    asmsub save_virtual_registers() clobbers(A,Y) {
		; TODO: Romable
        %asm {{
            ldy  #31
    -       lda  cx16.r0,y
            sta  _cx16_vreg_storage,y
            dey
            bpl  -
            rts

    _cx16_vreg_storage
            .word 0,0,0,0,0,0,0,0
            .word 0,0,0,0,0,0,0,0
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

asmsub  init_system()  {
    ; Initializes the machine to a sane starting state.
    ; Called automatically by the loader program logic.
    ; This means that the KERNAL and CHARGEN ROMs are banked in,
    ; BASIC ROM is NOT banked in (so we have another 8Kb of RAM at our disposal),
    ; the VIC, SID and CIA chips are reset, screen is cleared, and the default IRQ is set.
    ; Also a different color scheme is chosen to identify ourselves a little.
    ; Uppercase charset is activated.
    %asm {{
;        sei
;        lda  #%00101111
;        sta  $00
;        lda  #%00100110   ; kernal and i/o banked in, basic off
;        sta  $01
;        jsr  cbm.IOINIT
;        jsr  cbm.RESTOR
;        jsr  cbm.CINT
;        lda  #6
;        sta  vic20.EXTCOL
;        lda  #7
;        sta  cbm.COLOR
;        lda  #0
;        sta  vic20.BGCOL0
;        jsr  disable_runstop_and_charsetswitch
;        lda  #PROG8_vic20_BANK_CONFIG     ; apply bank config
;        sta  $01
;        and  #1
;        bne  +
;        ; basic is not banked in, adjust MEMTOP
;        ldx  #<$d000
;        ldy  #>$d000
;        clc
;        jsr  cbm.MEMTOP
;+       cli

        ; do what PET does for now..
        sei
        lda  #142
        jsr  cbm.CHROUT     ; uppercase
        lda  #147
        jsr  cbm.CHROUT     ; clear screen
        lda  #159
        jsr  cbm.CHROUT     ; text color cyan
        lda #%01101011      ; cyan border, blue background, not inverted
        sta $900f           ; set colors
        cli
        rts
    }}
}

asmsub  init_system_phase2()  {
    %asm {{
        cld
        clc
        clv
        rts
    }}
}

asmsub  cleanup_at_exit() {
    ; executed when the main subroutine does rts
    %asm {{
;        lda  #%00101111
;        sta  $00
;        lda  #31
;        sta  $01            ; bank the kernal and basic in
;        ldx  #<$a000
;        ldy  #>$a000
;        clc
;        jsr  cbm.MEMTOP     ; adjust MEMTOP down again
        jsr  cbm.CLRCHN		; reset i/o channels
        jsr  enable_runstop_and_charsetswitch
        
_exitcodeCarry = *+1
        lda  #0
        lsr  a
_exitcode = *+1
        lda  #0        ; exit code possibly modified in exit()
_exitcodeX = *+1
        ldx  #0
_exitcodeY = *+1
        ldy  #0
        rts
    }}
}

asmsub  disable_runstop_and_charsetswitch() clobbers(A) {
    %asm {{
;        lda  #$80
;        sta  657    ; disable charset switching
        lda  #184
        sta  806    ; disable run/stop key
        rts
    }}
}

asmsub  enable_runstop_and_charsetswitch() clobbers(A) {
    %asm {{
;        lda  #0
;        sta  657    ; enable charset switching
        ; TODO: not sure if this is correct.
        lda  #122
        sta  806    ; enable run/stop key
        rts
    }}
}

}
