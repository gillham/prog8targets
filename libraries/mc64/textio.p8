; Prog8 definitions for the Text I/O and Screen routines for the Minicube64
; Reference: https://www.aeriform.io/minicube64

%import syslib
%import conv

txt {

    %option no_symbol_prefixing, ignore_unused

    ; 16x16 with 3x4 font (4x4 with gap) = 64 * 64 pixels.
    const ubyte DEFAULT_WIDTH = 16
    const ubyte DEFAULT_HEIGHT = 16
    ; 128 = print inverse character, 0 = normal
    ubyte inverse_mode = 0

    ; virtual screen coords/color
    ubyte vcol
    ubyte vrow
    ubyte vcolor = 63        ; text color white (TODO: const colors)
    ubyte bcolor = 0        ; text background color 
    ; temporary screen coords/color (for txt.set* mostly))
    ubyte tcol
    ubyte trow
    ubyte tcolor = 7        ; text color white ish (TODO: const colors)
    ubyte icolor = 0        ; background / inverse color (black normally)

sub  clear_screen() {
    sys.set_irqd()
    sys.memset(mc64.Screen, 16*16, 32)
    sys.memset(mc64.Color, 16*16, 32)
    sys.memset(mc64.Bitmap, 4096, 0)
    sys.clear_irqd()
    vcolor = 63
}

sub  cls() {
    clear_screen()
}

sub  home() {
    plot(0,0)
}

sub nl() {
    chrout('\n')
;    vrow++
;    vcol=0
}

sub spc() {
    chrout(' ')
}

sub rvs_on() {
    inverse_mode = 1
}

sub rvs_off() {
    inverse_mode = 0
}

sub bell() {
;    chrout($fd)
}

;sub column(ubyte col) {
;    ; ---- set the cursor on the given column (starting with 0) on the current line
;    vcol = col
;}

inline asmsub column(ubyte col @A) {
    ; ---- set the cursor on the given column (starting with 0) on the current line
    %asm {{
        sta  txt.vcol
    }}
}

sub get_column() -> ubyte {
    return vcol
}

;sub row(ubyte rownum) {
;    ; ---- set the cursor on the given row (starting with 0) on the current line
;    vrow = rownum
;}

inline asmsub row(ubyte rownum @A) {
    ; ---- set the cursor on the given row (starting with 0) on the current line
    %asm {{
        sta  txt.vrow
    }}
}

sub get_row() -> ubyte {
    return vrow
}

asmsub  fill_screen (ubyte character @ A, ubyte color @ Y) clobbers(A)  {
    ; ---- fill the character screen with the given fill character and character color.
    ;      (assumes screen and color matrix are at their default addresses)
    ;      TODO

    %asm {{
        rts
    }}
}

asmsub  clear_screenchars (ubyte character @ A) clobbers(Y)  {
	; ---- clear the character screen with the given fill character (leaves colors)
	;      (assumes screen matrix is at the default address)
	; TODO
	%asm {{
	    rts
	}}
}

asmsub  clear_screencolors (ubyte color @ A) clobbers(Y)  {
	; ---- clear the character screen colors with the given color (leaves characters).
	;      (assumes color matrix is at the default address)
	; TODO
	%asm {{
	    rts
        }}
}

sub color (ubyte txtcol) {
    vcolor = txtcol
}

sub lowercase() {
    ; remove?
}

sub uppercase() {
    ; remove?
}

asmsub  scroll_left  (bool alsocolors @ Pc) clobbers(A, Y)  {
	; ---- scroll the whole screen 1 character to the left
	;      contents of the rightmost column are unchanged, you should clear/refill this yourself
	;      Carry flag determines if screen color data must be scrolled too
	;  TODO

	%asm {{
	    rts
        }}
}

asmsub  scroll_right  (bool alsocolors @ Pc) clobbers(A)  {
	; ---- scroll the whole screen 1 character to the right
	;      contents of the leftmost column are unchanged, you should clear/refill this yourself
	;      Carry flag determines if screen color data must be scrolled too
	; TODO
	%asm {{
	    rts
        }}
}

