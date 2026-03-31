;
; --- GameTank startup ---
;

; Place vectors at end of cartridge rom
*=$fffa
.dsection rom_vectors

;
; The upper 16KB ($c000-$ffff) of the cartridge rom
; is fixed.  It is the same as bank 255 in the lower
; 16KB banked ROM. ($8000-$bfff)
;
*=prog8_program_start       ; allow %address to override
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

    ; continue with normal Prog8 sys_startup
    jsr  p8_sys_startup.init_system
    jsr  p8_sys_startup.init_system_phase2
    jsr  p8b_main.p8s_start
    jmp  p8_sys_startup.cleanup_at_exit

;
; end of custom launcher / startup
;
