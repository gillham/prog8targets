; Prog8 definitions for the Text I/O and Screen routines for the Foenix F256
;

%import syslib
%import conv
%import shared_cbm_textio_functions

cbm {
%option no_symbol_prefixing, ignore_unused

    ubyte TIME_LO = $00

; the alias was working but I broke it somehow.
;alias CHROUT = txt.chrout
asmsub CHROUT(ubyte character @ A) {
    %asm {{
        jmp txt.chrout
    }}
}
asmsub GETIN() -> bool @Pc, ubyte @A {
    %asm {{
        rts
    }}
}
}

txt {
%option no_symbol_prefixing, ignore_unused

const ubyte DEFAULT_WIDTH = 80
const ubyte DEFAULT_HEIGHT = 60

; self tracked screen coordinates
; potentially could be at $04/$05 in reserved ZP area?
ubyte screen_row = 0
ubyte screen_col = 0
ubyte screen_color = $f2    ; default text/background color
&uword screen_ptr = $02 ; and $03.  used to calculate screen/color ram offsets

;
; calculates screen memory pointer for the start of a row
; in screen_ptr in zeropage.
; ldy column
; sta (screen_ptr), y
;
asmsub rowptr(ubyte row @Y) {
    %asm {{
        stz txt.screen_ptr      ; reset to start of screen ram
        lda #>f256.Screen
        sta txt.screen_ptr+1
        cpy #0      ; row in @Y will be our loop counter
        beq ptr_done
rowloop:
        clc
        lda txt.screen_ptr      ; load count
        adc #DEFAULT_WIDTH
        bcc +
        inc txt.screen_ptr+1
+       sta txt.screen_ptr
        dey
        bne rowloop
ptr_done:
        rts
    }}
}

;
; calculates screen memory pointer for the specific col/row
; in screen_ptr in zeropage. Points directly to character after.
; ldy #0
; sta (screen_ptr), y
;
asmsub chrptr(ubyte col @X, ubyte row @Y) clobbers(A) {
    %asm {{
        phx             ; preserve col
        jsr  rowptr     ; calculate pointer to row
        pla             ; restore col
        clc
        adc  screen_ptr
        sta  screen_ptr 
        bcc  +
        inc  screen_ptr+1
+       rts
    }}
}

asmsub chrout(ubyte character @ A) {
    %asm {{
        phx                     ; preserve x
        phy                     ; preserve y
        cmp #$0d                ; check for carriage return
        beq crlf
        cmp #$0a                ; check for line feed
        beq crlf
        pha                     ; preserve a
        ldy txt.screen_row
        jsr rowptr              ; calculates screen pointer to start of row
        ldy txt.screen_col      ; column will be our index against the row pointer
        lda #2
        sta f256.io_ctrl        ; map in screen memory
        pla
        sta (txt.screen_ptr),y
        lda #3
        sta f256.io_ctrl        ; map in color memory
        lda screen_color
        sta (txt.screen_ptr),y
        lda #0
        sta f256.io_ctrl        ; return to default map
        inc txt.screen_col
        lda txt.screen_col
        cmp #DEFAULT_WIDTH
        bcc +                   ; less than DEFAULT_WIDTH
crlf:
        stz txt.screen_col
        inc txt.screen_row
        lda txt.screen_row
        cmp #DEFAULT_HEIGHT
        bcc +
        sec
        jsr scroll_up
        dec txt.screen_row
+       ply
        plx
        rts
    }}
}

sub  clear_screen() {
    fill_screen(' ', screen_color)
}

sub  cls() {
    clear_screen()
}

sub home() {
    screen_row = 0
    screen_col = 0
}

sub nl() {
    chrout($0d)
    ;chrout($0a)
}

sub spc() {
    chrout(' ')
}

sub bell() {
    ; beep
;    c64.MVOL = 11
;    c64.AD1 = %00110111
;    c64.SR1 = %00000000
;    c64.FREQ1 = 8500
;    c64.CR1 = %00010000
;    c64.CR1 = %00010001
}

asmsub column(ubyte col @A) clobbers(A, X, Y) {
    ; ---- set the cursor on the given column (starting with 0) on the current line
    %asm {{
        sta screen_col
        rts
    }}
}


asmsub get_column() -> ubyte @Y {
    %asm {{
        ldy screen_col
        rts
    }}
}

asmsub row(ubyte rownum @A) clobbers(A, X, Y) {
    ; ---- set the cursor on the given row (starting with 0) on the current line
    %asm {{
        sta screen_row
        rts
    }}
}

asmsub get_row() -> ubyte @X {
    %asm {{
        ldx screen_row
        rts
    }}
}

asmsub get_cursor() -> ubyte @X, ubyte @Y {
    %asm {{
        ldx screen_row
        ldy screen_col
        rts
    }}
}

asmsub  fill_screen (ubyte character @ A, ubyte color @ Y) clobbers(A)  {
    ; ---- fill the character screen with the given fill character and character color.
    ;      (assumes screen and color matrix are at their default addresses)

    %asm {{
        pha
        tya
        jsr  clear_screencolors
        pla
        jsr  clear_screenchars
        rts
        }}
}

asmsub  clear_screenchars (ubyte character @ A) clobbers(Y)  {
    ; ---- clear the character screen with the given fill character (leaves colors)
    ;      (assumes screen matrix is at the default address)
    %asm {{
        ldy  f256.io_ctrl           ; load current mapping
        phy                         ; save to stack
        ldy  #2
        sty  f256.io_ctrl           ; map in screen memory
        ldy  #240
-       sta  f256.Screen+240*0-1,y
        sta  f256.Screen+240*1-1,y
        sta  f256.Screen+240*2-1,y
        sta  f256.Screen+240*3-1,y
        sta  f256.Screen+240*4-1,y
        sta  f256.Screen+240*5-1,y
        sta  f256.Screen+240*6-1,y
        sta  f256.Screen+240*7-1,y
        sta  f256.Screen+240*8-1,y
        sta  f256.Screen+240*9-1,y
        sta  f256.Screen+240*10-1,y
        sta  f256.Screen+240*11-1,y
        sta  f256.Screen+240*12-1,y
        sta  f256.Screen+240*13-1,y
        sta  f256.Screen+240*14-1,y
        sta  f256.Screen+240*15-1,y
        sta  f256.Screen+240*16-1,y
        sta  f256.Screen+240*17-1,y
        sta  f256.Screen+240*18-1,y
        sta  f256.Screen+240*19-1,y
        dey
        bne  -
        ply                         ; previous mapping from stack
        sty  f256.io_ctrl           ; restore previous map
        rts
        }}
}

asmsub  clear_screencolors (ubyte color @ A) clobbers(Y)  {
    ; ---- clear the character screen colors with the given color (leaves characters).
    ;      (assumes color matrix is at the default address)
    %asm {{
        ldy  f256.io_ctrl           ; load current mapping
        phy                         ; save to stack
        ldy  #3
        sty  f256.io_ctrl           ; map in color memory
        ldy  #240
-       sta  f256.Colors+240*0-1,y
        sta  f256.Colors+240*1-1,y
        sta  f256.Colors+240*2-1,y
        sta  f256.Colors+240*3-1,y
        sta  f256.Colors+240*4-1,y
        sta  f256.Colors+240*5-1,y
        sta  f256.Colors+240*6-1,y
        sta  f256.Colors+240*7-1,y
        sta  f256.Colors+240*8-1,y
        sta  f256.Colors+240*9-1,y
        sta  f256.Colors+240*10-1,y
        sta  f256.Colors+240*11-1,y
        sta  f256.Colors+240*12-1,y
        sta  f256.Colors+240*13-1,y
        sta  f256.Colors+240*14-1,y
        sta  f256.Colors+240*15-1,y
        sta  f256.Colors+240*16-1,y
        sta  f256.Colors+240*17-1,y
        sta  f256.Colors+240*18-1,y
        sta  f256.Colors+240*19-1,y
        dey
        bne  -
        ply                         ; previous mapping from stack
        sty  f256.io_ctrl           ; restore previous map
        rts
        }}
}

sub color (ubyte txtcol) {
    screen_color = txtcol
}

sub lowercase() {
;    c64.VMCSB |= 2
}

sub uppercase() {
;    c64.VMCSB &= ~2
}

asmsub  scroll_left  (bool alsocolors @ Pc) clobbers(A, X, Y)  {
    ; ---- scroll the whole screen 1 character to the left
    ;      contents of the rightmost column are unchanged, you should clear/refill this yourself
    ;      Carry flag determines if screen color data must be scrolled too

    %asm {{
        bcc _scroll_screen

+               ; scroll the screen and the color memory
        ldx  #0
        ldy  #38
-
        .for row=0, row<=24, row+=1
            lda  f256.Screen + 40*row + 1,x
            sta  f256.Screen + 40*row + 0,x
            lda  f256.Colors + 40*row + 1,x
            sta  f256.Colors + 40*row + 0,x
        .next
        inx
        dey
        bpl  -
        rts

_scroll_screen  ; scroll only the screen memory
        ldx  #0
        ldy  #38
-
        .for row=0, row<=24, row+=1
            lda  f256.Screen + 40*row + 1,x
            sta  f256.Screen + 40*row + 0,x
        .next
        inx
        dey
        bpl  -

        rts
    }}
}

asmsub  scroll_right  (bool alsocolors @ Pc) clobbers(A,X)  {
    ; ---- scroll the whole screen 1 character to the right
    ;      contents of the leftmost column are unchanged, you should clear/refill this yourself
    ;      Carry flag determines if screen color data must be scrolled too
    %asm {{
        bcc  _scroll_screen

+               ; scroll the screen and the color memory
        ldx  #38
-
        .for row=0, row<=24, row+=1
            lda  f256.Screen + 40*row + 0,x
            sta  f256.Screen + 40*row + 1,x
            lda  f256.Colors + 40*row + 0,x
            sta  f256.Colors + 40*row + 1,x
        .next
        dex
        bpl  -
        rts

_scroll_screen  ; scroll only the screen memory
        ldx  #38
-
        .for row=0, row<=24, row+=1
            lda  f256.Screen + 40*row + 0,x
            sta  f256.Screen + 40*row + 1,x
        .next
        dex
        bpl  -

        rts
    }}
}

asmsub  scroll_up  (bool alsocolors @ Pc) clobbers(A,X)  {
    ; ---- scroll the whole screen 1 character up
    ;      contents of the bottom row are unchanged, you should refill/clear this yourself
    ;      Carry flag determines if screen color data must be scrolled too
    %asm {{
        bcc  _scroll_screen

+               ; scroll the screen and the color memory
        ldx #DEFAULT_WIDTH-1
-
        lda #2
        sta f256.io_ctrl        ; map in screen memory
        .for row=1, row<=DEFAULT_HEIGHT, row+=1
            lda  f256.Screen + DEFAULT_WIDTH*row,x
            sta  f256.Screen + DEFAULT_WIDTH*(row-1),x
        .next
        lda #3
        sta f256.io_ctrl        ; map in color memory
        .for row=1, row<=DEFAULT_HEIGHT, row+=1
            lda  f256.Colors + DEFAULT_WIDTH*row,x
            sta  f256.Colors + DEFAULT_WIDTH*(row-1),x
        .next


        dex
        bpl  -
        lda #0
        sta f256.io_ctrl        ; restore I/O configuration
        rts

_scroll_screen  ; scroll only the screen memory
        ldx #DEFAULT_WIDTH-1
-
        lda #2
        sta f256.io_ctrl        ; map in screen memory
        .for row=1, row<=DEFAULT_HEIGHT, row+=1
            lda  f256.Screen + DEFAULT_WIDTH*row,x
            sta  f256.Screen + DEFAULT_WIDTH*(row-1),x
        .next
        dex
        bpl  -
        lda #0
        sta f256.io_ctrl        ; restore I/O configuration
        rts
    }}
}

asmsub  scroll_down  (bool alsocolors @ Pc) clobbers(A,X)  {
    ; ---- scroll the whole screen 1 character down
    ;      contents of the top row are unchanged, you should refill/clear this yourself
    ;      Carry flag determines if screen color data must be scrolled too
    %asm {{
        bcc  _scroll_screen

+               ; scroll the screen and the color memory
        ldx #39
-
        .for row=23, row>=0, row-=1
            lda  f256.Colors + 40*row,x
            sta  f256.Colors + 40*(row+1),x
            lda  f256.Screen + 40*row,x
            sta  f256.Screen + 40*(row+1),x
        .next
        dex
        bpl  -
        rts

_scroll_screen  ; scroll only the screen memory
        ldx #39
-
        .for row=23, row>=0, row-=1
            lda  f256.Screen + 40*row,x
            sta  f256.Screen + 40*(row+1),x
        .next
        dex
        bpl  -

        rts
    }}
}

asmsub  setchr  (ubyte col @X, ubyte row @Y, ubyte character @A) clobbers(A, Y)  {
    ; ---- sets the character in the screen matrix at the given position
    %asm {{
        pha                     ; preserve character
        jsr  chrptr             ; calculate offset
        pla                     ; restore character
        ldy  f256.io_ctrl       ; load current mapping
        phy                     ; save on stack
        ldy  #2
        sty  f256.io_ctrl       ; map in screen memory
        ldy  #0
        sta  (screen_ptr), y    ; write character
        ply
        sty  f256.io_ctrl       ; restore previous mapping
        rts
    }}
}

asmsub  getchr  (ubyte col @A, ubyte row @Y) clobbers(Y) -> ubyte @ A {
    ; ---- get the character in the screen matrix at the given location
    %asm  {{
        phx                 ; preserve
        tax                 ; move column to X for call
        jsr  chrptr         ; calculate offset to character
        ldy  f256.io_ctrl   ; load current mapping
        phy                 ; save on stack
        ldy  #2
        sty  f256.io_ctrl   ; map in screen memory
        ldy  #0
        lda  (screen_ptr),y ; get character
        ply
        sty  f256.io_ctrl   ; restore previous mapping
        plx                 ; restore
        rts
    }}
}

asmsub  setclr  (ubyte col @X, ubyte row @Y, ubyte color @A) clobbers(A, Y)  {
    ; ---- set the color in A on the screen matrix at the given position
    %asm {{
        pha                     ; preserve character
        jsr  chrptr             ; calculate offset
        pla                     ; restore character
        ldy  f256.io_ctrl       ; load current mapping
        phy                     ; save on stack
        ldy  #3
        sty  f256.io_ctrl       ; map in color memory
        ldy  #0
        sta  (screen_ptr), y    ; write color
        ply
        sty  f256.io_ctrl       ; restore previous mapping
        rts
    }}
}

asmsub  getclr  (ubyte col @A, ubyte row @Y) clobbers(Y) -> ubyte @ A {
    ; ---- get the color in the screen color matrix at the given location
    %asm  {{
        phx                 ; preserve
        tax                 ; move column to X for call
        jsr  chrptr         ; calculate offset to character
        ldy  f256.io_ctrl   ; load current mapping
        phy                 ; save on stack
        ldy  #3
        sty  f256.io_ctrl   ; map in color memory
        ldy  #0
        lda  (screen_ptr),y ; get color
        ply
        sty  f256.io_ctrl   ; restore previous mapping
        plx                 ; restore
        rts
    }}
}

sub  setcc  (ubyte col, ubyte row, ubyte character, ubyte charcolor)  {
    ; ---- set char+color at the given position on the screen
    %asm {{
        ldx  col                ; setup parameters
        ldy  row
        jsr  chrptr             ; calculate offset
        ldy  f256.io_ctrl       ; load current mapping
        phy                     ; save on stack
        ldy  #2
        sty  f256.io_ctrl       ; map in screen memory
        ldy  #0
        lda  character
        sta  (screen_ptr), y
        ldy  #3
        sty  f256.io_ctrl       ; map in color memory
        ldy  #0
        lda  charcolor
        sta  (screen_ptr), y
        ply                     ; previous mapping from stack
        sty  f256.io_ctrl       ; restore previous map
        rts
    }}
}

asmsub  plot  (ubyte col @ Y, ubyte row @ X) {
    %asm  {{
        sty  screen_col
        stx  screen_row
        rts
    }}
}

asmsub width() clobbers(X,Y) -> ubyte @A {
    ; -- returns the text screen width (number of columns)
    %asm {{
        lda  DEFAULT_WIDTH
        rts
    }}
}

asmsub height() clobbers(X, Y) -> ubyte @A {
    ; -- returns the text screen height (number of rows)
    %asm {{
        lda  DEFAULT_HEIGHT
        rts
    }}
}

asmsub waitkey() -> ubyte @A {
    %asm {{
-       jsr cbm.GETIN
        beq -
        rts
    }}
}
}
