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

RESET:
    INIT_NES

Main:
    bit PPU_STATUS      ; reset PPU_ADDR latch
    ldx #$3F
    stx PPU_ADDR        ; set PPU_ADDR hi-byte
    ldx #$00
    stx PPU_ADDR        ; set PPU_ADDR lo-byte

    jsr LoadPalette

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

.segment "VECTORS"
.word NMI
.word RESET
.word IRQ