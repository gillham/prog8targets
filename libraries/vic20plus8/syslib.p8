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
        const  uword  Screen    = $0400     ; to have this as an array[40*25] the compiler would have to support array size > 255
        const  uword  Colors    = $d800     ; to have this as an array[40*25] the compiler would have to support array size > 255


; ---- CBM ROM kernal routines (VIC-20 addresses) ----

extsub $AB1E = STROUT(uword strptr @ AY) clobbers(A, X, Y)      ; print null-terminated string (use txt.print instead)
extsub $E544 = CLEARSCR() clobbers(A,X,Y)                       ; clear the screen
extsub $E566 = HOMECRSR() clobbers(A,X,Y)                       ; cursor to top left of screen
extsub $EA31 = IRQDFRT() clobbers(A,X,Y)                        ; default IRQ routine
extsub $EA81 = IRQDFEND() clobbers(A,X,Y)                       ; default IRQ end/cleanup
extsub $FF81 = CINT() clobbers(A,X,Y)                           ; (alias: SCINIT) initialize screen editor and video chip
extsub $FF84 = IOINIT() clobbers(A, X)                          ; initialize I/O devices (CIA, SID, IRQ)
extsub $FF87 = RAMTAS() clobbers(A,X,Y)                         ; initialize RAM, tape buffer, screen
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
        ; vic20 I/O registers (VIC, SID, CIA)

        ; the default locations of the 8 sprite pointers (store address of sprite / 64)
        ; (depending on the VIC bank and screen ram address selection these can be shifted around though,
        ; see the two routines after this for a dynamic way of determining the correct memory location)
        &ubyte  SPRPTR0         = 2040
        &ubyte  SPRPTR1         = 2041
        &ubyte  SPRPTR2         = 2042
        &ubyte  SPRPTR3         = 2043
        &ubyte  SPRPTR4         = 2044
        &ubyte  SPRPTR5         = 2045
        &ubyte  SPRPTR6         = 2046
        &ubyte  SPRPTR7         = 2047
        &ubyte[8]  SPRPTR       = 2040      ; the 8 sprite pointers as an array.


; ---- VIC-II 6567/6569/856x registers ----

        &ubyte  SP0X            = $d000
        &ubyte  SP0Y            = $d001
        &ubyte  SP1X            = $d002
        &ubyte  SP1Y            = $d003
        &ubyte  SP2X            = $d004
        &ubyte  SP2Y            = $d005
        &ubyte  SP3X            = $d006
        &ubyte  SP3Y            = $d007
        &ubyte  SP4X            = $d008
        &ubyte  SP4Y            = $d009
        &ubyte  SP5X            = $d00a
        &ubyte  SP5Y            = $d00b
        &ubyte  SP6X            = $d00c
        &ubyte  SP6Y            = $d00d
        &ubyte  SP7X            = $d00e
        &ubyte  SP7Y            = $d00f
        &ubyte[16]  SPXY        = $d000        ; the 8 sprite X and Y registers as an array.
        &uword[8] @nosplit SPXYW  = $d000        ; the 8 sprite X and Y registers as a combined xy word array.

        &ubyte  MSIGX           = $d010
        &ubyte  SCROLY          = $d011
        &ubyte  RASTER          = $d012
        &ubyte  LPENX           = $d013
        &ubyte  LPENY           = $d014
        &ubyte  SPENA           = $d015
        &ubyte  SCROLX          = $d016
        &ubyte  YXPAND          = $d017
        &ubyte  VMCSB           = $d018
        &ubyte  VICIRQ          = $d019
        &ubyte  IREQMASK        = $d01a
        &ubyte  SPBGPR          = $d01b
        &ubyte  SPMC            = $d01c
        &ubyte  XXPAND          = $d01d
        &ubyte  SPSPCL          = $d01e
        &ubyte  SPBGCL          = $d01f

        &ubyte  EXTCOL          = $d020        ; border color
        &ubyte  BGCOL0          = $d021        ; screen color
        &ubyte  BGCOL1          = $d022
        &ubyte  BGCOL2          = $d023
        &ubyte  BGCOL4          = $d024
        &ubyte  SPMC0           = $d025
        &ubyte  SPMC1           = $d026
        &ubyte  SP0COL          = $d027
        &ubyte  SP1COL          = $d028
        &ubyte  SP2COL          = $d029
        &ubyte  SP3COL          = $d02a
        &ubyte  SP4COL          = $d02b
        &ubyte  SP5COL          = $d02c
        &ubyte  SP6COL          = $d02d
        &ubyte  SP7COL          = $d02e
        &ubyte[8]  SPCOL        = $d027