asmsub  scroll_up  (bool alsocolors @ Pc) clobbers(A)  {
	; ---- scroll the whole screen 1 character up
	;      contents of the bottom row are unchanged, you should refill/clear this yourself
	;      Carry flag determines if screen color data must be scrolled too
	; TODO
	%asm {{
	    rts
        }}
}

asmsub  scroll_down  (bool alsocolors @ Pc) clobbers(A)  {
	; ---- scroll the whole screen 1 character down
	;      contents of the top row are unchanged, you should refill/clear this yourself
	;      Carry flag determines if screen color data must be scrolled too
	; TODO
	%asm {{
	    rts
        }}
}

asmsub chrout(ubyte char @A) {
        %asm {{
	    sta  chrout_fb.TEMP
            pha
            tya
            pha
            txa
            pha
            lda  chrout_fb.TEMP
            ; check for linefeed
            cmp  #$0d       ; linefeed
            beq  _crlf
            ; maybe pass these in registers?
            ldx txt.vcol
            stx txt.tcol
            ldx txt.vrow
            stx txt.trow
            ldx txt.vcolor
            stx txt.tcolor
            ldx txt.bcolor
            stx txt.icolor
            tay
            lda txt.inverse_mode
            beq +
            ldx txt.vcolor      ; load normal text color
            stx txt.icolor      ; save to inverse/background
            ldx txt.bcolor      ; load background
            stx txt.tcolor      ; save to normal text color
+           tya                 ; restore A
            jsr chrout_fb
            ; fix up vcol/vrow
            inc  vcol       ; increment vcol now that we have drawn
            lda  vcol       ; now check for overflow
            cmp  #txt.DEFAULT_WIDTH        ; wrapped past end of screen
            bcc  +          ; less than 24 we are done
_crlf:      inc  vrow       ; new vrow
            lda  #0
            sta  vcol
            lda  vrow       ; check if we are off bottom of screen
            cmp  #txt.DEFAULT_HEIGHT
            bcc  +          ; less than 20 we are done
            lda  #txt.DEFAULT_HEIGHT-1        ; should scroll but just stop at bottom
            sta  vrow

+           pla
            tax
            pla
            tay
            pla
            rts
        }}
    }


    asmsub chrout_fb(ubyte char @A) {
        %asm {{
COLR = $f0
SPTR = $f1
FPTR = $f3
TEMP = $f5
FTMP = $f6
CHAR = $f7
            sta  CHAR       ; save character
            ; save X&Y
            tya
            pha
            txa
            pha
+           lda  #>MYFONT2  ; setup pointer to 3x4 font
            sta  FPTR+1
            lda  #<MYFONT2   ; should be $00
            sta  FPTR

            ; calculate screen memory pointer to text cell
            lda  #>mc64.Bitmap  ; high byte of screen memory start
            clc                 ; row offset is 64 pixel * 4 pixel (row width * font height) = 256 (1page)
            adc  txt.trow       ; add row offset to start of screen memory (add 1 page to high byte)
            sta  SPTR+1         ; store high byte 
            lda  txt.tcol       ; load column and multiply by 4 (font width)
            asl
            asl
            sta  SPTR           ; low byte of screen pointer is column offset

            ; calculate character rom offset (4 bytes per character)
            ; should be 0-127 so first multiply can't overflow
            ; for reverse characters we might want to use 128-255
            ; or just invert?
            ; MYFONT2 must be page aligned
            lda  CHAR       ; restore requested character
            clc
            asl             ; multiply by 2
            bcc  +
            inc  FPTR+1     ; increment font pointer high byte
            clc
+           asl             ; multiply by 2 again
            bcc  +
            inc  FPTR+1     ; increment font pointer high byte
            clc
+           sta  FPTR       ; save font pointer low byte

            ; loop through 4 bytes of character rom
            ldy  #0         ; start at index zero
charloop:   sty  TEMP       ; save Y
            lda  (FPTR),y
            sta  FTMP       ; save font byte
            ; loop through 4 lower bits of font byte
            ; unrolled
            clc
            ldy  #0
            and  #%00001000 ; check bit 3
            beq  +          ; background pixel
            lda  txt.tcolor ; text color
            bcc  ++
+           lda  txt.icolor ; background color
+           sta  (SPTR),y   ; set pixel
            ldy  #1         ; second bit -> pixel byte
            lda  FTMP       ; load font byte again
            and  #%00000100 ; check bit 2
            beq  +          ; background pixel
            lda  txt.tcolor ; text color
            bcc  ++
+           lda  txt.icolor ; background color
+           sta  (SPTR),y   ; set pixel
            ldy  #2         ; third bit -> pixel byte
            lda  FTMP       ; load font byte again
            and  #%00000010 ; check bit 1
            beq  +          ; background pixel
            lda  txt.tcolor ; text color
            bcc  ++
+           lda  txt.icolor ; background color
+           sta  (SPTR),y   ; set pixel
            ldy  #3         ; fourth bit -> pixel byte
            lda  FTMP       ; load font byte again
            and  #%00000001 ; check bit 0
            beq  +          ; background pixel
            lda  txt.tcolor ; text color
            bcc  ++
+           lda  txt.icolor ; background color
+           sta  (SPTR),y   ; set pixel


            ; add 64 to SPTR
            lda  SPTR       ; load low byte of screen pointer
            clc
            adc  #64        ; add one row width
            bcc  +
            inc  SPTR+1     ; increment high byte of screen pointer
+           sta  SPTR       ; save adjusted pointer

            ; next character rom byte
            ldy  TEMP       ; restore Y
            iny             ; increment char rom byte index
            cpy  #4
            bne  charloop   ; loop until y = 4

            ; should be done
+           pla
            tax
            pla
            tay
            rts
        }}
    }
