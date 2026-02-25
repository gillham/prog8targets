; Bitmap pixel graphics module for the GameTank retro console
;
; The GameTank has a native framebuffer that is 128x128 by 200 colors.
; There are two framebuffers that can be selected via register.
; There are different register bits for selecting which framebuffer renders
; to the TV and which one the CPU is accessing.
; 
; NOTE: For sake of speed, NO BOUNDS CHECKING is performed in most routines!
;       You'll have to make sure yourself that you're not writing outside of bitmap boundaries!

graphics {
    %option ignore_unused

    const uword WIDTH = 128
    const uword HEIGHT = 128

    ubyte stroke_color
    ubyte background_color

    ; The native framebuffer is from $4000-$7fff.
    const uword BITMAP_ADDRESS = $4000  ; 128x128x8 framebuffer effectively.

    sub enable_bitmap_mode() {
        ; GameTank is always in bitmap mode, so just clear framebuffer.
        clear_screen(63,0)
    }

    sub disable_bitmap_mode() {
        ; GameTank is always in bitmap mode. NOP.
    }

    sub clear_screen(ubyte pixelcolor, ubyte bgcolor) {
        stroke_color = pixelcolor
        background_color = bgcolor
        sys.memset(BITMAP_ADDRESS, 128*128, bgcolor)
    }

    sub line(uword @zp x1, ubyte @zp y1, uword @zp x2, ubyte @zp y2) {
        ; Bresenham algorithm.
        ; This code special-cases various quadrant loops to allow simple ++ and -- operations.
        ; TODO implement this as optimized assembly, for instance https://github.com/EgonOlsen71/bresenham/blob/main/src/asm/graphics.asm  ??
        ;      or from here https://retro64.altervista.org/blog/an-introduction-to-vector-based-graphics-the-commodore-64-rotating-simple-3d-objects/

        if y1>y2 {
            ; make sure dy is always positive to have only 4 instead of 8 special cases
            cx16.r0 = x1
            x1 = x2
            x2 = cx16.r0
            cx16.r0L = y1
            y1 = y2
            y2 = cx16.r0L
        }
        word @zp dx = (x2 as word)-x1
        word @zp dy = (y2 as word)-y1

        if dx==0 {
            vertical_line(x1, y1, abs(dy) as ubyte +1)
            return
        }
        if dy==0 {
            if x1>x2
                x1=x2
            horizontal_line(x1, y1, abs(dx) as uword +1)
            return
        }

        word @zp d = 0
        bool positive_ix = true
        if dx < 0 {
            dx = -dx
            positive_ix = false
        }
        word @zp dx2 = dx*2
        word @zp dy2 = dy*2
        internal_plotx = x1

        if dx >= dy {
            if positive_ix {
                repeat {
                    internal_plot(y1)
                    if internal_plotx==x2
                        return
                    internal_plotx++
                    d += dy2
                    if d > dx {
                        y1++
                        d -= dx2
                    }
                }
            } else {
                repeat {
                    internal_plot(y1)
                    if internal_plotx==x2
                        return
                    internal_plotx--
                    d += dy2
                    if d > dx {
                        y1++
                        d -= dx2
                    }
                }
            }
        }
        else {
            if positive_ix {
                repeat {
                    internal_plot(y1)
                    if y1 == y2
                        return
                    y1++
                    d += dx2
                    if d > dy {
                        internal_plotx++
                        d -= dy2
                    }
                }
            } else {
                repeat {
                    internal_plot(y1)
                    if y1 == y2
                        return
                    y1++
                    d += dx2
                    if d > dy {
                        internal_plotx--
                        d -= dy2
                    }
                }
            }
        }
    }

    sub rect(uword xx, ubyte yy, uword width, ubyte height) {
        if width==0 or height==0
            return
        horizontal_line(xx, yy, width)
        if height==1
            return
        horizontal_line(xx, yy+height-1, width)
        vertical_line(xx, yy+1, height-2)
        if width==1
            return
        vertical_line(xx+width-1, yy+1, height-2)
    }

    sub fillrect(uword xx, ubyte yy, uword width, ubyte height) {
        if width==0
            return
        repeat height {
            horizontal_line(xx, yy, width)
            yy++
        }
    }

    sub horizontal_line(uword xx, ubyte yy, uword length) {
        internal_plotx=xx
        repeat lsb(length) {
            internal_plot(yy)
            internal_plotx++
        }
        return
        if length<8 {
            internal_plotx=xx
            repeat lsb(length) {
                internal_plot(yy)
                internal_plotx++
            }
            return
        }

        ubyte separate_pixels = lsb(xx) & 7
        uword pixaddr = get_y_lookup(yy) + (xx&$fff8)

        if separate_pixels!=0 {
            %asm {{
                lda  p8v_pixaddr
                sta  P8ZP_SCRATCH_W1
                lda  p8v_pixaddr+1
                sta  P8ZP_SCRATCH_W1+1
                ldy  p8v_separate_pixels
                lda  hline_filled_right,y
                eor  #255
                ldy  #0
                ora  (P8ZP_SCRATCH_W1),y
                sta  (P8ZP_SCRATCH_W1),y
            }}
            pixaddr += 8
            length += separate_pixels
            length -= 8
        }

        if length!=0 {
            %asm {{
_pixeladdr = P8ZP_SCRATCH_W1
                lda  p8v_length
                and  #7
                sta  p8v_separate_pixels
                lsr  p8v_length+1
                ror  p8v_length
                lsr  p8v_length+1
                ror  p8v_length
                lsr  p8v_length+1
                ror  p8v_length
                lda  p8v_pixaddr
                sta  _pixeladdr
                lda  p8v_pixaddr+1
                sta  _pixeladdr+1
                lda  p8v_length
                ora  p8v_length+1
                beq  _zero
                ldy  p8v_length
                sty  P8ZP_SCRATCH_B1        ; length
                ldx  #$ff
_more           txa
                ldy  #0
                sta  (_pixeladdr),y
                lda  _pixeladdr
                clc
                adc  #8
                sta  _pixeladdr
                bcc  +
                inc  _pixeladdr+1
+               dec  P8ZP_SCRATCH_B1        ; length
                bne  _more
_zero
                ldy  p8v_separate_pixels
                beq  _end
                lda  hline_filled_right,y
                ldy  #0
                ora  (_pixeladdr),y
                sta  (_pixeladdr),y
_end            rts
hline_filled_right   .byte  0, %10000000, %11000000, %11100000, %11110000, %11111000, %11111100, %11111110
            }}
        }
    }

    sub vertical_line(uword xx, ubyte yy, ubyte height) {
        internal_plotx = xx
        repeat height {
            internal_plot(yy)
            yy++
        }
    }

    sub circle(uword xcenter, ubyte ycenter, ubyte radius) {
        ; Warning: NO BOUNDS CHECKS. Make sure circle fits in the screen.
        ; Midpoint algorithm.
        if radius==0
            return
        ubyte @zp ploty
        ubyte @zp yy = 0
        word @zp decisionOver2 = (1 as word)-radius

        while radius>=yy {
            internal_plotx = xcenter + radius
            ploty = ycenter + yy
            internal_plot(ploty)
            internal_plotx = xcenter - radius
            internal_plot(ploty)
            internal_plotx = xcenter + radius
            ploty = ycenter - yy
            internal_plot(ploty)
            internal_plotx = xcenter - radius
            internal_plot(ploty)
            internal_plotx = xcenter + yy
            ploty = ycenter + radius
            internal_plot(ploty)
            internal_plotx = xcenter - yy
            internal_plot(ploty)
            internal_plotx = xcenter + yy
            ploty = ycenter - radius
            internal_plot(ploty)
            internal_plotx = xcenter - yy
            internal_plot(ploty)
            yy++
            if decisionOver2>=0 {
                radius--
                decisionOver2 -= radius*$0002
            }
            decisionOver2 += yy*$0002
            decisionOver2++
        }
    }

    sub disc(uword xcenter, ubyte ycenter, ubyte radius) {
        ; Warning: NO BOUNDS CHECKS. Make sure circle fits in the screen.
        ; Midpoint algorithm, filled.
        ; Overdraws horizontal lines unfortunately.
        if radius==0
            return
        ubyte @zp yy = 0
        word decisionOver2 = (1 as word)-radius
        while radius>=yy {
            horizontal_line(xcenter-radius, ycenter+yy, radius*2+1)
            horizontal_line(xcenter-radius, ycenter-yy, radius*2+1)
            horizontal_line(xcenter-yy, ycenter+radius, yy*2+1)
            horizontal_line(xcenter-yy, ycenter-radius, yy*2+1)
            yy++
            if decisionOver2>=0 {
                radius--
                decisionOver2 -= radius*$0002
            }
            decisionOver2 += yy*$0002
            decisionOver2++
        }
    }


; here is the non-asm code for the plot routine below:
;    sub plot_nonasm(uword px, ubyte py) {
;        ubyte[] ormask = [128, 64, 32, 16, 8, 4, 2, 1]
;        uword pixaddr = BITMAP_ADDRESS + 320*(py>>3) + (py & 7) + (px & %0000000111111000)
;        @(pixaddr) |= ormask[lsb(px) & 7]
;    }

    sub plot_nonasm(uword px, ubyte py) {
        ubyte[] ormask = [128, 64, 32, 16, 8, 4, 2, 1]
        uword pixaddr = BITMAP_ADDRESS + 320*(py>>4) + (py & 15) + ((px<<1) & %0000000111110000)
        @(pixaddr) |= ormask[lsb(px) & 7]
    }

    inline asmsub  plot(uword plotx @AX, ubyte ploty @Y) clobbers (A, X, Y) {
        %asm {{
            sta  p8b_graphics.p8v_internal_plotx
            stx  p8b_graphics.p8v_internal_plotx+1
            jsr  p8b_graphics.p8s_internal_plot
        }}
    }

    ; for efficiency of internal algorithms here is the internal plot routine
    ; that takes the plotx coordinate in a separate variable instead of the XY register pair:

    uword @zp internal_plotx     ; 0..127        ; separate 'parameter' for internal_plot()
    uword @zp internal_plot_color                ; pixel color parameter for internal_plot()

    asmsub internal_plot(ubyte ploty @Y) clobbers (A, X, Y) {      ; internal_plotx is 8 bits 0 to 127.
        %asm {{
        ; plotx is only ever 0-127
        lda  #0
        sta  P8ZP_SCRATCH_W2+1
        lda  p8v_internal_plotx
        sta  P8ZP_SCRATCH_W2

        ; lookup Y aka start of row
        lda  _y_lookup_lo,y
        clc
        adc  P8ZP_SCRATCH_W2
        sta  P8ZP_SCRATCH_W2
        lda  _y_lookup_hi,y
        adc  P8ZP_SCRATCH_W2+1
        sta  P8ZP_SCRATCH_W2+1

        ldy  #0
        lda  p8b_graphics.p8v_stroke_color
        sta  (P8ZP_SCRATCH_W2),y
        rts

; We use the 64tass syntax for range expressions to calculate this table on assembly time.
_plot_y_values := p8c_BITMAP_ADDRESS + 128*range(128)

_y_lookup_lo    .byte  <_plot_y_values
_y_lookup_hi    .byte  >_plot_y_values
            ; !notreached!

        }}
    }

    asmsub get_y_lookup(ubyte yy @Y) -> uword @AY {
        %asm {{
            lda  p8s_internal_plot._y_lookup_lo,y
            pha
            lda  p8s_internal_plot._y_lookup_hi,y
            tay
            pla
            rts
        }}
    }

}


