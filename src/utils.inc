.macro PPU_SETADDR addr

    bit PPU_STATUS          ; read from PPU_STATUS to reset PPU_ADDR latch
    lda #>addr              ; get high byte of addr
    sta PPU_ADDR
    lda #<addr              ; get lo byte of addr
    sta PPU_ADDR

.endmacro

.macro PPU_SETDATA val

    lda val
    sta PPU_DATA

.endmacro