%align $100 ; must be before label
MYFONT:
MYFONT2:
%asmbinary "font3x4.bin", 2, 512

asmsub  print (str text @ AY) clobbers(A,Y)  {
	; ---- print zero terminated string from A/Y
	; note: the compiler contains an optimization that will replace
	;       a call to this subroutine with a string argument of just one char,
	;       by just one call to CHROUT of that single char.
	%asm {{
		sta  P8ZP_SCRATCH_W2
		sty  P8ZP_SCRATCH_W2+1
		ldy  #0
-		lda  (P8ZP_SCRATCH_W2),y
		beq  +
		jsr  chrout
		iny
		bne  -
+		rts
	}}
}

asmsub  print_ub0  (ubyte value @ A) clobbers(A,X,Y)  {
	; ---- print the ubyte in A in decimal form, with left padding 0s (3 positions total)
	%asm {{
		jsr  conv.internal_ubyte2decimal
		pha
		tya
		jsr  chrout
		txa
		jsr  chrout
		pla
		jmp  chrout
	}}
}

asmsub  print_ub  (ubyte value @ A) clobbers(A,X,Y)  {
	; ---- print the ubyte in A in decimal form, without left padding 0s
	%asm {{
		jsr  conv.internal_ubyte2decimal
_print_byte_digits
		pha
		cpy  #'0'
		beq  +
		tya
		jsr  chrout
		txa
		jsr  chrout
		jmp  _ones
+       cpx  #'0'
        beq  _ones
        txa
        jsr  chrout
_ones   pla
		jmp  chrout
	}}
}

asmsub  print_b  (byte value @ A) clobbers(A,X,Y)  {
	; ---- print the byte in A in decimal form, without left padding 0s
	%asm {{
		pha
		cmp  #0
		bpl  +
		lda  #'-'
		jsr  chrout
+		pla
		jsr  conv.internal_byte2decimal
		jmp  print_ub._print_byte_digits
	}}
}

