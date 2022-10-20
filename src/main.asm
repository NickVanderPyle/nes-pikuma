.include "consts.inc"
.include "header.inc"
.include "reset.inc"

.segment "CODE"

.proc LoadPalette
    ldy #0
LoopPalette:
    lda PaletteData,y    ; load from PaletteData+y
    sta PPU_DATA        ; set value to PPU_DATA
    iny
    cpy #32
    bne LoopPalette

    rts
.endproc

.proc LoadBackground
    ldy #0
LoopBackground:
    lda BackgroundData,y    ; load from PaletteData+y
    sta PPU_DATA        ; set value to PPU_DATA
    iny
    cpy #255
    bne LoopBackground

    rts
.endproc

RESET:
    INIT_NES

Main:
    bit PPU_STATUS      ; reset PPU_ADDR latch
    ldx #$3F
    stx PPU_ADDR        ; set PPU_ADDR hi-byte
    ldx #$00
    stx PPU_ADDR        ; set PPU_ADDR lo-byte

    jsr LoadPalette

    ;; set ppu addr to $2000 & load tiles of bg
    bit PPU_STATUS      ; reset PPU_ADDR latch
    ldx #$20
    stx PPU_ADDR        ; set PPU_ADDR hi-byte
    ldx #$00
    stx PPU_ADDR        ; set PPU_ADDR lo-byte

    jsr LoadBackground

EnablePPURendering:
    lda #%10010000      ; enable NMI, set BG 2nd pattern table ($1000)
    sta PPU_CTRL
    lda #%00011110
    sta PPU_MASK        ; set PPU_MASK to show bg


LoopForever:
    jmp LoopForever


NMI:
    rti

IRQ:
    rti


PaletteData:
.byte $0F,$2A,$0C,$3A, $0F,$2A,$0C,$3A, $0F,$2A,$0C,$3A, $0F,$2A,$0C,$3A    ;bg
.byte $0F,$10,$00,$26, $0F,$10,$00,$26, $0F,$10,$00,$26, $0F,$10,$00,$26    ;sprite

;name table
BackgroundData:
.byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$36,$37,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24
.byte $24,$24,$24,$24,$24,$24,$24,$24,$35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$60,$61,$62,$63,$24,$24,$24,$24
.byte $24,$36,$37,$24,$24,$24,$24,$24,$39,$3a,$3b,$3c,$24,$24,$24,$24,$53,$54,$24,$24,$24,$24,$24,$24,$64,$65,$66,$67,$24,$24,$24,$24
.byte $35,$25,$25,$38,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24,$24,$24,$24,$24,$68,$69,$26,$6a,$24,$24,$24,$24
.byte $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45
.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
.byte $47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47,$47
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


.segment "CHARS"
.incbin "mario.chr"

.segment "VECTORS"
.word NMI
.word RESET
.word IRQ