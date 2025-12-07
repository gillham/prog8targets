; Prog8 definitions for the Text I/O and Screen routines for the Foenix F256
;

%import syslib
%import conv
%import shared_cbm_textio_functions2

txt {
%option no_symbol_prefixing, ignore_unused

    ;alias chrout = f256.chrout
    asmsub chrout(ubyte character @A) {
        %asm {{
            jmp  f256.chrout
        }}
    }

    ; text screen size
    const ubyte DEFAULT_WIDTH = f256.DEFAULT_WIDTH
    const ubyte DEFAULT_HEIGHT = f256.DEFAULT_HEIGHT


sub  clear_screen() {
    fill_screen(' ', f256.screen_color)
    f256.screen_col = 0
    f256.screen_row = 0
}

sub  cls() {
    clear_screen()
}

sub home() {
    f256.screen_row = 0
    f256.screen_col = 0
}

sub nl() {
    f256.chrout($0d)
    ;f256.chrout($0a)
}

sub spc() {
    f256.chrout(' ')
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
        sta f256.screen_col
        rts
    }}
}


asmsub get_column() -> ubyte @Y {
    %asm {{
        ldy f256.screen_col
        rts
    }}
}

asmsub row(ubyte rownum @A) clobbers(A, X, Y) {
    ; ---- set the cursor on the given row (starting with 0) on the current line
    %asm {{
        sta f256.screen_row
        rts
    }}
}

asmsub get_row() -> ubyte @X {
    %asm {{
        ldx f256.screen_row
        rts
    }}
}

asmsub get_cursor() -> ubyte @X, ubyte @Y {
    %asm {{
        ldx f256.screen_row
        ldy f256.screen_col
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
    f256.screen_color = txtcol
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

; stub for call moved to the f256 block.
alias scroll_up = f256.scroll_up
;asmsub  scroll_up  (bool alsocolors @ Pc) clobbers(A,X)  {
;    %asm {{
;        jmp f256.scroll_up
;    }}
;}

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
		pha                     ; stash character on stack
                lda  f256.io_ctrl       ; save previous mapping
                pha                     ; on the stack
                lda  #0
                sta  f256.io_ctrl       ; map in base I/O registers
                lda  $d001              ; read text size register
                and  #%00000010         ; mask anything but text size
                bne  +
                tya
                asl  a
                tay
+		tya
		asl  a
		tay
                pla                     ; pull prior mapping from stack
                sta  f256.io_ctrl       ; restore prior mapping
		lda  _screenrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		txa
		clc
		adc  _screenrows,y
		sta  P8ZP_SCRATCH_W1
		bcc  +
		inc  P8ZP_SCRATCH_W1+1
+		pla                     ; restore character
                tay                     ; stash in Y temporarily
                lda  f256.io_ctrl       ; save previous mapping
                pha                     ; on the stack
                lda  #2
                sta  f256.io_ctrl       ; map in screen memory
                tya                     ; move character back to A
        ldy  #0
		sta  (P8ZP_SCRATCH_W1),y
                pla
                sta  f256.io_ctrl       ; restore previous mapping
		rts

_screenrows	.word  f256.Screen + range(0, 4800, 40)
        ; !notreached!
	}}
}

asmsub  getchr  (ubyte col @A, ubyte row @Y) -> ubyte @A  {
    ; ---- get the character in the screen matrix at the given location
	%asm {{
        pha                     ; preserve col @A on stack
        lda  f256.io_ctrl       ; save previous mapping
        pha                     ; on the stack
        lda  #0
        sta  f256.io_ctrl       ; map in base I/O registers
        lda  $d001              ; read text size register
        and  #%00000010         ; mask anything but text size
        bne  +
        tya
        asl  a
        tay
+		tya
		asl  a
		tay
        pla                     ; pull prior mapping from stack
        sta  f256.io_ctrl       ; restore prior mapping
		lda  setchr._screenrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		pla                     ; pull col @A from stack
		clc
		adc  setchr._screenrows,y
		sta  P8ZP_SCRATCH_W1
		bcc  +
		inc  P8ZP_SCRATCH_W1+1
+       lda  f256.io_ctrl       ; save previous mapping
        pha                     ; on the stack
        lda  #2
        sta  f256.io_ctrl       ; map in screen memory
        ldy  #0
		lda  (P8ZP_SCRATCH_W1),y
        tay                     ; stash in Y briefly
        pla
        sta  f256.io_ctrl       ; restore previous mapping
        tya                     ; move character back to A
		rts
	}}
}