asmsub  print_ubhex  (ubyte value @ A, bool prefix @ Pc) clobbers(A,X,Y)  {
	; ---- print the ubyte in A in hex form (if Carry is set, a radix prefix '$' is printed as well)
	%asm {{
		bcc  +
		pha
		lda  #'$'
		jsr  chrout
		pla
+		jsr  conv.internal_ubyte2hex
		jsr  chrout
		tya
		jmp  chrout
	}}
}

asmsub  print_ubbin  (ubyte value @ A, bool prefix @ Pc) clobbers(A,X,Y)  {
	; ---- print the ubyte in A in binary form (if Carry is set, a radix prefix '%' is printed as well)
	%asm {{
		sta  P8ZP_SCRATCH_B1
		bcc  +
		lda  #'%'
		jsr  chrout
+		ldy  #8
-		lda  #'0'
		asl  P8ZP_SCRATCH_B1
		bcc  +
		lda  #'1'
+		jsr  chrout
		dey
		bne  -
		rts
	}}
}

asmsub  print_uwbin  (uword value @ AY, bool prefix @ Pc) clobbers(A,X,Y)  {
	; ---- print the uword in A/Y in binary form (if Carry is set, a radix prefix '%' is printed as well)
	%asm {{
		pha
		tya
		jsr  print_ubbin
		pla
		clc
		jmp  print_ubbin
	}}
}

asmsub  print_uwhex  (uword value @ AY, bool prefix @ Pc) clobbers(A,X,Y)  {
	; ---- print the uword in A/Y in hexadecimal form (4 digits)
	;      (if Carry is set, a radix prefix '$' is printed as well)
	%asm {{
		pha
		tya
		jsr  print_ubhex
		pla
		clc
		jmp  print_ubhex
	}}
}

asmsub  print_uw0  (uword value @ AY) clobbers(A,X,Y)  {
	; ---- print the uword in A/Y in decimal form, with left padding 0s (5 positions total)
	%asm {{
		jsr  conv.internal_uword2decimal
		ldy  #0
-		lda  conv.internal_uword2decimal.decTenThousands,y
        beq  +
		jsr  chrout
		iny
		bne  -
+		rts
	}}
}

asmsub  print_uw  (uword value @ AY) clobbers(A,X,Y)  {
	; ---- print the uword in A/Y in decimal form, without left padding 0s
	%asm {{
		jsr  conv.internal_uword2decimal
		ldy  #0
-		lda  conv.internal_uword2decimal.decTenThousands,y
		beq  _allzero
		cmp  #'0'
		bne  _gotdigit
		iny
		bne  -

_gotdigit
		jsr  chrout
		iny
		lda  conv.internal_uword2decimal.decTenThousands,y
		bne  _gotdigit
		rts
_allzero
        lda  #'0'
        jmp  chrout
	}}
}

asmsub  print_w  (word value @ AY) clobbers(A,X,Y)  {
	; ---- print the (signed) word in A/Y in decimal form, without left padding 0's
	%asm {{
		cpy  #0
		bpl  +
		pha
		lda  #'-'
		jsr  chrout
		tya
		eor  #255
		tay
		pla
		eor  #255
		clc
		adc  #1
		bcc  +
		iny
+		jmp  print_uw
	}}
}

asmsub  input_chars  (^^ubyte buffer @ AY) clobbers(A) -> ubyte @ Y  {
	; ---- Input a string (max. 80 chars) from the keyboard. Returns length in Y. (string is terminated with a 0 byte as well)
	;      It assumes the keyboard is selected as I/O channel!
	;  TODO

	%asm {{
	    ldy  #0
	    rts
	}}
}

asmsub  setchr_fb  (ubyte col @X, ubyte row @Y, ubyte character @A) clobbers(A, Y)  {
	; ---- sets the character in the screen matrix at the given position
	%asm {{
                stx  txt.tcol
                sty  txt.trow
                ldx  txt.vcolor
                stx  txt.tcolor
                ldx  txt.bcolor
                stx  txt.icolor
                jmp  chrout_fb
	}}
}