; ---- end of VIC-II registers ----

; ---- CIA 6526 1 & 2 registers ----

        &ubyte  CIA1PRA         = $DC00        ; CIA 1 DRA, keyboard column drive (and joystick control port #2)
        &ubyte  CIA1PRB         = $DC01        ; CIA 1 DRB, keyboard row port (and joystick control port #1)
        &ubyte  CIA1DDRA        = $DC02        ; CIA 1 DDRA, keyboard column
        &ubyte  CIA1DDRB        = $DC03        ; CIA 1 DDRB, keyboard row
        &ubyte  CIA1TAL         = $DC04        ; CIA 1 timer A low byte
        &ubyte  CIA1TAH         = $DC05        ; CIA 1 timer A high byte
        &ubyte  CIA1TBL         = $DC06        ; CIA 1 timer B low byte
        &ubyte  CIA1TBH         = $DC07        ; CIA 1 timer B high byte
        &ubyte  CIA1TOD10       = $DC08        ; time of day, 1/10 sec.
        &ubyte  CIA1TODSEC      = $DC09        ; time of day, seconds
        &ubyte  CIA1TODMMIN     = $DC0A        ; time of day, minutes
        &ubyte  CIA1TODHR       = $DC0B        ; time of day, hours
        &ubyte  CIA1SDR         = $DC0C        ; Serial Data Register
        &ubyte  CIA1ICR         = $DC0D
        &ubyte  CIA1CRA         = $DC0E
        &ubyte  CIA1CRB         = $DC0F

        &ubyte  CIA2PRA         = $DD00        ; CIA 2 DRA, serial port and video address
        &ubyte  CIA2PRB         = $DD01        ; CIA 2 DRB, RS232 port / USERPORT
        &ubyte  CIA2DDRA        = $DD02        ; CIA 2 DDRA, serial port and video address
        &ubyte  CIA2DDRB        = $DD03        ; CIA 2 DDRB, RS232 port / USERPORT
        &ubyte  CIA2TAL         = $DD04        ; CIA 2 timer A low byte
        &ubyte  CIA2TAH         = $DD05        ; CIA 2 timer A high byte
        &ubyte  CIA2TBL         = $DD06        ; CIA 2 timer B low byte
        &ubyte  CIA2TBH         = $DD07        ; CIA 2 timer B high byte
        &ubyte  CIA2TOD10       = $DD08        ; time of day, 1/10 sec.
        &ubyte  CIA2TODSEC      = $DD09        ; time of day, seconds
        &ubyte  CIA2TODMIN      = $DD0A        ; time of day, minutes
        &ubyte  CIA2TODHR       = $DD0B        ; time of day, hours
        &ubyte  CIA2SDR         = $DD0C        ; Serial Data Register
        &ubyte  CIA2ICR         = $DD0D
        &ubyte  CIA2CRA         = $DD0E
        &ubyte  CIA2CRB         = $DD0F

; ---- end of CIA registers ----

; ---- SID 6581/8580 registers ----

        &ubyte  FREQLO1         = $D400        ; channel 1 freq lo
        &ubyte  FREQHI1         = $D401        ; channel 1 freq hi
        &uword  FREQ1           = $D400        ; channel 1 freq (word)
        &ubyte  PWLO1           = $D402        ; channel 1 pulse width lo (7-0)
        &ubyte  PWHI1           = $D403        ; channel 1 pulse width hi (11-8)
        &uword  PW1             = $D402        ; channel 1 pulse width (word)
        &ubyte  CR1             = $D404        ; channel 1 voice control register
        &ubyte  AD1             = $D405        ; channel 1 attack & decay
        &ubyte  SR1             = $D406        ; channel 1 sustain & release
        &ubyte  FREQLO2         = $D407        ; channel 2 freq lo
        &ubyte  FREQHI2         = $D408        ; channel 2 freq hi
        &uword  FREQ2           = $D407        ; channel 2 freq (word)
        &ubyte  PWLO2           = $D409        ; channel 2 pulse width lo (7-0)
        &ubyte  PWHI2           = $D40A        ; channel 2 pulse width hi (11-8)
        &uword  PW2             = $D409        ; channel 2 pulse width (word)
        &ubyte  CR2             = $D40B        ; channel 2 voice control register
        &ubyte  AD2             = $D40C        ; channel 2 attack & decay
        &ubyte  SR2             = $D40D        ; channel 2 sustain & release
        &ubyte  FREQLO3         = $D40E        ; channel 3 freq lo
        &ubyte  FREQHI3         = $D40F        ; channel 3 freq hi
        &uword  FREQ3           = $D40E        ; channel 3 freq (word)
        &ubyte  PWLO3           = $D410        ; channel 3 pulse width lo (7-0)
        &ubyte  PWHI3           = $D411        ; channel 3 pulse width hi (11-8)
        &uword  PW3             = $D410        ; channel 3 pulse width (word)
        &ubyte  CR3             = $D412        ; channel 3 voice control register
        &ubyte  AD3             = $D413        ; channel 3 attack & decay
        &ubyte  SR3             = $D414        ; channel 3 sustain & release
        &ubyte  FCLO            = $D415        ; filter cutoff lo (2-0)
        &ubyte  FCHI            = $D416        ; filter cutoff hi (10-3)
        &uword  FC              = $D415        ; filter cutoff (word)
        &ubyte  RESFILT         = $D417        ; filter resonance and routing
        &ubyte  MVOL            = $D418        ; filter mode and main volume control
        &ubyte  POTX            = $D419        ; potentiometer X
        &ubyte  POTY            = $D41A        ; potentiometer Y
        &ubyte  OSC3            = $D41B        ; channel 3 oscillator value read
        &ubyte  ENV3            = $D41C        ; channel 3 envelope value read

; ---- end of SID registers ----

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

    sub get_vic_memory_base() -> uword {
        ; one of the 4 possible banks. $0000/$4000/$8000/$c000.
        vic20.CIA2DDRA |= %11
        return ((vic20.CIA2PRA & 3) ^ 3) as uword << 14
    }

    sub get_char_matrix_ptr() -> uword {
        ; Usually the character screen matrix is at 1024-2039 (see above)
        ; However the vic memory configuration can be altered and this moves these registers with it.
        ; So this routine determines it dynamically from the VIC memory setup.
        uword chars_matrix_offset = (vic20.VMCSB & $f0) as uword << 6
        return get_vic_memory_base() + chars_matrix_offset
    }

    sub get_bitmap_ptr() -> uword {
        return get_vic_memory_base() + ((vic20.VMCSB & %00001000) as uword << 10)
    }

    sub get_sprite_addr_ptrs() -> uword {
        ; Usually the sprite address pointers are at addresses 2040-2047 (see above)
        ; However the vic memory configuration can be altered and this moves these registers with it.
        ; So this routine determines it dynamically from the VIC memory setup.
        return get_char_matrix_ptr() + 1016
    }

    sub set_sprite_ptr(ubyte sprite_num, uword sprite_data_address) {
        ; Sets the sprite data pointer to the given address.
        ; Because it takes some time to calculate things based on the vic memory setup,
        ; its only suitable if you're not continuously changing the data address.
        ; Otherwise store the correct sprite data pointer location somewhere yourself and reuse it.
        @(get_sprite_addr_ptrs() + sprite_num) = lsb(sprite_data_address / 64)
    }
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
-           bit  vic20.SCROLY
            bpl  -
-           bit  vic20.SCROLY
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
    &uword r0  = $1217
    &uword r1  = $1219
    &uword r2  = $121b
    &uword r3  = $121d
    &uword r4  = $121f
    &uword r5  = $1221
    &uword r6  = $1223
    &uword r7  = $1225
    &uword r8  = $1227
    &uword r9  = $1229
    &uword r10 = $122b
    &uword r11 = $122d
    &uword r12 = $122f
    &uword r13 = $1231
    &uword r14 = $1233
    &uword r15 = $1235

    ; signed word versions
    &word r0s  = $1217
    &word r1s  = $1219
    &word r2s  = $121b
    &word r3s  = $121d
    &word r4s  = $121f
    &word r5s  = $1221
    &word r6s  = $1223
    &word r7s  = $1225
    &word r8s  = $1227
    &word r9s  = $1229
    &word r10s = $122b
    &word r11s = $122d
    &word r12s = $122f
    &word r13s = $1231
    &word r14s = $1233
    &word r15s = $1235

    ; ubyte versions (low and high bytes)
    &ubyte r0L  = $1217
    &ubyte r1L  = $1219
    &ubyte r2L  = $121b
    &ubyte r3L  = $121d
    &ubyte r4L  = $121f
    &ubyte r5L  = $1221
    &ubyte r6L  = $1223
    &ubyte r7L  = $1225
    &ubyte r8L  = $1227
    &ubyte r9L  = $1229
    &ubyte r10L = $122b
    &ubyte r11L = $122d
    &ubyte r12L = $122f
    &ubyte r13L = $1231
    &ubyte r14L = $1233
    &ubyte r15L = $1235

    &ubyte r0H  = $1218
    &ubyte r1H  = $121a
    &ubyte r2H  = $121c
    &ubyte r3H  = $121e
    &ubyte r4H  = $1220
    &ubyte r5H  = $1222
    &ubyte r6H  = $1224
    &ubyte r7H  = $1226
    &ubyte r8H  = $1228
    &ubyte r9H  = $122a
    &ubyte r10H = $122c
    &ubyte r11H = $122e
    &ubyte r12H = $1230
    &ubyte r13H = $1232
    &ubyte r14H = $1234
    &ubyte r15H = $1236

    ; signed byte versions (low and high bytes)
    &byte r0sL  = $1217
    &byte r1sL  = $1219
    &byte r2sL  = $121b
    &byte r3sL  = $121d
    &byte r4sL  = $121f
    &byte r5sL  = $1221
    &byte r6sL  = $1223
    &byte r7sL  = $1225
    &byte r8sL  = $1227
    &byte r9sL  = $1229
    &byte r10sL = $122b
    &byte r11sL = $122d
    &byte r12sL = $122f
    &byte r13sL = $1231
    &byte r14sL = $1233
    &byte r15sL = $1235

    &byte r0sH  = $1218
    &byte r1sH  = $121a
    &byte r2sH  = $121c
    &byte r3sH  = $121e
    &byte r4sH  = $1220
    &byte r5sH  = $1222
    &byte r6sH  = $1224
    &byte r7sH  = $1226
    &byte r8sH  = $1228
    &byte r9sH  = $122a
    &byte r10sH = $122c
    &byte r11sH = $122e
    &byte r12sH = $1230
    &byte r13sH = $1232
    &byte r14sH = $1234
    &byte r15sH = $1236

    ; boolean versions
    &bool r0bL  = $1217
    &bool r1bL  = $1219
    &bool r2bL  = $121b
    &bool r3bL  = $121d
    &bool r4bL  = $121f
    &bool r5bL  = $1221
    &bool r6bL  = $1223
    &bool r7bL  = $1225
    &bool r8bL  = $1227
    &bool r9bL  = $1229
    &bool r10bL = $122b
    &bool r11bL = $122d
    &bool r12bL = $122f
    &bool r13bL = $1231
    &bool r14bL = $1233
    &bool r15bL = $1235

    &bool r0bH  = $1218
    &bool r1bH  = $121a
    &bool r2bH  = $121c
    &bool r3bH  = $121e
    &bool r4bH  = $1220
    &bool r5bH  = $1222
    &bool r6bH  = $1224
    &bool r7bH  = $1226
    &bool r8bH  = $1228
    &bool r9bH  = $122a
    &bool r10bH = $122c
    &bool r11bH = $122e
    &bool r12bH = $1230
    &bool r13bH = $1232
    &bool r14bH = $1234
    &bool r15bH = $1236

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
