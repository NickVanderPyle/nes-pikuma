; constants
PPU_CTRL    = $2000
PPU_MASK    = $2001
PPU_STATUS  = $2002
OAM_ADDR    = $2003
OAM_DATA    = $2004
PPU_SCROLL  = $2005
PPU_ADDR    = $2006
PPU_DATA    = $2007


; iNES Header 16 bytes
.segment "HEADER"
.byte $4E, $45, $53, $1A            ; NES newline
.byte $02                           ; 2x 16Kb (32Kb) PRG-ROM
.byte $01                           ; 1x 8Kb CHR-ROM
.byte %00000000                     ; flags: horiz mirroring, no battery, mirror 0
.byte %00000000                     ; flags: mapper 0, playchoice, nes2.0
.byte $00                           ; No PRG-RAM
.byte %00000000                     ; NTSC=0, PAL=1
.byte $00                           ; No PRG-RAM
.byte $00, $00, $00, $00, $00       ; Padding to fill 16bytes of header.


.segment "CODE"

RESET:
    sei                 ; disable all IRQ
    cld                 ; clear decimal mode (unsupported by NES)
    ldx #$FF            ;
    txs                 ; init stack pointer to end of stack (stack pointer holds low byte of stack pointer $01FF)

    inx                 ; rollover from FF to 00
    stx PPU_CTRL        ; disable NMI
    stx PPU_MASK        ; disable rendering
    stx $4010           ; disable DMC IRQ

    lda #$40
    sta $4017           ; disable APU frame IRQ

Wait1stVBlank:          ; wait for first VBLank
    bit PPU_STATUS
    bpl Wait1stVBlank

    txa                 ; a=0
ClearRAM:
    sta $0000,x         ; clear 0000-00FF
    sta $0100,x         ; clear 0100-01FF
    sta $0200,x         ; clear 0200-02FF
    sta $0300,x         ; clear 0300-03FF
    sta $0400,x         ; clear 0400-04FF
    sta $0500,x         ; clear 0500-05FF
    sta $0600,x         ; clear 0600-06FF
    sta $0700,x         ; clear 0700-07FF
    inx
    bne ClearRAM

Wait2ndVBlank:          ; wait for second VBLank
    bit PPU_STATUS
    bpl Wait2ndVBlank

Main:
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