asmsub  setchr  (ubyte col @X, ubyte row @Y, ubyte character @A) clobbers(A, Y)  {
	; ---- sets the character in the screen matrix at the given position
	%asm {{
		sty  chrout_fb.TEMP
		pha
		tya
		asl  a
		tay
		lda  _screenrows,y
		sta  P8ZP_SCRATCH_W1
		lda  _screenrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		txa
		tay
		pla
		sta  (P8ZP_SCRATCH_W1),y
                ldy  chrout_fb.TEMP
                jmp  setchr_fb

_screenrows	.word  mc64.Screen + range(0, DEFAULT_HEIGHT*DEFAULT_WIDTH, DEFAULT_WIDTH)
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
		lda  setchr._screenrows,y
		sta  P8ZP_SCRATCH_W1
		lda  setchr._screenrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		pla
		tay
		lda  (P8ZP_SCRATCH_W1),y
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
		lda  _colorrows,y
		sta  P8ZP_SCRATCH_W1
		lda  _colorrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		txa
		tay
		pla
		sta  (P8ZP_SCRATCH_W1),y
		rts

_colorrows	.word  mc64.Color + range(0, DEFAULT_HEIGHT*DEFAULT_WIDTH, DEFAULT_WIDTH)
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
		lda  setclr._colorrows,y
		sta  P8ZP_SCRATCH_W1
		lda  setclr._colorrows+1,y
		sta  P8ZP_SCRATCH_W1+1
		pla
		tay
        lda  (P8ZP_SCRATCH_W1),y
		rts
	}}
}

asmsub  setcc_fb  (ubyte col @X, ubyte row @Y, ubyte character @A, ubyte charcolor @R15) clobbers(A, Y)  {
	; ---- sets the character in the screen matrix at the given position
	%asm {{
                stx  txt.tcol
                sty  txt.trow
                ldx  cx16.r15L
                stx  txt.tcolor
                ldx  txt.bcolor
                stx  txt.icolor
                jmp  chrout_fb
	}}
}


sub  setcc  (ubyte col, ubyte row, ubyte character, ubyte charcolor)  {
	; ---- set char+color at the given position on the screen
	%asm {{
_charptr = P8ZP_SCRATCH_W1
_colorptr = P8ZP_SCRATCH_W2
		lda  row
		asl  a
		tay
		lda  setchr._screenrows,y
		sta  _charptr
		sta  _colorptr
		lda  setchr._screenrows+1,y
		sta  _charptr+1
		clc
		adc  #$01
		sta  _colorptr+1
		lda  character
		ldy  col
		sta  (_charptr),y
		lda  charcolor
		sta  (_colorptr),y
                sta  cx16.r15L
                ldx  col
                ldy  row
                lda  character
                jmp  setcc_fb
	}}
}

sub  plot(ubyte col, ubyte rownum) {
    column(col)
    row(rownum)
}

asmsub get_cursor() -> ubyte @X, ubyte @Y {
    %asm {{
        jsr  get_column
        pha
        jsr  get_row
        tay
        pla
        tax
        rts
    }}
}

asmsub waitkey() -> ubyte @A {
    %asm {{
        ;jmp  mc64.waitkey
        rts
    }}
}

asmsub width() clobbers(X,Y) -> ubyte @A {
    ; -- returns the text screen width (number of columns)
    %asm {{
        lda  #DEFAULT_WIDTH
        rts
    }}
}

asmsub height() clobbers(X, Y) -> ubyte @A {
    ; -- returns the text screen height (number of rows)
    %asm {{
        lda  #DEFAULT_HEIGHT
        rts
    }}
}

asmsub size() clobbers(A) -> ubyte @X, ubyte @Y {
    ; -- returns the text screen width in X and height in Y (number of columns and rows)
    %asm {{
        ldx  #DEFAULT_WIDTH
        ldy  #DEFAULT_HEIGHT
        rts
    }}
}

}
