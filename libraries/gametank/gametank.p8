%import gametank_logo
%import shared_compression

gametank {
%option merge

        ; ---- System control registers ----
        ; Audio control register
        &ubyte  audio_reset                 = $2000     ; Write 1 to reset audio coprocessor
        &ubyte  audio_nmi                   = $2001     ; Write 1 to send NMI to audio coprocessor
        &ubyte  audio_rate                  = $2006     ; Audio enable and sample rate
        const uword audio_ram               = $3000     ; 4KB ram for audio coprocessor


        ; Banking register
        &ubyte  bank_reg                    = $2005     ; Banking Register
        const ubyte BANK_SECOND_FRAMEBUFFER = %00001000 ; Bit selects active buffer for read/write/blit
        const ubyte BANK_CLIP_X             = %00010000 ; Bit to enable clipping left/right edge blits
        const ubyte BANK_CLIP_Y             = %00100000 ; Bit to enable clipping top/bottom edge blits
        const ubyte BANK_RAM_MASK           = %11000000 ; General purpose RAM page selection bits

        ; Blitter DMA engine controls (registers further down)
        &ubyte  dma_flags                   = $2007     ; Configure blitter and video memory
        const ubyte DMA_COLORFILL_ENABLE    = %00001000 ; Use solid color blits not sprites

        ; DMA offsets (for uword pointer based)
        const ubyte VX = 0
        const ubyte VY = 1
        const ubyte GX = 2
        const ubyte GY = 3
        const ubyte WIDTH = 4
        const ubyte HEIGHT = 5
        const ubyte START = 6
        const ubyte COLOR = 7


        const ubyte YELLOW  = 0 << 5
        const ubyte ORANGE  = 1 << 5
        const ubyte RED     = 2 << 5
        const ubyte MAGENTA = 3 << 5
        const ubyte VIOLET  = 4 << 5
        const ubyte BLUE    = 5 << 5
        const ubyte CYAN    = 6 << 5
        const ubyte GREEN   = 7 << 5

        const ubyte COLOR_YELLOW = YELLOW | %00011000 | %00000111
        const ubyte COLOR_GREEN = GREEN | %00011000 | %00000101

        ubyte LUMA = %00000101
        ubyte SATU = %00011000

        ; match gametank_sdk names as much as possible
        ubyte bankflip
        ubyte banksMirror
        ubyte frameflip
        ubyte flagsMirror

        sub await_drawing() {
            sys.clear_irqd()
            while(draw_busy){
                wait()
            }
        }

        sub await_vsync(ubyte frames) {
            repeat frames {
                frameflag = true
                while(frameflag) {}
            }
        }

        sub flip_pages() {
            frameflip ^= DMA_PAGE_OUT;
            bankflip ^= BANK_SECOND_FRAMEBUFFER;
            gametank.dmaflags = DMA_NMI | DMA_ENABLE | DMA_IRQ | DMA_OPAQUE | frameflip | DMA_GCARRY
            DMAFLAGS = flagsMirror
            BANKREG = bankflip
        }

        ubyte audio_params_index
        uword wavetable_page
        ubyte sine_offset
        &uword WAVE_TABLE_LOCATION = $3002
        const uword AUDIO_PARAM_INPUT_BUFFER = $3070 

        sub init_audio_coprocessor() {
            audio_rate = $7f
            void compression.decode_rle(assets.audio, audio_ram, 4096)
            audio_params_index = 0
            AUDIO_PARAM_INPUT_BUFFER[0] = 0
            audio_reset = 0
            audio_rate = 255
            while(WAVE_TABLE_LOCATION == 0) {}
            wavetable_page = $3000 + WAVE_TABLE_LOCATION
            sine_offset = @($3003)
        }

        sub init_graphics() {
            frameflip = 0
            draw_busy = false
            flagsMirror = DMA_NMI | DMA_ENABLE | DMA_IRQ
            bankflip = BANK_SECOND_FRAMEBUFFER
            dma_flags = flagsMirror
            banksMirror = bankflip
            bank_reg = banksMirror
        }

        ubyte[] logo_colors = [0, 0, 25, 57, 90, 122, 155, 187, 220, 252]
        ubyte[] fadeout_colors = [ 7, 6, 5, 4, 3, 2, 1, 32]
        ubyte logo_state
        const ubyte BG_COLOR = 32

        sub sdk_init(){
            init_graphics()
            logo_state = 0
            do {
                direct_prepare_box_mode()
                if(logo_state < 3) {
                    DIRECT_DRAW_COLOR(127, 127, 1, 1, BG_COLOR)
                    DIRECT_DRAW_COLOR(0, 0, 127, 127, BG_COLOR)
                    if(logo_state == 2) {
                        init_audio_coprocessor()
                        ;init_music()
                    }
                    await_drawing()
                    DIRECT_DRAW_COLOR(127, 0, 1, 127, BG_COLOR)
                    await_drawing()
                    DIRECT_DRAW_COLOR(0, 127, 127, 1, BG_COLOR)
                    await_drawing()
                }

                if(logo_state < 120 + (sizeof(fadeout_colors)<<2)) {
                    if(logo_state > 120) {
                        draw_gametank_logo(~fadeout_colors[(logo_state - 120) >> 2])
                    } else if(logo_state < 40) {
                        draw_gametank_logo(~logo_colors[logo_state >> 2])
                    } else {
                        draw_gametank_logo(~7)
                    }
                }
                flip_pages()
                await_vsync(1)
                if(logo_state == 3) {
                    ;play_song(ASSET__sdk_default__jingle_mid, REPEAT_NONE)
                }
                if(logo_state > 2) {
                    ;tick_music()
                }
                if(logo_state == 180) logo_state = 255;

                logo_state++
            } until logo_state == 0
            ;stop_music()
            ; set back to sane defaults
            dmaflags = DMA_NMI
            framebuffer_mem(0)
        }

        sub direct_prepare_box_mode() {
            ;await_draw_queue()  ; Make sure we don't intersect with the queued system.
            await_drawing()
            flagsMirror |= DMA_ENABLE | DMA_OPAQUE | DMA_IRQ | DMA_COLORFILL_ENABLE | DMA_OPAQUE
            dma_flags = flagsMirror
            banksMirror &= ~(BANK_RAM_MASK | BANK_SECOND_FRAMEBUFFER)
            banksMirror |= bankflip | BANK_CLIP_X | BANK_CLIP_Y
            bank_reg = banksMirror
        }

        inline asmsub DIRECT_DRAW_COLOR(ubyte dst_x @X, ubyte dst_y@Y, ubyte w @R12, ubyte h @R13, ubyte color @A) {
            %asm {{
                stx  gametank.BLIT_VX
                sty  gametank.BLIT_VY
                sta  gametank.BLIT_COLOR
                lda  cx16.r12L
                sta  gametank.BLIT_GX
                lda  cx16.r13L
                sta  gametank.BLIT_GY
                lda  #1
                sta  gametank.BLIT_START
            }}
        }

        inline asmsub wait() {
            %asm {{
                wai
            }}
        }


    ubyte bankreg
    ubyte dmaflags

    sub blitinit() {
        ; enable blitter
        gametank.dmaflags |= (DMA_ENABLE|DMA_GCARRY|DMA_IRQ)
        gametank.DMAFLAGS = gametank.dmaflags

        ; single pixel blit to set sprite ram quadrant
        gametank.BLIT_VX = 0
        gametank.BLIT_VY = 0
        gametank.BLIT_GX = 0
        gametank.BLIT_GY = 0
        gametank.BLIT_WIDTH = 1
        gametank.BLIT_HEIGHT = 1
        gametank.BLIT_START = 1

        ; don't wait for < 5 pixels blits or interrupt is missed
        ; disabling DMA_NMI vsync irq will demonstrate it.
        ; emulator bug, not an issue on hardware
        ; this is working on the emulator only when DMA_NMI is enabled
        blitwait()
        ; sys.wait() will hang if NMI irqs are disabled
        ; 
        ;sys.wait(1)
        ; disable blitter
        gametank.dmaflags &= ~DMA_ENABLE
        gametank.DMAFLAGS = gametank.dmaflags
    }

    sub blitter() {
        ; enable blitter
        gametank.dmaflags |= (DMA_ENABLE|DMA_GCARRY|DMA_IRQ)
        gametank.DMAFLAGS = gametank.dmaflags

        ; configure largest possible blit
        gametank.BLIT_VX = 1
        gametank.BLIT_VY = 0
        gametank.BLIT_GX = 0
        gametank.BLIT_GY = 0
        gametank.BLIT_WIDTH = 126
        gametank.BLIT_HEIGHT = 127
        gametank.BLIT_START = 1

        ; need to setup blitter interrupt and WAI?
        ; wait for vsync, then blitter, then WAI?
        ;sys.wait(20)
        blitwait()
        ; disable blitter
        gametank.dmaflags &= ~DMA_ENABLE
        
    }

    sub blitter0() {
        ; enable blitter
        gametank.dmaflags |= (DMA_ENABLE|DMA_GCARRY|DMA_IRQ)
        gametank.DMAFLAGS = gametank.dmaflags

        ; blit one quarter of the screen, minus one pixel on left & right
        gametank.BLIT_VX = 1
        gametank.BLIT_VY = 0
        gametank.BLIT_GX = 0
        gametank.BLIT_GY = 0
        gametank.BLIT_WIDTH = 63
        gametank.BLIT_HEIGHT = 64
        gametank.BLIT_START = 1

        ; need to setup blitter interrupt and WAI?
        ; wait for vsync, then blitter, then WAI?
        ;sys.wait(20)
        blitwait()
        ; disable blitter
        gametank.dmaflags &= ~DMA_ENABLE
        
    }

    sub blitter1() {
        ; enable blitter
        gametank.dmaflags |= (DMA_ENABLE|DMA_GCARRY|DMA_IRQ)
        gametank.DMAFLAGS = gametank.dmaflags

        ; blit one quarter of the screen, minus one pixel on left & right
        gametank.BLIT_VX = 64
        gametank.BLIT_VY = 0
        gametank.BLIT_GX = 64
        gametank.BLIT_GY = 0
        gametank.BLIT_WIDTH = 63
        gametank.BLIT_HEIGHT = 64
        gametank.BLIT_START = 1

        ; need to setup blitter interrupt and WAI?
        ; wait for vsync, then blitter, then WAI?
        ;sys.wait(20)
        blitwait()
        ; disable blitter
        gametank.dmaflags &= ~DMA_ENABLE
        
    }

    sub blitter2() {
        ; enable blitter
        gametank.dmaflags |= (DMA_ENABLE|DMA_GCARRY|DMA_IRQ)
        gametank.DMAFLAGS = gametank.dmaflags

        ; blit one quarter of the screen, minus one pixel on left & right
        gametank.BLIT_VX = 1
        gametank.BLIT_VY = 64
        gametank.BLIT_GX = 0
        gametank.BLIT_GY = 64
        gametank.BLIT_WIDTH = 63
        gametank.BLIT_HEIGHT = 64
        gametank.BLIT_START = 1

        ; need to setup blitter interrupt and WAI?
        ; wait for vsync, then blitter, then WAI?
        ;sys.wait(20)
        blitwait()
        ; disable blitter
        gametank.dmaflags &= ~DMA_ENABLE
        
    }

    sub blitter3() {
        ; enable blitter
        gametank.dmaflags |= (DMA_ENABLE|DMA_GCARRY|DMA_IRQ)
        gametank.DMAFLAGS = gametank.dmaflags

        ; blit one quarter of the screen, minus one pixel on left & right
        gametank.BLIT_VX = 64
        gametank.BLIT_VY = 64
        gametank.BLIT_GX = 64
        gametank.BLIT_GY = 64
        gametank.BLIT_WIDTH = 63
        gametank.BLIT_HEIGHT = 64
        gametank.BLIT_START = 1

        ; need to setup blitter interrupt and WAI?
        ; wait for vsync, then blitter, then WAI?
        ;sys.wait(20)
        blitwait()
        ; disable blitter
        gametank.dmaflags &= ~DMA_ENABLE
        
    }

    inline asmsub blitwait() {
        %asm {{
            wai
        }}
    }

    ; select framebuffer memory 0 or 1
    sub framebuffer_mem(ubyte unit) {
        ; framebuffer is bit 3
        gametank.bankreg = (gametank.bankreg & %11110111) | ((unit << 3) & %00001000)
        gametank.BANKREG = gametank.bankreg
        ; enable access to framebuffer ram
        gametank.dmaflags |= DMA_CPU_TO_VRAM
        gametank.DMAFLAGS = gametank.dmaflags
    }

    ; select framebuffer 0 or 1 to output to TV
    sub framebuffer_out(ubyte unit) {
        ; set framebuffer page sent to TV
        gametank.dmaflags = (gametank.dmaflags & ~DMA_PAGE_OUT) | ((unit << 1) & DMA_PAGE_OUT)
        gametank.DMAFLAGS = gametank.dmaflags
    }

    ; select sprite memory bank 0-7
    sub sprite_mem(ubyte bank) {
        ; sprite bank is lowest 3 bits
        gametank.bankreg = (gametank.bankreg & %11111000) | (bank & %00000111)
        gametank.BANKREG = gametank.bankreg
        ; enable cpu access to sprite ram
        gametank.dmaflags &= ~DMA_CPU_TO_VRAM
        gametank.DMAFLAGS = gametank.dmaflags
    }
}

assets {
audio:
    %asmbinary "audio_fw.bin.rle", 0, 4096
;graphics:
;    %asmbinary "raw_image.bin.rle", 0, 20000
}

cart {
    sub bank(ubyte value) {
        ubyte pins
        ubyte temp

        ; set data direction pins
        gametank.VIA1DDRA |= %00000000

        ; clear all pins
        gametank.VIA1PA1  = %00000000

        pins = value
        sys.clear_carry()
        rol(pins)   ; high-bit in carry
        rol(pins)   ; high-bit in bit 0
        rol(pins)   ; high-bit in bit 1 (data)

        repeat 8 {
            ; stash current value
            temp = pins

            ; mask data pin
            pins &= %00000010
            ; write data bit and set clock low
            gametank.VIA1PA1  = pins
            ; write data bit and set clock high
            gametank.VIA1PA1  = pins | %00000001

            ; restore
            pins = temp
            rol(pins)
        }
            ; set latch
            gametank.VIA1PA1  = %00000100
            ; reset latch
            gametank.VIA1PA1  = %00000000
    }
}

