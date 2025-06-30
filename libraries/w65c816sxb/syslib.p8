; Prog8 definitions for the WDC W65C816SXB board.

%option no_symbol_prefixing, ignore_unused

;
; Here for general compatibility with textio.
;
cbm {
    extsub $F803 = CHROUT(ubyte character @ A)
}

sxb {
    &uword  NMI_VEC         = $FFFA     ; 6502 nmi vector, determined by the kernal if banked in
    &uword  RESET_VEC       = $FFFC     ; 6502 reset vector, determined by the kernal if banked in
    &uword  IRQ_VEC         = $FFFE     ; 6502 interrupt vector, determined by the kernal if banked in
}

sys {
    ; ------- lowlevel system routines --------

    const ubyte target = 6         ;  compilation target specifier.  255=virtual, 128=C128, 64=C64, 32=PET, 25=Feonix F256, 16=CommanderX16, 8=atari800XL, 7=Neo6502, 6=WDC SXB6, 5=rp6502

    const ubyte SIZEOF_BOOL  = sizeof(bool)
    const ubyte SIZEOF_BYTE  = sizeof(byte)
    const ubyte SIZEOF_UBYTE = sizeof(ubyte)
    const ubyte SIZEOF_WORD  = sizeof(word)
    const ubyte SIZEOF_UWORD = sizeof(uword)
    const ubyte SIZEOF_LONG  = sizeof(long)
    ;const ubyte SIZEOF_POINTER = sizeof(&sys.wait)
    const ubyte SIZEOF_FLOAT = 0    ; undefined, no floats supported
    const byte  MIN_BYTE     = -128
    const byte  MAX_BYTE     = 127
    const ubyte MIN_UBYTE    = 0
    const ubyte MAX_UBYTE    = 255
    const word  MIN_WORD     = -32768
    const word  MAX_WORD     = 32767
    const uword MIN_UWORD    = 0
    const uword MAX_UWORD    = 65535
    ; MIN_FLOAT and MAX_FLOAT are defined in the floats module if importec


    asmsub  reset_system()  {
        ; Soft-reset the system back to initial power-on status
        ; TODO
        %asm {{
            sei
            jmp  (sxb.RESET_VEC)
        }}
    }

    sub wait(uword jiffies) {
        ; --- wait approximately the given number of jiffies (1/60th seconds)
        ;     TODO
    }

    asmsub waitvsync() clobbers(A) {
        ; --- busy wait till the next vsync has occurred (approximately), without depending on custom irq handling.
        ;     TODO
        %asm {{
            nop
            rts
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

    sub disable_caseswitch() {
        ; no-op
    }

    sub enable_caseswitch() {
        ; no-op
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
    &uword r0  = $0018
    &uword r1  = $001a
    &uword r2  = $001c
    &uword r3  = $001e
    &uword r4  = $0020
    &uword r5  = $0022
    &uword r6  = $0024
    &uword r7  = $0026
    &uword r8  = $0028
    &uword r9  = $002a
    &uword r10 = $002c
    &uword r11 = $002e
    &uword r12 = $0030
    &uword r13 = $0032
    &uword r14 = $0034
    &uword r15 = $0036

    &word r0s  = $0018
    &word r1s  = $001a
    &word r2s  = $001c
    &word r3s  = $001e
    &word r4s  = $0020
    &word r5s  = $0022
    &word r6s  = $0024
    &word r7s  = $0026
    &word r8s  = $0028
    &word r9s  = $002a
    &word r10s = $002c
    &word r11s = $002e
    &word r12s = $0030
    &word r13s = $0032
    &word r14s = $0034
    &word r15s = $0036

    &ubyte r0L  = $0018
    &ubyte r1L  = $001a
    &ubyte r2L  = $001c
    &ubyte r3L  = $001e
    &ubyte r4L  = $0020
    &ubyte r5L  = $0022
    &ubyte r6L  = $0024
    &ubyte r7L  = $0026
    &ubyte r8L  = $0028
    &ubyte r9L  = $002a
    &ubyte r10L = $002c
    &ubyte r11L = $002e
    &ubyte r12L = $0030
    &ubyte r13L = $0032
    &ubyte r14L = $0034
    &ubyte r15L = $0036

    &ubyte r0H  = $0019
    &ubyte r1H  = $001b
    &ubyte r2H  = $001d
    &ubyte r3H  = $001f
    &ubyte r4H  = $0021
    &ubyte r5H  = $0023
    &ubyte r6H  = $0025
    &ubyte r7H  = $0027
    &ubyte r8H  = $0029
    &ubyte r9H  = $002b
    &ubyte r10H = $002d
    &ubyte r11H = $002f
    &ubyte r12H = $0031
    &ubyte r13H = $0033
    &ubyte r14H = $0035
    &ubyte r15H = $0037

    &byte r0sL  = $0018
    &byte r1sL  = $001a
    &byte r2sL  = $001c
    &byte r3sL  = $001e
    &byte r4sL  = $0020
    &byte r5sL  = $0022
    &byte r6sL  = $0024
    &byte r7sL  = $0026
    &byte r8sL  = $0028
    &byte r9sL  = $002a
    &byte r10sL = $002c
    &byte r11sL = $002e
    &byte r12sL = $0030
    &byte r13sL = $0032
    &byte r14sL = $0034
    &byte r15sL = $0036

    &byte r0sH  = $0019
    &byte r1sH  = $001b
    &byte r2sH  = $001d
    &byte r3sH  = $001f
    &byte r4sH  = $0021
    &byte r5sH  = $0023
    &byte r6sH  = $0025
    &byte r7sH  = $0027
    &byte r8sH  = $0029
    &byte r9sH  = $002b
    &byte r10sH = $002d
    &byte r11sH = $002f
    &byte r12sH = $0031
    &byte r13sH = $0033
    &byte r14sH = $0035
    &byte r15sH = $0037

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
        %asm {{
            sei
            cld
            clc
            ; TODO reset screen mode etc etc?
            clv
            ; TODO what about IRQ handler?  cli
            rts
        }}
    }

    asmsub  init_system_phase2()  {
        %asm {{
            rts     ; no phase 2 steps on the WDC W65C816SXB
        }}
    }

    asmsub  cleanup_at_exit() {
        ; executed when the main subroutine does rts
        %asm {{
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

}
