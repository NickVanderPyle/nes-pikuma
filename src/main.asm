.include "consts.inc"
.include "header.inc"
.include "reset.inc"

.segment "CODE"

RESET:
    INIT_NES

Main:
    bit PPU_STATUS      ; reset PPU_ADDR latch
    ldx #$3F
    stx PPU_ADDR        ; set PPU_ADDR hi-byte
    ldx #$00
    stx PPU_ADDR        ; set PPU_ADDR lo-byte

    lda #$2A
    sta PPU_DATA        ; Send 2A to PPU_DATA

    lda #%00011110
    sta PPU_MASK        ; set PPU_MASK to show bg


LoopForever:
    jmp LoopForever


NMI:
    rti

IRQ:
    rti


.segment "VECTORS"
.word NMI
.word RESET
.word IRQ