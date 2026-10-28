;
; --- GameTank startup ---
;

; Allow a compiler defined symbol to override vector address.
; This allows building modules for cartridge banks.
.weak
is_library = 0
.endweak

; Place vectors at end of cartridge rom
.if is_library==0
*=$fffa
.endif
; needs to be outside if/endif above
; gets dropped if no org set because is_library==1
.dsection rom_vectors

;
; The upper 16KB ($c000-$ffff) of the cartridge rom
; is fixed.  It is the same as bank 255 in the lower
; 16KB banked ROM. ($8000-$bfff)
;

; "library" routines are for the lower banked ($8000-$bfff) rom
; and don't have rom_vectors or call init_system on entry
;
.if is_library==1
cartbank    = $fd17         ; banked "libraries" *should not* call cartbank
                            ; they should use a jsrfar type call
                            ; putting this here so libraries build
*=prog8_program_start       ; allow %address to override
prog8_program_entry         ; needed by rom_vectors section
    jmp  p8b_main.p8s_start
.endif

; Normal case of 16KB ROM in fixed ($c000-$ffff) upper
; bank.
.if is_library==0
; Official entry point, called by cpu reset vector.
; Must always be in the top fixed 16KB fixed bank
; if this program has rom_vectors. (aka not a "library")

; placed at $fd00 due to inflate testing at $fe00
; TODO: use section / dsection to place this here
; but keep the source in syslib?
*=$fd00
prog8_program_entry         ; needed by rom_vectors section
    sei
    stz  gametank.BANKREG   ; set all ram banks to 0 (low ram/stack!!)

    ; this clearing could be removed eventually
    ldx  #$00               ; zero stack for ease of debugging
-   stz  $0100,x
    inx
    bne  -                  ; full 256 byte page zeroed

    ; reset stack pointer
    ldx  #$ff               ; init stack register
    txs

    ; set cart bank here before we try to use $8000-$bfff
    lda  #$80
    jsr  cartbank

    ; jmp to start
    jmp  prog8_program_start

;
; Define this here as we need it immediately to switch the cartridge
; to bank 128 (aka 0 on ROM only cartridge)
;
; TODO: use section / dsection to place this here
; but keep the source in syslib?

cartbank	.block
; ubyte bank number passeed via A register
	sta  p8s_cartbank_value
	sta  p8s_cartbank_pins
	stz  p8s_cartbank_temp
	stz  gametank.VIA1PA1
        clc
	rol  p8s_cartbank_pins
	rol  p8s_cartbank_pins
	rol  p8s_cartbank_pins
	lda  #8
	sta  p8s_cartbank_loopc
p8_label_cartbank_loop
	lda  p8s_cartbank_pins
	sta  p8s_cartbank_temp
	lda  #253
	trb  p8s_cartbank_pins
	lda  p8s_cartbank_pins
	sta  gametank.VIA1PA1
	ora  #1
	sta  gametank.VIA1PA1
	lda  p8s_cartbank_temp
	sta  p8s_cartbank_pins
	rol  p8s_cartbank_pins
	dec  p8s_cartbank_loopc
	bne  p8_label_cartbank_loop
	lda  #4
	sta  gametank.VIA1PA1
	stz  gametank.VIA1PA1
	rts
; variables
	.section BSS_NOCLEAR
	.send BSS_NOCLEAR
        .section BSS
p8s_cartbank_loopc  .byte ?
p8s_cartbank_pins   .byte ?
p8s_cartbank_temp   .byte ?
p8s_cartbank_value  .byte ?
        .send BSS
	.bend

;
; Normal startup that could be in banked ram if %address
; puts it there.  So we need to ensure bank 0/128 is active
; before here.
;

; defaults to target load address
*=prog8_program_start       ; allow %address to override
    ; continue with normal Prog8 sys_startup
    jsr  p8_sys_startup.init_system
    jsr  p8_sys_startup.init_system_phase2
    jsr  p8b_main.p8s_start
    jmp  p8_sys_startup.cleanup_at_exit
.endif


;
; end of custom launcher / startup
;
