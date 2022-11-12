.include "consts.inc"
.include "header.inc"
.include "reset.inc"
.include "utils.inc"

.segment "ZEROPAGE"
Buttons:    .res 1

XPos:       .res 2      ; player x  (8.8, fixed point), hi-byte display portion, lo-byte sub-pixel fractional
YPos:       .res 2      ; player y

XVel:       .res 1      ; Player velocity pixel per 256 frames.
YVel:       .res 1      ;

Frame:      .res 1      ; reserve 1 byte to store frame counter
Clock60:    .res 1      ; increment ever second
BgPtr:      .res 2      ; Reserve 2 bytes, lo-byte and hi-byte.

MAXSPEED    = 120       ; max speed limit in 1/256 pixels per frame
ACCEL       = 2         ; movement accel in 1/256 px/frame^2
BRAKE       = 2         ; stopping accel in 1/256 px/frame^2

.segment "CODE"

.proc ReadControllers
    lda #1
    sta Buttons         ; 1 will help rotate only 8 times [00000001]
    sta JOYPAD1         ; Controller latch=1 begins input collection mode
    lsr                 ; shift-right the 1 off and zero the a-register.
    sta JOYPAD1         ; Controller latch=0 begin output mode
LoopButtons:
    lda JOYPAD1         ; Read bit from controller into right most bit; $4016 immediately loaded w/ next button.
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

InitVariables:
    lda #0
    sta Frame
    sta Clock60

    lda #20
    sta XVel
    sta YVel
    
    ldx #0
    lda SpriteData,x
    sta YPos+1          ; set y hi-byte
    ldx #3
    lda SpriteData,x
    sta XPos+1          ; set x lo-byte
    

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

OAMStartDMACopy:
    lda #$02            ; copy sprite data from $0200
    sta PPU_OAM_DMA    ; OAM DMA copy starts when we write to $4014

ControllerInput:
    jsr ReadControllers

; button bit flags: A, B, Select, Start, Up, Down, Left, Right
CheckRightButton:
    ; todo
CheckLeftButton:
    ; todo
CheckDownButton:
    ; todo
CheckUpButton:
    ; todo
EndInputCheck:

UpdateSpritePosition:
    lda XVel
    clc
    adc XPos            ; when overflows, sets carry, carry will add to XPos hi-byte
    sta XPos
    lda #0
    adc XPos+1          ; if there was a carry, then this will add +1.
    sta XPos+1

DrawSpritePosition:
    lda XPos+1
    sta $0203
    sta $020B
    clc
    adc #8
    sta $0207
    sta $020F

    lda YPos+1
    sta $0200
    sta $0204
    clc
    adc #8
    sta $0208
    sta $020C

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
.byte $1D,$10,$20,$2D, $1D,$1D,$2D,$10, $1D,$0C,$19,$1D, $1D,$06,$17,$07 ; Background palette
.byte $0F,$1D,$19,$29, $0F,$08,$18,$38, $0F,$0C,$1C,$3C, $0F,$2D,$10,$30 ; Sprite palette

;; Background data with tile numbers that must be copied to the nametable
BackgroundData:
.incbin "background.nam"

SpriteData:
;     y    tile attr       x
.byte $80, $18, %00000000, $10      ; x:16, y:16
.byte $80, $1A, %00000000, $18      ; x:24, y:16
.byte $88, $19, %00000000, $10      ; x:16, y:24
.byte $88, $1B, %00000000, $18      ; x:24, y:24 horizontal flip

.segment "CHARS"
.incbin "battle.chr"

.segment "VECTORS"
.word NMI
.word RESET
.word IRQ