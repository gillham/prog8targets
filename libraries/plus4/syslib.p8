; Prog8 definitions for the Commodore Plus/4
; Including memory registers, I/O registers, Basic and Kernal subroutines.

%option no_symbol_prefixing, ignore_unused

cbm {
    ; Commodore (CBM) common variables, vectors and kernal routines

        &ubyte  TIME_HI         = $a3       ; software jiffy clock, hi byte
        &ubyte  TIME_MID        = $a4       ;  .. mid byte
        &ubyte  TIME_LO         = $a5       ;    .. lo byte. Updated by IRQ every 1/60 sec
        &ubyte  STATUS          = $90       ; kernal status variable for I/O
        &ubyte  STKEY           = $91       ; various keyboard statuses (updated by IRQ)
        &ubyte  SFDX            = $cb       ; current key pressed (matrix value) (updated by IRQ)
        &ubyte  SHFLAG          = $0543     ; various modifier key status (updated by IRQ)

        &ubyte  COLOR           = $053B     ; cursor color
        &ubyte  HIBASE          = $053E     ; screen base address / 256 (hi-byte of screen memory address)

        &uword  IERROR          = $0300
        &uword  IMAIN           = $0302
        &uword  ICRNCH          = $0304
        &uword  IQPLOP          = $0306
        &uword  IGONE           = $0308
        &uword  IEVAL           = $030a
        ; TODO: IESCLK/IESCPR/IESCEX $030c-$0311
        &uword  ITIME           = $0312     ; TODO: define
        ; $0313 is unused.
        &uword  CINV            = $0314     ; IRQ vector (in ram)
        &uword  CBINV           = $0316     ; BRK vector (in ram)
        ; TODO: find.
        &uword  NMINV           = $0318     ; NMI vector (in ram)

        &uword  IOPEN           = $0318
        &uword  ICLOSE          = $031a
        &uword  ICHKIN          = $031c
        &uword  ICKOUT          = $031e
        &uword  ICLRCH          = $0320
        &uword  IBASIN          = $0322
        &uword  IBSOUT          = $0324
        &uword  ISTOP           = $0326
        &uword  IGETIN          = $0328
        &uword  ICLALL          = $032a
        &uword  USERCMD         = $032c
        &uword  ILOAD           = $032e
        &uword  ISAVE           = $0330

        &ubyte  SAREG           = $07f2     ; register storage for A for SYS calls
        &ubyte  SXREG           = $07f3     ; register storage for X for SYS calls
        &ubyte  SYREG           = $07f4     ; register storage for Y for SYS calls
        &ubyte  SPREG           = $07f5     ; register storage for P (status register) for SYS calls

        &uword  NMI_VEC         = $FFFA     ; 6502 nmi vector, but reset vector on Plus/4
        &uword  RESET_VEC       = $FFFC     ; 6502 reset vector, determined by the kernal if banked in
        &uword  IRQ_VEC         = $FFFE     ; 6502 interrupt vector, determined by the kernal if banked in

        ; the default addresses for the character screen chars and colors
        const  uword  Screen    = $0c00     ; to have this as an array[40*25] the compiler would have to support array size > 255
        const  uword  Colors    = $0800     ; to have this as an array[40*25] the compiler would have to support array size > 255


; ---- CBM ROM kernal routines (Plus/4 addresses) ----

extsub $CE0E = IRQDFRT() clobbers(A,X,Y)                        ; default IRQ routine

; TODO: find equivalent or cleanup
;extsub $E544 = CLEARSCR() clobbers(A,X,Y)                       ; clear the screen
;extsub $E566 = HOMECRSR() clobbers(A,X,Y)                       ; cursor to top left of screen
;extsub $EA81 = IRQDFEND() clobbers(A,X,Y)                       ; default IRQ end/cleanup

; 264 series specific
extsub $FF49 = DEFKEY()                                         ; TBD
extsub $FF4C = PRINT()                                          ; TBD
extsub $FF4F = PRIMM()                                          ; TBD
extsub $FF52 = MONITOR()                                        ; TBD

; ---- CBM ROM kernal routines (Plus/4 (& others) addresses) ----
extsub $FF81 = CINT() clobbers(A,X,Y)                           ; (alias: VIDINIT/SCINIT) initialize screen editor and video chip
extsub $FF84 = IOINIT() clobbers(A, X)                          ; initialize I/O devices
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
extsub $FFF6 = RESET()                                          ; bank ROM in and reset system via $FFF9 then $F2A4


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

plus4 {
        ; Plus/4 color table.  Maps "standard" CBM colors
        ; to the closest Plus/4 chroma + luma
        ubyte [16] color_table = [$10, $71, $32, $63, $44, $35, $46, $77,
                                  $48, $29, $5a, $6b, $5c, $6d, $2e, $5f]
        ; plus4 I/O registers (...)

; ---- ACIA 6551A registers ----
        &ubyte  ACIADATA        = $fd00         ; DATA port
        &ubyte  ACIASTATUS      = $fd01         ; STATUS port
        &ubyte  ACIACOMMAND     = $fd02         ; COMMAND port
        &ubyte  ACIACONTROL     = $fd03         ; CONTROL port

; ---- PIO 6529B registers ----
        &ubyte  PIO1            = $fd10         ; User Port PIO (P0-P7) (bit2 (P2) = cassette play button)
        &ubyte  PIO2            = $fd30         ; Keyboard matrix scan

; ---- TIA 6523A registers ----
        &ubyte  TIA9PORTA       = $fec0         ; CBM 1551 drive #9 port A data
        &ubyte  TIA9PORTB       = $fec1         ; CBM 1551 drive #9 port B status
        &ubyte  TIA9PORTC       = $fec2         ; CBM 1551 drive #9 port C handshake
        &ubyte  TIA9PORTADDR    = $fec3         ; CBM 1551 drive #9 port A data direction
        &ubyte  TIA9PORTBDDR    = $fec4         ; CBM 1551 drive #9 port B data direction
        &ubyte  TIA9PORTCDDR    = $fec5         ; CBM 1551 drive #9 port C data direction
        &ubyte  TIA8PORTA       = $fee0         ; CBM 1551 drive #8 port A data
        &ubyte  TIA8PORTB       = $fee1         ; CBM 1551 drive #8 port B status
        &ubyte  TIA8PORTC       = $fee2         ; CBM 1551 drive #8 port C handshake
        &ubyte  TIA8PORTADDR    = $fee3         ; CBM 1551 drive #8 port A data direction
        &ubyte  TIA8PORTBDDR    = $fee4         ; CBM 1551 drive #8 port B data direction
        &ubyte  TIA8PORTCDDR    = $fee5         ; CBM 1551 drive #8 port C data direction

; ---- TED 7360 registers ----
        &ubyte  TIMER1LO        = $ff00         ; Timer/counter #1 low bits
        &ubyte  TIMER1HI        = $ff01         ; Timer/counter #1 high bits
        &ubyte  TIMER2LO        = $ff02         ; Timer/counter #2 low bits
        &ubyte  TIMER2HI        = $ff03         ; Timer/counter #2 high bits
        &ubyte  TIMER3LO        = $ff04         ; Timer/counter #3 low bits
        &ubyte  TIMER3HI        = $ff05         ; Timer/counter #3 high bits
        &ubyte  TEDCR1          = $ff06         ; Configuration Register 1
        &ubyte  TEDCR2          = $ff07         ; Configuration Register 2
        &ubyte  KEYBOARD        = $ff08         ; Keyboard Latch Register
        &ubyte  TEDIRR          = $ff09         ; Interrupt Flags / Interrupt Request Reqister (IRQST)
        &ubyte  TEDIER          = $ff0a         ; Interrupt Enable Reqister / Raster interrupt bit 8 (IRQEN)
        &ubyte  RSTCMP          = $ff0b         ; Raster Interrupt bits 7..0
        &ubyte  CURSORHI        = $ff0c         ; Cursor position high two bits
        &ubyte  CURSORLO        = $ff0d         ; Cursor position low eight bits
        &ubyte  SND1FREQLO      = $ff0e         ; Sound channel 1 frequency low 8 bits
        &ubyte  SND2FREQLO      = $ff0f         ; Sound channel 2 frequency low 8 bits
        &ubyte  SND2FREQHI      = $ff10         ; Sound channel 2 frequency high 2 bits
        &ubyte  SNDCR           = $ff11         ; Sound control register
        &ubyte  BMPSNDR         = $ff12         ; bitmap/rom/ram,sound channel 1 high 2bits
        &ubyte  CHRGENCLKBANK   = $ff13         ; char gen address, single clock mode, ROM/RAM config
        &ubyte  SCRNMEMADDR     = $ff14         ; screen memory address
        &ubyte  LUMACHROMABK0   = $ff15         ; Background luma+chroma 0
        &ubyte  LUMACHROMABK1   = $ff16         ; Background luma+chroma 1
        &ubyte  LUMACHROMABK2   = $ff17         ; Background luma+chroma 2
        &ubyte  LUMACHROMABK3   = $ff18         ; Background luma+chroma 3
        &ubyte  LUMACHROMABRD   = $ff19         ; Border luma+chroma
        &ubyte  STCHPOSHI       = $ff1a         ; Start position of character row high 2 bits
        &ubyte  STCHPOSLO       = $ff1b         ; Start position of character row low 8 bits
        &ubyte  RSTL8           = $ff1c         ; Current vertical position high 1 bit
        &ubyte  RSTL            = $ff1d         ; Current vertical position low 8 bits
        &ubyte  LINEPOS         = $ff1e         ; Current horizontal position high 7 bits
        &ubyte  FLASHCNTCHRAST  = $ff1f         ; Flash counter, actual rasterline in character row
        &ubyte  SWITCHROM       = $ff3e         ; Switch to ROM for $8000 - $FFFF (write any value)
        &ubyte  SWITCHRAM       = $ff3f         ; Switch to RAM for $8000 - $FFFF (write any value)

; ---- end of TED 7360 registers ----

asmsub banks(ubyte banks @A) {
    ; -- set the memory bank configuration
    ;    TODO: figure out banking configuration?
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
    ;    TODO: get ROM banking configuration?
    %asm {{
        lda  plus4.CHRGENCLKBANK
        and  #%00000001
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
}

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
+               nop
;+		lda  plus4.TEDIRR               ; read interrupt request register
		;sta  plus4.TEDIRR		; write the same value back to acknowledge interrupts
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
; TODO: figure out correct setup.
;		lda  #0
;		sta  plus4.IREQMASK	; disable raster irq
;		lda  #%10000001
;		sta  plus4.CIA1ICR	; restore CIA1 irq
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
        sta  plus4.VICIRQ			; acknowledge raster irq
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
		sta  plus4.CIA1ICR    ; "switch off" interrupts signals from cia-1
		sta  plus4.CIA2ICR    ; "switch off" interrupts signals from cia-2
		and  plus4.SCROLY
		sta  plus4.SCROLY     ; clear most significant bit of raster position
		lda  plus4.CIA1ICR    ; ack previous irq
		lda  plus4.CIA2ICR    ; ack previous irq
		pla
		sta  plus4.RASTER     ; set the raster line number where interrupt should occur
		cpy  #0
		beq  +
		lda  plus4.SCROLY
		ora  #%10000000
		sta  plus4.SCROLY     ; set most significant bit of raster position
+		lda  #%00000001
		sta  plus4.IREQMASK   ; enable raster interrupt signals from vic
		rts
	}}
}


    asmsub reset_system()  {
        ; Soft-reset the system back to initial power-on Basic prompt.
        %asm {{
            sei
            jmp  cbm.RESET      ; banks in ROM and calls RESET_VEC on Plus/4
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
-           lda  plus4.RSTL8    ; highest bit of raster line
            and  #%00000001
            beq  -
-           lda  plus4.RSTL8    ; highest bit of raster line
            and  #%00000001
            bit  plus4.SCROLY
            bne  -
            rts
        }}
    }

    inline asmsub waitrastborder() {
        ; --- busy wait till the raster position has reached the bottom screen border (approximately)
        ;     note: a more accurate way to do this is by using a raster irq handler instead.
        %asm {{
-           lda  plus4.RSTL8    ; highest bit of raster line
            and  #%00000001
            beq  -
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
    ; they are simulated on the plus4 as well but their location in memory is different
    ; (because there's no room for them in the zeropage in the default configuration)
    ; Note that when using ZP options that free up more of the zeropage (such as %zeropage kernalsafe)
    ; there might be enough space to put them there after all, and the compiler will change these addresses!
; the sixteen virtual 16-bit registers in both normal unsigned mode and signed mode (s)
    &uword r0  = $0333
    &uword r1  = $0335
    &uword r2  = $0337
    &uword r3  = $0339
    &uword r4  = $033b
    &uword r5  = $033d
    &uword r6  = $033f
    &uword r7  = $0341
    &uword r8  = $0343
    &uword r9  = $0345
    &uword r10 = $0347
    &uword r11 = $0349
    &uword r12 = $034b
    &uword r13 = $034d
    &uword r14 = $034f
    &uword r15 = $0351

    ; signed word versions
    &word r0s  = $0333
    &word r1s  = $0335
    &word r2s  = $0337
    &word r3s  = $0339
    &word r4s  = $033b
    &word r5s  = $033d
    &word r6s  = $033f
    &word r7s  = $0341
    &word r8s  = $0343
    &word r9s  = $0345
    &word r10s = $0347
    &word r11s = $0349
    &word r12s = $034b
    &word r13s = $034d
    &word r14s = $034f
    &word r15s = $0351

    ; ubyte versions (low and high bytes)
    &ubyte r0L  = $0333
    &ubyte r1L  = $0335
    &ubyte r2L  = $0337
    &ubyte r3L  = $0339
    &ubyte r4L  = $033b
    &ubyte r5L  = $033d
    &ubyte r6L  = $033f
    &ubyte r7L  = $0341
    &ubyte r8L  = $0343
    &ubyte r9L  = $0345
    &ubyte r10L = $0347
    &ubyte r11L = $0349
    &ubyte r12L = $034b
    &ubyte r13L = $034d
    &ubyte r14L = $034f
    &ubyte r15L = $0351

    &ubyte r0H  = $0334
    &ubyte r1H  = $0336
    &ubyte r2H  = $0338
    &ubyte r3H  = $033a
    &ubyte r4H  = $033c
    &ubyte r5H  = $033e
    &ubyte r6H  = $0340
    &ubyte r7H  = $0342
    &ubyte r8H  = $0344
    &ubyte r9H  = $0346
    &ubyte r10H = $0348
    &ubyte r11H = $034a
    &ubyte r12H = $034c
    &ubyte r13H = $034e
    &ubyte r14H = $0350
    &ubyte r15H = $0352

    ; signed byte versions (low and high bytes)
    &byte r0sL  = $0333
    &byte r1sL  = $0335
    &byte r2sL  = $0337
    &byte r3sL  = $0339
    &byte r4sL  = $033b
    &byte r5sL  = $033d
    &byte r6sL  = $033f
    &byte r7sL  = $0341
    &byte r8sL  = $0343
    &byte r9sL  = $0345
    &byte r10sL = $0347
    &byte r11sL = $0349
    &byte r12sL = $034b
    &byte r13sL = $034d
    &byte r14sL = $034f
    &byte r15sL = $0351

    &byte r0sH  = $0334
    &byte r1sH  = $0336
    &byte r2sH  = $0338
    &byte r3sH  = $033a
    &byte r4sH  = $033c
    &byte r5sH  = $033e
    &byte r6sH  = $0340
    &byte r7sH  = $0342
    &byte r8sH  = $0344
    &byte r9sH  = $0346
    &byte r10sH = $0348
    &byte r11sH = $034a
    &byte r12sH = $034c
    &byte r13sH = $034e
    &byte r14sH = $0350
    &byte r15sH = $0352

    ; boolean versions
    &bool r0bL  = $0333
    &bool r1bL  = $0335
    &bool r2bL  = $0337
    &bool r3bL  = $0339
    &bool r4bL  = $033b
    &bool r5bL  = $033d
    &bool r6bL  = $033f
    &bool r7bL  = $0341
    &bool r8bL  = $0343
    &bool r9bL  = $0345
    &bool r10bL = $0347
    &bool r11bL = $0349
    &bool r12bL = $034b
    &bool r13bL = $034d
    &bool r14bL = $034f
    &bool r15bL = $0351

    &bool r0bH  = $0334
    &bool r1bH  = $0336
    &bool r2bH  = $0338
    &bool r3bH  = $033a
    &bool r4bH  = $033c
    &bool r5bH  = $033e
    &bool r6bH  = $0340
    &bool r7bH  = $0342
    &bool r8bH  = $0344
    &bool r9bH  = $0346
    &bool r10bH = $0348
    &bool r11bH = $034a
    &bool r12bH = $034c
    &bool r13bH = $034e
    &bool r14bH = $0350
    &bool r15bH = $0352


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
; TODO cleanup: (this is from C64)
;        sei
;        lda  #%00101111
;        sta  $00
;        lda  #%00100110   ; kernal and i/o banked in, basic off
;        sta  $01
;        jsr  cbm.IOINIT
;        jsr  cbm.RESTOR
;        jsr  cbm.CINT
;        lda  #6
;        sta  plus4.EXTCOL
;        lda  #7
;        sta  cbm.COLOR
;        lda  #0
;        sta  plus4.BGCOL0
;        jsr  disable_runstop_and_charsetswitch
;        lda  #PROG8_plus4_BANK_CONFIG     ; apply bank config
;        sta  $01
;        and  #1
;        bne  +
;        ; basic is not banked in, adjust MEMTOP
;        ldx  #<$fd00
;        ldy  #>$fd00
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
        ; TODO cleanup.
        lda  #%00001111
        sta  $00                ; kernal default data directions
        lda  #%00001000
        sta  $01                ; datasette motor off
        sta  plus4.SWITCHROM    ; make sure ROM is active
        ldx  #<$fd00
        ldy  #>$fd00
        clc
        jsr  cbm.MEMTOP         ; adjust MEMTOP down again
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
