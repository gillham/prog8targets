; Prog8 definitions for the Mega65
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
        const  uword  Screen    = $0800     ; to have this as an array[40*25] the compiler would have to support array size > 255
        const  uword  Colors    = $d800     ; to have this as an array[40*25] the compiler would have to support array size > 255


; ---- CBM ROM kernal routines (C64 addresses) ----

extsub $AB1E = STROUT(str strptr @ AY) clobbers(A, X, Y)      ; print null-terminated string (use txt.print instead)
extsub $E544 = CLEARSCR() clobbers(A,X,Y)                       ; clear the screen
extsub $E566 = HOMECRSR() clobbers(A,X,Y)                       ; cursor to top left of screen
extsub $F9EC = IRQDFRT() clobbers(A,X,Y)                        ; default IRQ routine
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

asmsub SETTIML(long jiffies @R0R1_32) {
    ; -- just like SETTIM, but with a single 32 bit (lower 24 bits used) argument.
    %asm {{
        lda  cx16.r0
        ldx  cx16.r0+1
        ldy  cx16.r0+2
        jmp  SETTIM
    }}
}

asmsub RDTIML() clobbers(X) -> long @R0R1_32 {
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

c64 {
;        const ubyte PROG8_C64_BANK_CONFIG=30

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

        &ubyte  CLKRATE         = $d030        ; Processor clock rate control register (like C128)


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
    ;    see https://www.c64-wiki.com/wiki/Bank_Switching
    %asm {{
        and  #%00000111
        sta  P8ZP_SCRATCH_REG
        php
        sei
        lda  $01
        and  #%11111000
        ora  P8ZP_SCRATCH_REG
        sta  $01
        plp
        rts
    }}
}

inline asmsub getbanks() -> ubyte @A {
    ; -- get the current memory bank configuration
    ;    see https://www.c64-wiki.com/wiki/Bank_Switching
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
            sta  _jmpfar_vec
            iny
            lda  (P8ZP_SCRATCH_W1),y            ; now the high byte
            sta  _jmpfar_vec+1
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
            jsr  _jsrfar        ; do the actual call
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
_jsrfar     jmp  (_jmpfar_vec)

            .section BSS
_jmpfar_vec .word ?
            .send BSS

            ; !notreached!
        }}
    }

    sub get_vic_memory_base() -> uword {
        ; one of the 4 possible banks. $0000/$4000/$8000/$c000.
        c64.CIA2DDRA |= %11
        return ((c64.CIA2PRA & 3) ^ 3) as uword << 14
    }

    sub get_char_matrix_ptr() -> uword {
        ; Usually the character screen matrix is at 1024-2039 (see above)
        ; However the vic memory configuration can be altered and this moves these registers with it.
        ; So this routine determines it dynamically from the VIC memory setup.
        uword chars_matrix_offset = (c64.VMCSB & $f0) as uword << 6
        return get_vic_memory_base() + chars_matrix_offset
    }

    sub get_bitmap_ptr() -> uword {
        return get_vic_memory_base() + ((c64.VMCSB & %00001000) as uword << 10)
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

c65 {

; ---- VIC-III / C65 registers ----

        &ubyte  BORDERCOL       = $d020     ; border color
        &ubyte  SCREENCOL       = $d021     ; screen color
        &ubyte  MC1             = $d022
        &ubyte  MC2             = $d023
        &ubyte  MC3             = $d024
        &ubyte  SPRMC0          = $d025
        &ubyte  SPRMC1          = $d026
        &ubyte  KEY             = $d02F     ; I/O personality configuration keyhole
        &ubyte  CRAM2K          = $D030     ; enable 2K color ram
        &ubyte  VIDMODE         = $D031     ; bit7=40/80 toggle

        &ubyte  B0AD            = $D033
        &ubyte  B1AD            = $D034
        &ubyte  B2AD            = $D035
        &ubyte  B3AD            = $D036
        &ubyte  B4AD            = $D037
        &ubyte  B5AD            = $D038
        &ubyte  B6AD            = $D039
        &ubyte  B7AD            = $D03A
        &ubyte  BPCOMP          = $D03B
        &ubyte  BPX             = $D03C
        &ubyte  BPY             = $D03D
        &ubyte  HPOS            = $D03E
        &ubyte  VPOS            = $D03F
        &ubyte  B0PIX           = $D040
        &ubyte  B1PIX           = $D041
        &ubyte  B2PIX           = $D042
        &ubyte  B3PIX           = $D043
        &ubyte  B4PIX           = $D044
        &ubyte  B5PIX           = $D045
        &ubyte  B6PIX           = $D046
        &ubyte  B7PIX           = $D047

        &ubyte  PALRED          = $D100
        &ubyte  PALGREEN        = $D200
        &ubyte  PALBLUE         = $D300

; ---- end of VIC-III / C65 registers ----

; ---- UART 6551 registers ----

        &ubyte  UARTDATA        = $D600
        &ubyte  UARTFLAG        = $D601
        &ubyte  UARTCONFIG      = $D602
        &ubyte  UARTDIVISOR0    = $D603
        &ubyte  UARTDIVISOR1    = $D604
        &ubyte  UARTIRQ0        = $D605
        &ubyte  UARTIRQ1        = $D606

; ---- end of UART registers ----

}

mega65 {
        ; placeholder
        const ubyte PROG8_MEGA65_BANK_CONFIG=30
        ubyte @shared restore_sysflags

        ; MEGA65 kernal routines
        extsub $FF47 = SYSFLAGS(ubyte value @ A, bool dir @ Pc) -> ubyte @ A ; read/set system flags

        ; I/O blocks
        ; $D000-$D02F: VIC-II (in C64 block above)
        ; $D030-$D07F: VIC-III
        ; $D080-$D08F: F011 ??
        ; $D090-$D09F: SD card
        ; $D0A0-$D0FF: unused
        ; $D100-$D1FF: RED Palette
        ; $D200-$D2FF: GREEN Palette
        ; $D300-$D3FF: BLUE Palette
        ; $D400-$D41F: SID Right #1
        ; $D420-$D43F: SID Right #2
        ; $D440-$D45F: SID Left #1
        ; $D460-$D47F: SID Left #2
        ; $D480-$D49F: SID Right #3?
        ; $D4A0-$D4BF: SID Right #4?
        ; $D4C0-$D4DF: SID Left #3?
        ; $D4E0-$D4FF: SID Left #4?
        ; $D500-$D5FF: reserved
        ; $D600-$D63F: UART
        ; $D640-$D67F: HyperTrap Registers
        ; $D680-$D6FF: MEGA65 Devices
        ; $D700-$D7FF: MEGA65 Devices
        ; $D800-$DBFF: Color / Colour RAM
        ; $DC00-$DDFF: CIAs / Color / Colour RAM
        ; $DE00-$DFFF: CART I/O / SD SECTOR

; ---- VIC-IV / MEGA65 registers ----

        &ubyte  BORDERCOL       = $d020     ; border color
        &ubyte  SCREENCOL       = $d021     ; screen color
        &ubyte  MC1             = $d022
        &ubyte  MC2             = $d023
        &ubyte  MC3             = $d024
        &ubyte  SPRMC0          = $d025
        &ubyte  SPRMC1          = $d026
        &ubyte  KEY             = $d02F     ; I/O personality configuration keyhole

        &ubyte  TBDRPOS         = $D048
        &ubyte  TBDRPOSMSB      = $D049
        &ubyte  BBDRPOS         = $D04A
        &ubyte  BBDRPOSMSB      = $D04B
        &ubyte  TEXTXPOS        = $D04C
        &ubyte  TEXTXPOSMSB     = $D04D
        &ubyte  TEXTYPOS        = $D04E
        &ubyte  TEXTYPOSMSB     = $D04F
        &ubyte  XPOSLSB         = $D050
        &ubyte  XPOSMSB         = $D051
        &ubyte  FNRASTERLSB     = $D052
        &ubyte  FNRASTERMSB     = $D053
        &ubyte  CHR16           = $D054
        &ubyte  SPRHGTEN        = $D055
        &ubyte  SPRHGHT         = $D056
        &ubyte  SPRX64EN        = $D057
        &ubyte  LINESTEPLSB     = $D058
        &ubyte  LINESTEPMSB     = $D059
        &ubyte  CHRXSCL         = $D05A
        &ubyte  CHRYSCL         = $D05B
        &ubyte  SDBDRWDLSB      = $D05C
        &ubyte  SDBDRWDMSB      = $D05D
        &ubyte  CHRCOUNT        = $D05E
        &ubyte  SPRXSMSBS       = $D05F
        &ubyte  SCRNPTRLSB      = $D060
        &ubyte  SCRNPTRMSB      = $D061
        &ubyte  SCRNPTRBNK      = $D062
        &ubyte  SCRNPTRMB       = $D063
        &ubyte  COLPTRLSB       = $D064
        &ubyte  COLPTRMSB       = $D065
        &ubyte  CHARPTRLSB      = $D068
        &ubyte  CHARPTRMSB      = $D069
        &ubyte  CHARPTRBNK      = $D06A
        &ubyte  SPR16EN         = $D06B
        &ubyte  SPRPTRADRLSB    = $D06C
        &ubyte  SPRPTRADRMSB    = $D06D
        &ubyte  SPRPTRBNK       = $D06E
        &ubyte  RASLINE0        = $D06F
        &ubyte  PALSEL          = $D070
        &ubyte  BP16ENS         = $D071
        &ubyte  SPRYADJ         = $D072
        &ubyte  RASTERHEIGHT    = $D073
        &ubyte  SPRENALPHA      = $D074
        &ubyte  SPRALPHAVAL     = $D075
        &ubyte  SPRENV400       = $D076
        &ubyte  SPRYMSBS        = $D077
        &ubyte  SPRYSMSBS       = $D078
        &ubyte  RASCMP          = $D079
        &ubyte  RASCMPMSB       = $D07A
        &ubyte  DISPROWS        = $D07B
        &ubyte  BITPBANK        = $D07C

; ---- end of VIC-IV / MEGA65 registers ----

; move to C65?
; ---- F011 Floppy registers ----
        &ubyte  FLPREG0         = $D080
        &ubyte  FLPREG1         = $D081
        &ubyte  FLPREG2         = $D082
        &ubyte  FLPREG3         = $D083
        &ubyte  FLPTRACK        = $D084
        &ubyte  FLPSECTOR       = $D085
        &ubyte  FLPSIDE         = $D086
        &ubyte  FLPDATA         = $D087
        &ubyte  FLPCLOCK        = $D088
        &ubyte  FLPSTEP         = $D089
        &ubyte  FLPPCODE        = $D08A

; ---- end of Floppy registers ----

; ---- 4551 GPIO registers ----

        &ubyte  UFAST           = $D609
        &ubyte  MODIFIERKEY     = $D60A
        &ubyte  PORTF           = $D60B
        &ubyte  PORTFDDR        = $D60C
        &ubyte  SDCARD          = $D60D
        &ubyte  BASHDDR         = $D60E
        &ubyte  MISCKEY         = $D60F
        &ubyte  ASCIIKEY        = $D610
        &ubyte  MEGAKEY         = $D611
        &ubyte  JOYSWAP         = $D612
        &ubyte  VIRTKEY1        = $D615
        &ubyte  VIRTKEY2        = $D616
        &ubyte  VIRTKEY3        = $D617
        &ubyte  KSCNRATE        = $D618
        &ubyte  PETSCIIKEY      = $D619
        &ubyte  SYSCTL          = $D61A
        &ubyte  KEYLEDREG       = $D61D
        &ubyte  KEYLEDVAL       = $D61E
        &ubyte  POTAX           = $D620
        &ubyte  POTAY           = $D621
        &ubyte  POTBX           = $D622
        &ubyte  POTBY           = $D623
        &ubyte  J21L            = $D625
        &ubyte  J21H            = $D626
        &ubyte  J21LDDR         = $D627
        &ubyte  J21HDDR         = $D628
        &ubyte  M65MODEL        = $D629

; ---- end of GPIO registers ----

; ---- SID mode registers ----

        &ubyte  SIDMODE         = $D63C

; ---- end of SID mode registers ----

; ---- 45IO27 registers ----

        &ubyte  SDCMDANDSTAT    = $D680
        &ubyte  SDSECTOR0       = $D681
        &ubyte  SDSECTOR1       = $D682
        &ubyte  SDSECTOR2       = $D683
        &ubyte  SDSECTOR3       = $D684
        &ubyte  SDFILLVAL       = $D686

        &ubyte  IO27FLAGS0      = $D68A
        &ubyte  IO27FLAGS1      = $D68B
        &ubyte  D0STARTSEC0     = $D68C
        &ubyte  D0STARTSEC1     = $D68D
        &ubyte  D0STARTSEC2     = $D68E
        &ubyte  D0STARTSEC3     = $D68F
        &ubyte  D1STARTSEC0     = $D690
        &ubyte  D1STARTSEC1     = $D691
        &ubyte  D1STARTSEC2     = $D692
        &ubyte  D1STARTSEC3     = $D693
        &ubyte  IO27FLAGS2      = $D6A1
        &ubyte  IO27FLAGS3      = $D6AE
        &ubyte  IO27FLAGS4      = $D6AF

        &ubyte  MIXREGSEL       = $D6F4
        &ubyte  MIXREGDATA      = $D6F5
        &ubyte  DIGILLSB        = $D6F8
        &ubyte  DIGILMSB        = $D6F9
        &ubyte  DIGIRLSB        = $D6FA
        &ubyte  DIGIRMSB        = $D6FB
        &ubyte  READBACKLSB     = $D6FC
        &ubyte  READBACKMSB     = $D6FD
        &ubyte  PWMPDM          = $D711

; ---- end of 45IO27 registers ----

; ---- 45E100 Ethernet registers ----

        &ubyte  ETHFLAGS0       = $D6E0
        &ubyte  ETHFLAGS1       = $D6E1
        &ubyte  ETHTXSZLSB      = $D6E2
        &ubyte  ETHTXSZMSB      = $D6E3
        &ubyte  ETHCOMMAND      = $D6E4
        &ubyte  ETHFLAGS2       = $D6E5
        &ubyte  ETHMIIM         = $D6E6
        &ubyte  ETHMIIMVLSB     = $D6E7
        &ubyte  ETHMIIMVMSB     = $D6E8
        &ubyte  ETHMACADDR1     = $D6E9
        &ubyte  ETHMACADDR2     = $D6EA
        &ubyte  ETHMACADDR3     = $D6EB
        &ubyte  ETHMACADDR4     = $D6EC
        &ubyte  ETHMACADDR5     = $D6ED
        &ubyte  ETHMACADDR6     = $D6EE

; ---- end of Ethernet registers ----


; ---- CIA 6526 Hypervisor registers ----

        &ubyte  CIA1TALATCH0    = $DC10
        &ubyte  CIA1TALATCH1    = $DC11
        &ubyte  CIA1TALATCH2    = $DC12
        &ubyte  CIA1TALATCH3    = $DC13
        &ubyte  CIA1TALATCH4    = $DC14
        &ubyte  CIA1TALATCH5    = $DC15
        &ubyte  CIA1TALATCH6    = $DC16
        &ubyte  CIA1TALATCH7    = $DC17
        &ubyte  CIA1TODJIF      = $DC18
        &ubyte  CIA1TODSEC      = $DC19
        &ubyte  CIA1TODMIN      = $DC1A
        &ubyte  CIA1TODHOUR     = $DC1B
        &ubyte  CIA1ALRMJIF     = $DC1C
        &ubyte  CIA1ALRMSEC     = $DC1D
        &ubyte  CIA1ALRMMIN     = $DC1E
        &ubyte  CIA1ALRMHOUR    = $DC1F

        &ubyte  CIA2TALATCH0    = $DD10
        &ubyte  CIA2TALATCH1    = $DD11
        &ubyte  CIA2TALATCH2    = $DD12
        &ubyte  CIA2TALATCH3    = $DD13
        &ubyte  CIA2TALATCH4    = $DD14
        &ubyte  CIA2TALATCH5    = $DD15
        &ubyte  CIA2TALATCH6    = $DD16
        &ubyte  CIA2TALATCH7    = $DD17
        &ubyte  CIA2TODJIF      = $DD18
        &ubyte  CIA2TODSEC      = $DD19
        &ubyte  CIA2TODMIN      = $DD1A
        &ubyte  CIA2TODHOUR     = $DD1B
        &ubyte  CIA2ALRMJIF     = $DD1C
        &ubyte  CIA2ALRMSEC     = $DD1D
        &ubyte  CIA2ALRMMIN     = $DD1E
        &ubyte  CIA2ALRMHOUR    = $DD1F

; ---- end of CIA 6526 Hypervisor registers ----

asmsub banks(ubyte banks @A) {
    ; -- set the memory bank configuration
    ;    see https://www.c64-wiki.com/wiki/Bank_Switching
    %asm {{
        and  #%00000111
        sta  P8ZP_SCRATCH_REG
        php
        sei
        lda  $01
        and  #%11111000
        ora  P8ZP_SCRATCH_REG
        sta  $01
        plp
        rts
    }}
}

inline asmsub getbanks() -> ubyte @A {
    ; -- get the current memory bank configuration
    ;    see https://www.c64-wiki.com/wiki/Bank_Switching
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
            sta  _jmpfar_vec
            iny
            lda  (P8ZP_SCRATCH_W1),y            ; now the high byte
            sta  _jmpfar_vec+1
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
            jsr  _jsrfar        ; do the actual call
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
_jsrfar     jmp  (_jmpfar_vec)

            .section BSS
_jmpfar_vec .word ?
            .send BSS

            ; !notreached!
        }}
    }

    sub get_vic_memory_base() -> uword {
        ; one of the 4 possible banks. $0000/$4000/$8000/$c000.
        c64.CIA2DDRA |= %11
        return ((c64.CIA2PRA & 3) ^ 3) as uword << 14
    }

    sub get_char_matrix_ptr() -> uword {
        ; Usually the character screen matrix is at 1024-2039 (see above)
        ; However the vic memory configuration can be altered and this moves these registers with it.
        ; So this routine determines it dynamically from the VIC memory setup.
        uword chars_matrix_offset = (c64.VMCSB & $f0) as uword << 6
        return get_vic_memory_base() + chars_matrix_offset
    }

    sub get_bitmap_ptr() -> uword {
        return get_vic_memory_base() + ((c64.VMCSB & %00001000) as uword << 10)
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

    ; set processor speed between 1/3.5/40
    ; TODO: support 2MHz C128 compatible mode
    sub speed(ubyte mhz) {
        when mhz {
            1 -> {
                ; disable C65 fast mode
                c65.VIDMODE &= %10111111
            }
            3,4 -> {
                ; enable C65 fast mode
                c65.VIDMODE |= %01000000
                ; disable MEGA65 40MHz mode
                mega65.CHR16 &= %10111111
            }
            40 -> {
                ; enable C65 fast mode
                c65.VIDMODE |= %01000000
                ; enable MEGA65 40 MHz mode
                mega65.CHR16 |= %01000000
            }
        }
    }
}

