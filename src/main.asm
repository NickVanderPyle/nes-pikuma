.include "consts.inc"
.include "header.inc"
.include "reset.inc"

.segment "CODE"

.proc LoadPalette
    ldy #0
:   lda PaletteData,y   ; load from PaletteData+y
    sta PPU_DATA        ; set value to PPU_DATA
    iny
    cpy #32
    bne :-

    rts
.endproc

.proc LoadBackground
    ldy #0
:   lda BackgroundData,y    ; load from BackgroundData+y
    sta PPU_DATA            ; set value to PPU_DATA
    iny
    cpy #255
    bne :-

    rts
.endproc

.proc LoadAttributes
    ldy #0
:   lda AttributeData,y     ; load from PaletteData+y
    sta PPU_DATA            ; set value to PPU_DATA
    iny
    cpy #16
    bne :-

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

    ;; set ppu addr to $2000 & load tiles of bg
    bit PPU_STATUS      ; reset PPU_ADDR latch
    ldx #$23
    stx PPU_ADDR        ; set PPU_ADDR hi-byte
    ldx #$C0
    stx PPU_ADDR        ; set PPU_ADDR lo-byte
    jsr LoadAttributes

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
.byte $22,$29,$1A,$0F, $22,$36,$17,$0F, $22,$30,$21,$0F, $22,$27,$17,$0F ; Background palette
.byte $22,$16,$27,$18, $22,$1A,$30,$27, $22,$16,$30,$27, $22,$0F,$36,$17 ; Sprite palette

;name table
BackgroundData:
.byte $24,$24,$24,$24, $24,$24,$24,$24, $24,$36,$37,$24, $24,$24,$24,$24, $24,$24,$24,$24, $24,$24,$24,$24, $24,$24,$24,$24, $24,$24,$24,$24
.byte $24,$24,$24,$24, $24,$24,$24,$24, $35,$25,$25,$38, $24,$24,$24,$24, $24,$24,$24,$24, $24,$24,$24,$24, $60,$61,$62,$63, $24,$24,$24,$24
.byte $24,$36,$37,$24, $24,$24,$24,$24, $39,$3a,$3b,$3c, $24,$24,$24,$24, $53,$54,$24,$24, $24,$24,$24,$24, $64,$65,$66,$67, $24,$24,$24,$24
.byte $35,$25,$25,$38, $24,$24,$24,$24, $24,$24,$24,$24, $24,$24,$24,$24, $55,$56,$24,$24, $24,$24,$24,$24, $68,$69,$26,$6a, $24,$24,$24,$24

.byte $45,$45,$45,$45, $45,$45,$45,$45, $45,$45,$45,$45, $45,$45,$45,$45, $45,$45,$45,$45, $45,$45,$45,$45, $45,$45,$45,$45, $45,$45,$45,$45
.byte $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47
.byte $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47, $47,$47,$47,$47
.byte $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00

AttributeData:
.byte %00000000, %00000000, %10101010, %00000000, %11110000, %00000000, %00000000, %00000000
.byte %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111


.segment "CHARS"
.incbin "mario.chr"

.segment "VECTORS"
.word NMI
.word RESET
.word IRQ