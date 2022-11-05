.include "consts.inc"
.include "header.inc"
.include "reset.inc"
.include "utils.inc"

.segment "ZEROPAGE"
Buttons:    .res 1
Frame:      .res 1      ; reserve 1 byte to store frame counter
Clock60:    .res 1      ; increment ever second
BgPtr:      .res 2      ; Reserve 2 bytes, lo-byte and hi-byte.

.segment "CODE"

.proc ReadControllers
    lda #1
    sta Buttons         ; 1 will help rotate only 8 times [00000001]
    sta $4016           ; Controller latch=1 begins input collection mode
    lsr                 ; shift-right the 1 off and zero the a-register.
    sta $4016           ; Controller latch=0 begin output mode
LoopButtons:
    lda $4016           ; Read bit from controller into right most bit; $4016 immediately loaded w/ next button.
    lsr                 ; Right shift a-register, button press into Carry Flag.
    rol Buttons         ; Left-shift buttons and load carry into right most bit.
    bcc LoopButtons     ; Will exit when the first "1" loaded into Buttons left-shifts into carry.
    rts
.endproc

.proc LoadPalette
    PPU_SETADDR $3F00
    ldy #0
:   lda PaletteData,y   ; load from PaletteData+y
    sta PPU_DATA        ; set value to PPU_DATA
    iny
    cpy #32
    bne :-

    rts
.endproc

.proc LoadBackground
    lda #<BackgroundData     ; Fetch the lo-byte of BackgroundData address
    sta BgPtr
    lda #>BackgroundData     ; Fetch the hi-byte of BackgroundData address
    sta BgPtr+1

    PPU_SETADDR $2000

    ldx #$00                 ; X = 0 --> x is the outer loop index (hi-byte) from $0 to $4
    ldy #$00                 ; Y = 0 --> y is the inner loop index (lo-byte) from $0 to $FF

OuterLoop:
InnerLoop:
    lda (BgPtr),y            ; Fetch the value *pointed* by BgPtr + Y
    sta PPU_DATA             ; Store in the PPU data
    iny                      ; Y++
    cpy #0                   ; If Y == 0 (wrapped around 256 times)?
    beq IncreaseHiByte       ;   Then: we need to increase the hi-byte
    jmp InnerLoop            ;   Else: Continue with the inner loop
IncreaseHiByte:
    inc BgPtr+1              ; We increment the hi-byte pointer to point to the next background section (next 255-chunk)
    inx                      ; X++
    cpx #4                   ; Compare X with #4
    bne OuterLoop            ;   If X is still not 4, then we keep looping back to the outer loop

    rts                      ; Return from subroutine
.endproc

.proc LoadSprites
    ldx #0
LoopSprites:
    lda SpriteData,x
    sta $0200,x
    inx
    cpx #32
    bne LoopSprites

    rts
.endproc

RESET:
    INIT_NES

    lda #0
    sta Frame
    sta Clock60

Main:
    jsr LoadPalette          ; Call LoadPalette subroutine to load 32 colors into our palette
    jsr LoadBackground       ; Call LoadBackground subroutine to load a full nametable of tiles and attributes
    jsr LoadSprites

EnablePPURendering:
    lda #%10010000      ; enable NMI, set BG 2nd pattern table ($1000)
    sta PPU_CTRL
    lda #0
    sta PPU_SCROLL      ; disable scroll X
    sta PPU_SCROLL      ; and Y
    lda #%00011110
    sta PPU_MASK        ; set PPU_MASK to show bg


LoopForever:
    jmp LoopForever


NMI:
    inc Frame           ; Frames++

    lda #$02            ; copy sprite data from $02**
    sta $4014           ; OAM DMA copy starts when we write to $4014

    jsr ReadControllers

    lda Frame
    cmp #60             ; compare Frames w/ 60
    bne Skip60              ; if != 0 goto :
    inc Clock60
    lda #0
    sta Frame
Skip60:

    rti

IRQ:
    rti


PaletteData:
.byte $22,$29,$1A,$0F, $22,$36,$17,$0F, $22,$30,$21,$0F, $22,$27,$17,$0F ; Background palette
.byte $22,$16,$27,$18, $22,$1A,$30,$27, $22,$16,$30,$27, $22,$0F,$36,$17 ; Sprite palette

;; Background data with tile numbers that must be copied to the nametable
BackgroundData:
.incbin "background.nam"

SpriteData:
; mario
;     y    tile attr       x
.byte $AE, $3A, %00000000, $98      ; x:16, y:16
.byte $AE, $37, %00000000, $A0      ; x:24, y:16
.byte $B6, $4F, %00000000, $98      ; x:16, y:24
.byte $B6, $4F, %01000000, $A0      ; x:24, y:24 horizontal flip

; goomba
;     y    tile attr       x
.byte $93, $70, %00100011, $C7      ; x:16, y:16
.byte $93, $71, %00100011, $CF      ; x:24, y:16
.byte $9B, $72, %00100011, $C7      ; x:16, y:24
.byte $9B, $73, %00100011, $CF      ; x:24, y:24 horizontal flip

.segment "CHARS"
.incbin "mario.chr"

.segment "VECTORS"
.word NMI
.word RESET
.word IRQ