sys {
    ; ------- lowlevel system routines --------

    const ubyte target = 65         ;  compilation target specifier.  255=virtual, 128=C128, 65=Mega65, 64=C64, 32=PET, 16=CommanderX16, 8=atari800XL, 7=Neo6502

    const ubyte SIZEOF_BOOL  = sizeof(bool)
    const ubyte SIZEOF_BYTE  = sizeof(byte)
    const ubyte SIZEOF_UBYTE = sizeof(ubyte)
    const ubyte SIZEOF_WORD  = sizeof(word)
    const ubyte SIZEOF_UWORD = sizeof(uword)
    const ubyte SIZEOF_LONG  = sizeof(long)
    const ubyte SIZEOF_POINTER = sizeof(&sys.wait)
    const ubyte SIZEOF_FLOAT = sizeof(float)
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
            .section BSS
save_SCRATCH_ZPB1	.byte  ?
save_SCRATCH_ZPREG	.byte  ?
save_SCRATCH_ZPWORD1	.word  ?
save_SCRATCH_ZPWORD2	.word  ?
            .send BSS
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
		beq  +
		jmp  cbm.IRQDFRT		; continue with normal kernal irq routine
+		lda  #$ff
;		sta  c64.VICIRQ			; acknowledge raster irq
;		lda  c64.CIA1ICR		; acknowledge CIA1 interrupt
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
		lda  #0
		sta  c64.IREQMASK	; disable raster irq
		lda  #%10000001
		sta  c64.CIA1ICR	; restore CIA1 irq
		cli
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

		lda  #%01111111
		sta  c64.CIA1ICR    ; "switch off" interrupts signals from cia-1
		sta  c64.CIA2ICR    ; "switch off" interrupts signals from cia-2
		lda  c64.CIA1ICR    ; ack previous irq
		lda  c64.CIA2ICR    ; ack previous irq
        lda  cx16.r0
        ldy  cx16.r0+1
		jsr  sys.set_rasterline
 		lda  #%00000001
		sta  c64.IREQMASK   ; enable raster interrupt signals from vic

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
        lda  #$ff
        sta  c64.VICIRQ			; acknowledge raster irq
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
        sta  c64.RASTER     ; set the raster line number where interrupt should occur
        lda  c64.SCROLY
        and  #%01111111
        cpy  #0
        beq  +
        ora  #%10000000
+       sta  c64.SCROLY     ; clear most significant bit of raster position
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
        ;     note: CIA2 TIMER A has to be active for this to work.
        %asm {{
            stx  P8ZP_SCRATCH_B1
            sta  P8ZP_SCRATCH_W1
            sty  P8ZP_SCRATCH_W1+1
_loop       lda  P8ZP_SCRATCH_W1
            ora  P8ZP_SCRATCH_W1+1
            bne  +
            ldx  P8ZP_SCRATCH_B1
            rts

+           lda  c64.CIA2TAH
            and  #%11000000
            sta  P8ZP_SCRATCH_B1
-           lda  c64.CIA2TAH
            and  #%11000000
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
-           bit  c64.SCROLY
            bpl  -
-           bit  c64.SCROLY
            bmi  -
            rts
        }}
    }

    inline asmsub waitrastborder() {
        ; --- busy wait till the raster position has reached the bottom screen border (approximately)
        ;     note: a more accurate way to do this is by using a raster irq handler instead.
        %asm {{
-           bit  c64.SCROLY
            bpl  -
        }}
    }

    asmsub waitrasterline(uword line @AY) {
        ; -- CPU busy wait until the given raster line is reached
        %asm {{
            cpy  #0
            bne  _larger
-           cmp  c64.RASTER
            bne  -
            bit  c64.SCROLY
            bmi  -
            rts
_larger
            cmp  c64.RASTER
            bne  _larger
            bit  c64.SCROLY
            bpl  _larger
            rts
        }}
    }


    asmsub internal_stringcopy(str source @R0, str target @AY) clobbers (A,Y) {
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
            sta  p8_sys_startup.cleanup_at_exit._exitcarry
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

    inline asmsub pushl(long value @R0R1_32) {
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

    inline asmsub popl() -> long @R0R1_32 {
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
        ; The SuperCPU expansion for the C64/C128 contains a 65816.
        %asm {{
			php
			clv
			.byte $e2, $ea  ; SEP #$ea, should be interpreted as 2 NOPs by 6502. 65c816 will set the Overflow flag.
			bvc +
			lda #1
			plp
			rts
+			lda #0
			plp
			rts
        }}
    }
}

cx16 {
    ; the sixteen virtual 16-bit registers that the CX16 has defined in the zeropage
    ; they are simulated on the C64 as well but their location in memory is different
    ; (because there's no room for them in the zeropage in the default configuration)
    ; Note that when using ZP options that free up more of the zeropage (such as %zeropage kernalsafe)
    ; there might be enough space to put them there after all, and the compiler will change these addresses!
; the sixteen virtual 16-bit registers in both normal unsigned mode and signed mode (s)
    &uword r0  = $bfe0
    &uword r1  = $bfe2
    &uword r2  = $bfe4
    &uword r3  = $bfe6
    &uword r4  = $bfe8
    &uword r5  = $bfea
    &uword r6  = $bfec
    &uword r7  = $bfee
    &uword r8  = $bff0
    &uword r9  = $bff2
    &uword r10 = $bff4
    &uword r11 = $bff6
    &uword r12 = $bff8
    &uword r13 = $bffa
    &uword r14 = $bffc
    &uword r15 = $bffe

    ; signed word versions
    &word r0s  = $bfe0
    &word r1s  = $bfe2
    &word r2s  = $bfe4
    &word r3s  = $bfe6
    &word r4s  = $bfe8
    &word r5s  = $bfea
    &word r6s  = $bfec
    &word r7s  = $bfee
    &word r8s  = $bff0
    &word r9s  = $bff2
    &word r10s = $bff4
    &word r11s = $bff6
    &word r12s = $bff8
    &word r13s = $bffa
    &word r14s = $bffc
    &word r15s = $bffe

    ; signed long versions
    &long r0r1sl = $bfe0
    &long r2r3sl = $bfe4
    &long r4r5sl = $bfe8
    &long r6r7sl = $bfec
    &long r8r9sl = $bff0
    &long r10r11sl = $bff4
    &long r12r13sl = $bff8
    &long r14r15sl = $bffc

    ; ubyte versions (low and high bytes)
    &ubyte r0L  = $bfe0
    &ubyte r1L  = $bfe2
    &ubyte r2L  = $bfe4
    &ubyte r3L  = $bfe6
    &ubyte r4L  = $bfe8
    &ubyte r5L  = $bfea
    &ubyte r6L  = $bfec
    &ubyte r7L  = $bfee
    &ubyte r8L  = $bff0
    &ubyte r9L  = $bff2
    &ubyte r10L = $bff4
    &ubyte r11L = $bff6
    &ubyte r12L = $bff8
    &ubyte r13L = $bffa
    &ubyte r14L = $bffc
    &ubyte r15L = $bffe

    &ubyte r0H  = $bfe1
    &ubyte r1H  = $bfe3
    &ubyte r2H  = $bfe5
    &ubyte r3H  = $bfe7
    &ubyte r4H  = $bfe9
    &ubyte r5H  = $bfeb
    &ubyte r6H  = $bfed
    &ubyte r7H  = $bfef
    &ubyte r8H  = $bff1
    &ubyte r9H  = $bff3
    &ubyte r10H = $bff5
    &ubyte r11H = $bff7
    &ubyte r12H = $bff9
    &ubyte r13H = $bffb
    &ubyte r14H = $bffd
    &ubyte r15H = $bfff

    ; signed byte versions (low and high bytes)
    &byte r0sL  = $bfe0
    &byte r1sL  = $bfe2
    &byte r2sL  = $bfe4
    &byte r3sL  = $bfe6
    &byte r4sL  = $bfe8
    &byte r5sL  = $bfea
    &byte r6sL  = $bfec
    &byte r7sL  = $bfee
    &byte r8sL  = $bff0
    &byte r9sL  = $bff2
    &byte r10sL = $bff4
    &byte r11sL = $bff6
    &byte r12sL = $bff8
    &byte r13sL = $bffa
    &byte r14sL = $bffc
    &byte r15sL = $bffe

    &byte r0sH  = $bfe1
    &byte r1sH  = $bfe3
    &byte r2sH  = $bfe5
    &byte r3sH  = $bfe7
    &byte r4sH  = $bfe9
    &byte r5sH  = $bfeb
    &byte r6sH  = $bfed
    &byte r7sH  = $bfef
    &byte r8sH  = $bff1
    &byte r9sH  = $bff3
    &byte r10sH = $bff5
    &byte r11sH = $bff7
    &byte r12sH = $bff9
    &byte r13sH = $bffb
    &byte r14sH = $bffd
    &byte r15sH = $bfff

    ; boolean versions
    &bool r0bL  = $bfe0
    &bool r1bL  = $bfe2
    &bool r2bL  = $bfe4
    &bool r3bL  = $bfe6
    &bool r4bL  = $bfe8
    &bool r5bL  = $bfea
    &bool r6bL  = $bfec
    &bool r7bL  = $bfee
    &bool r8bL  = $bff0
    &bool r9bL  = $bff2
    &bool r10bL = $bff4
    &bool r11bL = $bff6
    &bool r12bL = $bff8
    &bool r13bL = $bffa
    &bool r14bL = $bffc
    &bool r15bL = $bffe

    &bool r0bH  = $bfe1
    &bool r1bH  = $bfe3
    &bool r2bH  = $bfe5
    &bool r3bH  = $bfe7
    &bool r4bH  = $bfe9
    &bool r5bH  = $bfeb
    &bool r6bH  = $bfed
    &bool r7bH  = $bfef
    &bool r8bH  = $bff1
    &bool r9bH  = $bff3
    &bool r10bH = $bff5
    &bool r11bH = $bff7
    &bool r12bH = $bff9
    &bool r13bH = $bffb
    &bool r14bH = $bffd
    &bool r15bH = $bfff


    asmsub save_virtual_registers() clobbers(A,Y) {
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
    ; ---- utilities -----
    ubyte current_bank = 0  ; current bank via MAP as we can't query it.
    ubyte new_bank = 0      ; place to stash requested bank briefly

    ; no rom unless we fake it?
    inline asmsub rombank(ubyte bank @A) {
        ; -- set the rom banks
        %asm {{
            nop
        }}
    }

    ; support M65 banks starting with zero?
    ; so rambank(0) and banks(0) are not the same...
    asmsub rambank(ubyte bank @A) {
        ; -- set the ram bank
        %asm {{
            .cpu "45gs02"
            phz
            phy
            phx
            sta  cx16.current_bank  ; save currently selected bank since we can't retrieve from MAP
            tax                     ; stash x16bank from A for a moment
            lda  #$00
            tay                     ; make sure this is zero in case we branch to _switch0 (A&X zeroed below)
            ldz  #$83               ; default "bank 0" with kernal at $e000
            txa                     ; bring x16bank back to A
            beq  _switch0           ; x16bank 0 is base RAM or default mapping so skip ahead
            tay                     ; use x16bank as loop counter
            lda  #$00               ; we will track the most significant nibble in Z
            taz                     ; so start from zero
            lda  #$40               ; x16bank 1 is at offset $06000 ($6000+$A000=$10000 start of bank)
-           clc                     ; so we load with #$40 since we will for sure at $20 below (giving the $60)
            adc  #$20               ; offsets of $6000, $8000, ...   (which $a000 is added to)
            bcc  +                  ; no overflow so don't increment Z
            inz                     ; increment our highest nibble
+           dey
            bne  -                  ; keep adding #$20
            tay                     ; move offset portion to Y
            tza                     ; get high nibble of offset
            clc
            adc  #$20               ; add to the 0, 1, 3, 4, or 5 already in A (giving M65 bank 1/4/5) $A000 offset enabled            txa                     ; retrieve x16bank from X
            taz                     ; Z now has correct value for bank 1 (but will need adjusting for 4&5)
            txa                     ; retrieve x16bank
            dec  a                  ; make zero relative
            asr                     ; shift bits [4:3] to [1:0]
            asr
            asr
            beq  _switch0           ; zero means M65 bank 1 and we should be setup
            tza                     ; grab offset highest nibble
            clc
            adc  #$02               ; skip over banks 2&3
            taz                     ; Needs to be in Z
_switch0:
            lda  #$00               ; no offset for lower 32KB no matter what bank
            tax                     ; no offset enable for lower 32KB
            map                     ; do the mapping
            eom                     ; end of mapping, allow interrupts.
            plx
            ply
            plz
            .cpu "6502"
            rts
        }}
    }

    ; all rom banks are 0 for now.
    inline asmsub getrombank() -> ubyte @A {
        ; -- get the current rom bank
        %asm {{
            lda  #$00
        }}
    }

    ; this *only* reports 384KB chip ram in 8KB RAM banks
    ; this is not related to native c64 6510 banking
    inline asmsub getrambank() -> ubyte @A {
        ; -- get the current RAM bank
        %asm {{
            lda  cx16.current_bank
        }}
    }

    inline asmsub push_rombank(ubyte newbank @A) clobbers(Y) {
        ; push the current rombank on the stack and makes the given rom bank active
        ; combined with pop_rombank() makes for easy temporary rom bank switch
        %asm {{
            nop
        }}
    }

    inline asmsub pop_rombank() {
        ; sets the current rom bank back to what was stored previously on the stack
        %asm {{
            nop
        }}
    }

    inline asmsub push_rambank(ubyte newbank @A) clobbers(Y) {
        ; push the current hiram bank on the stack and makes the given hiram bank active
        ; combined with pop_rombank() makes for easy temporary hiram bank switch
        %asm {{
            sta  cx16.new_bank
            lda  cx16.current_bank
            pha
            lda  cx16.new_bank
            jsr  cx16.rambank
        }}
    }

    inline asmsub pop_rambank() {
        ; sets the current hiram bank back to what was stored previously on the stack
        %asm {{
            pla
            jsr  cx16.rambank
        }}
    }

    asmsub numbanks() clobbers(X) -> uword @AY {
        ; -- Returns the number of available M65 chip ram backed 8KB RAM banks.
        ;    Note that on the X16 the number of banks can be 256 so a word is returned.
        ;    Currently this is 24 on Mega65. (3x64KB banks with 8KB banks each)
        %asm {{
            lda #$18
            ldy #$00
            rts
        }}
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
        .cpu "45gs02"
        ; clear the C65 memory map
        lda #$00
        tax
        tay
        ;taz
        ; map the kernel (at $3e000) to $e000
        ; we should map it in / out as we need it instead.
        ldz  #$83
        map
        ; bank $d000 I/O in via C64 registers
        lda  #$35
        sta  $01
        ; C65 mode I/O knock
        ;lda #$a5
        ;sta $d02f
        ;lda #$96
        ;sta $d02f
        ; MEGA65 mode / VIC-IV I/O knock
        lda  #$47
        sta  $d02f
        lda  #$53
        sta  $d02f
        ; end of MAP sequence allowing interrupts again
        eom
        ; ensure 40MHz
        ;lda #65
        ;sta $00
        ; Use base page $16
        ;lda #$16
        ;tab
        lda  #6
        sta  c64.EXTCOL
        ;lda  #7
        ;sta  cbm.COLOR
        lda  #0
        sta  c64.BGCOL0
        ; save system flags prior to disabling function key macros
        sec
        jsr mega65.SYSFLAGS
        sta mega65.restore_sysflags
        ora #%00100000  ; disable function key macros
        clc
        jsr mega65.SYSFLAGS
        .cpu  "6502"
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
        .cpu "45gs02"
        ; restore system flags
        lda mega65.restore_sysflags
        clc
        jsr mega65.SYSFLAGS
        ; switch back to base page 0
        lda #$00
        tab
        jsr  cbm.CLRCHN		; reset i/o channels
        lda  _exitcarry
        lsr  a
        lda  _exitcode
        ldx  _exitcodeX
        ldy  _exitcodeY
        .cpu "6502"
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
        sta  657    ; disable charset switching
        lda  #239
        sta  808    ; disable run/stop key
        rts
    }}
}

asmsub  enable_runstop_and_charsetswitch() clobbers(A) {
    %asm {{
        lda  #0
        sta  657    ; enable charset switching
        lda  #237
        sta  808    ; enable run/stop key
        rts
    }}
}

}