asmsub  setclr  (ubyte col @X, ubyte row @Y, ubyte color @A) clobbers(A, Y)  {
	; ---- sets the character in the screen matrix at the given position
	%asm {{
		pha                     ; stash character on stack
                lda  f256.io_ctrl       ; save previous mapping
                pha                     ; on the stack
                lda  #0
                sta  f256.io_ctrl       ; map in base I/O registers
                lda  $d001              ; read text size register
                and  #%00000010         ; mask anything but text size
                bne  +
                tya
                asl  a
                tay
+		tya
		asl  a
		tay
                pla                     ; pull prior mapping from stack
                sta  f256.io_ctrl       ; restore prior mapping
		lda  _colorrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		txa
		clc
		adc  _colorrows,y
		sta  P8ZP_SCRATCH_W1
		bcc  +
		inc  P8ZP_SCRATCH_W1+1
+		pla                     ; restore character
                tay                     ; stash in Y temporarily
                lda  f256.io_ctrl       ; save previous mapping
                pha                     ; on the stack
                lda  #3                 ; color memory page 3
                sta  f256.io_ctrl       ; map in color memory
                tya                     ; move character back to A
        ldy  #0
		sta  (P8ZP_SCRATCH_W1),y
                pla
                sta  f256.io_ctrl       ; restore previous mapping
		rts

_colorrows	.word  f256.Colors + range(0, 4800, 40)
        ; !notreached!
	}}
}

asmsub  getclr  (ubyte col @A, ubyte row @Y) -> ubyte @A  {
    ; ---- get the color in the screen color matrix at the given location
	%asm {{
        pha                     ; preserve col @A on stack
        lda  f256.io_ctrl       ; save previous mapping
        pha                     ; on the stack
        lda  #0
        sta  f256.io_ctrl       ; map in base I/O registers
        lda  $d001              ; read text size register
        and  #%00000010         ; mask anything but text size
        bne  +
        tya
        asl  a
        tay
+		tya
		asl  a
		tay
        pla                     ; pull prior mapping from stack
        sta  f256.io_ctrl       ; restore prior mapping
		lda  setclr._colorrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		pla                     ; pull col @A from stack
		clc
		adc  setclr._colorrows,y
		sta  P8ZP_SCRATCH_W1
		bcc  +
		inc  P8ZP_SCRATCH_W1+1
+       lda  f256.io_ctrl       ; save previous mapping
        pha                     ; on the stack
        lda  #3                 ; color memory page 3
        sta  f256.io_ctrl       ; map in color memory
        ldy  #0
		lda  (P8ZP_SCRATCH_W1),y
        tay                     ; stash in Y briefly
        pla
        sta  f256.io_ctrl       ; restore previous mapping
        tya                     ; move character back to A
		rts
	}}
}

sub  setcc  (ubyte col, ubyte row, ubyte character, ubyte charcolor)  {
    ; ---- set char+color at the given position on the screen
    %asm {{
_charptr = P8ZP_SCRATCH_W1
_colorptr = P8ZP_SCRATCH_W2
        ldy  row
        lda  f256.io_ctrl       ; save previous mapping
        pha                     ; on the stack
        lda  #0
        sta  f256.io_ctrl       ; map in base I/O registers
        lda  $d001              ; read text size register
        and  #%00000010         ; mask anything but text size
        bne  +
        tya
        asl  a
        tay
+		tya
		asl  a
		tay
        pla                     ; pull prior mapping from stack
        sta  f256.io_ctrl       ; restore prior mapping
		lda  setchr._screenrows+1,y
		sta  _charptr+1
		sta  _colorptr+1
		lda  setchr._screenrows,y
		clc
		adc  col
		sta  _charptr
		sta  _colorptr
		bcc  +
		inc  _charptr+1
		inc  _colorptr+1
+       lda  f256.io_ctrl       ; save previous mapping
        pha                     ; on the stack
        lda  #2
        sta  f256.io_ctrl       ; map in screen memory
        lda  character
        ldy  #0
		sta  (_charptr),y
        lda  #3
        sta  f256.io_ctrl       ; map in color memory
        lda  charcolor
		sta  (_colorptr),y
        pla
        sta  f256.io_ctrl       ; restore previous mapping
		rts
    }}
}

asmsub  plot  (ubyte col @ Y, ubyte row @ X) {
    %asm  {{
        sty  f256.screen_col
        stx  f256.screen_row
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

; TODO: jmp to cbm.CHRIN?
asmsub waitkey() -> ubyte @A {
    %asm {{
-       stz f256.event.type         ; invalidate existing event type
        jsr f256.event.NextEvent
        lda f256.event.type
        cmp #f256.event.key.PRESSED
        bne -
        ;lda f256.event.key.raw ; return scan code?
        lda f256.event.key.ascii    ; return upper or lower ASCII
        rts
    }}
}

    sub rvs_on() {
        f256.inverse_mode=1
    }

    sub rvs_off() {
        f256.inverse_mode=0
    }
}
