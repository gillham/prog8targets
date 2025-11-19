; Prog8 definitions for the Text I/O and Screen routines for the Commodore VIC-20
; All routines work with Screencode character encoding, except `print`, `chrout` and `input_chars`,
; these work with PETSCII encoding instead.

%import syslib
%import conv
%import shared_cbm_textio_functions2

txt {

    %option no_symbol_prefixing, ignore_unused

const ubyte DEFAULT_WIDTH = 22
const ubyte DEFAULT_HEIGHT = 23

extsub $FFD2 = chrout(ubyte character @ A)    ; for consistency. You can also use cbm.CHROUT directly ofcourse. Note: takes a PETSCII encoded character.

sub  clear_screen() {
    chrout(147)
}

sub  cls() {
    chrout(147)
}

sub home() {
    chrout(19)
}

sub nl() {
    chrout('\n')
}

sub spc() {
    chrout(' ')
}

sub bell() {
    ; beep
;    vic20.MVOL = 11
;    vic20.AD1 = %00110111
;    vic20.SR1 = %00000000
;    vic20.FREQ1 = 8500
;    vic20.CR1 = %00010000
;    vic20.CR1 = %00010001
}

asmsub column(ubyte col @A) clobbers(A, X, Y) {
    ; ---- set the cursor on the given column (starting with 0) on the current line
    %asm {{
        pha
        sec
        jsr  cbm.PLOT
        pla
        tay
        clc
        jmp  cbm.PLOT
    }}
}


asmsub get_column() -> ubyte @Y {
    %asm {{
        sec
        jmp cbm.PLOT
    }}
}

asmsub row(ubyte rownum @A) clobbers(A, X, Y) {
    ; ---- set the cursor on the given row (starting with 0) on the current line
    %asm {{
        pha
        sec
        jsr  cbm.PLOT
        pla
        tax
        clc
        jmp  cbm.PLOT
    }}
}

asmsub get_row() -> ubyte @X {
    %asm {{
        sec
        jmp cbm.PLOT
    }}
}

asmsub get_cursor() -> ubyte @X, ubyte @Y {
    %asm {{
        sec
        jsr  cbm.PLOT
        stx  P8ZP_SCRATCH_REG  ; swap X and Y
        tya
        tax
        ldy  P8ZP_SCRATCH_REG
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
		ldy  #253
-		sta  cbm.Screen+253*0-1,y
		sta  cbm.Screen+253*1-1,y
		dey
		bne  -
		rts
        }}
}

asmsub  clear_screencolors (ubyte color @ A) clobbers(Y)  {
	; ---- clear the character screen colors with the given color (leaves characters).
	;      (assumes color matrix is at the default address)
	%asm {{
                and  #%00000111         ; limit to 8 colors
		ldy  #253
-		sta  cbm.Colors+253*0-1,y
		sta  cbm.Colors+253*1-1,y
		dey
		bne  -
		rts
        }}
}

sub color (ubyte txtcol) {
    ; limit to 8 colors
    cbm.COLOR = txtcol & %00000111
}

sub lowercase() {
    cbm.CHROUT(14)
}

sub uppercase() {
    cbm.CHROUT(142)
}

asmsub  scroll_left  (bool alsocolors @ Pc) clobbers(A, X, Y)  {
	; ---- scroll the whole screen 1 character to the left
	;      contents of the rightmost column are unchanged, you should clear/refill this yourself
	;      Carry flag determines if screen color data must be scrolled too

	%asm {{
		bcc _scroll_screen

+               ; scroll the screen and the color memory
		ldx  #0
		ldy  #20
-
        .for row=0, row<=22, row+=1
            lda  cbm.Screen + 22*row + 1,x
            sta  cbm.Screen + 22*row + 0,x
            lda  cbm.Colors + 22*row + 1,x
            sta  cbm.Colors + 22*row + 0,x
        .next
		inx
		dey
		bpl  -
		rts

_scroll_screen  ; scroll only the screen memory
		ldx  #0
		ldy  #20
-
        .for row=0, row<=22, row+=1
            lda  cbm.Screen + 22*row + 1,x
            sta  cbm.Screen + 22*row + 0,x
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
		ldx  #20
-
        .for row=0, row<=22, row+=1
            lda  cbm.Screen + 22*row + 0,x
            sta  cbm.Screen + 22*row + 1,x
            lda  cbm.Colors + 22*row + 0,x
            sta  cbm.Colors + 22*row + 1,x
        .next
		dex
		bpl  -
		rts

_scroll_screen  ; scroll only the screen memory
		ldx  #20
-
        .for row=0, row<=22, row+=1
            lda  cbm.Screen + 22*row + 0,x
            sta  cbm.Screen + 22*row + 1,x
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
		ldx #21
-
        .for row=1, row<=22, row+=1
            lda  cbm.Screen + 22*row,x
            sta  cbm.Screen + 22*(row-1),x
            lda  cbm.Colors + 22*row,x
            sta  cbm.Colors + 22*(row-1),x
        .next
		dex
		bpl  -
		rts

_scroll_screen  ; scroll only the screen memory
		ldx #21
-
        .for row=1, row<=22, row+=1
            lda  cbm.Screen + 22*row,x
            sta  cbm.Screen + 22*(row-1),x
        .next
		dex
		bpl  -

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
		ldx #21
-
        .for row=21, row>=0, row-=1
            lda  cbm.Colors + 22*row,x
            sta  cbm.Colors + 22*(row+1),x
            lda  cbm.Screen + 22*row,x
            sta  cbm.Screen + 22*(row+1),x
        .next
		dex
		bpl  -
		rts

_scroll_screen  ; scroll only the screen memory
		ldx #21
-
        .for row=21, row>=0, row-=1
            lda  cbm.Screen + 22*row,x
            sta  cbm.Screen + 22*(row+1),x
        .next
		dex
		bpl  -

		rts
	}}
}

asmsub  setchr  (ubyte col @X, ubyte row @Y, ubyte character @A) clobbers(A, Y)  {
	; ---- sets the character in the screen matrix at the given position
	%asm {{
		pha
		tya
		asl  a
		tay
		lda  _screenrows+1,y
		sta  _mod+2
		txa
		clc
		adc  _screenrows,y
		sta  _mod+1
		bcc  +
		inc  _mod+2
+		pla
_mod		sta  $ffff		; modified
		rts

_screenrows	.word  cbm.Screen + range(0, 506, 22)
        ; !notreached!
	}}
}

asmsub  getchr  (ubyte col @A, ubyte row @Y) clobbers(Y) -> ubyte @ A {
	; ---- get the character in the screen matrix at the given location
	%asm  {{
		pha
		tya
		asl  a
		tay
		lda  setchr._screenrows+1,y
		sta  _mod+2
		pla
		clc
		adc  setchr._screenrows,y
		sta  _mod+1
		bcc  _mod
		inc  _mod+2
_mod		lda  $ffff		; modified
		rts
	}}
}

asmsub  setclr  (ubyte col @X, ubyte row @Y, ubyte color @A) clobbers(A, Y)  {
	; ---- set the color in A on the screen matrix at the given position
	%asm {{
		pha
		tya
		asl  a
		tay
		lda  _colorrows+1,y
		sta  _mod+2
		txa
		clc
		adc  _colorrows,y
		sta  _mod+1
		bcc  +
		inc  _mod+2
+		pla
                and  #%00000111         ; limit to 8 colors
_mod		sta  $ffff		; modified
		rts

_colorrows	.word  cbm.Colors + range(0, 506, 22)
        ; !notreached!
	}}
}

asmsub  getclr  (ubyte col @A, ubyte row @Y) clobbers(Y) -> ubyte @ A {
	; ---- get the color in the screen color matrix at the given location
	%asm  {{
		pha
		tya
		asl  a
		tay
		lda  setclr._colorrows+1,y
		sta  _mod+2
		pla
		clc
		adc  setclr._colorrows,y
		sta  _mod+1
		bcc  _mod
		inc  _mod+2
_mod		lda  $ffff		; modified
		rts
	}}
}

sub  setcc  (ubyte col, ubyte row, ubyte character, ubyte charcolor)  {
	; ---- set char+color at the given position on the screen
	%asm {{
		lda  row
		asl  a
		tay
		lda  setchr._screenrows+1,y
		sta  _charmod+2
		adc  #vic20.SCREEN_COLOR_OFFSET
		sta  _colormod+2
		lda  setchr._screenrows,y
		clc
		adc  col
		sta  _charmod+1
		sta  _colormod+1
		bcc  +
		inc  _charmod+2
		inc  _colormod+2
+		lda  character
_charmod	sta  $ffff		; modified
		lda  charcolor
                and  #%00000111         ; limit to 8 colors
_colormod	sta  $ffff		; modified
		rts
	}}
}

asmsub  plot  (ubyte col @ Y, ubyte row @ X) {
	%asm  {{
		clc
		jmp  cbm.PLOT
	}}
}

asmsub width() clobbers(X,Y) -> ubyte @A {
    ; -- returns the text screen width (number of columns)
    %asm {{
        jsr  cbm.SCREEN
        txa
        rts
    }}
}

asmsub height() clobbers(X, Y) -> ubyte @A {
    ; -- returns the text screen height (number of rows)
    %asm {{
        jsr  cbm.SCREEN
        tya
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

    asmsub  input_chars  (^^ubyte buffer @ AY) clobbers(A) -> ubyte @ Y  {
        ; ---- Input a string (max. 80 chars) from the keyboard, in PETSCII encoding.
        ;      Returns length in Y. (string is terminated with a 0 byte as well)
        ;      It assumes the keyboard is selected as I/O channel!

        ;
        ; VIC-20 hack to deal with long prompts wrapping and returning
        ; the whole line, not the typed in values.
        ;

        %asm {{
            sta  P8ZP_SCRATCH_W1
            sty  P8ZP_SCRATCH_W1+1
            lda  $d6                    ; load current physical line
            pha                         ; save to stack
            lda  $d3                    ; cursor position within logical line
            cmp  #txt.DEFAULT_WIDTH*2   ; wrapping two extra lines?
            bcc  +
            dec  $d6                    ; otherwise reduce physical line
+           cmp  #txt.DEFAULT_WIDTH     ; screen width
            bcc  +                      ; if logical less than physical width
            dec  $d6                    ; otherwise reduce physical line
+           ldy  #0				; char counter = 0
-           jsr  cbm.CHRIN
            cmp  #$0d			; return (ascii 13) pressed?
            beq  +				; yes, end.
            sta  (P8ZP_SCRATCH_W1),y	; else store char in buffer
            iny
            bne  -
+           lda  #0
            sta  (P8ZP_SCRATCH_W1),y	; finish string with 0 byte
            pla                         ; restore physical line from stack
            sta  $d6                    ; restore to zp
            rts
        }}
    }
}
